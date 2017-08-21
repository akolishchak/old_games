Rec     struc
        _al  db  0
        _cx  dw  0
        _dh  db  0
Rec     ends
max     equ      2000


        MODEL tiny
        .CODE
        .STARTUP

        jmp     main
int13   proc
        cmp     ah,3
        jne     int13_pass

        cmp     cs:count,max*4-4
        jge     int13_pass
        add     cs:count,4
        push    bx
        mov     bx,offset buf
        add     bx,cs:count
        mov     cs:bx._al,al
        mov     cs:bx._cx,cx
        mov     cs:bx._dh,dh
        pop     bx

int13_pass:
        jmp  dword ptr cs:old13

old13   dd      0
count   dw      -4

int13   endp

main:
        mov     es,ds:[2ch]
        mov     ah,49h
        int     21h

; создаем файл  'c:\mem.###'

        mov    ah,3ch
        mov    cx,2
        mov    dx,offset fname1
        int    21h
        mov    handler,ax

; вешаем обработчик на int 13h
        mov     ax,3513h
        int     21h

        mov     word ptr old13,bx
        mov     word ptr old13+2,es

        mov     dx,offset int13
        mov     ax,2513h
        int     21h

; записываем 1M
        mov     cx,16
loop1:
        push    cx
        mov     ah,40h
        mov     bx,handler
        mov     cx,0ffffh
        int     21h
        mov     ah,40h
        mov     bx,handler
        mov     cx,1
        int     21h
        pop     cx
        loop    loop1


        mov     ah,40h
        mov     bx,handler
        mov     cx,0
        int     21h

        mov     ah,3eh
        mov     bx,handler
        int     21h
; восстанавливаем int 13h
        push    ds
        mov     ax,2513h
        mov     dx,word ptr old13
        mov     ds,word ptr old13+2
        int     21h
        pop     ds

        mov     ah,3ch
        mov     cx,2
        mov     dx,offset fname2
        int     21h
        mov     handler,ax

        mov     cx,count
        add     cx,4
        xor     si,si
loop2:
        push    cx
        mov     ah,40h
        mov     bx,handler
        mov     dx,offset buf
        add     dx,si
        int     21h
        pop     cx
        loop    loop2

        mov     ah,3eh
        mov     bx,handler
        int     21h

exit:
        mov     ax,4c00h
        int     21h

fname1  db      'c:\mem.###',0
fname2  db      'c:\reg.###',0
handler dw      0
buf     Rec     max   dup(<0,0,0>)

        end


