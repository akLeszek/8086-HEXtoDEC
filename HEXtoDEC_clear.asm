Progr   segment
        assume  cs:Progr, ds:dane, ss:stosik

start:
        mov ax,dane
        mov ds,ax
        mov ax,stosik
        mov ss,ax
        mov sp,offset szczyt
again:
        call wyczysc_bufor

        mov ah,09h
        lea dx,Tekst1
        int 21h

        mov ah,0Ah
        lea dx,hex
        int 21h

        lea si,hex+2
        mov bh,[si-1]
        call hex2number

        lea si,bufor
        call number2string

        mov ah,09h
        lea dx,Tekst2
        int 21h

        mov ah,09h
        lea dx,bufor
        int 21h

blad:
        mov ah,09h
        lea dx,Tekst3
        int 21h

        mov ah,1
        int 21h
        cmp al,'t'
        je again
        cmp al,'T'
        je again

        mov ah,4ch
        mov al,0
        int 21h

wyczysc_bufor proc
        lea si,bufor
        mov al,'$'
        mov cx,5
czyszczenie:
        mov [si],al
        inc si
        loop czyszczenie

        ret
wyczysc_bufor endp

hex2number proc
        mov ax,0
petla:
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1

        mov bl,[si]

        call sprawdzenie

        cmp bl,'A'
        jae literaAF
        
        sub bl,48
        jmp skokLiczba
literaAF:
        sub bl,55
skokLiczba:
        or al,bl
        inc si
        dec bh
        jnz petla
koniec:
        ret
hex2number endp

sprawdzenie proc
        cmp bl,'0'
        jb error
        cmp bl,'F'
        ja error
        cmp bl,'9'
        jbe good
        cmp bl,'A'
        jae good
error:
        pop ax
        pop ax

        mov ah,09h
        lea dx,Tekst4
        int 21h
        jmp blad
good:
        ret
sprawdzenie endp

number2string proc
        mov bx,10
        mov cx,0
petla1:
        mov dx,0
        div bx
        push dx
        inc cx
        cmp ax,0
        jne petla1

        lea si,bufor
petla2:
        pop dx
        add dl,48
        mov [si],dl
        inc si
        loop petla2

        ret
number2string endp

Progr   ends

dane    segment
        Tekst1 db 10,13,10,13, 'WPROWADZ 1 DO 4 WARTOSCI HEX:$'
        Tekst2 db 10,13, 'WARTOSC W SYSTEMIE DZIESIETNYM: $'
        Tekst3 db 10,13,10,13, 'CZY CHCESZ WYKONAC PONOWNIE (T/N)?$'
        Tekst4 db 10,13, 'NIEPRAWIDLOWA WARTOSC - WPROWADZ 0-9 LUB A-F:$'

        hex db 5,?,5 dup(?)
        bufor db 6 dup('$')

dane    ends

stosik  segment stack
        dw 100h dup(0)
szczyt  Label word
stosik  ends
end start