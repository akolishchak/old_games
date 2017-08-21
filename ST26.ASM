
        .MODEL tiny
        .CODE
        .STARTUP
;       The VGA identification

        mov     ax,1a00h
        int     10h
        cmp     al,1ah
        je      eli
        ret

;       The extra line installation

eli:    mov     ax,1212h
        mov     dx,3d4h
        out     dx,al
        inc     dx
        in      al,dx
        add     al,10h
        xchg    al,ah
        dec     dx
        out     dx,ax
        add     ah,6
        mov     al,10h
        out     dx,ax
        mov     al,15h
        out     dx,ax

        ret

        end
