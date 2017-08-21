;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                                   ▓▓
;▓▓   Защита от выгорания :                           ▓▓
;▓▓   отключает регенерацию экрана по <Scroll Lock>   ▓▓
;▓▓                                                   ▓▓
;▓▓   (C) TigerSoft Lab  v 1.0 1996                   ▓▓
;▓▓                                                   ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE
        .STARTUP

        jmp      init
;---------------------------
; Обработчик  9h прерывания
;---------------------------
interrupt   proc  far

            pushf
            cli
            push    ax
            push    bx
            push    es

            in      al,60h                  ; port 60h, keybd scan or sw1

            test    cs:flg,10000000b
            jz      next11

;            test    cs:flg,01000000b
;            jnz     runint

            cmp     al,0fah
            je      runint

            cmp     al,0c6h
            je      runint
            cmp     al,0e0h
            je      runint
            jmp short show
next11:
            cmp     al,46h                  ; 'S'
            jne     runint                  ; Jump if not equal
;---------------------------

            mov     ax,1201h
            mov     bl,36h
            int     10h
            or      cs:flg,10000000b
            or      cs:flg,00000001b
            mov     ax,40h
            mov     es,ax
            mov     al,es:[17h]       ; keep Keyboard Condition Word
            mov     cs:kbd_byte,al

            jmp short quit10
show:
            mov     bl,al
            mov     ax,0b800h
            mov     es,ax
            mov     es:[0],bl

            mov     ax,1200h
            mov     bl,36h
            int     10h
            and     cs:flg,01111111b
quit10:
            in      al,61h                  ; port 61h, 8255 port B, read
            mov     ah,al
            or      al,80h
            out     61h,al                  ; port 61h, 8255 B - spkr, etc
            xchg    ah,al
            out     61h,al                  ; port 61h, 8255 B - spkr, etc
            mov     al,20h                  ; ' '
            out     20h,al                  ; port 20h, 8259-1 int command

            pop     es
            pop     bx
            pop     ax
            sti
            popf
            iret
runint:
            pop   es
            pop   bx
            pop   ax
            sti
            popf

          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
flg       db        00h
count     db        0
kbd_byte  db        0
numl      db        0
interrupt   endp

timer   proc    near

        test    cs:flg,10000000b
        jnz     next21
        test    cs:flg,00000001b
        jnz     next22
        jmp     non_act01
next22:
        push    es
        push    bx
        push    ax

        mov     ax,40h
        mov     es,ax
        or      cs:flg,01000000b
        mov     al,cs:kbd_byte
        mov     es:[17h],al
        and     cs:flg,11111110b
        jmp  short  okey01

next21:
        inc     cs:count
        cmp     cs:count,3
        jl      non_act01

        mov     cs:count,0
        or      cs:flg,01000000b

        push    es
        push    bx
        push    ax

        ; choice of lamp number
        cmp     cs:numl,0
        jne     next31
        mov     bl,00010000b
next31:
        cmp     cs:numl,1
        jne     next32
        mov     bl,01000000b
next32:
        cmp     cs:numl,2
        jne     next33
        mov     bl,00100000b
next33:
        mov     ax,40h
        mov     es,ax

        test    cs:flg,00100000b
        jz      lamp_on

        xor     bl,0
        and     byte ptr es:[17h],bl  ; lamp off
        and     cs:flg,11011111b
        inc     cs:numl
        cmp     cs:numl,3
        jl      okey01
        mov     cs:numl,0
        jmp     short okey01

lamp_on:
        or      byte ptr es:[17h],bl
        or      cs:flg,00100000b
okey01:

        pop     ax
        pop     bx
        pop     es

non_act01:
          db        0EAh
oldofs01  dw        0
oldseg01  dw        0

timer   endp

init    proc    near

        push    ES
        mov     AX,DS:[2Ch]
        mov     ES,AX
        mov     AH,49h
        int     21h
        pop     ES

        push    DS
        push    ES

        mov     AX,3509h                    ;****** edit here ****
        int     21h

        mov     CS:oldXXo,BX
        mov     CS:oldXXs,ES

        mov     AX,CS
        mov     DS,AX

        lea     DX,interrupt
        mov     AX,2509h                    ;***** edit here ******
        int     21h

        mov     AX,3508h                    ;****** edit here ****
        int     21h

        mov     CS:oldofs01,BX
        mov     CS:oldseg01,ES

        mov     AX,CS
        mov     DS,AX

        lea     DX,timer
        mov     AX,2508h                    ;***** edit here ******
        int     21h

        pop     es
        pop     ds

        mov     ah,9h
        mov     dx,offset hello
        int     21h

        mov     ax,3100h
        mov     dx,offset init
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     21h
exit:
        int     20h
;-----------------------------
hello   db      13,10,"Save screen : regeneration off",13,10
        db      "Activate - <Scroll Lock>",13,10
        db      "Copyright  (C) TigerSoft Lab  v 1.0 , 1996",13,10,"$"
;------------------------------
init    endp
;-----------------------------

           end


