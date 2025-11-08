;==============================================================================
; Digital Clock with Date - AVR ATmega32A Assembly Implementation
; Target: ATmega32A @ 1MHz
; ADJUSTED FOR 1MHz CLOCK
;==============================================================================

.include "m32Adef.inc"

;------------------------------------------------------------------------------
; Hardware Pin Definitions
;------------------------------------------------------------------------------
.equ LCD_RS = PD0
.equ LCD_RW = PD1
.equ LCD_EN = PD2
.equ LED_GREEN = PD3
.equ LED_RED = PD4
.equ LED_YELLOW = PD5
.equ BUZZER = PD6

.equ KEYPAD_ROWS_MASK = 0x0F
.equ KEYPAD_COLS_MASK = 0xF0

;------------------------------------------------------------------------------
; Global Variables in SRAM
;------------------------------------------------------------------------------
.dseg
.org 0x0060

hours:          .byte 1
minutes:        .byte 1
seconds:        .byte 1
milliseconds:   .byte 2
day:            .byte 1
month:          .byte 1
year:           .byte 2
mode_12hr:      .byte 1
display_mode:   .byte 1
tick_flag:      .byte 1
second_flag:    .byte 1
last_second:    .byte 1
blink_state:    .byte 1
line_buffer:    .byte 17
input_buffer:   .byte 10
temp_byte:      .byte 1
temp_word:      .byte 2
idx_counter:    .byte 1
disp_hour:      .byte 1
am_pm_flag:     .byte 1

;------------------------------------------------------------------------------
; Program Code
;------------------------------------------------------------------------------
.cseg
.org 0x0000
    rjmp RESET
.org 0x0014
    rjmp TIMER0_COMP_ISR

;------------------------------------------------------------------------------
; Reset and Initialization
;------------------------------------------------------------------------------
RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    rcall PORT_INIT
    rcall LCD_INIT_ROUTINE
    rcall TIMER_INIT
    
    sei

    rcall STARTUP_SCREEN
    rcall INITIAL_SETUP
    rcall UPDATE_DISPLAY
    
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    rcall LCD_CLEAR
    
    lds r16, seconds
    sts last_second, r16
    clr r16
    sts blink_state, r16

;------------------------------------------------------------------------------
; Main Loop
;------------------------------------------------------------------------------
MAIN_LOOP:
    lds r16, seconds
    lds r17, last_second
    cp r16, r17
    breq CHECK_KEYPAD
    
    sts last_second, r16
    rcall UPDATE_DISPLAY
    
    lds r16, blink_state
    ldi r17, 1
    eor r16, r17
    sts blink_state, r16
    
    cpi r16, 0
    breq TURN_GREEN_OFF
    sbi PORTD, LED_GREEN
    rjmp CHECK_HOUR_LED
    
TURN_GREEN_OFF:
    cbi PORTD, LED_GREEN
    
CHECK_HOUR_LED:
    lds r16, minutes
    cpi r16, 0
    brne TURN_YELLOW_OFF
    lds r16, seconds
    cpi r16, 3
    brsh TURN_YELLOW_OFF
    sbi PORTD, LED_YELLOW
    rjmp CHECK_KEYPAD
    
TURN_YELLOW_OFF:
    cbi PORTD, LED_YELLOW

CHECK_KEYPAD:
    rcall KEYCHECK
    cpi r24, 'a'
    breq MAIN_LOOP
    
    mov r25, r24
    ldi r24, 20
    rcall DELAY_MS
    
WAIT_RELEASE:
    rcall KEYCHECK
    cpi r24, 'a'
    brne WAIT_RELEASE
    
    rcall BUZZER_BEEP
    
    cpi r25, 'A'
    breq KEY_A_PRESSED
    cpi r25, 'B'
    breq KEY_B_PRESSED
    cpi r25, 'C'
    breq KEY_C_PRESSED
    cpi r25, 'D'
    breq KEY_D_PRESSED
    cpi r25, '#'
    breq KEY_HASH_PRESSED
    rjmp MAIN_LOOP

KEY_A_PRESSED:
    rcall SET_TIME_12HR
    rjmp MAIN_LOOP

KEY_B_PRESSED:
    rcall SET_DATE
    rjmp MAIN_LOOP

KEY_C_PRESSED:
    rcall TOGGLE_12HR_MODE
    rcall UPDATE_DISPLAY
    rjmp MAIN_LOOP

KEY_D_PRESSED:
    lds r16, display_mode
    ldi r17, 1
    eor r16, r17
    sts display_mode, r16
    cpi r16, 0
    breq DISPLAY_D_OFF
    sbi PORTD, LED_RED
    rjmp DISPLAY_D_UPDATE
DISPLAY_D_OFF:
    cbi PORTD, LED_RED
DISPLAY_D_UPDATE:
    rcall UPDATE_DISPLAY
    rjmp MAIN_LOOP

KEY_HASH_PRESSED:
    rcall SYSTEM_RESET
    rjmp MAIN_LOOP

;------------------------------------------------------------------------------
; Port Initialization
;------------------------------------------------------------------------------
PORT_INIT:
    ldi r16, 0xFF
    out DDRB, r16
    
    ldi r16, (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_EN)|(1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW)|(1<<BUZZER)
    out DDRD, r16
    
    ldi r16, KEYPAD_ROWS_MASK
    out DDRC, r16
    ldi r16, KEYPAD_COLS_MASK | KEYPAD_ROWS_MASK
    out PORTC, r16
    ret

;------------------------------------------------------------------------------
; Timer0 Initialization - ADJUSTED FOR 1MHz with Prescaler 64
;------------------------------------------------------------------------------
TIMER_INIT:
    ldi r16, (1<<WGM01) | (1<<CS01) | (1<<CS00)  ; CTC mode, prescaler 64
    out TCCR0, r16
    ldi r16, 155                     ; 10ms at 1MHz with prescaler 64
    out OCR0, r16
    ldi r16, (1<<OCIE0)
    out TIMSK, r16
    ret
;------------------------------------------------------------------------------
; Timer0 ISR - ADJUSTED FOR 10ms TICKS
;------------------------------------------------------------------------------
TIMER0_COMP_ISR:
    push r16
    push r17
    push r18
    push r19
    in r16, SREG
    push r16
    
    lds r16, milliseconds
    lds r17, milliseconds+1
    subi r16, low(-10)              ; Add 10ms each interrupt
    sbci r17, high(-10)
    sts milliseconds, r16
    sts milliseconds+1, r17
    
    ldi r16, 1
    sts tick_flag, r16
    
    lds r16, milliseconds
    lds r17, milliseconds+1
    cpi r16, low(1000)
    ldi r18, high(1000)
    cpc r17, r18
    brlo TIMER_ISR_END
    
    ; Reset milliseconds when reaching 1000
    subi r16, low(1000)
    sbci r17, high(1000)
    sts milliseconds, r16
    sts milliseconds+1, r17
    
    lds r16, seconds
    inc r16
    sts seconds, r16
    
    ldi r16, 1
    sts second_flag, r16
    
    lds r16, seconds
    cpi r16, 60
    brlo TIMER_ISR_END
    
    clr r16
    sts seconds, r16
    lds r16, minutes
    inc r16
    sts minutes, r16
    
    cpi r16, 60
    brlo TIMER_ISR_END
    
    clr r16
    sts minutes, r16
    lds r16, hours
    inc r16
    sts hours, r16
    
    cpi r16, 24
    brlo TIMER_ISR_END
    
    clr r16
    sts hours, r16
    
    lds r16, day
    cpi r16, 0
    breq TIMER_ISR_END
    lds r16, month
    cpi r16, 0
    breq TIMER_ISR_END
    
    rcall ADVANCE_DATE

TIMER_ISR_END:
    pop r16
    out SREG, r16
    pop r19
    pop r18
    pop r17
    pop r16
    reti

;------------------------------------------------------------------------------
; LCD Functions
;------------------------------------------------------------------------------
LCD_INIT_ROUTINE:
    ldi r24, 20
    rcall DELAY_MS
    ldi r24, 0x38
    rcall LCD_COMMAND
    ldi r24, 0x0C
    rcall LCD_COMMAND
    ldi r24, 0x06
    rcall LCD_COMMAND
    ldi r24, 0x01
    rcall LCD_COMMAND
    ldi r24, 2
    rcall DELAY_MS
    ldi r24, 0x80
    rcall LCD_COMMAND
    ret

LCD_COMMAND:
    out PORTB, r24
    cbi PORTD, LCD_RS
    cbi PORTD, LCD_RW
    sbi PORTD, LCD_EN
    rcall DELAY_US_40
    cbi PORTD, LCD_EN
    push r24
    ldi r24, 2
    rcall DELAY_MS
    pop r24
    ret

LCD_CHAR:
    out PORTB, r24
    sbi PORTD, LCD_RS
    cbi PORTD, LCD_RW
    sbi PORTD, LCD_EN
    rcall DELAY_US_40
    cbi PORTD, LCD_EN
    push r24
    ldi r24, 2
    rcall DELAY_MS
    pop r24
    ret

LCD_CLEAR:
    ldi r24, 0x01
    rcall LCD_COMMAND
    ldi r24, 0x80
    rcall LCD_COMMAND
    ret

LCD_STRING_SRAM:
    ld r24, Z+
    cpi r24, 0
    breq LCD_STRING_SRAM_END
    rcall LCD_CHAR
    rjmp LCD_STRING_SRAM
LCD_STRING_SRAM_END:
    ret

LCD_STRING_XY_SRAM:
    cpi r22, 0
    brne LCD_SXY_ROW1
    mov r16, r23
    andi r16, 0x0F
    ori r16, 0x80
    mov r24, r16
    rcall LCD_COMMAND
    rjmp LCD_STRING_SRAM
LCD_SXY_ROW1:
    mov r16, r23
    andi r16, 0x0F
    ori r16, 0xC0
    mov r24, r16
    rcall LCD_COMMAND
    rjmp LCD_STRING_SRAM

LCD_PUT_CHAR_AT:
    push r24
    cpi r22, 0
    brne LCD_PCA_ROW1
    mov r16, r23
    andi r16, 0x0F
    ori r16, 0x80
    mov r24, r16
    rcall LCD_COMMAND
    rjmp LCD_PCA_WRITE
LCD_PCA_ROW1:
    mov r16, r23
    andi r16, 0x0F
    ori r16, 0xC0
    mov r24, r16
    rcall LCD_COMMAND
LCD_PCA_WRITE:
    pop r24
    rcall LCD_CHAR
    ret

LCD_PRINT_FULL_LINE:
    push r22
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    
    clr r16
LCD_PFL_COUNT:
    ld r17, Z+
    cpi r17, 0
    breq LCD_PFL_GOT_LEN
    inc r16
    cpi r16, 17
    brlo LCD_PFL_COUNT
    
LCD_PFL_GOT_LEN:
    cpi r16, 16
    brlo LCD_PFL_OK
    ldi r16, 16
LCD_PFL_OK:
    
    ldi r17, 16
    sub r17, r16
    lsr r17
    mov r18, r17
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi XL, low(line_buffer+16)
    ldi XH, high(line_buffer+16)
    
    mov r19, r18
LCD_PFL_PAD1:
    cpi r19, 0
    breq LCD_PFL_COPY
    ldi r24, ' '
    st -X, r24
    dec r19
    rjmp LCD_PFL_PAD1
    
LCD_PFL_COPY:
    mov r19, r16
LCD_PFL_COPY_LOOP:
    cpi r19, 0
    breq LCD_PFL_PAD2
    ld r24, Z+
    st -X, r24
    dec r19
    rjmp LCD_PFL_COPY_LOOP
    
LCD_PFL_PAD2:
    ldi r19, 16
    sub r19, r16
    sub r19, r18
LCD_PFL_PAD2_LOOP:
    cpi r19, 0
    breq LCD_PFL_PRINT
    ldi r24, ' '
    st -X, r24
    dec r19
    rjmp LCD_PFL_PAD2_LOOP
    
LCD_PFL_PRINT:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r16, 16
LCD_PFL_PRINT_LOOP:
    cpi r16, 0
    breq LCD_PFL_NULL
    ld r24, Z+
    st Z, r24
    inc ZL
    dec r16
    rjmp LCD_PFL_PRINT_LOOP
    
LCD_PFL_NULL:
    clr r24
    st Z, r24
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    pop r22
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM
    ret

;------------------------------------------------------------------------------
; Keypad Functions
;------------------------------------------------------------------------------
KEYCHECK:
    in r16, PORTC
    andi r16, ~KEYPAD_ROWS_MASK
    ori r16, 0x0E
    out PORTC, r16
    ldi r24, 3
    rcall DELAY_MS
    in r17, PINC
    sbrs r17, 4
    rjmp KC_R1C1
    sbrs r17, 5
    rjmp KC_R1C2
    sbrs r17, 6
    rjmp KC_R1C3
    sbrs r17, 7
    rjmp KC_R1C4
    
    in r16, PORTC
    andi r16, ~KEYPAD_ROWS_MASK
    ori r16, 0x0D
    out PORTC, r16
    ldi r24, 3
    rcall DELAY_MS
    in r17, PINC
    sbrs r17, 4
    rjmp KC_R2C1
    sbrs r17, 5
    rjmp KC_R2C2
    sbrs r17, 6
    rjmp KC_R2C3
    sbrs r17, 7
    rjmp KC_R2C4
    
    in r16, PORTC
    andi r16, ~KEYPAD_ROWS_MASK
    ori r16, 0x0B
    out PORTC, r16
    ldi r24, 3
    rcall DELAY_MS
    in r17, PINC
    sbrs r17, 4
    rjmp KC_R3C1
    sbrs r17, 5
    rjmp KC_R3C2
    sbrs r17, 6
    rjmp KC_R3C3
    sbrs r17, 7
    rjmp KC_R3C4
    
    in r16, PORTC
    andi r16, ~KEYPAD_ROWS_MASK
    ori r16, 0x07
    out PORTC, r16
    ldi r24, 3
    rcall DELAY_MS
    in r17, PINC
    sbrs r17, 4
    rjmp KC_R4C1
    sbrs r17, 5
    rjmp KC_R4C2
    sbrs r17, 6
    rjmp KC_R4C3
    sbrs r17, 7
    rjmp KC_R4C4
    
    in r16, PORTC
    ori r16, KEYPAD_ROWS_MASK
    out PORTC, r16
    ldi r24, 'a'
    ret

KC_R1C1: ldi r24, '1'
    rjmp KC_END
KC_R1C2: ldi r24, '2'
    rjmp KC_END
KC_R1C3: ldi r24, '3'
    rjmp KC_END
KC_R1C4: ldi r24, 'A'
    rjmp KC_END
KC_R2C1: ldi r24, '4'
    rjmp KC_END
KC_R2C2: ldi r24, '5'
    rjmp KC_END
KC_R2C3: ldi r24, '6'
    rjmp KC_END
KC_R2C4: ldi r24, 'B'
    rjmp KC_END
KC_R3C1: ldi r24, '7'
    rjmp KC_END
KC_R3C2: ldi r24, '8'
    rjmp KC_END
KC_R3C3: ldi r24, '9'
    rjmp KC_END
KC_R3C4: ldi r24, 'C'
    rjmp KC_END
KC_R4C1: ldi r24, '*'
    rjmp KC_END
KC_R4C2: ldi r24, '0'
    rjmp KC_END
KC_R4C3: ldi r24, '#'
    rjmp KC_END
KC_R4C4: ldi r24, 'D'
KC_END:
    in r16, PORTC
    ori r16, KEYPAD_ROWS_MASK
    out PORTC, r16
    ret

SCANKEY:
SCANKEY_LOOP:
    rcall KEYCHECK
    cpi r24, 'a'
    breq SCANKEY_LOOP
    push r24
    ldi r24, 10
    rcall DELAY_MS
    rcall KEYCHECK
    mov r25, r24
    pop r24
    cp r24, r25
    brne SCANKEY_LOOP
SCANKEY_WAIT_RELEASE:
    push r24
    rcall KEYCHECK
    mov r25, r24
    pop r24
    cp r24, r25
    breq SCANKEY_WAIT_RELEASE
    push r24
    ldi r24, 10
    rcall DELAY_MS
    pop r24
    ret

;------------------------------------------------------------------------------
; Buzzer Functions - ADJUSTED FOR 1MHz
;------------------------------------------------------------------------------
BUZZER_BEEP:
    push r16
    ldi r16, 40
BUZZER_BEEP_LOOP:
    sbi PORTD, BUZZER
    rcall DELAY_US_250
    cbi PORTD, BUZZER
    rcall DELAY_US_250
    dec r16
    brne BUZZER_BEEP_LOOP
    pop r16
    ret

BUZZER_LONG_BEEP:
    push r16
    ldi r16, 200
BUZZER_LONG_LOOP:
    sbi PORTD, BUZZER
    rcall DELAY_US_250
    cbi PORTD, BUZZER
    rcall DELAY_US_250
    dec r16
    brne BUZZER_LONG_LOOP
    pop r16
    ret

;------------------------------------------------------------------------------
; Delay Functions - OPTIMIZED FOR 1MHz
;------------------------------------------------------------------------------
DELAY_MS:
    push r24
    push r25
DELAY_MS_OUTER:
    ldi r25, 250        ; More precise: 250 iterations
DELAY_MS_INNER:
    nop
    nop
    dec r25
    brne DELAY_MS_INNER
    dec r24
    brne DELAY_MS_OUTER
    pop r25
    pop r24
    ret

DELAY_US_250:
    push r16
    ldi r16, 83         ; More precise: (250-3)/3 = ~82.3
DELAY_US_250_LOOP:
    nop
    dec r16
    brne DELAY_US_250_LOOP
    pop r16
    ret

DELAY_US_40:
    push r16
    ldi r16, 13         ; More precise: (40-3)/3 = ~12.3
DELAY_US_40_LOOP:
    nop
    dec r16
    brne DELAY_US_40_LOOP
    pop r16
    ret

;------------------------------------------------------------------------------
; Startup Screen
;------------------------------------------------------------------------------
STARTUP_SCREEN:
    rcall LCD_CLEAR
    
    ldi ZL, low(STR_DIGITAL_CLOCK<<1)
    ldi ZH, high(STR_DIGITAL_CLOCK<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_WITH_DATE<<1)
    ldi ZH, high(STR_WITH_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_YELLOW
    sbi PORTD, LED_GREEN
    ldi r24, 250
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    ldi r24, 200
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    rcall LCD_CLEAR
    ret

;------------------------------------------------------------------------------
; Initial Setup
;------------------------------------------------------------------------------
INITIAL_SETUP:
    rcall LCD_CLEAR
    
    ldi ZL, low(STR_INITIAL_SETUP<<1)
    ldi ZH, high(STR_INITIAL_SETUP<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_PLEASE_WAIT<<1)
    ldi ZH, high(STR_PLEASE_WAIT<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_YELLOW
    sbi PORTD, LED_RED
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 150
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_SELECT_FORMAT<<1)
    ldi ZH, high(STR_SELECT_FORMAT<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_12HR_24HR<<1)
    ldi ZH, high(STR_12HR_24HR<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
IS_WAIT_FORMAT:
    rcall SCANKEY
    cpi r24, 'A'
    breq IS_12HR
    cpi r24, 'B'
    breq IS_24HR
    rjmp IS_WAIT_FORMAT
    
IS_12HR:
    ldi r16, 1
    sts mode_12hr, r16
    rcall BUZZER_BEEP
    rcall LCD_CLEAR
    ldi ZL, low(STR_12HR_MODE<<1)
    ldi ZH, high(STR_12HR_MODE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    rjmp IS_FORMAT_DONE
    
IS_24HR:
    clr r16
    sts mode_12hr, r16
    rcall BUZZER_BEEP
    rcall LCD_CLEAR
    ldi ZL, low(STR_24HR_MODE<<1)
    ldi ZH, high(STR_24HR_MODE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
IS_FORMAT_DONE:
    ldi ZL, low(STR_SELECTED<<1)
    ldi ZH, high(STR_SELECTED<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    sbi PORTD, LED_GREEN
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    cbi PORTD, LED_GREEN
    
    ; Continue to part 2
    rjmp INITIAL_SETUP_PART2

INITIAL_SETUP_PART2:
    rcall LCD_CLEAR
    ldi ZL, low(STR_STEP1<<1)
    ldi ZH, high(STR_STEP1<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi ZL, low(STR_SET_TIME<<1)
    ldi ZH, high(STR_SET_TIME<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 150
    rcall DELAY_MS
    
    rcall SET_TIME_12HR
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_STEP2<<1)
    ldi ZH, high(STR_STEP2<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi ZL, low(STR_SET_DATE<<1)
    ldi ZH, high(STR_SET_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 150
    rcall DELAY_MS
    
    rcall SET_DATE
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_SETUP_COMPLETE<<1)
    ldi ZH, high(STR_SETUP_COMPLETE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi ZL, low(STR_STARTING<<1)
    ldi ZH, high(STR_STARTING<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    in r16, PORTD
    ori r16, (1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW)
    out PORTD, r16
    ldi r24, 250
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    ldi r24, 200
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    rcall LCD_CLEAR
    ret

;------------------------------------------------------------------------------
; Update Display
;------------------------------------------------------------------------------
UPDATE_DISPLAY:
    lds r16, display_mode
    cpi r16, 0
    breq UD_TIME_MODE
    rjmp UD_DATE_MODE
    
UD_TIME_MODE:
    lds r16, hours
    sts disp_hour, r16
    clr r17
    sts am_pm_flag, r17
    
    lds r18, mode_12hr
    cpi r18, 0
    brne UD_TM_12HR_MODE
    
    jmp UD_TM_24HR
    
UD_TM_12HR_MODE:
    cpi r16, 0
    brne UD_TM_NOT_MIDNIGHT
    ldi r16, 12
    sts disp_hour, r16
    rjmp UD_TM_CHECK_PM
    
UD_TM_NOT_MIDNIGHT:
    cpi r16, 13
    brlo UD_TM_CHECK_PM
    subi r16, 12
    sts disp_hour, r16
    
UD_TM_CHECK_PM:
    lds r16, hours
    cpi r16, 12
    brlo UD_TM_IS_AM
    ldi r17, 1
    sts am_pm_flag, r17
    
UD_TM_IS_AM:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r24, ' '
    st Z+, r24
    
    lds r16, disp_hour
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ':'
    st Z+, r24
    
    lds r16, minutes
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ':'
    st Z+, r24
    
    lds r16, seconds
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ' '
    st Z+, r24
    
    lds r19, mode_12hr
    cpi r19, 0
    breq UD_TM_NO_AMPM
    
    lds r19, am_pm_flag
    cpi r19, 0
    brne UD_TM_PM
    ldi r24, 'A'
    st Z+, r24
    ldi r24, 'M'
    st Z+, r24
    rjmp UD_TM_AMPM_DONE
    
UD_TM_PM:
    ldi r24, 'P'
    st Z+, r24
    ldi r24, 'M'
    st Z+, r24
    
UD_TM_AMPM_DONE:
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    rjmp UD_TM_LINE1_DONE
    
UD_TM_NO_AMPM:
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    
UD_TM_LINE1_DONE:
    clr r24
    st Z, r24
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r22, 0
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM
    rjmp UD_TM_DATE_LINE

UD_TM_24HR:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    
    lds r16, hours
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ':'
    st Z+, r24
    
    lds r16, minutes
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ':'
    st Z+, r24
    
    lds r16, seconds
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    clr r24
    st Z, r24
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r22, 0
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM

UD_TM_DATE_LINE:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r24, ' '
    st Z+, r24
    
    lds r16, day
    cpi r16, 0
    brne UD_TM_DATE_VALID
    ldi r24, '0'
    st Z+, r24
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    ldi r24, '0'
    st Z+, r24
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    ldi r24, '0'
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    rjmp UD_TM_DATE_END
    
UD_TM_DATE_VALID:
    lds r16, day
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    
    lds r16, month
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    
    lds r16, year
    lds r17, year+1
    rcall YEAR_TO_ASCII
    
UD_TM_DATE_END:
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    clr r24
    st Z, r24
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r22, 1
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM
    ret

UD_DATE_MODE:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r24, ' '
    st Z+, r24
    
    lds r16, day
    cpi r16, 0
    brne UD_DM_VALID
    
    ldi r24, '0'
    st Z+, r24
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    st Z+, r24
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    ldi r24, '0'
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    rjmp UD_DM_LINE1_END
    
UD_DM_VALID:
    lds r16, day
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, '-'
    st Z+, r24
    
    lds r16, month
    rcall GET_MONTH_NAME
    lpm r24, Z+
    st X+, r24
    lpm r24, Z+
    st X+, r24
    lpm r24, Z+
    st X+, r24
    
    mov ZL, XL
    mov ZH, XH
    ldi r24, '-'
    st Z+, r24
    
    lds r16, year
    lds r17, year+1
    rcall YEAR_TO_ASCII
    
UD_DM_LINE1_END:
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    clr r24
    st Z, r24
    
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r22, 0
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM
    
UD_DM_TIME_LINE:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    
    lds r16, hours
    sts disp_hour, r16
    clr r17
    sts am_pm_flag, r17
    
    lds r18, mode_12hr
    cpi r18, 0
    breq UD_DM_24HR
    
    cpi r16, 0
    brne UD_DM_NOT_MIDNIGHT
    ldi r16, 12
    sts disp_hour, r16
    rjmp UD_DM_CHECK_PM
UD_DM_NOT_MIDNIGHT:
    cpi r16, 13
    brlo UD_DM_CHECK_PM
    subi r16, 12
    sts disp_hour, r16
UD_DM_CHECK_PM:
    lds r16, hours
    cpi r16, 12
    brlo UD_DM_IS_AM
    ldi r17, 1
    sts am_pm_flag, r17
UD_DM_IS_AM:
    
    lds r16, disp_hour
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, ':'
    st Z+, r24
    
    lds r16, minutes
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, ' '
    st Z+, r24
    
    lds r19, am_pm_flag
    cpi r19, 0
    brne UD_DM_PM
    ldi r24, 'A'
    st Z+, r24
    ldi r24, 'M'
    st Z+, r24
    rjmp UD_DM_AMPM_DONE
UD_DM_PM:
    ldi r24, 'P'
    st Z+, r24
    ldi r24, 'M'
    st Z+, r24
UD_DM_AMPM_DONE:
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    clr r24
    st Z, r24
    rjmp UD_DM_LINE2_DONE
    
UD_DM_24HR:
    ldi r24, ' '
    st Z+, r24
    
    lds r16, hours
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    ldi r24, ':'
    st Z+, r24
    
    lds r16, minutes
    rcall BCD_CONVERT
    mov r24, r17
    st Z+, r24
    mov r24, r18
    st Z+, r24
    
    ldi r24, ' '
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    st Z+, r24
    clr r24
    st Z, r24
    
UD_DM_LINE2_DONE:
    ldi ZL, low(line_buffer)
    ldi ZH, high(line_buffer)
    ldi r22, 1
    ldi r23, 0
    rcall LCD_STRING_XY_SRAM
    ret

;------------------------------------------------------------------------------
; Set Time Function
;------------------------------------------------------------------------------
SET_TIME_12HR:
    cli
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_SET_TIME<<1)
    ldi ZH, high(STR_SET_TIME<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    lds r16, mode_12hr
    cpi r16, 0
    breq ST_24HR_LABEL
    
    ldi ZL, low(STR_HHMMSS_AMPM<<1)
    ldi ZH, high(STR_HHMMSS_AMPM<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    rjmp ST_LABEL_DONE
    
ST_24HR_LABEL:
    ldi ZL, low(STR_HHMMSS<<1)
    ldi ZH, high(STR_HHMMSS<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    
ST_LABEL_DONE:
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_ENTER_TIME<<1)
    ldi ZH, high(STR_ENTER_TIME<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi r24, '_'
    ldi r22, 1
    ldi r23, 2
    rcall LCD_PUT_CHAR_AT
    ldi r23, 3
    rcall LCD_PUT_CHAR_AT
    ldi r24, ':'
    ldi r23, 4
    rcall LCD_PUT_CHAR_AT
    ldi r24, '_'
    ldi r23, 5
    rcall LCD_PUT_CHAR_AT
    ldi r23, 6
    rcall LCD_PUT_CHAR_AT
    ldi r24, ':'
    ldi r23, 7
    rcall LCD_PUT_CHAR_AT
    ldi r24, '_'
    ldi r23, 8
    rcall LCD_PUT_CHAR_AT
    ldi r23, 9
    rcall LCD_PUT_CHAR_AT
    
    clr r16
    sts idx_counter, r16

ST_INPUT_LOOP:
    lds r16, idx_counter
    cpi r16, 6
    brsh ST_INPUT_DONE
    
    rcall SCANKEY
    
    cpi r24, '*'
    breq ST_BACKSPACE
    
    cpi r24, '0'
    brlo ST_INPUT_LOOP
    cpi r24, '9'+1
    brsh ST_INPUT_LOOP
    
    lds r16, idx_counter
    ldi XL, low(input_buffer)
    ldi XH, high(input_buffer)
    add XL, r16
    adc XH, r1
    st X, r24
    
    ldi r17, 2
    add r17, r16
    mov r18, r16
    cpi r18, 2
    brlo ST_NO_SEP1
    inc r17
ST_NO_SEP1:
    cpi r18, 4
    brlo ST_NO_SEP2
    inc r17
ST_NO_SEP2:
    
    mov r23, r17
    ldi r22, 1
    rcall LCD_PUT_CHAR_AT
    
    lds r16, idx_counter
    inc r16
    sts idx_counter, r16
    rjmp ST_INPUT_LOOP
    
ST_BACKSPACE:
    lds r16, idx_counter
    cpi r16, 0
    breq ST_INPUT_LOOP
    
    dec r16
    sts idx_counter, r16
    
    ldi r17, 2
    add r17, r16
    mov r18, r16
    cpi r18, 2
    brlo ST_BS_NO_SEP1
    inc r17
ST_BS_NO_SEP1:
    cpi r18, 4
    brlo ST_BS_NO_SEP2
    inc r17
ST_BS_NO_SEP2:
    
    mov r23, r17
    ldi r22, 1
    ldi r24, '_'
    rcall LCD_PUT_CHAR_AT
    rjmp ST_INPUT_LOOP

ST_INPUT_DONE:
    ldi XL, low(input_buffer)
    ldi XH, high(input_buffer)
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r18, r0
    ld r16, X+
    subi r16, '0'
    add r18, r16
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r19, r0
    ld r16, X+
    subi r16, '0'
    add r19, r16
    sts minutes, r19
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r20, r0
    ld r16, X+
    subi r16, '0'
    add r20, r16
    sts seconds, r20
    
    lds r16, mode_12hr
    cpi r16, 0
    breq ST_STORE_24HR
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_SELECT<<1)
    ldi ZH, high(STR_SELECT<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_AM_PM<<1)
    ldi ZH, high(STR_AM_PM<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
ST_WAIT_AMPM:
    rcall SCANKEY
    cpi r24, 'A'
    breq ST_AM_SEL
    cpi r24, 'B'
    breq ST_PM_SEL
    rjmp ST_WAIT_AMPM
    
ST_AM_SEL:
    rcall BUZZER_BEEP
    cpi r18, 12
    brne ST_AM_NOT_12
    clr r18
    rjmp ST_STORE_HOUR
ST_AM_NOT_12:
    rjmp ST_STORE_HOUR
    
ST_PM_SEL:
    rcall BUZZER_BEEP
    cpi r18, 12
    breq ST_STORE_HOUR
    subi r18, -12
    rjmp ST_STORE_HOUR
    
ST_STORE_24HR:
    ; r18 already has hour
    
ST_STORE_HOUR:
    sts hours, r18
    
    clr r16
    sts milliseconds, r16
    sts milliseconds+1, r16
    
    lds r16, hours
    cpi r16, 24
    brlo ST_H_OK
    ldi r16, 23
    sts hours, r16
ST_H_OK:
    
    lds r16, minutes
    cpi r16, 60
    brlo ST_M_OK
    ldi r16, 59
    sts minutes, r16
ST_M_OK:
    
    lds r16, seconds
    cpi r16, 60
    brlo ST_S_OK
    ldi r16, 59
    sts seconds, r16
ST_S_OK:
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_TIME_SET<<1)
    ldi ZH, high(STR_TIME_SET<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_GREEN
    sbi PORTD, LED_YELLOW
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    
    rcall LCD_CLEAR
    sei
    ret

;------------------------------------------------------------------------------
; Set Date Function
;------------------------------------------------------------------------------
SET_DATE:
    rcall LCD_CLEAR
    ldi ZL, low(STR_SET_DATE<<1)
    ldi ZH, high(STR_SET_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_DDMMYYYY<<1)
    ldi ZH, high(STR_DDMMYYYY<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_ENTER_DATE<<1)
    ldi ZH, high(STR_ENTER_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi r24, '_'
    ldi r22, 1
    ldi r23, 1
    rcall LCD_PUT_CHAR_AT
    ldi r23, 2
    rcall LCD_PUT_CHAR_AT
    ldi r24, '-'
    ldi r23, 3
    rcall LCD_PUT_CHAR_AT
    ldi r24, '_'
    ldi r23, 4
    rcall LCD_PUT_CHAR_AT
    ldi r23, 5
    rcall LCD_PUT_CHAR_AT
    ldi r24, '-'
    ldi r23, 6
    rcall LCD_PUT_CHAR_AT
    ldi r24, '_'
    ldi r23, 7
    rcall LCD_PUT_CHAR_AT
    ldi r23, 8
    rcall LCD_PUT_CHAR_AT
    ldi r23, 9
    rcall LCD_PUT_CHAR_AT
    ldi r23, 10
    rcall LCD_PUT_CHAR_AT
    
    clr r16
    sts idx_counter, r16

SD_INPUT_LOOP:
    lds r16, idx_counter
    cpi r16, 8
    brsh SD_INPUT_DONE
    
    rcall SCANKEY
    
    cpi r24, '*'
    breq SD_BACKSPACE
    
    cpi r24, '0'
    brlo SD_INPUT_LOOP
    cpi r24, '9'+1
    brsh SD_INPUT_LOOP
    
    lds r16, idx_counter
    ldi XL, low(input_buffer)
    ldi XH, high(input_buffer)
    add XL, r16
    adc XH, r1
    st X, r24
    
    ldi r17, 1
    add r17, r16
    mov r18, r16
    cpi r18, 2
    brlo SD_NO_SEP1
    inc r17
SD_NO_SEP1:
    cpi r18, 4
    brlo SD_NO_SEP2
    inc r17
SD_NO_SEP2:
    
    mov r23, r17
    ldi r22, 1
    rcall LCD_PUT_CHAR_AT
    
    lds r16, idx_counter
    inc r16
    sts idx_counter, r16
    rjmp SD_INPUT_LOOP
    
SD_BACKSPACE:
    lds r16, idx_counter
    cpi r16, 0
    breq SD_INPUT_LOOP
    
    dec r16
    sts idx_counter, r16
    
    ldi r17, 1
    add r17, r16
    mov r18, r16
    cpi r18, 2
    brlo SD_BS_NO_SEP1
    inc r17
SD_BS_NO_SEP1:
    cpi r18, 4
    brlo SD_BS_NO_SEP2
    inc r17
SD_BS_NO_SEP2:
    
    mov r23, r17
    ldi r22, 1
    ldi r24, '_'
    rcall LCD_PUT_CHAR_AT
    rjmp SD_INPUT_LOOP

SD_INPUT_DONE:
    ldi XL, low(input_buffer)
    ldi XH, high(input_buffer)
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r18, r0
    ld r16, X+
    subi r16, '0'
    add r18, r16
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r19, r0
    ld r16, X+
    subi r16, '0'
    add r19, r16
    
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    mov r20, r0
    ld r16, X+
    subi r16, '0'
    ldi r17, 100
    mul r16, r17
    add r20, r0
    ld r16, X+
    subi r16, '0'
    ldi r17, 10
    mul r16, r17
    add r20, r0
    ld r16, X+
    subi r16, '0'
    add r20, r16
    mov r21, r1
    
    ; Validate month
    cpi r19, 1
    brlo SD_INVALID_MONTH
    cpi r19, 13
    brsh SD_INVALID_MONTH
    
    ; Validate day
    mov r16, r19
    mov r17, r20
    rcall DAYS_IN_MONTH
    
    cp r18, r24
    brlo SD_DAY_OK
    breq SD_DAY_OK
    rjmp SD_INVALID_DAY
    
SD_DAY_OK:
    ; Validate year (2000-2099)
    cpi r20, 100
    brlo SD_YEAR_VALID
    jmp SD_INVALID_YEAR
    
SD_YEAR_VALID:
    ; Store valid date
    sts day, r18
    sts month, r19
    sts year, r20
    sts year+1, r21
    
    rcall LCD_CLEAR
    
    ; Check for leap year
    mov r16, r20
    rcall IS_LEAP_YEAR
    cpi r24, 0
    breq SD_NOT_LEAP
    
    lds r16, month
    cpi r16, 2
    brne SD_NOT_LEAP
    
    ldi ZL, low(STR_LEAP_YEAR<<1)
    ldi ZH, high(STR_LEAP_YEAR<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    rjmp SD_DATE_SET_MSG
    
SD_NOT_LEAP:
    ldi ZL, low(STR_DATE_SET<<1)
    ldi ZH, high(STR_DATE_SET<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    
SD_DATE_SET_MSG:
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_RED
    sbi PORTD, LED_YELLOW
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    
    rcall LCD_CLEAR
    ret
    
SD_INVALID_MONTH:
    rcall LCD_CLEAR
    ldi ZL, low(STR_INVALID_MONTH<<1)
    ldi ZH, high(STR_INVALID_MONTH<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    rcall LCD_CLEAR
    ret
    
SD_INVALID_DAY:
    rcall LCD_CLEAR
    ldi ZL, low(STR_INVALID_DATE<<1)
    ldi ZH, high(STR_INVALID_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    rcall LCD_CLEAR
    ret
    
SD_INVALID_YEAR:
    rcall LCD_CLEAR
    ldi ZL, low(STR_INVALID_DATE<<1)
    ldi ZH, high(STR_INVALID_DATE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    rcall LCD_CLEAR
    ret

;------------------------------------------------------------------------------
; Toggle 12/24 Hour Mode
;------------------------------------------------------------------------------
TOGGLE_12HR_MODE:
    lds r16, mode_12hr
    ldi r17, 1
    eor r16, r17
    sts mode_12hr, r16
    
    rcall LCD_CLEAR
    
    cpi r16, 0
    breq T12_24HR
    
    ldi ZL, low(STR_12HR_MODE<<1)
    ldi ZH, high(STR_12HR_MODE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    rjmp T12_DISPLAY
    
T12_24HR:
    ldi ZL, low(STR_24HR_MODE<<1)
    ldi ZH, high(STR_24HR_MODE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    
T12_DISPLAY:
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_YELLOW
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 100
    rcall DELAY_MS
    cbi PORTD, LED_YELLOW
    
    rcall LCD_CLEAR
    ret

;------------------------------------------------------------------------------
; System Reset Function
;------------------------------------------------------------------------------
SYSTEM_RESET:
    cli
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_RESET_SYSTEM<<1)
    ldi ZH, high(STR_RESET_SYSTEM<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_AYES_BCANCEL<<1)
    ldi ZH, high(STR_AYES_BCANCEL<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    ldi r16, 5
SR_FLASH_LOOP:
    push r16
    
    in r16, PORTD
    ori r16, (1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW)
    out PORTD, r16
    sbi PORTD, BUZZER
    ldi r24, 150
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    cbi PORTD, BUZZER
    ldi r24, 150
    rcall DELAY_MS
    
    pop r16
    dec r16
    brne SR_FLASH_LOOP
    
SR_WAIT_CONFIRM:
    rcall SCANKEY
    cpi r24, 'A'
    breq SR_CONFIRMED
    cpi r24, 'B'
    breq SR_CANCELLED
    rjmp SR_WAIT_CONFIRM

SR_CONFIRMED:
    rcall BUZZER_LONG_BEEP
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_RESETTING<<1)
    ldi ZH, high(STR_RESETTING<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    sbi PORTD, LED_RED
    
    clr r16
    sts hours, r16
    sts minutes, r16
    sts seconds, r16
    sts milliseconds, r16
    sts milliseconds+1, r16
    sts day, r16
    sts month, r16
    sts year, r16
    sts year+1, r16
    ldi r16, 1
    sts mode_12hr, r16
    clr r16
    sts display_mode, r16
    
    rcall LCD_CLEAR
    ldi ZL, low(STR_RESET_COMPLETE<<1)
    ldi ZH, high(STR_RESET_COMPLETE<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    ldi ZL, low(STR_RESTARTING<<1)
    ldi ZH, high(STR_RESTARTING<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 1
    rcall LCD_PRINT_FULL_LINE
    
    in r16, PORTD
    ori r16, (1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW)
    out PORTD, r16
    ldi r24, 250
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    rcall DELAY_MS
    ldi r24, 200
    rcall DELAY_MS
    
    in r16, PORTD
    andi r16, ~((1<<LED_GREEN)|(1<<LED_RED)|(1<<LED_YELLOW))
    out PORTD, r16
    
    rcall INITIAL_SETUP
    rcall UPDATE_DISPLAY
    
    sei
    ret
    
SR_CANCELLED:
    rcall LCD_CLEAR
    ldi ZL, low(STR_CANCELLED<<1)
    ldi ZH, high(STR_CANCELLED<<1)
    rcall COPY_PROGMEM_TO_BUFFER
    ldi r22, 0
    rcall LCD_PRINT_FULL_LINE
    
    sbi PORTD, LED_YELLOW
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 250
    rcall DELAY_MS
    ldi r24, 50
    rcall DELAY_MS
    cbi PORTD, LED_YELLOW
    
    rcall LCD_CLEAR
    sei
    rcall UPDATE_DISPLAY
    ret

;------------------------------------------------------------------------------
; Date Functions
;------------------------------------------------------------------------------
IS_LEAP_YEAR:
    push r16
    push r17
    
    mov r17, r16
    andi r17, 0x03
    breq ILY_DIV_BY_4
    clr r24
    rjmp ILY_END
    
ILY_DIV_BY_4:
    ldi r17, 100
    rcall DIV8
    cpi r25, 0
    brne ILY_LEAP
    cpi r16, 100
    brne ILY_NOT_LEAP
    ldi r24, 1
    rjmp ILY_END
    
ILY_NOT_LEAP:
    clr r24
    rjmp ILY_END
    
ILY_LEAP:
    ldi r24, 1
    
ILY_END:
    pop r17
    pop r16
    ret

DAYS_IN_MONTH:
    push r16
    push r17
    
    cpi r16, 0
    brne DIM_CHECK_12
    ldi r24, 31
    rjmp DIM_END
    
DIM_CHECK_12:
    cpi r16, 13
    brlo DIM_VALID
    ldi r24, 31
    rjmp DIM_END
    
DIM_VALID:
    cpi r16, 2
    brne DIM_NOT_FEB
    
    push r16
    mov r16, r17
    rcall IS_LEAP_YEAR
    pop r16
    
    cpi r24, 0
    breq DIM_FEB_28
    ldi r24, 29
    rjmp DIM_END
    
DIM_FEB_28:
    ldi r24, 28
    rjmp DIM_END
    
DIM_NOT_FEB:
    ldi ZL, low(DAYS_TABLE<<1)
    ldi ZH, high(DAYS_TABLE<<1)
    dec r16
    add ZL, r16
    adc ZH, r1
    lpm r24, Z
    
DIM_END:
    pop r17
    pop r16
    ret

ADVANCE_DATE:
    push r16
    push r17
    push r18
    
    lds r16, day
    inc r16
    
    lds r17, month
    lds r18, year
    push r16
    mov r16, r17
    mov r17, r18
    rcall DAYS_IN_MONTH
    pop r16
    
    cp r16, r24
    brlo AD_DAY_OK
    breq AD_DAY_OK
    
    ldi r16, 1
    sts day, r16
    
    lds r17, month
    inc r17
    
    cpi r17, 13
    brlo AD_MONTH_OK
    
    ldi r17, 1
    sts month, r17
    
    lds r18, year
    lds r19, year+1
    subi r18, -1
    sbci r19, -1
    sts year, r18
    sts year+1, r19
    rjmp AD_END
    
AD_MONTH_OK:
    sts month, r17
    rjmp AD_END
    
AD_DAY_OK:
    sts day, r16
    
AD_END:
    pop r18
    pop r17
    pop r16
    ret

;------------------------------------------------------------------------------
; Helper Functions
;------------------------------------------------------------------------------
BCD_CONVERT:
    push r16
    ldi r17, 10
    rcall DIV8
    
    mov r17, r24
    subi r17, -'0'
    mov r18, r25
    subi r18, -'0'
    pop r16
    ret

DIV8:
    push r16
    clr r24
    mov r25, r16
DIV8_LOOP:
    cp r25, r17
    brlo DIV8_DONE
    sub r25, r17
    inc r24
    rjmp DIV8_LOOP
DIV8_DONE:
    pop r16
    ret

YEAR_TO_ASCII:
    push r16
    push r17
    
    ldi r24, '2'
    st Z+, r24
    
    mov r16, r17
    ldi r17, 100
    rcall DIV8
    
    mov r18, r24
    ldi r24, '0'
    add r24, r18
    st Z+, r24
    
    mov r16, r25
    ldi r17, 10
    rcall DIV8
    
    mov r18, r24
    ldi r24, '0'
    add r24, r18
    st Z+, r24
    
    mov r18, r25
    ldi r24, '0'
    add r24, r18
    st Z+, r24
    
    pop r17
    pop r16
    ret

GET_MONTH_NAME:
    push r16
    push r17
    
    cpi r16, 0
    brne GMN_VALID
    ldi ZL, low(STR_MONTH_INVALID<<1)
    ldi ZH, high(STR_MONTH_INVALID<<1)
    rjmp GMN_END
    
GMN_VALID:
    cpi r16, 13
    brlo GMN_OK
    ldi ZL, low(STR_MONTH_INVALID<<1)
    ldi ZH, high(STR_MONTH_INVALID<<1)
    rjmp GMN_END
    
GMN_OK:
    dec r16
    ldi r17, 3
    mul r16, r17
    ldi ZL, low(MONTH_NAMES<<1)
    ldi ZH, high(MONTH_NAMES<<1)
    add ZL, r0
    adc ZH, r1
    
GMN_END:
    pop r17
    pop r16
    ret

COPY_PROGMEM_TO_BUFFER:
    push ZL
    push ZH
    push r16
    
    ldi XL, low(line_buffer)
    ldi XH, high(line_buffer)
    
CPTB_LOOP:
    lpm r16, Z+
    st X+, r16
    cpi r16, 0
    brne CPTB_LOOP
    
    pop r16
    pop ZH
    pop ZL
    ret

;------------------------------------------------------------------------------
; String Constants in Program Memory
;------------------------------------------------------------------------------

STR_DIGITAL_CLOCK:   .db "DIGITAL CLOCK", 0

STR_WITH_DATE:       .db "WITH DATE", 0, 0, 0

STR_INITIAL_SETUP:   .db "INITIAL SETUP", 0

STR_PLEASE_WAIT:     .db "Please Wait...", 0, 0

STR_SELECT_FORMAT:   .db "SELECT FORMAT:", 0, 0

STR_12HR_24HR:       .db "A=12HR  B=24HR", 0, 0

STR_12HR_MODE:       .db "12-HOUR MODE", 0, 0

STR_24HR_MODE:       .db "24-HOUR MODE", 0, 0

STR_SELECTED:        .db "SELECTED", 0, 0

STR_STEP1:           .db "STEP 1 OF 2:", 0, 0

STR_STEP2:           .db "STEP 2 OF 2:", 0, 0

STR_SET_TIME:        .db "SET TIME", 0, 0

STR_SET_DATE:        .db "SET DATE", 0, 0

STR_HHMMSS_AMPM:     .db "HH:MM:SS AM/PM", 0, 0

STR_HHMMSS:          .db "HH:MM:SS", 0, 0

STR_ENTER_TIME:      .db "ENTER TIME:", 0, 0, 0

STR_SELECT:          .db "SELECT:", 0, 0, 0

STR_AM_PM:           .db "A=AM    B=PM", 0, 0

STR_TIME_SET:        .db "TIME SET!", 0, 0, 0

STR_DDMMYYYY:        .db "DD-MM-YYYY", 0, 0

STR_ENTER_DATE:      .db "ENTER DATE:", 0, 0, 0

STR_DATE_SET:        .db "DATE SET!", 0, 0, 0

STR_LEAP_YEAR:       .db "LEAP YEAR!", 0, 0

STR_INVALID_MONTH:   .db "INVALID MONTH!", 0, 0

STR_INVALID_DATE:    .db "INVALID DATE!", 0, 0, 0

STR_SETUP_COMPLETE:  .db "SETUP COMPLETE!", 0, 0, 0

STR_STARTING:        .db "Starting...", 0, 0, 0

STR_RESET_SYSTEM:    .db "RESET SYSTEM?", 0, 0, 0

STR_AYES_BCANCEL:    .db "A=YES B=CANCEL", 0, 0

STR_RESETTING:       .db "RESETTING...", 0, 0

STR_RESET_COMPLETE:  .db "RESET COMPLETE!", 0, 0, 0

STR_RESTARTING:      .db "RESTARTING...", 0, 0, 0

STR_CANCELLED:       .db "CANCELLED", 0, 0, 0

STR_MONTH_INVALID:   .db "---", 0

MONTH_NAMES:         .db "JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC", 0, 0

DAYS_TABLE:          .db 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


.exit