        .MODEL tiny
        .CODE
        .STARTUP

        mov     ah,15h
        mov     dl,82h
        int     13h


        int     20h

        end
