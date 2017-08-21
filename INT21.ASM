        .MODEL tiny
        .CODE
        .STARTUP

        xor    ax,ax
        mov    es,ax
        cli
        mov    ax,word ptr es:[84h]
        mov    word ptr es:[1f4h],ax
        mov    ax,word ptr es:[86h]
        mov    word ptr es:[1f6h],ax
        mov    word ptr es:[84h],offset int21
        mov    es:[86h],cs
        sti
        mov    dx,offset q
        int    27h

int21   proc   far
        int    7dh
        retf   2
int21   endp

q       proc   near
q       endp
        end
