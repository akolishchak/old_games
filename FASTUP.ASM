;
;
;
        MODEL tiny
        .CODE
        .STARTUP


          mov       ah,52h          ; получение адреса 1-го MCB
          int       21h
          sub       bx,2
          xor       di,di
          mov       dx,es:[bx]
          mov       es,dx           ; в ES
          cli
repeat:
          xor       ax,ax
          mov       es:[01],ax      ; [01] - владелец блока

next:
          mov       al,es:[00]
          cmp       al,"Z"          ; если маркер Z, то последний MCB
          je        exit
          mov       ax,es:[03]      ; переход к следующему MCB
          mov       bx,es
          add       bx,ax
          inc       bx
          mov       es,bx
          jmp       short   repeat
exit:
          int       19h

        end


