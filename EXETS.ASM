        .MODEL small
        STACK  2048
        .DATA
        db     0
        .CODE
;        .286p
        mov   ax,DGROUP
        mov   ds,ax
        mov   ax,4c00h
        int   21h
        end
