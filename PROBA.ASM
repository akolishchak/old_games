        cseg segment
        assume cs:cseg,ds:cseg,es:cseg
        org 100h
main:
        mov     ah,7
        int     21h
        int     20h

        cseg ends
        end main
