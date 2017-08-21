        .MODEL tiny
        .CODE
        .STARTUP

        mov ax,1201h
        mov bl,36h
        int 10h

        end
