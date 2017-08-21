;
;
;
        MODEL tiny
        .CODE

; заголовок драйвера устройств - device header
        dd      -1              ; последний драйвер
        dw      8000h           ; символьный
        dw      offset start    ; адрес основной процедуры
        dw      offset intrp    ; адрес процедуры обработки
                                ; прерываний
        db      1               ; не используется
        db      7 dup(?)        ; не используется
        ; end device header

rh_ptra label   dword           ; для хранения адреса заголовка
                                ; запроса
rh_ptro dw      ?
rh_ptrs dw      ?

start   proc    far
        mov     cs:rh_ptro,bx   ; сохранение смещения заголовка
                                ; запроса
        mov     cs:rh_ptrs,es   ; сохранение сегмента заголовка
                                ; запроса
        ret
start   endp

intrp   proc    far
        push    ax
        push    bx
        push    dx
        lds     bx,cs:rh_ptra
        push    ds

        mov     ah,9
        mov     dx,offset hello
        push    cs
        pop     ds
        int     21h
        mov     ah,7
        int     21h


        pop     ds              ; восстановление
        mov     byte ptr ds:[bx+13],0 ; подготовка к
        mov     word ptr ds:[bx+14],0 ; выходу с освобождением
        mov     word ptr ds:[bx+16],cs ; памяти
        pop     dx
        pop     bx
        pop     ax

        ret

hello   db      13,10,"It's driver for hello only !!!"
        db      13,10,"Press any key",13,10,"$"

intrp   endp
        end

