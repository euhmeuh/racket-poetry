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

(require
  racket/path
  racket/sandbox
  racket/string
  web-server/http
  web-galaxy/response
  web-galaxy/serve
  racket-poetry/private/assembler)

(define static-path (path->string (build-path (current-server-root-path) "static")))

(define-response (poem)
  (define raw (request-post-data/raw req))
  (define text (bytes->string/utf-8 raw))
  (define evaluator (make-module-evaluator (string-append "#lang racket-poetry\n" text "\n")))
  (evaluator '(require 'poem-file))
  (define result (evaluator 'poem))
  (response/json
    (hasheq
      'binary (assemble result)
      'lines result
      'errors (list))))

(parameterize ([current-server-static-paths (list static-path)])
  (serve/all
    [POST ("") response-poem]))
