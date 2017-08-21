
        MODEL tiny
        .CODE
        .386p
        .STARTUP

        jmp     start

int01h  proc    near

        mov     cs:s_eax,eax
        mov     cs:s_ebx,ebx
        mov     cs:s_cx,cx
        mov     cs:s_dx,dx
        mov     cs:s_si,si
        mov     cs:s_ds,ds
        mov     cs:s_es,es


        mov     ax,0b800h
        mov     es,ax
        mov     byte ptr es:[640],1


        pop     bx
        pop     dx
        popf
        pushfd
        pop     eax
        or      eax, 10000h    ;устанавливаем флаг возобновления
        push    eax            ;флаги помещаем в стек
        push    0
        push    dx
        push    0
        push    bx

        mov     eax,cs:s_eax
        mov     ebx,cs:s_ebx
        mov     cx,cs:s_cx
        mov     dx,cs:s_dx
        mov     si,cs:s_si
        mov     ds,cs:s_ds
        mov     es,cs:s_es

        iretd

;----------------------------------
s_eax   dd      ?
s_ebx   dd      ?
s_cx    dw      ?
s_dx    dw      ?
s_si    dw      ?
s_ds    dw      ?
s_es    dw      ?
int01h   endp
;------------------------------------------------------
;   Усхановка контрольной точки по обращению к данным
; Входные парамхтры:
;    EAX - Линейный адресх
;    DL  - "R" для считывания/записи и "W" для записи,
;    DH  - "B" байт
;          "W" слово
;          "D" двойное слово
; Выходные параметры :
;    Установлен бит переноса в случае ошибки
;-----------------------------------------------------
data_brkpt_set    proc    near
          mov    eax,dr7         ; считать регистр DR7
          mov    ecx,4           ; проверять 4 точки
next:     test   al,00000011b    ; бит Ln или Gn = 1?
          jz     open            ; свободная точка есть
          ror    al,2            ; проверять следующую точку
          loop   next            ; повторять, если нужно
          jmp    perror          ; все точки заняты
open:
          xor    ebx,ebx         ; сбросить рабочий регистр
type11:   cmp    dl,'R'          ; контрольная точка по RW?
          jne    type01          ; нет
          or     bl,0011b        ; временное поле RWn = 11
          jmp    size00          ; обработать размер
type01:   cmp    dl,'W'          ; контрольная точка по W?
          jne    perror          ; ошибка в параметре
          or     bl,0001b        ; временное поле RWn = 01
size00:   cmp    dh,'B'          ; размер байт?
          jne    size01
          or     bl,0000b        ; временное поле LENn = 00
          jmp    brkpt0
size01:   cmp    dh,'W'          ; размер - слово?
          jne    size11
          or     bl,0100b        ; временное поле LENn = 01
          jmp    brkpt0
size11:   cmp    dh,'D'          ; размер - двойное слово?
          jne    perror          ; ошибка в параметре
          or     bl,1100b        ; временное поле LENn = 11
          ; Теперь можно установить контрольную точку.
          ; Регистр ECX содержит 3, 2, 1 или 0 для регистров
          ;   DR0-DR3, соответственно.
          ; В регистре EAX находится 32-битный линейный адрес.
          ; В регистре BL содержатся значения полей LENn и RWn
brkpt0:   mov    eax,dr7         ; считать регистр DR7
          cmp    ecx,4
          jne    brkpt1
          mov    dr0,eax         ; передать линейный адрес
          mov    eax,dr7         ; считать регистр DR7
          and    eax,0fff0ffffh  ; пока сбросить LEN и RW
          shl    ebx,16
          or     eax,ebx         ; правильные LEN и RW
          or     eax,02h         ; установить бит G0
          jmp    pexit
          ;
brkpt1:   cmp    ecx,3
          jne    brkpt2
          mov    dr1,eax         ; передать линейный адрес
          mov    eax,dr7         ; считать регистр DR7
          and    eax,0ff0fffffh  ; пока сбросить LEN и RW
          shl    ebx,20
          or     eax,ebx         ; правильные LEN и RW
          or     eax,08h         ; установить G1
          jmp    pexit
          ;
brkpt2:   cmp    ecx,2
          jne    brkpt3
          mov    dr2,eax         ; передать линейный адрес
          mov    eax,dr7         ; считать регистр DR7
          and    eax,0f0ffffffh  ; пока сбросить LEN и RW
          shl    ebx,24
          or     eax,ebx         ; правильные LEN и RW
          or     eax,20h         ; установить G2
          jmp    pexit
          ;
brkpt3:   cmp    ecx,1
          jnz    perror
          mov    dr3,eax         ; передать линейный адрес
          mov    eax,dr7         ; считать регистр DR7
          and    eax,0fffffffh       ; пока сбросить LEN и RW
          shl    ebx,28
          or     eax,ebx         ; правильные LEN и RW
          or     eax,80h         ; установить G3
          ;
pexit:    bts    eax,9           ; установить бит GE
          mov    dr7,eax         ; модифицировать DR7

          clc                    ; сбросить флаг переноса
          ret

perror:   stc                    ; установить флаг переноса
          ret

data_brkpt_set    endp

start:
;        int     7dh
        mov     ah,9
        mov     dx,offset hello
        int     21h


        lea       DX,int01h
        mov       AX,2501h                    ;***** edit here ******
        int       21h

        mov     eax,cs
        shl     eax,4
        add     eax,offset test_dt
        mov     dr0,eax
        mov     eax,00050302h
        mov     dr7,eax
;        mov     dl,'W'
;        mov     dh,'W'
;        call    data_brkpt_set
;        jc      exit
        mov     ax,7
        mov     test_dt,ax        ;
        xor     eax,eax
        mov     dr7,eax
exit:
        mov     ax,4c00h
        int     21h

;------------------------------------------------------
hello    db      'Проверка контрольной точки по данным',13,10,36
test_dt  dw      0000h



        end

