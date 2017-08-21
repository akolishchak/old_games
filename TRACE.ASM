        .MODEL tiny
        .CODE
        .STARTUP
        jmp     start

int09   proc    near



        db      0eah
_ofs01  dw      0
_seg01  dw      0

int09   endp

int01   proc    near

        push    es
        push    ax

        mov     ax,40h
        mov     ax,es
        mov     ax,cs:last
        cmp     es:[6ch],ax
        je      exit
        mov     ax,0b800h
        mov     es,ax
        mov     al,cs:mark
        mov     es:[0],al
        inc     cs:mark

 exit:
        pop     ax
        pop     es
        iret
last    dw       0
mark    db       1
int01   endp

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

        mov     ax,2501h
        mov     dx,offset int01
        int     21h

        mov     ax,3100h
        mov     dx,offset start
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     21h



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

        ; set debug flag

        pushf
        mov     si,sp
        inc     si
        or      byte ptr ss:[si],00000001b
        popf

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
