        MODEL tiny
        .CODE
        .386p
        .STARTUP

        jmp     main
int1    proc
        push    es
        push    eax

        mov     eax,dr6
        bt      eax,2
        jnc     intexit

        xor     ax,ax
        mov     es,ax
        mov     al,sab
        cmp     byte ptr es:[4*7dh],al
        je      intexit

        mov     ax,0b800h
        mov     es,ax
        mov     al,cs:zn
        mov     byte ptr es:[320],al
        inc     cs:zn

intexit:
        pop     eax
        pop     es
;        iret

        mov     m_bx,bx
        mov     m_dx,dx
        mov     m_eax,eax

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

        mov     bx,m_bx
        mov     dx,m_dx
        mov     eax,m_eax

        iretd

zn      db      1
m_bx    dw      0
m_dx    dw      0
m_eax   dd      0
sab     db      0
int1    endp

main    proc
        mov     ah,9
        mov     dx,offset hello
        int     21h
;
; set int1
;
        mov     dx,offset int1
        mov     ax,2501h
        int     21h

;
; calcute adress
;
        xor     eax,eax
;        mov     ax,cs
;        shl     eax,4
;        mov     edx,offset wdata
;        add     eax,edx
;        mov     dr2,eax
         mov     eax,4*7dh
         mov     dr2,eax

         xor     ax,ax
         mov     es,ax
         mov     al,byte ptr es:[4*7dh]
         mov     sab,al

;
; set point
;
        mov     eax,01000330h
        mov     ebx,dr7
        or      ebx,eax
        mov     dr7,ebx
;
; test
;
;        mov     wdata,7

        ; set debug flag

;        pushf
;        mov     si,sp
;        inc     si
;        or      byte ptr ss:[si],00000001b
;        popf
;there:
;        jmp short there
         mov     wdata,7
         mov      cx,100
mloop:
        mov     wdata,7
        loop     mloop

        mov     dx,offset main
        mov     cl,4
        shr     dx,cl
        inc     dx
        mov     ah,31h
        int     21h
;-----------------------------------
hello   db      'Контрольная точка по данным',13,10,36
wdata   db      0
;-----------------------------------

main    endp
        end

