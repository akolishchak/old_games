        MODEL tiny
        .CODE
        .STARTUP


        push    dx

        mov     dx,3c4h
        mov     al,1
        out     dx,al
        jmp short $+2
        mov     dx,3c5h
        in      al,dx
        jmp short $+2
        xor     al,00100000b
        mov     ah,al
        mov     dx,3c4h
        mov     al,1
        out     dx,al
        jmp short $+2
        mov     dx,3c5h
        mov     al,ah
        out     dx,al

        pop     bx
        pop     dx
        ret

        end

