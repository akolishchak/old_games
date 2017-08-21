;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                                   ▓▓
;▓▓   Защита от выгорания :                           ▓▓
;▓▓   отключает регенерацию экрана по <Scroll Lock>   ▓▓
;▓▓                                                   ▓▓
;▓▓   (C) TigerSoft Lab  v 1.0  1996                  ▓▓
;▓▓                                                   ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE
        .STARTUP

        jmp      init
;---------------------------
; Обработчик  9h прерывания
;---------------------------

interrupt   proc    near

            push    ax
            push    es
            push    bx
            push    si

            in      al,60h                  ; port 60h, keybd scan or sw1

            mov     bx,0b800h
            mov     es,bx
            mov     bl,cs:flg
            shl     bl,1
            xor     bh,bh
            mov     si,bx
            mov     byte ptr es:[si],al
            inc     cs:flg

runint:
            pop     si
            pop     bx
            pop     es
            pop     ax

          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
flg       db        0
interrupt   endp

init    proc    near

        mov     AX,DS:[2Ch]
        mov     ES,AX
        mov     AH,49h
        int     21h

        mov     AX,3509h                    ;****** edit here ****
        int     21h

        mov     CS:oldXXo,BX
        mov     CS:oldXXs,ES

        mov     dx,offset interrupt
        mov     AX,2509h                    ;***** edit here ******
        int     21h

        mov     ah,9h
        mov     dx,offset hello
        int     21h

        mov     ax,3100h
        mov     dx,offset init
        mov     cl,4
        shr     dx,cl
        inc     dx
        int     21h

;-----------------------------
hello   db      13,10,"Save screen : regeneration off",13,10
        db      "Activate - <Scroll Lock>",13,10
        db      "Copyright  (C) TigerSoft Lab  v 1.2 , 1996",13,10,"$"
;------------------------------
init    endp

           end


