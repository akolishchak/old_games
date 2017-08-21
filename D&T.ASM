        .MODEL  tiny
        .CODE
        .STARTUP

        push    ds

        push    cs
        pop     ds

        mov     ax,ss
        mov     ast,ax

        pop     ds
        push    ds

        mov     ax,1203h
        int     2fh

        mov     ax,ds
        mov     ss,ax
        mov     ax,120dh
        int     2fh

        push    ds
        push    cs
        pop     ds

        mov     bx,ast

        pop     ds

        mov     ss,bx
        mov     date,ax
        mov     time,dx

        pop     ds

        ret

ast      dw      00h
date    dw      ?
time    dw      ?
        end
