        .MODEL tiny
        .CODE
        .STARTUP

        jmp       install

intXXh  proc

          cmp       ah,4Bh
          jne       runint
          push      si
          push      di
          push      ax
          push      ds
          push      es

          push      dx
          mov       si,dx
next00:   cmp       byte ptr [si],0
          je        next01
          inc       si
          jmp       short next00
next01:   mov       byte ptr [si],'$'
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

          mov       byte ptr [si],0

          pop       dx

          push      cs
          pop       ds
          mov       si,(-1)
          xor       ax,ax
          mov       es,ax
repeat:
          cmp       si,(256*4)-3
          jg        thats_all
          inc       si
          mov       al,es:[si]
          xor       al,last[si]
          jz        repeat
          call      about
          jmp  short  repeat
thats_all:
          ; save  hookers
          mov       ax,ds
          mov       es,ax
          mov       di,offset last
          xor       si,si
          mov       ds,si
          mov       cx,256*4
          rep       movsb

          pop       es
          pop       ds
          pop       ax
          pop       di
          pop       si

;          pushf
;          call      cs:[_int]
;          iret


runint:
          db        0EAh
_int      label     dword
oldXXo    dw        0
oldXXs    dw        0
intXXh    endp
;-----------------------------------------
last      label     byte
          dd   256  dup(0)
decvect   db        30h,30h,13,10,"$"
hexcod    db  "0123456789ABCDEF"
;-----------------------------------------
about     proc      near

          push      ax
          push      bx
          push      cx
          push      dx
          push      ds

          push      cs
          pop       ds

          mov       ax,si
          shr       ax,1
          shr       ax,1
          mov       bl,10h
          div       bl
          mov       cx,ax
          mov       bx,offset hexcod
          mov       al,cl
          mov       ah,0
          add       bx,ax
          mov       dl,cs:[bx]
          mov       byte ptr decvect[0],dl
          mov       bx,offset hexcod
          mov       al,ch
          mov       ah,0
          add       bx,ax
          mov       dl,cs:[bx]
          mov       byte ptr decvect[1],dl

          mov       ah,09h
          mov       dx,offset decvect
          int       21h
          mov       ah,07
          int       21h

          shr       si,1
          shr       si,1
          add       si,4
          shl       si,1
          shl       si,1

          pop       ds
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret

about     endp
þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
install   proc      near

          ; save  hookers
          push      ds
          mov       di,offset last
          xor       si,si
          push      si
          pop       ds
          mov       cx,256*4
          rep       movsb
          pop       ds

          push      ES
;          mov       AX,DS:[2Ch]
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
          end

