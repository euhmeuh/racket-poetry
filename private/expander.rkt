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
  #%app #%top #%top-interaction require quote
  (rename-out [module-begin #%module-begin]))

(require
  racket/function
  racket/string
  (for-syntax
    racket/base
    syntax/stx
    syntax/parse))

(define ((word rx val) test-word)
  (define w (string-downcase test-word))
  (and (regexp-match-exact? rx w)
       val))

(define dictionary
  (list

    ; Numbers
    (word #rx"(void|death|night|blackhole)s?" 0)
    (word #rx"zero(es|s)?|none"               0)
    (word #rx"(water|tear|sea)s?"             1)
    (word #rx"(ones?|once|first)"             1)
    (word #rx"(fire(s)?|firing)"              2)
    (word #rx"blaz(e|es|ing)"                 2)
    (word #rx"burn(ed|ing)?"                  2)
    (word #rx"(two|twice|second(ary)?)"       2)
    (word #rx"(vapor|steam|fog)s?"            3)
    (word #rx"(three|third)"                  3)
    (word #rx"(earth|soil|ground|rock)s?"     4)
    (word #rx"four(th)?"                      4)
    (word #rx"(mud|oil|glue|stick)s?"         5)
    (word #rx"(five|fifth)"                   5)
    (word #rx"(lava|volcano)s?"               6)
    (word #rx"six(th)?"                       6)
    (word #rx"(ceramic|bowl)s?"               7)
    (word #rx"seven(th)?"                     7)
    (word #rx"(wind|blow)s?"                  8)
    (word #rx"eight(h)?"                      8)
    (word #rx"(rain)s?"                       9)
    (word #rx"nine|ninth"                     9)
    (word #rx"(thunder|bolt|spark)s?"        10)
    (word #rx"ten|tenth"                     10)
    (word #rx"(cloud|sky)s?"                 11)
    (word #rx"eleven(th)?"                   11)
    (word #rx"(sand|desert|snake)s?"         12)
    (word #rx"twelve|twelfth"                12)
    (word #rx"(river|net)s?"                 13)
    (word #rx"fish(es)?"                     13)
    (word #rx"thirteen(th)?"                 13)
    (word #rx"(window|transparent)s?"        14)
    (word #rx"glass(es)?"                    14)
    (word #rx"fourteen(th)?"                 14)
    (word #rx"complete(s|d)?"                15)
    (word #rx"full(y)?"                      15)
    (word #rx"life|liv(es|ing|ed)"           15)
    (word #rx"(sun|light|planet)s?"          15)
    (word #rx"fifteen(th)?"                  15)

    ; Modifiers for meta verbs
    (word #rx"like|similar|identical" '(mode eq))
    (word #rx"unlike|different|apart" '(mode ne))

    ; Verbs
    (word #rx"quit(ted|s|ting)?"       'ext)
    (word #rx"clear(ed|s|ing)?"        'cls)
    (word #rx"return(ed|s|ing)?"       'ret)
    (word #rx"leav(e|es|ing)|left"     'ret)
    (word #rx"(went|go(ne|ing|es)?)"   'jmp)
    (word #rx"call(ed|s|ing)?"         'cal)
    (word #rx"hail(ed|s|ing)?"         'cal)
    (word #rx"skip(ped|s|ping)?"       '(meta [eq . sei] [ne . sni]))
    (word #rx"jump(ped|s|ping)?"       '(meta [eq . sev] [ne . snv]))
    (word #rx"put(s|ting)?"            'ldi)
    (word #rx"add(ed|s|ing)?"          'adi)
    (word #rx"load(ed|s|ing)?"         'ldv)
    (word #rx"merg(e|ed|es|ing)"       'ior)
    (word #rx"ponder(s|ed|ing)?"       'and)
    (word #rx"cross(ed|es|ing)?"       'xor)
    (word #rx"stack(s|ed|ing)?"        'add)
    (word #rx"remov(e|es|ed|ing)"      'sub)
    (word #rx"turn(s|ed|ing)?"         'shr)
    (word #rx"compar(e|es|ed|ing)"     'dif)
    (word #rx"rotat(e|es|ed|ing)"      'shl)
    (word #rx"remember(ed|s)?"         'mem)
    (word #rx"travel(led|s|ling)?"     'jma)
    (word #rx"confus(e|es|ed|ing)"     'rnd)
    (word #rx"paint(s|ed|ing)?"        'drw)
    (word #rx"listen(ed|s|ing)?"       'skp)
    (word #rx"ear(s|ed|ing)?"          'skn)
    (word #rx"tick(s|ed|ing)?"         'ldt)
    (word #rx"wait(s|ed|ing)?"         'ldk)
    (word #rx"rest(s|ed|ing)?"         'std)
    (word #rx"sing(s|eg|ing)?"         'sts)
    (word #rx"remind(s|ed|ing)?"       'mea)
    (word #rx"(writ(es|en|ing)|wrote)" 'fnt)
    (word #rx"represent(s|ed|ing)?"    'bcd)
    (word #rx"sav(e|es|ed|ing)"        'dmp)
    (word #rx"restor(e|es|ed|ing)"     'rst)
    ))

(define ((starts-with? sym) l)
  (and (pair? l)
       (eq? (car l) sym)))

(define indexed '(jmp cal mem jma))
(define optional-b '(sei sni ldi adi rnd))

(define (find-in-dict dict word)
  (for/or ([entry dict]) (entry word)))

(define (find-meaning sentence)
  (map (lambda (word) (find-in-dict dictionary word))
       (cdr sentence)))

(define (find-verb sentence)
  (findf (lambda (word)
           (or (symbol? word)
               ((starts-with? 'meta) word)))
         sentence))

(define (find-index sentence indexes)
  "todo")

(define (pop-args! sentence [size 0])
  '(0 0))

(define (interpret indexes sentence)
  (define verb (find-verb sentence))
  (cond
    [(memq verb indexed)    (list verb (find-index sentence indexes))]
    [(memq verb optional-b) (cons verb (append (pop-args! sentence 1)
                                               (pop-args! sentence 2)))]
    [(eq? verb #f)          (cons 'data (pop-args! sentence))]
    [else                   (cons verb (pop-args! sentence))]))

(define (normalize title)
  (string-join (map string-downcase (cdr title)) ""))

(define (read-program prog)
  (define indexes
    (map normalize
         (filter (starts-with? 'title) (cdr prog))))
  (displayln indexes)
  (map (compose (curry interpret indexes) find-meaning)
       (filter (starts-with? 'sentence) (cdr prog))))

(define-syntax-rule (module-begin expr)
  (#%module-begin
    (provide poem)
    (define poem (read-program 'expr))
    poem))


#;(list
  (label "reset")
  (mem "pattern")
  (ldi 0 0)
  (ldi 1 0)
  (ldi 2 0)
  (ldi 10 1)
  (label "pixel")
  (cal "renderer")
  (drw 0 1 1)
  (xor 3 15)
  (xor 3 10)
  (sni 3 1)
  (drw 0 1 1)
  (adi 0 1)
  (sei 0 4 0)
  (jmp "over")
  (adi 1 1)
  (ldi 0 0)
  (label "over")
  (sni 1 2 0)
  (ldi 1 0)
  (adi 2 1)
  (jmp "pixel")
  (label "renderer")
  (rnd 3 1)
  (ret)
  (label "pattern")
  (data 8 0 0 0)
  )