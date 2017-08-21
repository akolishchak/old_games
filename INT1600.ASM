        .MODEL tiny
        .CODE
        .STARTUP

        mov     al,03
        xor     ah,ah
        int     16h

        mov     ax,4c00h
        int     21h

        end
