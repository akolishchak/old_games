;
;  Драйвер электронного диска
;  использует основную память компьютера
;
    segment _TEXT para public
    assume  cs:_TEXT,ds:_TEXT
    org 0

ramdisk  proc     far

; Заголовок драйвера
         dd       0ffffffffh        ; адрес следующего драйвера
         dw       2000h             ; байт атрибутов
         dw       dev_strategy      ; адрес процедуры стратегии
         dw       dev_interrupt     ; адрес процедуры прерывания
         db       1
         db       7 dup(?)
; блок BPB для электроннго диска
bpb      equ      $
         dw       512               ; кол-во байт в секторе
         db       1                 ; кол-во секторов в кластере
         dw       1                 ; кол-во зарезервировааных секторов
         dw       2                 ; кол-во копий FAT
         dw       64                ; макс. кол-во файлов в корн. каталоге
         dw       360               ; общее кол-во секторов
         db       0fch              ; описатель среды носителя данных
         dw       2                 ; кол-во секторов на одну копию FAT
bpb_ptr  dw       bpb               ; указатель на блок BPB
; Область локальных переменных драйвера
total     dw       ?                ; кол-во секторов
verify    db       0                ; флаг проверки при записи
start_sec dw       0                ; номер начального сектора
vdisk_ptr dw       0                ; сегмент начала участка памяти,
                                    ; в котором расположен диск
user_dta  dw       ?                ; адрес области передачи данных
          dw       ?
;  Образец записи BOOT для инициализации
;  первого сектора диска
boot_rec  equ      $
          db       3 dup(0)
          db       'MSDOS6.2'
          dw       512
          db       1
          dw       1
          db       2
          dw       64
          dw       360
          db       0fch
          dw       2
;--------------------------------------------------
; Программа стратегии
dev_strategy:
           mov     cs:req_seg,es
           mov     cs:req_off,bx
           ret
req_seg    dw      ?
req_off    dw      ?
;---------------------------------------------------
; Обработчик прерывания
dev_interrupt:
            push   es
            push   ds
            push   ax
            push   bx
            push   cx
            push   dx
            push   si
            push   di
            push   bp

            mov    ax,cs:req_seg
            mov    es,ax
            mov    bx,cs:req_off
            mov    al,es:[bx]+2;
            shl    al,1
            sub    ah,ah
            lea    di,functions
            add    di,ax
            jmp word ptr [di]

functions   label  dword
            dw     initialize
            dw     check_media
            dw     make_bpb
            dw     ioctl_in
            dw     input_data
            dw     nondestruct_in
            dw     input_status
            dw     clear_input
            dw     output_data
            dw     output_verify
            dw     output_status
            dw     clear_output
            dw     ioctl_out
            dw     Device_open
            dw     Device_close
            dw     Removable_media

ioctl_in:
nondestruct_in:
input_status:
clear_input:
output_status:
clear_output:
ioctl_out:
Removable_media:
Device_open:
Device_close:
            or     es:word ptr [bx]+3,8103h
            jmp    quit
;---------------------------------------------------------
; Построение блока BPB
make_bpb:
            push   es
            push   bx

            mov    cs:word ptr start_sec,0
            mov    cs:word ptr total,1
            call   calc_adr

            push   cs
            pop    es
            lea    di,bpb
            add    si,11
            mov    cx,13
            rep    movsb

            pop    bx
            pop    es
            lea    dx,bpb
            mov    es:18[bx],dx
            mov    es:20[bx],cs

            jmp    quit

check_media:
; Проверка смены носителя данных.
; Носитель не менялся.
            mov    es:byte ptr 14[bx],1
            jmp    quit

; Обработчик команды вывода данных
output_verify:
; Для вывода с проверкой устанавливаем флаг проверки
            mov    cs:byte ptr verify,1
output_data:
             call  in_save
             mov   ax,es:word ptr 20[bx]
             mov   cs:start_sec,ax
             mov   ax,es:word ptr 18[bx]
             mov   cs:total,ax

             call  sector_write

             mov   es,cs:req_seg
             mov   bx,cs:req_off

             cmp   cs:byte ptr verify,0
             jz    no_verify

             mov   cs:byte ptr verify,0
             jmp   input_data
no_verify:
             jmp   quit
;-----------------------------------------------------
; Обработчик команды ввода данных
input_data:
             call   in_save
             mov    ax,es:word ptr 20[bx]
             mov    cs:start_sec,ax

             mov    ax,es:word ptr 18[bx]
             mov    cs:total,ax

             call   sector_read

             mov    es,cs:req_seg
             mov    bx,cs:req_off

             jmp    quit
;------------------------------------------------------
quit:
             or     es:word ptr [bx]+3,100h

             pop    bp
             pop    di
             pop    si
             pop    dx
             pop    cx
             pop    bx
             pop    ax
             pop    ds
             pop    es
             ret
;-------------------------------------------------------
dpc      proc     near
         push     si
dpc_loop:
         cmp      ds:byte ptr [si],0
         jz       end_dpc
         mov      dl,ds:byte ptr [si]
         mov      ah,02h
         int      21h

         inc      si
         jmp      dpc_loop
end_dpc:
         pop      si
         ret
dpc      endp

hello    db       13,10,'Low memory RAMDISK',13,10,0
;------------------------------------------------------------
; Сохранение адреса буфера и значения счетчика
; из области запроса в облости локальных данных

in_save  proc     near

         mov       ax,es:word ptr 14[bx]
         mov       cs:user_dta,ax
         mov       ax,es:word ptr 16[bx]
         mov       cs:user_dta+2,ax
         mov       ax,es:word ptr 18[bx]
         xor       ah,ah
         mov       cs:total,ax
         ret
in_save  endp
; Процедура пересчитывает адрес сектора
; в адрес соответствующего блока памяти.
; В регистре DS возвращается
; сегментный адрес этого блока,
; в CX - общее кол-во байт во всех секторах.
; Количество секторов задается в total,
; номер начального сектора - в start_sec

calc_adr  proc       near

          mov        ax,cs:start_sec
          mov        cx,20h
          mul        cx

          mov        dx,cs:vdisk_ptr
          add        dx,ax
          mov        ds,dx

          xor        si,si
          mov        ax,cs:total
          mov        cx,512
          mul        cx

          or         ax,ax
          jnz        move_it

          mov        ax,0ffffh
move_it:
          xchg       cx,ax
          ret
calc_adr  endp
; Чтение сектора из памяти виртуального диска

sector_read   proc   near

          call       calc_adr
          mov        es,cs:user_dta+2
          mov        di,cs:user_dta

          mov        ax,di
          add        ax,cx
          jnc        read_copy
          mov        ax,0ffffh
          sub        ax,di
          mov        cx,ax
read_copy:
          rep movsb
          ret
sector_read   endp
; Запись сектора в память виртуального диска

sector_write  proc   near

          call       calc_adr
          push       ds
          pop        es
          mov        di,si
          mov        ds,cs:user_dta+2
          mov        si,cs:user_dta

          mov        ax,si
          add        ax,cx
          jnc        write_copy
          mov        ax,0ffffh
          sub        ax,si
          mov        cx,ax
write_copy:
          rep movsb
          ret
sector_write  endp
;--------------------------------------------------------
E_O_P:                              ; Метка конца программы
;--------------------------------------------------------
initialize:
          push       cs
          pop        dx
; Начало памяти, в которой расположен диск
          lea        ax,cs:vdisk

          mov        cl,4
          ror        ax,cl
          add        dx,ax
          mov        cs:vdisk_ptr,dx
; Размер памяти, отведенной для диска
          mov        ax,2d00h

          add        dx,ax
; Записываем в область запроса адрес за
; концом области памяти, отведенной диску
          mov        es:word ptr [bx]+14,0
          mov        es:word ptr [bx]+16,dx
; Количество поддерживаемых логических дисков равно 1
          mov        es:word ptr [bx]+13,1
; Возвращаем адрес построенного BPB
          lea        dx,bpb_ptr
          mov        es:word ptr [bx]+18,dx
          mov        es:word ptr [bx]+20,cs
; Инициализируем загрузочный сектор
          mov        es,cs:vdisk_ptr
          xor        di,di
          lea        si,boot_rec
          mov        cx,24
          rep        movsb
; Обнуляем два сектора для FAT
          mov        cs:word ptr start_sec,1
          mov        cs:word ptr total,2
          call       calc_adr

          push       ds
          pop        es
          mov        di,si
          xor        al,al
          rep        stosb
; Подготавливаем первую копию FAT
          mov        ds:byte ptr [si],0fch
          mov        ds:byte ptr 1[si],0ffh
          mov        ds:byte ptr 2[si],0ffh
; Подготавливаем вторую копию FAT
          push       ds
          push       si
          mov        cs:word ptr start_sec,3
          mov        cs:word ptr total,2
          call       calc_adr

          push       ds
          pop        es
          mov        di,si

          pop        si
          pop        ds

          rep        movsb
; Записываем нули в секторы корневого каталога
          mov        cs:word ptr start_sec,5
          mov        cs:word ptr total,4
          call       calc_adr

          xor        al,al
          push       ds
          pop        es
          xor        di,di
          rep        stosb
; Вывводим сообщение
          mov        ax,cs
          mov        ds,ax
          mov        si,offset hello
          call       dpc

          jmp        quit
; Здесь начинается область данных, в которой
; расположен злектронный диск. Эта область
; выравнена на границу параграфа.
          align      16
vdisk     equ        $

ramdisk   endp
          ends       _TEXT
          end        ramdisk



