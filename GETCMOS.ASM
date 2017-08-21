        MODEL tiny
        .CODE
        .STARTUP

        mov     ah,9
        mov     dx,offset hello
        int     21h

        mov     cx,0f5h
        mov     al,0ah
        xor     si,si
repeat:
        push    ax
        out     70h,al
        jmp short $+2
        in      al,71h
        mov byte ptr buf[si],al
        pop     ax
        inc     al
        inc     si
        loop    repeat
        call    open
        jnc     next0
        mov     ah,9
        mov     dx,offset errmsg0
        int     21h
        jmp  short exit
next0:
        mov     bx,handle
        mov     ah,40h
        mov     cx,0f5h
        mov     dx,offset buf
        int     21h
        jnc     next1
        mov     ah,9
        mov     dx,offset errmsg1
        int     21h
        jmp short exit
next1:
        mov     ah,9
        mov     dx,offset endpro
        int     21h
exit:
        mov     ax,4c00h
        int     21h
;------------------------------------
buf     db   0f5h dup(0)
fname   db   'cmos.dat',0
hello   db   'Чтение CMOS в файл CMOS.DAT','$'
endpro  db   ' ...',13,10,36
errmsg0  db   'Ошибка создания файла',13,10,36
errmsg1 db   'Ошибка записи',13,10,36
;------------------------------------
;------------------------------
; Открытие файла для записи
;------------------------------
open    proc    near

        mov     ah,3ch     ;
        mov     cx,02      ;\
        lea     dx,fname   ;  создать файл
        int     21h        ;/
        mov     handle,ax
        ret
handle  dw      0
open    endp
        end

