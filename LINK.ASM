
        MODEL tiny
        .CODE
        .STARTUP

        push    es ds cs
        pop     ds
        push    cs
        pop     es

        mov     ah,9
        mov     dx,offset hello
        int     21h
        mov     ah,7
        int     21h


        pop     ds es
        retf


hello   db      7,'Вышло !!!',13,10,36
        end


