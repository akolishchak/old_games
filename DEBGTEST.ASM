
        .MODEL tiny
        .CODE
        .STARTUP

        pushf
        pop     ax
        and     ah,1
        jz      exit
        mov     ah,9
        mov     dx,offset msg
        int     21h
exit:
        int     20h

msg     db      13,10,"It is debug mode",13,10,"$"
        db      "(C) The Guard v 1.0, 1996"

        end
