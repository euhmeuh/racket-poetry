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

(provide
  (rename-out
    [poem-read read]
    [poem-read-syntax read-syntax]))

(require
  racket/port
  syntax/strip-context
  brag/support
  "parser.rkt")

(define (poem-read in)
  (syntax->datum
    (poem-read-syntax #f in)))

(define (poem-read-syntax src in)
  (with-syntax ([parse-tree (parse src (make-tokenizer in src))])
    (strip-context
      #'(module poem-file racket-poetry/private/expander
          parse-tree))))

(define (make-tokenizer port [path #f])
  (port-count-lines! port)
  (lexer-file-path path)
  (define (next-token)
    (define poem-lexer
      (lexer-srcloc
        [(eof) (return-without-srcloc eof)]
        ["\n" (token 'EOL)]
        [(:+ (:& (:~ "\n") whitespace)) (token 'SP)]
        [(:+ "-" "=" "_") (token 'MARKER lexeme)]
        [(:+ "." "," ";" ":") (token 'PUNCT lexeme)]
        [(:>= 1 alphabetic) (token 'STRING lexeme)]
        [any-char (next-token)]))
    (poem-lexer port))
  next-token)
