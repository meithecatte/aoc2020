INCLUDE "hardware.inc"

SECTION "Entrypoint", ROM0[$100]
    jp Start
    nop

    ; reserve ROM header space
    ds $150 - $104, 0

SECTION "Start", ROM0
Start:

.waitLCD:
    ldh a, [rLY]
    cp SCRN_Y
    jr c, .waitLCD
    xor a
    ldh [rLCDC], a
    ld [wDay1], a
    ld [wDay1 + 1], a
    ld [wDay2], a
    ld [wDay2 + 1], a

    ld hl, $9100
    ld de, Font
    ld bc, Font.end - Font
.copyFont:
    ld a, [de]
    inc de
    ld [hli], a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .copyFont

    ld hl, Input
.processPasswords:
    call ReadNumber
    jr c, .done
    ld d, a ; min
    call ReadNumber
    ld e, a ; max
    push de

    inc hl ; skip space
    ld a, [hli] ; letter
    inc hl ; skip colon
    push hl
    inc hl ; skip space
    push af

    ld b, a
    call CountOccurences

    ld a, c ; count < min
    cp d
    jr c, .part2

    ld a, e
    cp c ; max < count
    jr c, .part2

    ld de, wDay1
    call IncrementCounter

.part2:
    pop bc ; B = target letter
    pop hl
    pop de
    push hl

    ld a, l
    add e
    ld l, a
    adc h
    sub l
    ld h, a
    ld a, [hl]
    cp b
    ld c, 0
    jr nz, .checkedOnePosition
    ld c, 1
.checkedOnePosition
    pop hl

    ld a, l
    add d
    ld l, a
    adc h
    sub l
    ld h, a
    ld a, [hl]
    cp b
    ld a, 0
    jr nz, .checkedBothPositions
    inc a
.checkedBothPositions
    ld de, wDay2
    xor c
    call nz, IncrementCounter
    jr .processPasswords

.done:

    ld hl, $9800
    ld de, wDay1 + 1

    ld a, [de]
    call PrintBCD
    dec de
    ld a, [de]
    call PrintBCD

    ld l, $20
    ld de, wDay2 + 1

    ld a, [de]
    call PrintBCD
    dec de
    ld a, [de]
    call PrintBCD

    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a

    halt

SECTION "Variables", WRAM0, ALIGN[1]
wDay1: dw
wDay2: dw

SECTION "Processing", ROM0

; How many times does the letter in B occur in the newline-terminated string at HL?
; Return value in C
; Clobbers A
CountOccurences:
    ld c, 0
.loop:
    ld a, [hli]
    cp $0a
    ret z

    cp b
    jr nz, .loop
    inc c
    jr .loop

; Increment the 16-bit BCD counter at DE
; Clobbers A
; Assumes the counter doesn't cross a page boundary
IncrementCounter:
    ld a, [de]
    add 1
    daa
    ld [de], a
    ret nz
    inc e
    ld a, [de]
    add 1
    daa
    ld [de], a
    ret

SECTION "Output", ROM0
PrintBCD:
    ld b, a
    swap a
    and $0f
    add $10
    ld [hli], a

    ld a, b
    and $0f
    add $10
    ld [hli], a
    ret

SECTION "Parsing", ROM0

CheckEOF:
    ld a, l
    cp LOW(Input.end)
    jr nz, .notEOF
    ld a, h
    cp HIGH(Input.end)
    jr nz, .notEOF
    scf
    ret
.notEOF:
    and a
    ret

; Manipulates input pointer in HL
; Sets carry flag on EOF
; If not EOF, character stored in A
NextChar:
    call CheckEOF
    ret c
    ld a, [hli]
    ret

; If the next character is a digit, output its value in A and clear carry
; otherwise, exits with carry set
ParseDigit:
    sub "0"
    ret c
    cp 10
    ccf
    ret

; Skips input until a digit is encountered. Reads in a decimal number into A,
; then exits with carry clear. BC points at the first unread character.
; If carry is set, EOF encountered before any digits were found.
; Clobbers C
ReadNumber:
    call CheckEOF
    ret c

    ld a, [hli]
    call ParseDigit
    jr c, ReadNumber

    ld c, a
.subseqDigits:
    call CheckEOF
    jr c, .done

    ld a, [hl]
    call ParseDigit
    jr c, .done
    inc hl

    sla c
    add a, c
    sla c
    sla c
    add a, c
    ld c, a
    jr .subseqDigits
.done:
    ld a, c
    and a ; clear carry
    ret

SECTION "Data", ROM0
Font:
    INCBIN "font.1bpp"
.end:

Input:
    INCBIN "input"
.end:
