;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                               ▓▓
;▓▓   Оставление резидента в памяти               ▓▓
;▓▓   без использования прерываний (27h, DOS 31h) ▓▓
;▓▓  (C) TigerSoft Lab v 1.2,  1995  2 мая        ▓▓
;▓▓                                               ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE

idpro = $

        .STARTUP

start:  jmp       install
vol     db        0
;        db     dup(0)



■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
install   proc      near

        mov     pspseg,cs
        mov     ah,4ah
        mov     bx,1000h
        int     21h

        mov     ax,cs:[2ch]
        mov     es,ax
        mov     ah,49h
        int     21h

        mov     bx,sizetsrp
        call    analog48
        jc      jake
        mov     kpp,ax

        mov       AX,351ch                    ;****** edit here ****
        int       21h

        mov       CS:oldXXo,BX
        mov       CS:oldXXs,ES

        push    cs
        pop     ds
        mov     si,offset intXXh
        mov     ax,kpp
        mov     es,ax
        xor     di,di
        mov     cx,sizetsr
        rep  movsb
        mov       ax,kpp
        mov       ds,ax
        xor       dx,dx
        mov       AX,251ch                    ;***** edit here ******
        int       21h


        push    cs
        pop     ds
        mov     ah,9
        mov     dx,offset hello
        int     21h
jake:
        int     20h
install   endp

keeptsr   proc      near

          ; блок памяти выделен,
          ; теперь пересылаем туда код TSR-а

          ret
;-------------------------------------------------
kp        dw        ?
hello     db        " (C) TigerSoft Lab v 1.1 , 1996 ",13,10,"$"
pspseg    dw        0
five_b    db   5   dup(0)
kpp        dw        0
;-------------------------------------------------
;sizeprop = (($ - idpro)/16 + 1)
;sizepro  = ($ - idpro)
keeptsr   endp
;-------------------------------------------------
analog48  proc    near

          push      es
          push      bx
          push      cx
          push      dx
          push      di

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

intXXh  proc      near

        push      ax
        push      es
        mov       ax,0b800h
        mov       es,ax
        mov       al,vol
        mov       es:[0],al
        inc       vol
        pop       es
        pop       ax

         db        0EAh
_int     label     dword
oldXXo    dw        0
oldXXs    dw        0
          db   100 dup(0)
intXXh    endp
sizetsr = ($ - id_treater)
sizetsrp = (($ - id_treater)/16 + 1)
          end

