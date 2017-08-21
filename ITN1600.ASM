        .MODEL tiny
        .CODE
        STARTUP

        mov     al,03
        xor     ah,ah
        int     16h
        mov     ax,4c00
        int     21h

        end
