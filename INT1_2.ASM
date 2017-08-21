;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                            ▓▓
;▓▓     Извраты  с INT 01.                     ▓▓
;▓▓   Не снимаемый обработчик INT 9            ▓▓
;▓▓                                            ▓▓
;▓▓   (C) TigerSoft Lab  v 1.0,  1996          ▓▓
;▓▓                                            ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        MODEL tiny
        .CODE
        .STARTUP

        jmp     main
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
mark    db       0
int01   endp

main    proc    near

        mov     ax,es:[0ah]
        mov     ofss,ax
        mov     ax,es:[0ch]
        mov     segs,ax

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

        int     20h
there:
        push    es
        push    ds
        push    si
        push    di
        push    ax

;

        push    cs
        pop     ds
        mov     ah,9
        mov     dx,offset hello
        int     21h

        push    cs
        pop     ds
        mov     si,offset five_b
        mov     ax,cs:segs
        mov     es,ax
        mov     di,cs:ofss
        mov     cx,5
        rep movsb

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

        mov     ax,2501h
        mov     dx,offset int01
        int     21h
        mov     ah,9
        mov     dx,offset hello
        int     21h

        ; set debug flag

        pushf
        mov     si,sp
        inc     si
        or      byte ptr ss:[si],00000001b
        popf

        mov     ax,3100h
        mov     dx,offset main
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     21h

hello   db      13,10,"(C) TigerSoft Lab v 1.0,  1996",13,10,"$"

main    endp

        end

