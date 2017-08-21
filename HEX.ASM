.286
        .MODEL tiny
        .CODE
        .STARTUP


main:
        mov     al,077h
        call    byte2hex
        call    ttest
        call    ttest

        int     20h

ttest    proc    near

        pusha

        mov     ax,ss
        mov     ds,ax
        mov     si,sp
        mov     ax,cs
        mov     es,ax
        mov     di,offset buff
        mov     ax,20
        mov     bx,cs:count
        mul     bx
        add     di,ax
        mov     cx,10
        cld
        rep  movsw
        popa

        inc     cs:count

        ret
buff    db    100h  dup(0)
count   dw    0
ttest    endp


byte2hex  proc   near

        push    cx
        push    bx
        mov     bx,offset tabl
        push    ax
        and     al,0fh
        xlat
        mov     dl,al
        pop     ax
        mov     cl,4
        shr     al,cl
        xlat
        mov     dh,al
        pop     bx
        pop     cx
        ret
;---------------------------------
tabl    db      '0123456789ABCDEF'
;---------------------------------
byte2hex   endp

        end
