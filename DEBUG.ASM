        ;********************************************************************
        ; DB386 - пример использования отладочных регистров процессора 80386
        ; Автор - Тед Мирецки
        ;********************************************************************

        ; Макрос для преобразования сегментированного адреса из
        ; двойного слова с меткой DBREGx в линейный адрес с последующей
        ; загрузкой его в соответствующий отладочный регистр


        mov2dbreg  macro   XX
                   xor     eax, eax
                   mov     ax, word ptr dbreg&XX+2   ;получить сегмент
                   shl     eax, 4
                   mov     bx, word ptr dbreg&XX     ;получить смещение
                   add     eax, ebx                  ;преобразовать в
                                                     ;линейный адрес и
                   mov     dr&XX, eax                ;записать его в
                                                     ;отладочный регистр
                   endm

        ; Макрос для конкатенации бит отладочного управляющего регистра
        ; DR7. Биты R/W и LEN заносятся в AX, биты L/П - в BX

        setdr7     macro   xx
                   mov     dx, word ptr rw&xx   ;LEN в DH, R/W в DL
                   and     dx, 303h        ;из всех битов выбрать по два
                                           ; младших
                   shl     ax, 2           ;переслать предыдущие биты
                   or      al, dh          ;вставить биты длины
                   shl     ax, 2
                   or      al, dl
                   mov     dx, word ptr loc&xx  ;глобальн. флаг в DH,
                                                ;локальный - в DL
                   and     dx, 101h             ;сохранить только младшие
                                                ;биты
                   shl     bx, 1                ;вставить в регистр
                   or      bl, dh
                   shl     bx, 1
                   or      bl, dl
                   endm

        code       segment word public 'CODE'
                   assume  cs:code, ds:code

        ;******************************************************************
        ; Отладочная таблица данных, заполняемая и читаемая с помощью
        ; отладчика. Первые 4 двойных слова содержат адреса, помещаемые в
        ; отладочные регистры DR0-DR3. Последующие параграфы таблицы
        ; состоят из восьмисимвольной текстовой строки, идентифицирующей
        ; данные, расположенные в последующих 2-8 байтах
        ;******************************************************************


                   org     100h
        dbreg0     label   dword      ;данные перекрывают точку входа
        entry:     jmp     install
                   org     104h
        dbreg1     dd      0
        dbreg2     dd      0
        dbreg3     dd      0
                   db      'R/W&LEN'
        rw0        db      0
        len0       db      0
        rw1        db      0
        len1       db      0
        rw2        db      0
        len2       db      0
        rw3        db      0
        len3       db      0
                   db      'LOC/GLOB'
        loc0       db      0
        glob0      db      0
        loc1       db      0
        glob1      db      0
        loc2       db      0
        glob2      db      0
        loc3       db      0
        glob3      db      0
                   db      'L/G EXAC'
        loce       db      0
        globe      db      0,0,0,0,0,0,0

                   db      'BRKX,WHY'
        statN      db      0
        why1       db      0,0,0,0,0,0,0

                   db      'GO ADDR '
        resume     label   dword
        resoff     dw      0
        resseg     dw      0

        old1       label   dword
        old1off    dw      0
        old1seg    dw      0
        saveax     dd      0             ;память под регистр EAX


        ;******************************************************************

        go         proc
            ;Загружает данные из таблицы в отладочные регистры, переустана-
            ;вливает вектор INT 1, видоизменяет содержимое стека для
            ;последующего вызова IRETD с установкой флага возобновления,
            ;затем осуществляет переход по адресу, определенному как
            ;адрес возобновления выполнения отлаживаемой программы
        ;******************************************************************

                   .386p
                   push    ebx
                   push    dx
                   push    ds
                   push    es
                   mov     cs:saveax, eax  ;сохранить EAX вместо push
                   mov     ax, cs
                   mov     ds, ax
                   mov     ax, 3501h       ;сохранить вектор INT 1
                   int     21h
                   mov     old1off, bx
                   mov     old1seg, es
                   lea     dx, new1
                   mov     ax, 2501h       ;переустановить вектор INT 1
                   int     21h

                   xor     ebx, ebx
                   mov2dreg  0         ;занести адреса в отладочные регистры
                   mov2dreg  1         ;DB0-DB3
                   mov2dreg  2
                   mov2dreg  3

                   xor     ax, ax      ;заполнить управляющий регистр DR7
                   mov     bx, ax
                   mov     bx, word ptr loce   ;loce->bl,globe->bh
                   and     bx, 101h            ;берем только по одному
                                               ;младшему биту
                   shl     bl, 7               ;собираем в bx биты 1 и 2
                   shr     bx, 7
                   setdr7  3
                   setdr7  2
                   setdr7  1
                   setdr7  0
                   shl     eax, 16     ;объединяем AX, BX в 32 бита
                   or      eax, ebx
                   mov     dr7, eax    ;загружаем управляющий регистр
                   xor     eax, eax
                   mov     dr6, eax    ;обнуляем регистр состояния

                   pop     es
                   pop     ds
                   pop     dx
                   pop     ebx
                   pushfd              ;получаем 32-разрядный регистр
                                       ;флагов в EAX
                   pop     eax
                   or      eax, 10000h    ;устанавливаем флаг возобновления
                   push    eax            ;флаги помещаем в стек
                   push    0              ;дополняем адрес возврата до 32 бит
                   push    cs:resseg      ;32-разрядное значение CS
                   push    0              ;32-разрядное значение IP
                   push    cs:resoff
                   mov     eax, cs:saveax ;все регистры восстановлены
                   iretd                  ;переход по адресу возобновления
        go         endp

        ;*******************************************************************

        new1       proc
           ; Новый обработчик прерывания INT 1: записывает содержимое
           ; отладочного регистра состояния DR6 в поля таблицы данных,
           ; затем осуществляет вход в обработчик прерывания, принадлежащий
           ; отладчику
        ;*******************************************************************

                   assume  cs:code, ds:nothing
                   sti
                   push    eax
                   mov     eax, dr6
                   and     al, 0fh        ;загружаем 4 бита: какой из
                                          ;адресов вызвал прерывание?
                   mov     cs:statN, al
                   shr     ah, 5          ;3 старших бита: причина INT 1
                   mov     cs:why1, ah
                   pop     eax
                   jmp     cs:old1
        new1       endp

        ;*******************************************************************
        install    proc
            ; Печать сообщения и "выход+остаться резидентом" без каких-либо
            ; других действий
        ;*******************************************************************
                   assume  cs:code, ds:code
                   xor     ax, ax
                   mov     ds:100h, ax  ;инициализировать начало таблицы
                   mov     ds:102h, ax  ;данных
                   mov     ax, cs       ;преобразовать адреса в
                   lea     di, raddr$   ;символьный вид
                   call    ax2hex
                   lea     ax, dbreg0
                   add     di, 5
                   call    ax2hex
                   mov     ax, cs
                   lea     di, gaddr$
                   call    ax2hex
                   lea     ax, go
                   add     di, 5
                   call    ax2hex
                   lea     dx, msg$     ;выдать на экран сообщение
                   mov     ah, 9
                   int     21h
                   lea     dx, install  ;выйти и остаться резидентом
                   int     27h
        install    endp

        msg$       db      'Программа DB386 Copyright (c) 1988 '
                   db      'PC Tech Journal and Ziff-Davis Publishing Co.'
                   db      10, 13, 'Написана Тедом Мирецки', 10, 10, 13
                   db      'Таблица данных находится по адресу '
        raddr$     db      'xxxx:xxxx', 10, 13
                   db      'Адрес запуска '
        gaddr$     db      'xxxx:xxxx', 10, 13, '$'
        code       ends

        ;******************************************************************
        ;Программа ax2hex осуществляет преобразование слова, содержащегося
        ;в регистре АХ, в символьный вид: 4 шестнадцатеричные цифры
        ;     Входные данные: ES:DI -> четырехбайтовое поле
        ;     Информация в АХ не сохраняется, другие регистры не изменяются
        ;******************************************************************
        code       segment word public 'CODE'
                   assume  cs:code
        ax2hex     proc    near
                   push    cx
                   push    di
                   mov     cx, 4       ;счетчик цифр
                   cld

        nextbyte:  rol     ax, 4       ;старшие 4 бита -> в младшие
                   push    ax
                   and     al, 0fh     ;оставляем только младшие 4 бита
                   or      al, 30h     ;преобразуем в ASCII
                   cmp     al, 39h     ;полученная цифра > 9?
                   jbe     storit
                   add     al, 7       ;3aH -> 41H и т.д.
        storit:    stosb               ;запись в сроку
                   pop     ax
                   loop    nextbyte

                   pop     di
                   pop     cx
        exit:      ret
        axtohex    endp
        code       ends
                   end     entry
        ;******************************************************************

