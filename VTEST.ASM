;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                      ▓▓
;▓▓    Определение виртуального режима   ▓▓
;▓▓          работы процессора           ▓▓
;▓▓    (C) TigerSoft Lab  v 1.0 ,1996    ▓▓
;▓▓                                      ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
        MODEL tiny
        P386
        .CODE
        .STARTUP
;---------------------------
        smsw    ax
        test    al,1
        jz      doesntv
        mov     ah,9
        lea     dx,mas1
        int     21h
        jmp short  exit
doesntv:
        mov     ah,9
        lea     dx,mas2
        int     21h
exit:
        mov     ax,4c00h
        int     21h
;----------------------------
mas1    db      13,10,"It's V mode !!!",7,13,10,"$"
mas2    db      13,10,"It is not V mode",13,10,"$"
        db      "(C) TigerSoft Lab  v 1.0 1996"
;----------------------------
        end

