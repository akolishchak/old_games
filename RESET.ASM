;--------------------
; Ctrl+Alt+Del
;--------------------
        .MODEL tiny
        .CODE
        .STARTUP

        jmp      init

mark    db       1
;---------------------------
; Обработчик  9h прерывания
;---------------------------
interrupt   proc  far

            pushf
            push    ax
            push    es

            in      al,60h                  ; port 60h, keybd scan or sw1
            cmp     al,52h                  ; 'S'
            jne     runint                  ; Jump if not equal
            xor     ax,ax                   ; Zero register
            mov     es,ax
            mov     al,es:0417h             ; (0000:0417=0)
            and     al,0ch
            cmp     al,0ch
            jne     runint
;---------------------------
            mov     ax,1201h
            mov     bl,36h
            int     10h


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
            pop     ax
            popf
            iret
runint:
            pop   es
            pop   ax
            popf

          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0

interrupt   endp

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

        cli
        mov     AX,CS
        mov     DS,AX

        lea     DX,interrupt
        mov     AX,2509h                    ;***** edit here ******
        int     21h
        sti

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
hello   db      "Ctrl+Alt+Del Demo"
        db      13,10,"Copyright  (C) TigerSoft Lab  v 1.0 , 1996",13,10,"$"
;------------------------------
init    endp
;-----------------------------

           end


