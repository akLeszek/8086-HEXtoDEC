Progr   segment
        assume  cs:Progr, ds:dane, ss:stosik

start:
        mov ax,dane
        mov ds,ax
        mov ax,stosik
        mov ss,ax
        mov sp,offset szczyt
again:
;CZYSZCZENIE BUFORA DLA PRZYPADKU PONOWNEGO WPROWADZENIA
        call wyczysc_bufor 

;WYSWIETLA TEKST 'WPROWADZ 1 DO 4 W HEX:'
        mov ah,09h
        lea dx,Tekst1
        int 21h

;PRZECHWYTUJE WPROWADZONA WARTOSC JAKO STRING
        mov ah,0Ah
        lea dx,hex
        int 21h

;WYWOLANIE KONWERSJI HEX-STRUNG DO LICZBY
        lea si,hex+2            ;ZNAKI HEX-STRING
        mov bh,[si-1]           ;DRUGI BAJT JEST DLUZSZY
        call hex2number         ;WARTOSC WRACA W AX

;WYWOLANIE KONWERSJI 
        lea si,bufor
        call number2string      ;STRING WRACA W SI(BUFOR)
;WYSWIETLENIE 'NUMWER DZIESIETNIE:'
        mov ah,09h
        lea dx,Tekst2
        int 21h

;WYSWIETLENIE WARTOSCI JAKO STRING
        mov ah,09h
        lea dx,bufor
        int 21h

blad:                           ;SKOCZ TU JEZELI ZNALEZIONO ZŁY ZNAK

;WYSWIETL ZAPYTANIE O KONTYNUACJE PROGRAMU
        mov ah,09h
        lea dx,Tekst3
        int 21h

;PRZECHWYC KLAWISZ
        mov ah,1
        int 21h
        cmp al,'t'
        je again
        cmp al,'T'
        je again

;ZAKONCZENIE PROGRAMU
        mov ah,4ch
        mov al,0
        int 21h

;-------------------------
;WYPELNIAMY BUFOR '$'
;ZA KAZDYM RAZEM KIEDY UZYTKOWNIK CHCE WYKONAC PONOWNIE,
;BUFOR MUSI ZOSTAC WYCZYSZCZONY

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

;----------------------
;INPUT  : BH = DLUGOSC STRINGA(1...4)
;         SI = INFORMACJA O POZYCJI DANEGO HEX-STRING
;OUTPUT : AX = LICZBA


hex2number proc
        mov ax,0        ;NUMER
petla:
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;     SHL  AX, 4       
;PRZESUWAMY W LEWO CZTERY MLODSZE BITY.
;PRZSUWAMY W LEWO AL AND AH MANUALNIE 4 RAZY SYMULUJAC/DOPROWADZAJAC DO SHL AX,4.
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1
        shl al,1
        rcl ah,1
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

        mov bl,[si]     ;POBRANIE JEDNEGO ZNAKU HEX Z STRINGA

        call sprawdzenie

        cmp bl,'A'      ;BL = 'A'..'F' : LITERA
        jae literaAF    ;BL = '0'..'9' : LICZBA

;JESLI ZNAK JEST LICZBA OD 0 DO 9 TO
        sub bl,48       ;KONWERSJA LICZBY NA WARTOSC
        jmp skokLiczba
literaAF:
        sub bl,55       ;KONWERSJA LITERY NA WARTOSC
skokLiczba:
        or al,bl        ;CZYSCIMY BL
        inc si          ;NASTEPNY ZNAK HEX
        dec bh          ;BH == 0 : KONIEC
        jnz petla       ;BH != 0 : PETLA
koniec:
        ret
hex2number endp

;------------------------
;INPUT  : BL = HEX ZNAK DO SPRAWDZENIA

sprawdzenie proc
        cmp bl,'0'
        jb error        ;IF BL < '0'
        cmp bl,'F'
        ja error        ;IF BL > 'F'
        cmp bl,'9'
        jbe good        ;IF BL <= '9'
        cmp bl,'A'      ;IF BL >= 'A'
        jae good
error:
        pop ax          ;USUNIECIE ZE STOSU CALL SPRAWDZ
        pop ax          ;USUNIECIE ZE STOSU CALL HEX2NUMBER

;WYSWIETL WIADOMOSC O NIEPRAWIDLOWYM ZNAKU
        mov ah,09h
        lea dx,Tekst4
        int 21h
        jmp blad        ;SKOK DO BLAD, WYSWIETLENIE ZAPYTANIA O KONTYNUACJE
good:
        ret
sprawdzenie endp

;---------------------------
;INPUT  : AX = LICZBA KONWERTOWANA NA DZIESIETNA
;         SI = INFORMACJA O POZYCJI W STRINGU
;ALGORYTM : WYCIAGAMY LICZBE JEDNA PO DRUGIEJ ZE STRINGA,
;WRZUCAMY JE NA STOS, NASTEPNIE WYCIAGAMY JE W ODWROTNEJ KOLEJNOSCI
;W CELU UTWORZENIA STRINGA WYNIKOWEGO.

number2string proc
        mov bx,10       ;LICZBA JEST DZIELONA PRZEZ 10
        mov cx,0        ;LICZNIK DLA ILOSCI LICZB WYCIAGANYCH ZE STRINGA WEJSCIOWEGO
petla1:
        mov dx,0        ;OBOWIAZKOWE W CEKU DZIELENIA PRZEZ BX
        div bx          ;DX:AX / 10 = AX:ILORAZ DX:RESZTA
        push dx         ;PRZECHOWANIE RESZTY NA POTEM
        inc cx          ;INKREMENTACJA LICZNIKA 
        cmp ax,0        ;JESLI LICZBA TO 0
        jne petla1      ;NIE ZERO, PETLA1
;WYCIAGNIECIE PRZECHOWYWANEJ RESZTY
        lea si,bufor
petla2:
        pop dx
        add dl,48       ;KONWERSJA LICZBY NA JEJ ZNAK
        mov [si],dl
        inc si
        loop petla2

        ret
number2string endp

;----------------------
Progr   ends

dane    segment
        Tekst1 db 10,13,10,13, 'WPROWADZ 1 DO 4 WARTOSCI HEX:$'
        Tekst2 db 10,13, 'WARTOSC W SYSTEMIE DZIESIETNYM: $'
        Tekst3 db 10,13,10,13, 'CZY CHCESZ WYKONAC PONOWNIE (Y/N)?$'
        Tekst4 db 10,13, 'NIEPRAWIDLOWA WARTOSC - WPROWADZ 0-9 LUB A-F:$'

        hex db 5,?,5 dup(?) ;ZMIENNA Z 3 SEKCJAMI
        bufor db 7 dup('$') ;WYNIK BEDZIE MIAL MAX 5 LICZB

dane    ends

stosik  segment stack
        dw 100h dup(0)
szczyt  Label word
stosik  ends
end