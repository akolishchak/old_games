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

            mov     bl,cs:flg
            and     bl,10000000b
            jz      next11

            cmp     swflg,1
            jne     next41
            mov     swflg,0
            jmp short runint
next41:
            cmp     al,0e0h
            je      runint

            cmp     al,0c6h
            je      runint

            cmp     al,0fah
            je      runint

            jmp short show
next11:
            cmp     al,46h                  ; 'S'
            jne     runint                  ; Jump if not equal
;---------------------------

            mov     ax,1201h
            mov     bl,36h
            int     10h
            mov     ax,40h
            mov     es,ax
            mov     cs:indic,1
            mov     cs:pindic,1
            mov     ax,es:[17h]
            mov     cs:kword,ax

            mov     cs:flg,10000000b

            jmp short quit10
show:
            mov     ax,1200h
            mov     bl,36h
            int     10h
            mov     cs:indic,0
            mov     cs:flg,0
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
kword     dw        ?
flg       db        00h
indic     db        0
pindic    db        0
count     db        0
numl      db        4
tflg      db        0
swflg     db        0
interrupt   endp

timer   proc    near
        cli
        cmp     cs:indic,1
        je      next23
        cmp     cs:pindic,1
        je      next50
        jmp exit02
next50:
        push    es
        push    ax
        mov     ax,40h
        mov     es,ax
        mov     ax,cs:kword
        mov     es:[17h],ax
        mov     cs:swflg,1
        mov     cs:pindic,0
        pop     ax
        pop     es
        jmp  exit02
next23:
        inc     cs:count
        cmp     cs:count,3
        jne     exit02

        push    es
        push    cx
        push    ax

        mov     ax,40h
        mov     es,ax
        mov     cs:count,0
        cmp     cs:numl,4
        jne     next51
        mov     bl,00010000b
next51:
        cmp     cs:numl,5
        jne     next52
        mov     bl,01000000b
next52:
        cmp     cs:numl,6
        jne     next53
        mov     bl,00100000b
next53:
        cmp     cs:tflg,0
        je      ind_on

        xor     bl,0
        and     byte ptr es:[17h],bl
        and     byte ptr es:[18h],bl
        mov     cs:tflg,0
        mov     cs:swflg,1
        inc     cs:numl
        cmp     cs:numl,7
        jl      exit01
        mov     cs:numl,4
        jmp  short  exit01
ind_on:
        or      byte ptr es:[17h],bl
        or      byte ptr es:[18h],bl
        mov     cs:tflg,1
        mov     cs:swflg,1
exit01:
        pop     ax
        pop     cx
        pop     es
exit02:
        sti
          db    0eah
old_ofs   dw
old_seg   dw

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

        push    DS
        push    ES
        mov     AX,3508h
        int     21h

        mov     CS:old_ofs,BX
        mov     CS:old_seg,ES


        mov     AX,CS
        mov     DS,AX

        lea     DX,timer
        mov     AX,2508h
        int     21h

        pop     ES
        pop     DS

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
        db      "Copyright  (C) The Guard  v 1.0 , 1996",13,10,"$"
;------------------------------
init    endp
;-----------------------------

           end


