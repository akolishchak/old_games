        MODEL tiny
        .CODE
        .STARTUP

        mov     al,2eh
        out     70h,al
        jmp short $+2
        in      al,71h
        jmp short $+2
        mov     byte ptr sum[1],al

        mov     al,2fh
        out     70h,al
        jmp short $+2
        in      al,71h
        jmp short $+2
        mov     byte ptr sum[0],al

        mov     ax,sum

        ret


sum     dw      0
        end
