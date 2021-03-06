;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                               ▓▓
;▓▓   Оставление резидента в памяти               ▓▓
;▓▓   без использования прерываний (27h, DOS 31h) ▓▓
;▓▓  (C) TigerSoft Lab  v 1.0,  1995  2 мая       ▓▓
;▓▓                                               ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE

idpro = $

        .STARTUP

start:  jmp       install
vol     db        0
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
intXXh    endp
size_treater = ($ - id_treater)

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
install   proc      near

          mov       ah,4ah
          mov       bx,1000h
          int       21h
          jc        quit

;          push      ES
;          mov       AX,DS:[2Ch]
;          mov       ES,AX
;          mov       AH,49h
;          int       21h
;          pop       ES

          push      DS
          push      ES
          mov       AX,351ch                    ;****** edit here ****
          int       21h

          mov       CS:oldXXo,BX
          mov       CS:oldXXs,ES

          mov       cx,size_treater             ; размер TSR-а
          mov       bx,offset intXXh            ; его адрес
          call      keeptsr
          jc        quit
          mov       memb,ax                       ; в AX адрес TSR

          cli
          mov       ax,memb
          mov       ds,ax
          xor       dx,dx
          mov       AX,251ch                    ;***** edit here ******
          int       21h
          sti

          pop       ES
          pop       DS


quit:
          int       20h
memb        dw        ?
install   endp

keeptsr   proc      near

          mov       si,bx
          xor       di,di
          mov       ah,52h          ; получение адреса 1-го MCB
          int       21h
          sub       bx,2
          mov       dx,es:[bx]
          mov       kp,cx           ; сохраняем размер в kp
          shr       cx,1            ;
          shr       cx,1            ; \
          shr       cx,1            ;   догоняем до параграфов
          shr       cx,1            ; /
          inc       cx              ;
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
          ; блок памяти выделен,
          ; теперь пересылаем туда код TSR-а

          inc       di
          mov       es,di           ; DS:SI уже есть
          xor       di,di
          mov       cx,kp
          cli
          rep       movsb
          sti
next03:
          mov       ax,es
          ret
;-------------------------------------------------
kp        dw        ?
hello     db        " (C) TigerSoft Lab  v 1.0 , 1996 "
;-------------------------------------------------
sizepro = (($ - idpro)/16 + 1)
sizeprop = ($ - idpro)
keeptsr   endp
          end

