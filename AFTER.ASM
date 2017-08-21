        .MODEL tiny
        .CODE
        .STARTUP
        jmp     start
start:

        mov     ax,es:[0ah]
        mov     ofss,ax
        mov     ax,es:[0ch]
        mov     segs,ax

        cld
        push    ds
        mov     ax,cs:segs
        mov     ds,ax
        mov     si,cs:ofss
        push    cs
        pop     es
        mov     di,offset five_b
        mov     cx,5
        rep  movsb
        pop     ds

        mov     word ptr _ofs,offset there
        mov     _seg,cs

        mov     si,offset jumpm
        mov     ax,segs
        mov     es,ax
        mov     di,ofss
        mov     cx,5

        rep  movsb

        mov     dx,offset start

        int     27h
there:
        push    es
        push    ds
        push    si
        push    di
        push    ax
        push    bx
        push    cx
        push    dx

        mov     ah,9
        mov     dx,offset hello
        push    cs
        pop     ds
        int     21h

jake:
        push    cs
        pop     ds
        mov     si,offset five_b
        mov     ax,cs:segs
        mov     es,ax
        mov     di,cs:ofss
        mov     cx,5
        rep movsb

        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     di
        pop     si
        pop     ds
        pop     es

        db      0eah
ofss    dw      0
segs    dw      0

jumpm   db      0eah
_ofs    dw      0
_seg    dw      0
;------------------------------------------------------
five_b  db      5  dup(?)
pspseg  dw      0
kpp     dw      0
hello   db      13,10,"It's output code run",13,10,"$"
;-------------------------------------------------------
        end
