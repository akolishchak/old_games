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

            in      al,60h                  ; port 60h, keybd scan or sw1

            cmp     cs:flg,1
            je      next00
            jmp short next01
next00:
            cmp     al,0c6h
            jne     next02
            jmp short runint
next02:
            cmp     al,0fah
            jne     next07
            jmp short runint

next01:
            cmp     al,46h                  ; 'S'
            je      next07
            jmp short runint

;---------------------------
next07:
            cmp     al,0e0h
            jne     next08
next08:
            in      al
next11:
            push    ax
            xor     cs:flg,01h
            mov     al,cs:flg
            mov     ah,12h
            mov     bl,36h
            int     10h

            mov     ax,0b800h
            mov     es,ax
            pop     ax
            mov     byte ptr es:[0],al

runint:
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


