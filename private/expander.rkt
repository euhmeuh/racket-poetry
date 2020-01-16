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
  (rename-out [module-begin #%module-begin]))

(require
  racket/string
  (for-syntax
    racket/base
    syntax/stx
    syntax/parse))

(define ((word rx val) test-word)
  (define w (string-downcase test-word))
  (displayln (format "Does ~a matches ~a -> ~a" w rx (regexp-match-exact? rx w)))
  (and (regexp-match-exact? rx w)
       val))

(define dictionary
  (list
    (word #rx"fire(s)?"        4)

    (word #rx"like|similar|identical" 'eq)
    (word #rx"unlike|different|apart" 'ne)

    (word #rx"quit(ted|s|ting)?"     '(ext))
    (word #rx"clear(ed|s|ing)?"      '(cls))
    (word #rx"return(ed|s|ing)?"     '(rst))
    (word #rx"(went|go(ne|ing|es)?)" '(jma))
    (word #rx"travel(led|s|ling)?"   '(jsr))
    (word #rx"skip(ped|s|ping)?"     (lambda (mode) (if mode '(sei) '(sni))))
    (word #rx"remember(ed|s)?"       '(mem))
    ))

(define (find-in-dict dict word)
  (for/or ([entry dict]) (entry word)))

(define (find-meaning sentence)
  (map
    (lambda (word)
      (find-in-dict dictionary word))
    (cdr sentence)))

(define-syntax-rule (module-begin expr)
  (#%module-begin
    (map (lambda (line)
           (if (eq? (car line) 'sentence)
               (find-meaning line)
               line))
         (cdr 'expr))))
