.286
code      segment   para      public
          assume    cs:code,ds:code,es:code

          org       100h

start:    jmp       install

intXXh    proc

          cmp       ah,09h
          jne       runint
          push      si
          push      ax
          push      dx
next01:   mov       dx,offset mes
          mov       ah,9
          pushf
          call      cs:[_int]
          iret


runint:
          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
mes       db        13,10,"€ƒ€  !!!!!!",13,10,"$"


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
