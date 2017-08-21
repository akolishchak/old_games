;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
;▓▓       Вырезаловка Boot-а      ▓▓
;▓▓ (C)  TigerSoft Lab v 1.0 1996 ▓▓
;▓▓                               ▓▓
;▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
        .MODEL tiny
        .CODE
        .STARTUP

        mov    ah,09h
        lea    dx,hello
        int    21h

        mov    si,81h
scanp:
        lodsb
        cmp    al,0dh
        je     cut00
        cmp    al," "
        jne    scanp
        cmp    byte ptr [si],0dh
        je     scanp
        ; определение регистра
        lodsb
        cmp    al,61h
        jge    down
        sub    al,41h         ; верхний
        jmp    short   cut01
down:
        sub    al,61h         ; нижний
        jmp    short   cut01
cut00:
        mov   al,0            ; чтение boot
cut01:
        cmp   al,2
        jl    fd
        mov   dl,10000000b    ; hard disk
        mov   ch,0
        mov   cl,00000001b
        mov   dh,0
        mov   ax,0201h
        lea   bx,buffer
        int   13h
        jc    error
        jmp   short   keep

fd:
        mov   dx,0            ; floppy disk
        mov   cx,1
        lea   bx,buffer
        int   25h
        pop   dx
        jc    error
keep:
        mov   ah,3ch        ; запись в файл
        mov   cx,3
        lea   dx,fname
        int   21h
        jc    error
        mov   bx,ax
        mov   ah,40h
        mov   cx,512
        lea   dx,buffer
        int   21h
        jc    error

        mov   ax,4c00h
        int   21h
error:
        mov   ax,4c01h
        int   21h
;----------------------
buffer  db   512   dup(?)
hello   db   13,10,"Вырезать boot в файл : boot.dat"
        db   13,10,"Вызов :  cutboot  <дисковод>",13,10,"$"
        db   "(C) TigerSoft Lab v 1.0, 1996"
fname   db   "boot.dat",0
;----------------------
        end

