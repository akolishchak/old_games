      .MODEL tiny
      .CODE
      .STARTUP

      xor ax,ax
      mov es,ax
      cli
      mov word ptr es:[70h],offset int1c
      mov word ptr es:[72h],cs
      sti
      mov dx,offset q
      int 27h
int1c proc far
      iret
int1c endp
q     proc near
q     endp

      end
