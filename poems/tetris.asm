Registers
V0 -> Position X
V1 -> Position Y
V4 -> Tetromino
V3 -> Rotation
V6 -> Temp var
V5 -> Speed (from 16 to 4, -2 every 4 lines)
V2 -> Button speed
V7 -> Button left
V8 -> Button right
V9 -> Button rotate
VA -> Score
VB


Addr   Opcode  ASM

200    a2b4    mem 2B4       ; I = pixel-pattern
202    23e6    cal 3E6       ; call init0
204    22b6    cal 2B6       ; call init1

draw-base:
206    7001    adi V0,1      ; V0 += 1
208    d011    drw V0,V1,1   ; draw 1 col
20A    3025    sei V0,25     ; until V0 = 37
20C    1206    jmp 206       ; loop draw-base

draw-walls:
20E    71ff    adi V1,FF     ; V1 -= 1
210    d011    drw V0,V1,1   ; draw 1 col
212    601a    ldi V0,1A     ; V0 = 26
214    d011    drw V0,V1,1   ; draw 1 col
216    6025    ldi V0,25     ; V0 = 37
218    3100    sei V1,0      ; until V1 = 0
21A    120e    jmp 20E       ; loop draw-walls

new-piece:
21C    c470    rnd V4,70     ; V4 = rand [0,112] step 16
21E    4470    sni V4,70     ; while V4 = 112
220    121c    jmp 21C       ; loop new-piece
222    c303    rnd V3,3      ; V3 = rand [0,3]
224    601e    ldi V0,1E     ; V0 = 30
226    6103    ldi V1,3      ; V1 = 3
228    225c    cal 25C       ; call find-piece
step-down:
22A    f515    std V5        ; delay = V5
22C    d014    drw V0,V1,4   ; draw 4 cols
22E    3f01    sei VF,1      ; unless VF = 1
230    123c    jmp 23C       ; go handle-keys
232    d014    drw V0,V1,4   ; draw 4 cols
234    71ff    adi V1,FF     ; V1 -= 1
236    d014    drw V0,V1,4   ; draw 4 cols
238    2340    cal 340       ; call check-line
23A    121c    jmp 21C       ; go new-piece

handle-keys:
23C    e7a1    skn V7        ; if key V7
23E    2272    cal 272       ; call move-left
240    e8a1    skn V8        ; if key V8
242    2284    cal 284       ; call move-right
244    e9a1    skn V9        ; if key V9
246    2296    cal 296       ; call rotate
248    e29e    skp V2        ; unless key V2
24A    1250    jmp 250       ; go @
24C    6600    ldi V6,0      ; V6 = 0
24E    f615    std V6        ; delay = V6
@:
250    f607    ldt V6        ; V6 = delay
252    3600    sei V6,0      ; until V6 = 0
254    123c    jmp 23C       ; loop handle-keys
256    d014    drw V0,V1,4   ; draw 4 cols
258    7101    adi V1,1      ; V1 += 1
25A    122a    jmp 22A       ; go step-down

find-piece:
25C    a2c4    mem 2C4       ; I = tetrominos
25E    f41e    mea V4        ; I += V4
260    6600    ldi V6,0      ; V6 = 0
262    4301    sni V3,1      ; if V3 = 1
264    6604    ldi V6,4      ; V6 = 4
266    4302    sni V3,2      ; if V3 = 2
268    6608    ldi V6,8      ; V6 = 8
26A    4303    sni V3,3      ; if V3 = 3
26C    660c    ldi V6,C      ; V6 = 12
26E    f61e    mea V6        ; I += V6
270    00ee    ret

move-left:
272    d014    drw V0,V1,4   ; draw 4 cols
274    70ff    adi V0,FF     ; V0 -= 1
276    2334    cal 334       ; call draw-piece
278    3f01    sei VF,1      ; unless VF = 1
27A    00ee    ret           : return
27C    d014    drw V0,V1,4   ; draw 4 cols
27E    7001    adi V0,1      ; V0 += 1
280    2334    cal 334       ; call draw-piece
282    00ee    ret

move-right:
284    d014    drw V0,V1,4   ; draw 4 cols
286    7001    adi V0,1      ; V0 += 1
288    2334    cal 334       ; call draw-piece
28A    3f01    sei VF,1      ; unless VF = 1
28C    00ee    ret           ; return
28E    d014    drw V0,V1,4   ; draw 4 cols
290    70ff    adi V0,FF     ; V0 -= 1
292    2334    cal 334       ; call draw-piece
294    00ee    ret

rotate:
296    d014    drw V0,V1,4   ; draw 4 cols
298    7301    adi V3,1      ; V3 += 1
29A    4304    sni V3,4      ; if V3 = 4
29C    6300    ldi V3,0      ; V3 = 0
29E    225c    cal 25C       ; call find-piece
2A0    2334    cal 334       ; call draw-piece
2A2    3f01    sei VF,1      ; unless VF = 1
2A4    00ee    ret           ; return
2A6    d014    drw V0,V1,4   ; draw 4 cols
2A8    73ff    adi V3,FF     ; V3 -= 1
2AA    43ff    sni V3,FF     ; if V3 = -1
2AC    6303    ldi V3,3      ; V3 = 3
2AE    225c    cal 25C       ; call find-piece
2B0    2334    cal 334       ; call draw-piece
2B2    00ee    ret

pixel-pattern:
2B4    8000

init1:
2B6    6705    ldi V7,5    ; V7 = 5
2B8    6806    ldi V8,6    ; V8 = 6
2BA    6904    ldi V9,4    ; V9 = 4
2BC    611f    ldi V1,1F   ; V1 = 31
2BE    6510    ldi V5,10   ; V5 = 16
2C0    6207    ldi V2,7    ; V2 = 7
2C2    00ee    ret

tetrominos:
2C4    40e0
2C6    0000
2C8    40c0
2CA    4000
2CC    00e0
2CE    4000
2D0    4060
2D2    4000
2D4    4040
2D6    6000
2D8    20e0
2DA    0000
2DC    c040
2DE    4000
2E0    00e0
2E2    8000
2E4    4040
2E6    c000
2E8    00e0
2EA    2000
2EC    6040
2EE    4000
2F0    80e0
2F2    0000
2F4    40c0
2F6    8000
2F8    c060
2FA    0000
2FC    40c0
2FE    8000
300    c060
302    0000
304    80c0
306    4000
308    0060
30A    c000
30C    80c0
30E    4000
310    0060
312    c000
314    c0c0
316    0000
318    c0c0
31A    0000
31C    c0c0
31E    0000
320    c0c0
322    0000
324    4040
326    4040
328    00f0
32A    0000
32C    4040
32E    4040
330    00f0
332    0000

draw-piece:
334    d014    drw V0,V1,4    ; draw 4 cols
336    6635    ldi V6,35      ; V6 = 53
wait:
338    76ff    adi V6,FF      ; V6 -= 1
33A    3600    sei V6,0       ; until V6 = 0
33C    1338    jmp 338        ; loop wait
33E    00ee    ret

check-line:
340    a2b4    mem 2B4        ; I = pixel-pattern
342    8c10    ldv VC,V1      ; VC = V1
344    3c1e    sei VC,1E      ; unless VC = 30
346    7c01    adi VC,1       ; VC += 1
348    3c1e    sei VC,1E      ; unless VC = 30
34A    7c01    adi VC,1       ; VC += 1
34C    3c1e    sei VC,1E      ; unless VC = 30
34E    7c01    adi VC,1       ; VC += 1
@:
350    235e    cal 35E        ; call count-blocks
352    4b0a    sni VB,A       ; if VB = 10
354    2372    cal 372        ; call delete-line
356    91c0    snv V1,VC      ; if V1 = VC
358    00ee    ret            ; return
35A    7101    adi V1,1       ; V1 += 1
35C    1350    jmp 350        ; loop @

count-blocks:
35E    601b    ldi 0,1B       ; V0 = 27
360    6b00    ldi VB,0       ; VB = 0
@:
362    d011    drw V0,V1,1    ; draw 1 col
364    3f00    sei VF,0       ; unless VF = 0
366    7b01    adi VB,1       ; VB += 1
368    d011    drw V0,V1,1    ; draw 1 col
36A    7001    adi V0,1       ; V0 += 1
36C    3025    sei V0,25      ; unless V0 = 37
36E    1362    jmp 362        ; loop @
370    00ee    ret

delete-line:
372    601b    ldi V0,1B      ; V0 = 27
@:
374    d011    drw V0,V1,1    ; draw 1 col
376    7001    adi V0,1       ; V0 += 1
378    3025    sei V0,25      ; unless V0 = 37
37A    1374    jmp 374        ; loop @
37C    8e10    ldv VE,V1      ; VE = V1
37E    8de0    ldv VD,VE      ; VD = VE
380    7eff    adi VE,FF      ; VE -= 1
@2:
382    601b    ldi V0,1B      ; V0 = 27
384    6b00    ldi VB,0       ; VB = 0
@3:
386    d0e1    drw V0,VE,1    ; draw 1 col at V0,VE
388    3f00    sei VF,0       ; unless VF = 0
38A    1390    jmp 390        ; go @4
38C    d0e1    drw V0,VE,1    ; draw 1 col at V0,VE
38E    1394    jmp 394        ; go @5
@4:
390    d0d1    drw V0,VD,1    ; draw 1 col at V0,VD
392    7b01    adi VB,1       ; VB += 1
@5:
394    7001    adi V0,1       ; V0 += 1
396    3025    sei V0,25      ; unless V0 = 37
398    1386    jmp 386        ; loop @3
39A    4b00    sni VB,0       ; if VB = 0
39C    13a6    jmp 3A6        ; go update-score
39E    7dff    adi VD,FF      ; VD -= 1
3A0    7eff    adi VE,FF      ; VE -= 1
3A2    3d01    sei VD,1       ; unless VD = 1
3A4    1382    jmp 382        ; loop @2
update-score:
3A6    23c0    cal 3C0        ; call draw-score
3A8    3f01    sei VF,1       ; unless VF = 1
3AA    23c0    cal 3C0        ; call draw-score
3AC    7a01    adi VA,1       ; VA += 1
3AE    23c0    cal 3C0        ; call draw-score
accelerate:
3B0    80a0    ldv V0,VA      ; V0 = VA
3B2    6d07    ldi VD,7       ; VD = 7
3B4    80d2    and V0,VD      ; V0 = V0 & VD
3B6    4004    sni V0,4       ; if V0 = 4
3B8    75fe    adi V5,FE      ; V5 -= 2
3BA    4502    sni V5,2       ; if V5 = 2
3BC    6504    ldi V5,4       ; V5 = 4
3BE    00ee    ret

draw-score:
3C0    a700    mem 700        ; at 700
3C2    f255    dmp V2         ; save V0,V1,V2
3C4    a804    mem 804        ; at 804
3C6    fa33    bcd VA         ; save VA as BCD
3C8    f265    rst V2         ; restore V0,V1,V2 from here
3CA    f029    fnt V0         ; prepare character V0
3CC    6d32    ldi VD,32      ; VD = 50
3CE    6e00    ldi VE,0       ; VE = 0
3D0    dde5    drw VD,VE,5    ; draw 5 cols at VD,VE
3D2    7d05    adi VD,5       ; VD += 5
3D4    f129    fnt V1         ; prepare character V1
3D6    dde5    drw VD,VE,5    ; draw 5 cols at VD,VE
3D8    7d05    adi VD,5       ; VD += 5
3DA    f229    fnt V2         ; prepare character V2
3DC    dde5    drw VD,VE,5    ; draw 5 cols at VD,VE
3DE    a700    mem 700        ; at 700
3E0    f265    rst V2         ; restore V0,V1,V2 from here
3E2    a2b4    mem 2B4        ; I = pixel-pattern
3E4    00ee    ret

init0:
3E6    6a00    ldi VA,0    ; VA = 0
3E8    6019    ldi V0,19   ; V0 = 25
3EA    00ee    ret

3EC    3723    
