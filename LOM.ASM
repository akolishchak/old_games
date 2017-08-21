; get INT 1 vector
;----------------------------------
        .MODEL tiny
        .CODE
        .STARTUP
;---------------------------------
        xor     ax,ax
        mov     ds,ax
        mov     si,4
        mov     di,offset vect
        mov     cx,4
;        cld
        movsb

        mov     ah,9
        mov     dx,offset vect
        int     21h
;---------------------------------
vect    db      0,0,0,0,"$"
;---------------------------------
        end
