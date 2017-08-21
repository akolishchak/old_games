.286
code      segment   para      public
          assume    cs:code,ds:code,es:code

          org       100h

start:    jmp       install

intXXh    proc

          push      es
          push      ds
          push      ax
          push      bx
          push      cx
          push      dx
          push      si
          push      di

work:
          mov     ax,40h
          mov     es,ax

          test    cs:flg,00100000b
          jz      lamp_on

          and     byte ptr es:[17h],11101111b  ; lamp off
          and     cs:flg,11011111b
          jmp     short vdo

lamp_on:
          or      byte ptr es:[17h],00010000b
          or      cs:flg,00100000b
vdo:
          mov       ax,0b800h
          mov       es,ax
          inc       cs:ind
          mov       al,cs:ind
          mov       byte ptr es:[0],al

next20:
          pop       di
          pop       si
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          pop       ds
          pop       es
;          pushf
;          call      cs:[_int]

          mov     al,20h                  ; ' '
          out     0a0h,al                  ; port 20h, 8259-1 int command
          mov     al,20h
          out     20h,al
          iret


runint:
          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
ind       db        0
flg       db        0

intXXh    endp


þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
install   proc      near

          push      ES
          mov       AX,DS:[2Ch]
          mov       ES,AX
          mov       AH,49h
          int       21h
          pop       ES

          push      DS
          push      ES
          mov       AX,3521h                    ;****** edit here ****
          int       21h

          mov       CS:oldXXo,BX
          mov       CS:oldXXs,ES

          cli
          mov       AX,CS
          mov       DS,AX

          lea       DX,intXXh
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
