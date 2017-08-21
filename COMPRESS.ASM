;
; Проба MRCI
;
        MODEL tiny
        .CODE
        .386
        .STARTUP
max      equ        20000
;
;  подготовка буфера для компрессии
;

        mov     ax,3d00h
        mov     dx,offset fname
        int     21h
        jc      error

        mov     bx,ax
        mov     ah,3fh
        mov     cx,max
        mov     dx,offset input_buf
        int     21h

;
; подготовка к копрессии данных
;
        mov     ax,4a12h
        mov     cx,4d52h
        mov     dx,4349h
        int     2fh
        cmp     cx,4943h
        jne     error

        mov     eax,es:[di+8]
        mov     mrci_call,eax
        xor     eax,eax
        mov     ax,0001h
        mov     cx,0000h
        mov     bx,di
        mov     si,offset data_id
        mov     word ptr source_addr,offset input_buf
        mov     word ptr source_addr+2,cs
        mov     source_size,max

        mov     word ptr dist_addr,offset output_buf
        mov     word ptr dist_addr+2,cs
        mov     dist_size,max

        call    cs:[mrci_call]

        or      ax,ax
        jnz     error

        mov     ax,4c00h
        int     21h


error:
        mov     dx,offset err_msg
        mov     ah,9
        int     21H

        mov     ax,4c01h
        int     21h

err_msg      db   13,10,'Error',07,13,10,36
fname        db   'c:\-\phone\phone.dat'
mrci_call    dd      0
data_id      label   byte
source_addr  dd      0
source_size  dw      0
reserved     dw      0
dist_addr    dd      0
dist_size    dw      0
some         dw      0
some2        dd      0

input_buf    db   max dup(0)
output_buf   db   max dup(0)

        end


