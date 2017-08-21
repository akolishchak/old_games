            .MODEL tiny
            .CODE
            .STARTUP
            lea   dx,fn
            call  open        ; открыть файл
            jc    quit10
; Запись данных (6 байт) в файл
            mov   bx,handle
            mov   ah,40h
            lea   dx,kod
            mov   cx,06
            int   21h
            jc    quit20
next:
            inc   si
            cmp   byte ptr es:[bx+si],00
            jne   next
            mov   cx,si
            mov   ah,40h
            mov   bx,handle
            int   21h
quit20:
            call  close
quit10:
            ret
;----------------------------
kod     dw  0000h
fname   db  "c:\spy.dat",00
        db  128   dup(?)
fn      db  "c:\sssssss",00
handle  dw  0ffffh
;----------------------------


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
quit02:
        ret

open    endp
close   proc    near

        mov     bx,handle
        mov     ah,3eh
        int     21h
        ret

close   endp

        end

