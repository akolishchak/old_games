;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓                                                   ▓▓
;▓▓   Защита от выгорания :                           ▓▓
;▓▓   отключает регенерацию экрана по <Scroll Lock>   ▓▓
;▓▓                                                   ▓▓
;▓▓   (C) TigerSoft Lab  v 1.0  1996                  ▓▓
;▓▓                                                   ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

        .MODEL tiny
        .CODE
        .STARTUP

        jmp      init
;---------------------------
; Обработчик  9h прерывания
;---------------------------
id_treater = $

interrupt   proc  far

            pushf
            cli
            push    ax
            push    es

            in      al,60h                  ; port 60h, keybd scan or sw1

            test    cs:flg,10000000b
            jz      next11

            cmp     al,0fah
            je      runint

            cmp     al,0c6h
            je      runint
            cmp     al,0e0h
            je      runint
            jmp short show
next11:
            cmp     al,46h                  ; 'S'
            jne     runint                  ; Jump if not equal
;---------------------------

            mov     ax,1201h
            mov     bl,36h
            int     10h
            or      cs:flg,10000000b
            or      cs:flg,00000001b
            mov     ax,40h
            mov     es,ax
            mov     al,es:[17h]       ; keep Keyboard Condition Word
            mov     cs:kbd_byte,al

            jmp short quit10
show:
            mov     ax,1200h
            mov     bl,36h
            int     10h
            and     cs:flg,01111111b
quit10:
            in      al,61h                  ; port 61h, 8255 port B, read
            mov     ah,al
            or      al,80h
            out     61h,al                  ; port 61h, 8255 B - spkr, etc
            xchg    ah,al
            out     61h,al                  ; port 61h, 8255 B - spkr, etc
            mov     al,20h                  ; ' '
            out     20h,al                  ; port 20h, 8259-1 int command

            pop     es
            pop     ax
            sti
            popf
            iret
runint:
            pop   es
            pop   ax
            sti
            popf

          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
flg       db        00h
count     db        0
kbd_byte  db        0
interrupt   endp

timer   proc    near

        test    cs:flg,10000000b
        jnz     next21
        test    cs:flg,00000001b
        jz      non_act01

        push    es
        push    ax
        mov     ax,40h
        mov     es,ax
        mov     al,cs:kbd_byte
        mov     es:[17h],al
        and     cs:flg,11111110b
        jmp  short  okey01

next21:
        inc     cs:count
        cmp     cs:count,3
        jl      non_act01

        mov     cs:count,0
        or      cs:flg,01000000b

        push    es
        push    ax

        mov     ax,40h
        mov     es,ax

        test    cs:flg,00100000b
        jz      lamp_on

        and     byte ptr es:[17h],11101111b  ; lamp off
        and     cs:flg,11011111b
        jmp     short okey01

lamp_on:
        or      byte ptr es:[17h],00010000b
        or      cs:flg,00100000b
okey01:
        pop     ax
        pop     es

non_act01:
          db        0EAh
oldofs01  dw        0
oldseg01  dw        0

timer   endp
sizetsr = ($ - id_treater)
sizetsrp = (($ - id_treater)/16 + 1)

init    proc    near

        push    ES
        mov     AX,DS:[2Ch]
        mov     ES,AX
        mov     AH,49h
        int     21h
        pop     ES

        push    DS
        push    ES

        mov     AX,3509h                    ;****** edit here ****
        int     21h

        mov     CS:oldXXo,BX
        mov     CS:oldXXs,ES

        mov     AX,3508h                    ;****** edit here ****
        int     21h

        mov     CS:oldofs01,BX
        mov     CS:oldseg01,ES

        mov     bx,sizetsrp
        call    analog48
        jc      exit00

        mov     mem,ax

        cld
        mov     es,ax
        xor     di,di
        mov     si,offset interrupt
        mov     cx,sizetsr
        rep  movsb

        mov     ax,mem
        xor     dx,dx
        mov     ds,ax
        mov     AX,2509h                    ;***** edit here ******
        int     21h

        mov     ax,offset interrupt
        mov     dx,offset timer
        sub     dx,ax
        mov     AX,2508h                    ;***** edit here ******
        int     21h

        pop     es
        pop     ds

        mov     ah,9h
        mov     dx,offset hello
        int     21h

exit00:
        int     20h
;-----------------------------
hello   db      13,10,"Save screen : regeneration off",13,10
        db      "Activate - <Scroll Lock>",13,10
        db      "Copyright  (C) TigerSoft Lab  v 1.2 , 1996",13,10,"$"
mem     dw      0
;------------------------------
init    endp
;-----------------------------
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

          mov       word ptr es:[01],7 ; '7'- признак занятости
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

           end


