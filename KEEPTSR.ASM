;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                               ▓▓
;▓▓   Оставление резидента в памяти               ▓▓
;▓▓   без использования прерываний (27h, DOS 31h) ▓▓
;▓▓  (C) TigerSoft Lab  v 1.1,  1995  2 мая       ▓▓
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
;          db 2000 dup(0)
intXXh    endp
size_treater = ($ - id_treater)

■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
install   proc      near

          mov       ah,4ah
          mov       bx,1000h
          int       21h
          jnc       there00
          jmp       quit
there00:
          push      ES
          mov       AX,DS:[2Ch]
          mov       ES,AX
          mov       AH,49h
          int       21h
          pop       ES

          mov       ah,48h
          mov       bx,1000h
          int       21h
          jc        quit

          mov       es,ax
          xor       di,di
          xor       si,si
          mov       cx,0ffffh
          cld
          rep       movsb
          xor       al,al
          mov       es:[0ffffh],al

          mov       cs:_ofs,offset there
          mov       cs:_seg,es
          mov       ax,es
          mov       ds,ax
          mov       ss,ax
          mov       ah,4ah
          mov       bx,cs
          mov       es,bx
          mov       oldseg,bx
          mov       bx,1
          int       21h
          push      cs
          pop       es

          db        0eah
_ofs      dw        0
_seg      dw        0
_ses      dw        0
oldseg    dw        0
there:
;          mov       ah,50h
;          mov       bx,cs
;          int       21h

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
            mov       ah,49h
            mov       bx,oldseg
            mov       es,bx
            int       21h

            mov       ah,49h
            mov       bx,cs
            mov       es,bx
            int       21h

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
hello     db        " (C) TigerSoft Lab v 1.1 , 1996 "
;-------------------------------------------------
;sizeprop = (($ - idpro)/16 + 1)
sizepro  = ($ - idpro)
keeptsr   endp
          end

