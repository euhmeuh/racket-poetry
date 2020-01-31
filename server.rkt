#lang racket/base

;===============================================================================
;
;  Copyright (c) 2020 Jérôme Martin <rilouw.eu>
;  The code for this project is released under the terms of the GNU AGPLv3.
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU Affero General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU Affero General Public License for more details.
;
;  You should have received a copy of the GNU Affero General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>.
;
;===============================================================================

(provide response-poem)

(require
  racket/path
  racket/sandbox
  racket/string
  web-server/http
  web-galaxy/response
  racket-poetry/private/assembler)

(define (format-assembly ast)
  (map
    (lambda (line)
      (map (lambda (word)
             (if (symbol? word) (symbol->string word) word))
           line))
    ast))

(define ((error-handler message) e)
  (hasheq 'error (string-append message ": " (exn-message e))))

(define (sandbox-eval text)
  (with-handlers ([exn:fail:contract:arity? (error-handler "Incorrect number of arguments")]
                  [exn? (error-handler "An unknown exception occured")])
    (define evaluator (make-module-evaluator (string-append "#lang racket-poetry\n" text "\n")))
    (evaluator '(require 'poem-file))
    (define ast (evaluator 'poem))
    (hasheq
      'binary (assemble ast)
      'assembly (format-assembly ast))))

(define-response (poem)
  (define raw (request-post-data/raw req))
  (define text (bytes->string/utf-8 raw))
  (define result (sandbox-eval text))
  (response/json result))

(module+ main
  (require web-galaxy/serve)
  (define static-path (path->string (build-path (current-server-root-path) "static")))
  (parameterize ([current-server-static-paths (list static-path)])
    (serve/all
      [POST ("") response-poem])))
