;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                                   ▓▓
;▓▓   Защита от выгорания :                           ▓▓
;▓▓   отключает регенерацию экрана по <Scroll Lock>   ▓▓
;▓▓                                                   ▓▓
;▓▓   (C) TigerSoft Lab  v 1.0 1996                   ▓▓
;▓▓                                                   ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE
        .STARTUP

start:  jmp       install

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
install   proc      near

        mov     pspseg,cs
        mov     ah,4ah
        mov     bx,1000h
        int     21h
        jc      by

        push    es
        mov     ax,cs:[2ch]
        mov     es,ax
        mov     ah,49h
        int     21h
        jc      by
        pop     es

        mov     bx,1000h
        mov     ah,48h
        int     21h
        jc      by

        xor     si,si
        mov     es,ax
        xor     di,di
        mov     cx,8000h
        rep  movsw
        mov     word ptr seg01,ax
        mov     word ptr ofs01,offset work
        mov     es,ax
        mov     ds,ax
        mov     ss,ax

        db      0eah
ofs01:  dw      0
seg01:  dw      0
by:
        mov     ah,2
        mov     dl,7
        int     21h

        mov     ax,4c01h
        int     21h
work:
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
        push    dx
        push    ax

        mov     bx,100h
        call    analog48
        jc      jake
;        mov     cs:kpp,ax


;        mov       ax,cs:kpp
;        mov       ds,ax

        push    cs
        pop     ds
        mov     ah,9
        mov     dx,offset hello
        int     21h
jake:
        mov     ah,2
        mov     dl,7
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
        pop     dx
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

install   endp

;-------------------------------------------------
hello   db      13,10,"Save screen : regeneration off",13,10
        db      "Activate - <Scroll Lock>",13,10
        db      "Copyright  (C) The Guard  v 1.2 , 1996",13,10,"$"
pspseg    dw        0
five_b    db   5   dup(0)
kpp        dw        0
;-------------------------------------------------
analog48  proc    near

          push      es
          push      bx
          push      cx
          push      dx
          push      di

          clc
          mov       cx,bx
          mov       ah,52h          ; получение адреса 1-го MCB
          int       21h
          sub       bx,2
          xor       di,di
          mov       dx,es:[bx]
          mov       es,dx           ; в ES
          mov       dx,0ffffh       ; в DX размер оптимального MCB
repeat:
          mov       ax,es:[01]      ; [01] - владелец блока
          cmp       ax,0
          jne       next
          mov       ax,es:[03]      ; [03] - размер блока
          cmp       ax,cx
          jb        next            ; размер меньше требуемого ?
          cmp       ax,dx
          jae       next            ; больше оптимального ?
          mov       di,es           ; запоминание
          mov       dx,ax           ; оптимального MCB
next:
          mov       al,es:[00]
          cmp       al,"Z"          ; если маркер Z, то последний MCB
          je        exit
          mov       ax,es:[03]      ; переход к следующему MCB
          mov       bx,es
          add       bx,ax
          inc       bx
          mov       es,bx
          jmp       short   repeat
exit:
          or        di,di
          jnz       next01          ; найден хотя бы один блок ?
          stc                       ; set CF
          jmp       short   next03
next01:
          ; оптимальный блок найден, теперь его выделяем

          mov       es,di
          mov       word ptr es:[01],0007h ; '7'- признак занятости
          sub       dx,cx
          cmp       dx,2
          jb        next02          ; не нужна коррекция размера ?

          ; если Да, то из этого блока памяти делаем два,
          ; т. е.  из пустого пространства делаем еще один блок
          mov       al,es:[00]
          mov       byte ptr es:[00],"M"
          mov       es:[03],cx
          mov       bx,es
          add       bx,cx
          inc       bx              ; в его ES адрес
          mov       es,bx
          mov       es:[00],al
          mov       word ptr es:[01],0000h
          dec       dx
          mov       word ptr es:[03],dx
next02:
          mov       ax,di
          inc       ax
next03:
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       es

          ret
analog48  endp

id_treater = $

          end

