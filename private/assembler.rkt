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

(provide assemble)

(require
  racket/string
  net/base64)

(define (op a b c d)
  (list
    (+ (* a 16) b)
    (+ (* c 16) d)))

(define (index-labels program)
  (for/fold ([indexes (hash)]
             [instructions (list)]
             [pc #x200])
            ([line program])
    (define label (and (eq? (car line) 'label)
                       (cadr line)))
    (if label
      (values (hash-set indexes label pc)
              instructions
              pc)
      (values indexes
              (append instructions (list line))
              (+ pc 2)))))

(define optable
  (hasheq
    'ext (lambda (a)     (op  0  0  1  a)) ; Exit with code A
    'cls (lambda ()      (op  0  0 14  0)) ; Clear screen
    'ret (lambda ()      (op  0  0 14 14)) ; Return from subroutine
    'jmp (lambda (a b c) (op  1  a  b  c)) ; Jump to address ABC
    'cal (lambda (a b c) (op  2  a  b  c)) ; Jump to subroutine ABC
    'sei (lambda (x a b) (op  3  x  a  b)) ; Skip next if VX equals AB
    'sni (lambda (x a b) (op  4  x  a  b)) ; Skip next if VX does not equal AB
    'sev (lambda (x y)   (op  5  x  y  0)) ; Skip next if VX equals VY
    'ldi (lambda (x a b) (op  6  x  a  b)) ; Set VX to AB
    'adi (lambda (x a b) (op  7  x  a  b)) ; Add AB to VX
    'ldv (lambda (x y)   (op  8  x  y  0)) ; Set VX to VY
    'ior (lambda (x y)   (op  8  x  y  1)) ; Set VX to VX OR VY
    'and (lambda (x y)   (op  8  x  y  2)) ; Set VX to VX AND VY
    'xor (lambda (x y)   (op  8  x  y  3)) ; Set VX to VX XOR VY
    'add (lambda (x y)   (op  8  x  y  4)) ; Add VY to VX and set carry in VF
    'sub (lambda (x y)   (op  8  x  y  5)) ; Substract VY from VX and set borrow in VF
    'shr (lambda (x)     (op  8  x  0  6)) ; Rotate VX right through VF
    'dif (lambda (x y)   (op  8  x  y  7)) ; Set VX to VY - VX and set borrow in VF
    'shl (lambda (x)     (op  8  x  0 14)) ; Rotate VX left through VF
    'snv (lambda (x y)   (op  9  x  y  0)) ; Skip next if VX does not equal VY
    'mem (lambda (a b c) (op 10  a  b  c)) ; Set I to ABC
    'jma (lambda (a b c) (op 11  a  b  c)) ; Jump to ABC + V0
    'rnd (lambda (x a b) (op 12  x  a  b)) ; Set VX to a random number masked by AB
    'drw (lambda (x y a) (op 13  x  y  a)) ; Draw a sprite at VX,VY with height A and set VF on collision
    'skp (lambda (x)     (op 14  x  9 14)) ; Skip next if key in VX is pressed
    'skn (lambda (x)     (op 14  x 10  1)) ; Skip next if key in VX is not pressed
    'ldt (lambda (x)     (op 15  x  0  7)) ; Set VX to the delay timer
    'ldk (lambda (x)     (op 15  x  0 10)) ; Wait for key and put in VX
    'std (lambda (x)     (op 15  x  1  5)) ; Set timer to VX
    'sts (lambda (x)     (op 15  x  1  8)) ; Set sound timer to VX
    'mea (lambda (x)     (op 15  x  1 14)) ; Add VX to I and set VF if overflow
    'fnt (lambda (x)     (op 15  x  2  9)) ; Set I to the font character representing VX
    'bcd (lambda (x)     (op 15  x  3  3)) ; Convert VX to BCD and save it to I+0, I+1 and I+2
    'dmp (lambda (x)     (op 15  x  5  5)) ; Dump V0-VX at I
    'rst (lambda (x)     (op 15  x  6  5)) ; Restore V0-VX from I

    'data (lambda (a b c d) (op a b c d))
    ))

(define indexed '(jmp cal mem jma))

(define (get-index indexes ref)
  (define result (hash-ref indexes ref))
  (list
    (arithmetic-shift (bitwise-and result #xF00) -8)
    (arithmetic-shift (bitwise-and result #x0F0) -4)
    (bitwise-and result #x00F)))

(define (assemble program)
  (define-values
    (indexes instructions pc)
    (index-labels program))
  (bytes->string/utf-8
    (base64-encode
      (list->bytes
        (apply append
          (map
            (lambda (instr)
              (define func (hash-ref optable (car instr)))
              (if (memq (car instr) indexed)
                  (apply func (get-index indexes (cadr instr)))
                  (apply func (cdr instr))))
            instructions)))
      #"")))
