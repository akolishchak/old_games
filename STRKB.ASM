        MODEL tiny
        .CODE
        .386p
        .STARTUP
vect    equ     9h

        jmp     main
prob    dd      0
int1    proc
        push    es
        push    eax

        mov     eax,dr6
        bt      eax,2
        jnc     steeps

        xor     eax,eax
        mov     dr6,eax

        mov     ax,0b800h
        mov     es,ax
        mov     al,cs:zn
        mov     byte ptr es:[480],al
        inc     cs:zn

        xor     eax,eax             ; запрещаем АКТ
        mov     dr7,eax

        mov     ax,si
        mov     si,sp               ; set steeps
        add     si,11
        or      byte ptr ss:[si],00000001b
        mov     si,ax
        jmp intexit
steeps:
;        mov     ax,40h
;        mov     es,ax
;        or      byte ptr es:[17h],00010000b
        xor     eax,eax
        mov     dr6,eax

        mov     ax,0b800h
        mov     es,ax
        mov     al,cs:zn
        mov     byte ptr es:[800],al
        inc     cs:zn
;        cmp     cs:zn,110
;        jne     intexit0
        mov     cs:m_si,si
        mov     si,sp
        add     si,11
        test    byte ptr ss:[si],00000010b
        jz      intexit0

        xor     si,si
        mov     es,si
        mov     eax,dword ptr es:[4*vect]
        mov     cs:prob,eax
        mov     dword ptr cs:oldXXo,eax

        mov     ax,offset int9
        mov     word ptr es:[4*vect],ax
        mov     ax,cs
        mov     word ptr es:[4*vect+2],ax

        mov     si,sp
        add     si,11
        and     byte ptr ss:[si],11111110b
        mov     eax,cs:m_dr2
        mov     dr2,eax
        mov     eax,cs:m_dr7
        mov     dr7,eax
        mov     si,cs:m_si
        jmp     intexit

intexit0:
        mov     si,cs:m_si
        pop     eax
        pop     es
        iret

intexit:
        pop     eax
        pop     es
;        iret

        mov     cs:m_bx,bx
        mov     cs:m_dx,dx
        mov     cs:m_eax,eax

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

        mov     bx,cs:m_bx
        mov     dx,cs:m_dx
        mov     eax,cs:m_eax

        iretd

zn      db      1
m_bx    dw      0
m_dx    dw      0
m_eax   dd      0
m_dr7   dd      0
m_dr2   dd      0
m_si    dw      0
sab     db      0
int1    endp
int9    proc
;        cmp     cs:flag,1
;        jne     no_fl
;
;        mov     cs:flag,0
;        db      0eah
;_ofs    dw      0
;_seg    dw      0
;
;no_fl:
        pushf
        push    ax
        push    dx

        in      al,60h                  ; port 60h, keybd scan or sw1

        cmp     al,46h                  ; 'S'
        jne     runint
;---------------------------
;        xor     cs:flg,01h
;        mov     al,cs:flg
;        mov     ah,12h
;        mov     bl,36h
;        int     10h

        mov     dx,3c4h
        mov     al,1
        out     dx,al
        jmp short $+2
        mov     dx,3c5h
        in      al,dx
        jmp short $+2
        xor     al,00100000b
        mov     ah,al
        mov     dx,3c4h
        mov     al,1
        out     dx,al
        jmp short $+2
        mov     dx,3c5h
        mov     al,ah
        out     dx,al
        jmp short $+2

runint:
        pop     dx
        pop     ax
        call    cs:[_int]
        iret

          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
flg       db        0
flag      db        0
int9    endp

main    proc
        mov     ah,9
        mov     dx,offset hello
        int     21h
;
; set int1 and int9
;
        mov     dx,offset int1
        mov     ax,2501h
        int     21h

        mov     ax,3509h
        int     21h
        mov     CS:oldXXo,BX
        mov     CS:oldXXs,ES
;        mov     cs:_ofs,bx
;        mov     cs:_seg,es

        mov     ax,cs
        mov     ds,ax
        mov     ax,2509h
        mov     dx,offset int9
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
         mov     eax,4*vect
         mov     cs:m_dr2,eax
         mov     dr2,eax

         xor     ax,ax
         mov     es,ax
         mov     al,byte ptr es:[4*vect]
         mov     sab,al

;
; set point
;
        mov     eax,0d000330h
        mov     cs:m_dr7,eax
        mov     dr7,eax
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
        mov     ax,3100h
        int     21h
;-----------------------------------
hello   db      'Контрольная точка по данным',13,10,36
wdata   db      0
;-----------------------------------

main    endp
        end

