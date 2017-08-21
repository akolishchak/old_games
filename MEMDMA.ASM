        MODEL tiny
        .CODE
        .STARTUP
        jmp  main

Start1  db      0aah                ; исходный байт
Start2  db      0bbh                ; результирующий байт
Msg     label   byte                ; сообщение о результате
                                    ; пересылки
        db      'Result byte '
RB      dw      2020h
        db      13,10,36
main    proc
        cli
        in      al,8                ; прочистим статус регистр
;
; выключим каналы 0 и 1
;
        mov     al,00000100b        ;замаскировать канал 0
        out     0ah,al
        jmp short $+2
        mov     al,00000101b        ; замаскировать канал 1
        out     0ah,al
        jmp short $+2
;
; сбросим запрос на передачу для каналов 0 и 1
;
        mov     al,00000000b        ; сбросим запрос канала 0
        out     9,al
        jmp short $+2
        mov     al,00000001b        ; сбросим запрос канала 1
        out     9,al
        jmp short $+2
;
; сбросим указатель последовательности байт
;
        out     0ch,al
        jmp short $+2
;
; установим адреса для передачи канала 0
;
        mov     ax,cs               ; адрес сегмента
        mov     cl,4                ; для сдвига
        rol     ax,cl               ; сдвинем
        mov     ch,al               ; остаток от сдвига и сдвинутые
                                    ; данные
        and     al,0f0h             ; сбросим остаток сдвига
        add     ax,offset  Start1   ; добавим смещение
        adc     ch,0                ; добавим потерянную единицу

        out     0,al                ; передать младшую часть адреса
        jmp short $+2
        mov     al,ah               ; старшая часть адреса
        out     0,al                ; передать старшую часть адреса
        jmp short $+2
        mov     al,ch               ; старшие 4 бита адреса
        and     al,0fh
        out     87h,al              ; запишем регистр страницы
        jmp short $+2
;
; запишем длину данных - 1 байт
;
        sub     al,al
        out     1,al
        jmp short $+2
        out     1,al
        jmp short $+2
;
; установим адреса для передачи канала 1
;
        mov     ax,cs               ; адрес сегмента
        mov     cl,4                ; для сдвига
        rol     ax,cl               ; сдвинем
        mov     ch,al               ; остаток от сдвига и
                                    ; сдвинутые данные
        and     al,0f0h             ; сбросим остаток сдвига
        add     ax,offset Start2    ; добавим смещение
        adc     ch,0                ; добавим потерянную единицу
        out     2,al                ; передать младшую часть адреса
        jmp short $+2
        mov     al,ah               ; старшая часть адреса
        out     2,al                ; передать старшую часть адреса
        jmp short $+2
        mov     al,ch               ; старшие 4 бита адреса
        and     al,0fh
        out     83h,al              ; запишем регистр страницы
        jmp short $+2
;
; запишем длину данных 1 байт
;
        sub     al,al
        out     3,al
        jmp short $+2
        out     3,al
        jmp short $+2
;
; установим режимы работы каналов 0 и 1
;
        mov     al,10001000b        ; канал 0 - чтение, передача блока
        out     0bh,al
        jmp short $+2
        mov     al,10000101b        ; канал 1 - запись, передача блока
        out     0bh,al
        jmp short $+2
;
; установим режим память-память
;
        mov     al,00000001b
        out     8,al
        jmp short $+2
;
; откроем каналы
;
        mov     al,00000000b
        out     0fh,al
        jmp short $+2
;-----------------------
; запрос на передачу
;-----------------------
        mov     al,00000100b        ; запрос на передачу
        out     9,al
        jmp short $+2
;
WaitDMA:
        in      al,8                ; ждем завершения
        test    al,00000010b        ; передача закончена?
        jz      WaitDMA             ; нет, ждем
;
; восстановим состояние DMA
;
        mov     al,00000011b        ; выключим каналы 0 и 1
        out     0fh,al
        jmp short $+2
        mov     al,0                ; восствновим командный регистр
        out     8,al
        jmp short $+2
        mov     al,40h              ; установим канал 0 в режим
                                    ; передачи байта
        out     0bh,al
        jmp short $+2
        mov     al,41h              ; установим канал 1 в режим
                                    ; передачи байта
        out     0bh,al
        jmp short $+2
        sub     al,al               ; откроем каналы
        out     0fh,al
        jmp short $+2
;
; выведем результат из приемного буфера
;
        sti
        mov      al,Start2
        call     HexChar
        mov      RB,ax
        mov      dx,offset Msg
        mov      ah,9
        int      21h
;
; завершим программу
;
        mov      ax,4c00h
        int      21h
main    endp
;
;  Input:   AL - number
;  Output:  AX - number in hex
;
HexChar proc
        push    bx
        xor     ah,ah
        mov     bl,16
        div     bl
        add     al,30h
        cmp     al,39h
        jna     Hex1
        add     al,7
Hex1:   add     ah,30h
        cmp     ah,39h
        jna     Hex2
        add     ah,7
Hex2:   pop     bx
        ret

HexChar endp

        end












