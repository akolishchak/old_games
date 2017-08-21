          .MODEL tiny
          .CODE
          .STARTUP
start:    jmp       install

intXXh    proc

          pushf
          call cs:_int
          cmp       fl,1
          je        by

          mov       fl,1
          mov       ax,101bh
          mov       bx,0
          mov       cx,256
          int       10h
          mov       fl,0

by:       iret

;          pushf
;          call cs:_int
;          iret

fl        db        00h
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

;          mov       ax,101bh
;          mov       bx,0
;          mov       cx,256
;          int       10h

          push      DS
          push      ES
          mov       AX,3510h                    ;****** edit here ****
          int       21h

          mov       CS:oldXXo,BX
          mov       CS:oldXXs,ES

          cli
          mov       AX,CS
          mov       DS,AX

          lea       DX,intXXh
          mov       AX,2510h                    ;***** edit here ******
          int       21h
          sti

          pop       ES
          pop       DS

          mov       DX,offset install
          int       27h

install   endp
          end
