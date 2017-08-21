        MODEL tiny
        .CODE
        .STARTUP

        mov     ax,3d02h
        mov     dx,offset fname
        int     21h
        mov     handle,ax

        mov     bx,ax
        mov     ax,4202h
        xor     cx,cx
        mov     dx,07
        int     21h

        mov     ah,40h
        mov     bx,handle
        lea     dx,buf
        mov     cx,3
        int     21h

        mov     bx,handle
        mov     ax,4200h
        xor     cx,cx
        mov     dx,0
        int     21h

        mov     ah,3eh
        mov     bx,handle
        int     21h

        int     20h

fname   db      'd:\asd.',0
buf     db      3 dup(36)
handle  dw      0
        end
