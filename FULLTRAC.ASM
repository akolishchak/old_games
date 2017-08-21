;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒▒                                                  ▒▒
;▒▒  Эта программа переводит процессор в Debug mode  ▒▒
;▒▒  и котролирует команды, которые могут изменить   ▒▒
;▒▒  флаг отладки TF  (iret,popf,int).               ▒▒
;▒▒                       (C)  4.9.96                ▒▒
;▒▒                                                  ▒▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
        MODEL tiny
        .CODE
        .STARTUP

        jmp     main
int1    proc

        mov     cs:m_bp,bp
        mov     cs:m_es,es
        mov     cs:m_si,si
        mov     cs:m_ax,ax

        mov     bp,sp
        xor     ax,ax
        mov     si,[bp]
        mov     es,[bp+2]
        ; проверка на команду, изменяющую 2-ой (старший) байт флагов
comp:
        cmp     byte ptr es:[si],0cfh
        je      c_iret
        cmp     byte ptr es:[si],09dh
        je      c_popf
        cmp     byte ptr es:[si],066h    ; префикс 32-го кода
        jne     int_comp
        inc     si
        mov     ax,0ffffh
        jmp  short comp
int_comp:
        cmp     byte ptr es:[si],0cdh
        je      c_int
        jmp  short pass
c_iret:
        or      ax,ax                    ; 32 code ?
        jnz     c_iretd
        mov     si,11
        jmp  short store
c_iretd:
        mov     si,21
        jmp short store
c_popf:
        or      ax,ax
        jnz     c_popfd
        mov     si,7
        jmp short store
c_popfd:
        mov     si,13
        jmp  short store
c_int:
        inc     si
        xor     ax,ax
        mov     al,es:[si]
        shl     al,1
        shl     al,1
        xor     si,si
        mov     si,ax
        xor     ax,ax
        mov     es,ax
        mov     ax,es:[si]
        mov     word ptr cs:OldHandler,ax
        mov     ax,es:[si+2]
        mov     word ptr cs:OldHandler+2,ax
        cli
        mov     es:[si],offset handler
        mov     es:[si+2],cs
        sti
        mov     cs:num,si
        jmp  short pass

store:
        or      byte ptr [bp+si],1
pass:
    ; индикация
        mov     ax,0b800h
        mov     es,ax
        inc     cs:count
        mov     al,cs:count
        mov     es:[0],al

        mov     bp,cs:m_bp
        mov     es,cs:m_es
        mov     si,cs:m_si
        mov     ax,cs:m_ax

        iret

m_bp    dw      0
m_es    dw      0
m_si    dw      0
m_ax    dw      0
count   db      0
num     dw      0
OldHandler dd   0

int1    endp

handler  proc

        mov     cs:m2_bp,bp
        mov     cs:m2_es,es
        mov     cs:m2_si,si
        mov     cs:m2_ax,ax

        mov     bp,sp
        or      byte ptr [bp+5],1
        mov     si,cs:num
        xor     ax,ax
        mov     es,ax

        cli
        mov     ax,word ptr cs:OldHandler
        mov     es:[si],ax
        mov     ax,word ptr cs:OldHandler+2
        mov     es:[si+2],ax
        sti

        pushf
        pop     ax
        or      ah,1
        push    ax
        popf

        mov     bp,cs:m2_bp
        mov     es,cs:m2_es
        mov     si,cs:m2_si
        mov     ax,cs:m2_ax

        jmp dword ptr cs:OldHandler

m2_bp    dw      0
m2_es    dw      0
m2_si    dw      0
m2_ax    dw      0

handler  endp


main:
;        int     7dh
        mov     ax,ds:[2ch]
        mov     es,ax
        mov     ah,49h
        int     21h

        mov     ah,9
        mov     dx,offset hello
        int     21h


        mov     dx,offset int1
        mov     ax,2501h
        int     21h

; set debug mode

        pushf
        pop     ax
        or      ah,1
        push    ax
        popf

;saaaa:   jmp     saaaa

        mov     dx,offset main
        shr     dx,1
        shr     dx,1
        shr     dx,1
        shr     dx,1
        inc     dx
        mov     ah,31h
        int     21h
hello   db      'Установка Debug mode',13,10,36
        end


