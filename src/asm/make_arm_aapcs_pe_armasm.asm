;/*
;            Copyright Oliver Kowalke 2009.
;   Distributed under the Boost Software License, Version 1.0.
;      (See accompanying file LICENSE_1_0.txt or copy at
;          http://www.boost.org/LICENSE_1_0.txt)
;*/

;/*******************************************************************
; *                                                                 *
; *  -------------------------------------------------------------  *
; *  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  *
; *  -------------------------------------------------------------  *
; *  | 0x0 | 0x4 | 0x8 | 0xc | 0x10| 0x14| 0x18| 0x1c| 0x20| 0x24|  *
; *  -------------------------------------------------------------  *
; *  |  v1 |  v2 |  v3 |  v4 |  v5 |  v6 |  v7 |  v8 |  lr |  sp |  *
; *  -------------------------------------------------------------  *
; *  -------------------------------------------------------------  *
; *  |  10 |                                                     |  *
; *  -------------------------------------------------------------  *
; *  | 0x28|                                                     |  *
; *  -------------------------------------------------------------  *
; *  |  pc |                                                     |  *
; *  -------------------------------------------------------------  *
; *  -------------------------------------------------------------  *
; *  |  11 |  12 |  13 |                                         |  *
; *  -------------------------------------------------------------  *
; *  | 0x2c| 0x30| 0x34|                                         |  *
; *  -------------------------------------------------------------  *
; *  |  sp | size|limit|                                         |  *
; *  -------------------------------------------------------------  *
; *  -------------------------------------------------------------  *
; *  |  14 | 15 |  16 |  17 |  18 |  19 |  20 |  21 |  22  |  23 |  *
; *  -------------------------------------------------------------  *
; *  | 0x38|0x3c| 0x40| 0x44| 0x48| 0x4c| 0x50| 0x54| 0x58 | 0x5c|  *
; *  -------------------------------------------------------------  *
; *  | s16 | s17 | s18 | s19 | s20 | s21 | s22 | s23 | s24 | s25 |  *
; *  -------------------------------------------------------------  *
; *  -------------------------------------------------------------  *
; *  |  24 |  25 |  26 |  27 |  28 |  29 |                       |  *
; *  -------------------------------------------------------------  *
; *  | 0x60| 0x64| 0x68| 0x6c| 0x70| 0x74|                       |  *
; *  -------------------------------------------------------------  *
; *  | s26 | s27 | s28 | s29 | s30 | s31 |                       |  *
; *  -------------------------------------------------------------  *
; *  -------------------------------------------------------------  *
; *  |  30 |                                                     |  *
; *  -------------------------------------------------------------  *
; *  | 0x78|                                                     |  *
; *  -------------------------------------------------------------  *
; *  |deall|                                                     |  *
; *  -------------------------------------------------------------  *
; *                                                                 *
; * *****************************************************************/


    AREA |.text|, CODE
    ALIGN 4
    EXPORT make_fcontext
    IMPORT _exit

make_fcontext PROC
    mov     a4, a1          ; save address of context stack (base) A4
    sub     a1, a1, #0x7c   ; reserve space for fcontext_t at top of context stack

    ; shift address in A1 to lower 16 byte boundary
    ; == pointer to fcontext_t and address of context stack
    bic     a1, a1, #0x0f

    str     a4, [a1,#0x2c]  ; save address of context stack (base) in fcontext_t
    str     a2, [a1,#0x30]  ; save context stack size in fcontext_t
    sub     a4, a4, a2      ; limit = base - size
    str     a4, [a1,#0x34]  ; save context stack limit in fcontext_t
    str     a4, [a1,#0x78]  ; save context stack limit as 'deallocation stack' in fcontext_t
    str     a3, [a1,#0x28]  ; save address of context function in fcontext_t

    str     a1, [a1,#0x24]  ; save address in A4 as stack pointer for context function

    adr     a2, finish      ; compute abs address of label finish
    str     a2, [a1,#0x20]  ; save address of finish as return address for context function
                            ; entered after context function returns

    bx      lr

finish
    ; SP points to same addras SP on entry of context function
    mov     a1, #0          ; exit code is zero
    bl      _exit           ; exit application

    ENDP
    END
