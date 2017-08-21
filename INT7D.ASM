        .MODEL tiny
        .CODE
        .STARTUP

        jmp init

int7d   proc    near

        iret

int7d   endp

init:   mov     ax,257dh
        mov     dx,offset int7d
        int     21h

        mov     ax,3100h
        mov     dx,offset init
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     21h

        end
