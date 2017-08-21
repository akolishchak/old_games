.286
code      segment   para      public
          assume    cs:code,ds:code,es:code

          org       100h

start:    jmp       install

int13h    proc

        pusha
        mov     ax,ds
        mov     cs:mds,ax
        mov     ax,es
        mov     cs:mes,ax

        mov     ax,ss
        mov     ds,ax
        mov     si,sp
        mov     ax,cs
        mov     es,ax
        mov     di,offset buff
        mov     ax,20
        mov     bx,cs:count
        mul     bx
        add     di,ax
        mov     cx,10
        cld
        rep  movsw

        mov     ax,cs:mds
        mov     ds,ax
        mov     ax,cs:mes
        mov     es,ax
        popa

        inc     cs:count

runint13:
          db        0EAh
old13o    dw        0
old13s    dw        0
;---------------------------------
buff    db    1000h  dup(0)
mds     dw    0
mes     dw    0
count   dw    0
handle  dw    0
;----------------------------------
int13h    endp

int21h    proc

          or      cs:count,0
          jz      runint21
          push    ax
          push    bx
          push    cx
          push    dx
          push    ds

          push    cs
          pop     ds

          mov     ax,3d02h
          mov     dx,offset fname
          pushf
          call    cs:[_int]
          jnc     quit01

          mov     ah,3ch            ;
          mov     cx,02             ;\
          mov     dx,offset fname   ; если ошибка, создать файл
          pushf                     ;/
          call    cs:[_int]         ;
          jc      pass

quit01:
          mov     handle,ax  ;
          mov     bx,ax      ; \
          mov     ax,4202h   ;   указатель на конец
          xor     cx,cx      ;   файла
          xor     dx,dx      ; /
          pushf
          call    cs:[_int]
          jc      pass

          mov     dx,offset buff
          mov     ax,20
          mov     bx,cs:count
          mul     bx
          mov     cx,ax

          mov     ah,40h
          mov     bx,handle
          mov     dx,offset buff
          pushf
          call    cs:[_int]

pass:
          mov     cs:count,0

          pop     ds
          pop     dx
          pop     cx
          pop     bx
          pop     ax

runint21:
          db        0EAh
_int      label     dword
old21o    dw        0
old21s    dw        0
;---------------------------------------------
mesg      db        13,10,"INT 13H",13,10,"$"
fname     db        "c:\int13hac.dat",0
;---------------------------------------------
int21h    endp


■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
install   proc      near

          push      ES
          mov       AX,DS:[2Ch]
          mov       ES,AX
          mov       AH,49h
          int       21h
          pop       ES

          push      DS
          push      ES
          mov       AX,3513h                    ;****** edit here ****
          int       21h

          mov       CS:old13o,BX
          mov       CS:old13s,ES

          cli
          mov       AX,CS
          mov       DS,AX

          lea       DX,int13h
          mov       AX,2513h                    ;***** edit here ******
          int       21h
          sti

          mov       AX,3521h                    ;****** edit here ****
          int       21h

          mov       CS:old21o,BX
          mov       CS:old21s,ES

          cli
          mov       AX,CS
          mov       DS,AX

          lea       DX,int21h
          mov       AX,2521h                    ;***** edit here ******
          int       21h
          sti

          pop       ES
          pop       DS

          mov       DX,offset install
          int       27h

install   endp
code      ends
          end       start
