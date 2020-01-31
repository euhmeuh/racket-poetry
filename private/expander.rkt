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
  racket/list
  racket/match
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
    (word #rx"empt(y|iness)"                  0)
    (word #rx"nothing(ness)?"                 0)
    (word #rx"still(ness)?"                   0)
    (word #rx"snow(s|ed|ing|y)?"              0)
    (word #rx"nowhere|false"                  0)
    (word #rx"dark(ness)?"                    0)
    (word #rx"black"                          0)
    (word #rx"(water|tear|sea)s?"             1)
    (word #rx"yes|true|truth"                 1)
    (word #rx"everywhere"                     1)
    (word #rx"(ones?|once|first)"             1)
    (word #rx"blue"                           1)
    (word #rx"(fire(s)?|firing)"              2)
    (word #rx"blaz(e|es|ing)"                 2)
    (word #rx"burn(ed|ing|s)?"                2)
    (word #rx"(two|twice|second(ary)?)"       2)
    (word #rx"red"                            2)
    (word #rx"(vapor|steam|fog)s?"            3)
    (word #rx"(three|third)"                  3)
    (word #rx"purple"                         3)
    (word #rx"(earth|soil|ground|rock)s?"     4)
    (word #rx"four(th)?"                      4)
    (word #rx"yellow"                         4)
    (word #rx"mud(s|dy)?"                     5)
    (word #rx"oil(s|y)?"                      5)
    (word #rx"glue(s)?|stick(s|y)?"           5)
    (word #rx"tree(s)?"                       5)
    (word #rx"lea(f|ves)"                     5)
    (word #rx"(five|fifth)"                   5)
    (word #rx"green"                          5)
    (word #rx"(lava|volcano)s?"               6)
    (word #rx"six(th)?"                       6)
    (word #rx"orange"                         6)
    (word #rx"(ceramic|bowl)s?"               7)
    (word #rx"seven(th)?"                     7)
    (word #rx"grey|gray"                      7)
    (word #rx"(wind|blow)s?"                  8)
    (word #rx"eight(h)?"                      8)
    (word #rx"cyan"                           8)
    (word #rx"rain(s|y)?"                     9)
    (word #rx"drop(s)?"                       9)
    (word #rx"nine|ninth"                     9)
    (word #rx"marine"                         9)
    (word #rx"(thunder|bolt|spark)s?"        10)
    (word #rx"ten|tenth"                     10)
    (word #rx"violet"                        10)
    (word #rx"(cloud|sky)s?"                 11)
    (word #rx"eleven(th)?"                   11)
    (word #rx"pink"                          11)
    (word #rx"(sand|desert|snake)s?"         12)
    (word #rx"twelve|twelfth"                12)
    (word #rx"rose"                          12)
    (word #rx"(river|net)s?"                 13)
    (word #rx"fish(es)?"                     13)
    (word #rx"thirteen(th)?"                 13)
    (word #rx"azure|azurean"                 13)
    (word #rx"(window|transparent)s?"        14)
    (word #rx"glass(es)?"                    14)
    (word #rx"fourteen(th)?"                 14)
    (word #rx"complete(s|d)?"                15)
    (word #rx"full(y)?"                      15)
    (word #rx"life|liv(es|ing|ed)"           15)
    (word #rx"(sun|light|planet)s?"          15)
    (word #rx"fifteen(th)?"                  15)
    (word #rx"white"                         15)

    ; Modifiers for meta verbs
    (word #rx"like(ly)?|similar|identical" '(mode eq))
    (word #rx"equal(s|ity)?"               '(mode eq))
    (word #rx"sometimes"                   '(mode eq))
    (word #rx"unlike(ly)?|different|apart" '(mode ne))
    (word #rx"unequal|inequality"          '(mode ne))
    (word #rx"always"                      '(mode ne))

    ; Verbs
    (word #rx"quit(ted|s|ting)?"       'ext)
    (word #rx"clear(ed|s|ing)?"        'cls)
    (word #rx"return(ed|s|ing)?"       'ret)
    (word #rx"leav(e|es|ing)|left"     'ret)
    (word #rx"(went|go(ne|ing|es)?)"   'jmp)
    (word #rx"call(ed|s|ing)?"         'cal)
    (word #rx"hail(ed|s|ing)?"         'cal)
    (word #rx"skip(ped|s|ping)?"       '(meta [eq . sei] [ne . sni]))
    (word #rx"evad(e|es|ed|ing)"       '(meta [eq . sei] [ne . sni]))
    (word #rx"jump(ped|s|ping)?"       '(meta [eq . sev] [ne . snv]))
    (word #rx"put(s|ting)?"            'ldi)
    (word #rx"tak(e|es|ing)|took"      'ldi)
    (word #rx"embrac(e|ed|ing)"        'ldi)
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
    (word #rx"draw(s|ing|n)?|drew"     'drw)
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
  (cons
    (car sentence)
    (map (lambda (word) (or (find-in-dict dictionary word) word))
         (cdr sentence))))

(define (find-mode verb sentence)
  (define mode (findf symbol?
                      (filter-map
                        (lambda (word)
                          (and ((starts-with? 'mode) word)
                               (cadr word)))
                        sentence)))
  (define found (and mode
                    (assq mode (cdr verb))))
  (and found
       (cdr found)))

(define (find-verb sentence)
  (findf symbol?
    (filter-map
      (lambda (word)
        (cond
          [(symbol? word) word]
          [((starts-with? 'meta) word) (find-mode word sentence)]))
      sentence)))

(define (find-index sentence indexes)
  (define words
    (filter-map
      (lambda (word)
        (and (string? word)
             (normalize word)))
      sentence))
  (define matches
    (filter-map
      (lambda (pair)
        (match-define (list word index) pair)
        (and (string-contains? index word)
             (cons (string-length word) index)))
      (cartesian-product words indexes)))
  (if (pair? matches)
      (cdr (argmax car matches))
      (raise-arguments-error 'poem-index
                             "no index found for jump"
                             "words" words
                             "indexes" indexes)))

(define (take-numbers sentence [size 0] [skip 0])
  (define filtered (filter number? sentence))
  (define numbers (or (and (pair? filtered) (drop filtered skip))
                      '()))
  (define len (length numbers))
  (cond
    [(= size 0) numbers]
    [(< len size) (append (build-list (- size len) (lambda (x) 0))
                          numbers)]
    [else (take numbers size)]))

(define (interpret indexes line)
  (define content (cdr line))
  (define verb (and ((starts-with? 'sentence) line)
                    (find-verb content)))
  (cond
    [((starts-with? 'title) line) (list 'label (normalize-title line))]
    [(memq verb indexed)          (list verb (find-index content indexes))]
    [(memq verb optional-b)       (cons verb (append (take-numbers content 1)
                                                     (take-numbers content 2 1)))]
    [(eq? verb #f)                (cons 'data (take-numbers content 4))]
    [else                         (cons verb (take-numbers content))]))

(define (normalize str)
  (string-downcase str))

(define (normalize-title title)
  (string-join (map normalize (cdr title)) " "))

(define (read-program prog)
  (define indexes
    (map normalize-title
         (filter (starts-with? 'title) (cdr prog))))
  (map (compose (curry interpret indexes) find-meaning)
       (cdr prog)))

(define-syntax-rule (module-begin expr)
  (#%module-begin
    (provide poem)
    (define poem (read-program 'expr))
    poem))
