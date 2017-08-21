.286
code      segment   para      public
          assume    cs:code,ds:code,es:code

          org       100h

start:    jmp       install

intXXh    proc
          cmp       ah,3dh
          jne       runint
          push      si
          push      ax
          push      dx
          mov       si,dx
next00:   cmp       byte ptr [si],0
          je        next01
          inc       si
          jmp       short next00
next01:   mov       byte ptr [si],'$'
          push      si
          push      ax
          mov       ah,9
          int       21h
          pop       ax


          mov       dl,al
          mov       ah,2
          int       21h

          mov       ah,2
          mov       dl,13
          int       21h
          mov       dl,10
          int       21h
;          mov       ah,07
;          int       21h

          pop       si
          mov       byte ptr [si],0

          pop       dx
          pop       ax
          pop       si


          push      ds ax bx si dx es
          add       bx,2
          mov       ax,es:[bx]
          mov       si,ax
          mov       es,es:[bx+2]
          mov       dx,si
          inc       dx
          mov       bx,es:[si]
          mov       byte ptr ds:[bx],'$'
          mov       ax,es
          mov       ds,ax
          mov       ah,9
          int        21h

          pop       es dx si bx ax ds


          pushf
          call      cs:[_int]
          iret


runint:
          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
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
