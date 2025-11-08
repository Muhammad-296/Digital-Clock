	.file	"main.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
.global	timer_init
	.type	timer_init, @function
timer_init:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(11)
	out 0x33,r24
	ldi r24,lo8(-101)
	out 0x3c,r24
	in r24,0x39
	ori r24,lo8(2)
	out 0x39,r24
/* epilogue start */
	ret
	.size	timer_init, .-timer_init
.global	is_leap_year
	.type	is_leap_year, @function
is_leap_year:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	movw r18,r24
	sbiw r24,0
	breq .L7
	ldi r22,lo8(-112)
	ldi r23,lo8(1)
	call __udivmodhi4
	or r24,r25
	breq .L6
	movw r24,r18
	ldi r22,lo8(100)
	ldi r23,0
	call __udivmodhi4
	or r24,r25
	breq .L7
	andi r18,lo8(3)
	ldi r19,0
	ldi r24,lo8(1)
	or r18,r19
	breq .L2
.L7:
	ldi r24,0
.L2:
/* epilogue start */
	ret
.L6:
	ldi r24,lo8(1)
	ret
	.size	is_leap_year, .-is_leap_year
	.section	.rodata
.LC0:
	.base64	"AB8cHx4fHh8fHh8eHw=="
	.text
.global	days_in_month
	.type	days_in_month, @function
days_in_month:
	push r17
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,13
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 13 */
/* stack size = 16 */
.L__stack_usage = 16
	mov r17,r24
	ldi r25,lo8(13)
	ldi r30,lo8(.LC0)
	ldi r31,hi8(.LC0)
	movw r26,r28
	adiw r26,1
	0:
	ld r0,Z+
	st X+,r0
	dec r25
	brne 0b
	ldi r24,lo8(-1)
	add r24,r17
	cpi r24,lo8(12)
	brsh .L14
	cpi r17,lo8(2)
	brne .L13
	movw r24,r22
	call is_leap_year
	cpse r24,__zero_reg__
	rjmp .L15
.L13:
	movw r30,r28
	adiw r30,1
	add r30,r17
	adc r31,__zero_reg__
	ld r24,Z
.L11:
/* epilogue start */
	adiw r28,13
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	pop r17
	ret
.L14:
	ldi r24,lo8(31)
	rjmp .L11
.L15:
	ldi r24,lo8(29)
	rjmp .L11
	.size	days_in_month, .-days_in_month
.global	advance_date
	.type	advance_date, @function
advance_date:
	push r16
	push r17
	push r28
	push r29
/* prologue: function */
/* frame size = 0 */
/* stack size = 4 */
.L__stack_usage = 4
	lds r29,day
	subi r29,lo8(-(1))
	sts day,r29
	lds r16,year
	lds r17,year+1
	lds r28,month
	movw r22,r16
	mov r24,r28
	call days_in_month
	cp r24,r29
	brsh .L16
	ldi r24,lo8(1)
	sts day,r24
	subi r28,lo8(-(1))
	cpi r28,lo8(13)
	brsh .L19
	sts month,r28
.L16:
/* epilogue start */
	pop r29
	pop r28
	pop r17
	pop r16
	ret
.L19:
	sts month,r24
	subi r16,-1
	sbci r17,-1
	sts year,r16
	sts year+1,r17
	rjmp .L16
	.size	advance_date, .-advance_date
.global	__vector_10
	.type	__vector_10, @function
__vector_10:
	push r1
	push r0
	in r0,__SREG__
	push r0
	clr __zero_reg__
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r26
	push r27
	push r30
	push r31
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 15 */
.L__stack_usage = 15
	lds r24,milliseconds
	lds r25,milliseconds+1
	adiw r24,10
	sts milliseconds+1,r25
	sts milliseconds,r24
	ldi r25,lo8(1)
	sts tick_flag,r25
	lds r18,milliseconds
	lds r19,milliseconds+1
	cpi r18,-24
	sbci r19,3
	brlo .L21
	sts milliseconds+1,__zero_reg__
	sts milliseconds,__zero_reg__
	lds r24,seconds
	subi r24,lo8(-(1))
	sts seconds,r24
	sts second_flag,r25
	lds r24,seconds
	cpi r24,lo8(60)
	brlo .L21
	sts seconds,__zero_reg__
	lds r24,minutes
	subi r24,lo8(-(1))
	sts minutes,r24
	lds r24,minutes
	cpi r24,lo8(60)
	brlo .L21
	sts minutes,__zero_reg__
	lds r24,hours
	subi r24,lo8(-(1))
	sts hours,r24
	lds r24,hours
	cpi r24,lo8(24)
	brlo .L21
	sts hours,__zero_reg__
	lds r24,day
	cp r24, __zero_reg__
	breq .L21
	lds r24,month
	cp r24, __zero_reg__
	breq .L21
	lds r24,year
	lds r25,year+1
	or r24,r25
	breq .L21
	call advance_date
.L21:
/* epilogue start */
	pop r31
	pop r30
	pop r27
	pop r26
	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r0
	out __SREG__,r0
	pop r0
	pop r1
	reti
	.size	__vector_10, .-__vector_10
.global	buzzer_beep
	.type	buzzer_beep, @function
buzzer_beep:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(40)
.L35:
	sbi 0x12,6
	ldi r25,lo8(-90)
1:	dec r25
	brne 1b
	rjmp .
	cbi 0x12,6
	ldi r25,lo8(-90)
1:	dec r25
	brne 1b
	rjmp .
	subi r24,lo8(1)
	brne .L35
/* epilogue start */
	ret
	.size	buzzer_beep, .-buzzer_beep
.global	buzzer_long_beep
	.type	buzzer_long_beep, @function
buzzer_long_beep:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(-56)
.L38:
	sbi 0x12,6
	ldi r25,lo8(-90)
1:	dec r25
	brne 1b
	rjmp .
	cbi 0x12,6
	ldi r25,lo8(-90)
1:	dec r25
	brne 1b
	rjmp .
	subi r24,lo8(1)
	brne .L38
/* epilogue start */
	ret
	.size	buzzer_long_beep, .-buzzer_long_beep
.global	LCD_Command
	.type	LCD_Command, @function
LCD_Command:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	out 0x18,r24
	cbi 0x12,0
	cbi 0x12,1
	sbi 0x12,2
	nop
	cbi 0x12,2
	ldi r24,lo8(499)
	ldi r25,hi8(499)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
/* epilogue start */
	ret
	.size	LCD_Command, .-LCD_Command
.global	LCD_Char
	.type	LCD_Char, @function
LCD_Char:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	out 0x18,r24
	sbi 0x12,0
	cbi 0x12,1
	sbi 0x12,2
	nop
	cbi 0x12,2
	ldi r24,lo8(499)
	ldi r25,hi8(499)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
/* epilogue start */
	ret
	.size	LCD_Char, .-LCD_Char
.global	LCD_Init
	.type	LCD_Init, @function
LCD_Init:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	in r24,0x11
	ori r24,lo8(7)
	out 0x11,r24
	ldi r24,lo8(-1)
	out 0x17,r24
	ldi r24,lo8(4999)
	ldi r25,hi8(4999)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	ldi r24,lo8(56)
	call LCD_Command
	ldi r24,lo8(12)
	call LCD_Command
	ldi r24,lo8(6)
	call LCD_Command
	ldi r24,lo8(1)
	call LCD_Command
	ldi r24,lo8(499)
	ldi r25,hi8(499)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	ldi r24,lo8(-128)
	jmp LCD_Command
	.size	LCD_Init, .-LCD_Init
.global	LCD_Clear
	.type	LCD_Clear, @function
LCD_Clear:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(1)
	call LCD_Command
	ldi r24,lo8(-128)
	jmp LCD_Command
	.size	LCD_Clear, .-LCD_Clear
.global	LCD_String
	.type	LCD_String, @function
LCD_String:
	push r28
	push r29
/* prologue: function */
/* frame size = 0 */
/* stack size = 2 */
.L__stack_usage = 2
	movw r28,r24
.L45:
	ld r24,Y
	cpse r24,__zero_reg__
	rjmp .L46
/* epilogue start */
	pop r29
	pop r28
	ret
.L46:
	adiw r28,1
	call LCD_Char
	rjmp .L45
	.size	LCD_String, .-LCD_String
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"AM"
.LC2:
	.string	"PM"
.LC3:
	.string	" %02d:%02d:%02d %s  "
.LC4:
	.string	"   %02d:%02d:%02d    "
.LC5:
	.string	" 00-00-0000     "
.LC6:
	.string	" %02d-%02d-%04d   "
.LC7:
	.string	" 00-000-0000    "
.LC8:
	.string	" %02d-%s-%04d  "
.LC9:
	.string	"   %02d:%02d %s   "
.LC10:
	.string	"    %02d:%02d     "
	.text
.global	update_display
	.type	update_display, @function
update_display:
	push r10
	push r11
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,37
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 37 */
/* stack size = 46 */
.L__stack_usage = 46
	lds r24,display_mode
	movw r16,r28
	subi r16,-18
	sbci r17,-1
	movw r14,r28
	ldi r25,-1
	sub r14,r25
	sbc r15,r25
	cpse r24,__zero_reg__
	rjmp .L48
	lds r13,hours
	ldi r24,lo8(32)
	ldi r25,lo8(32)
	std Y+35,r24
	std Y+36,r25
	std Y+37,__zero_reg__
	lds r24,mode_12hr
	cp r24, __zero_reg__
	brne .+2
	rjmp .L49
	lds r24,hours
	cp r24, __zero_reg__
	brne .+2
	rjmp .L66
	lds r24,hours
	cpi r24,lo8(13)
	brlo .L50
	lds r24,hours
	ldi r21,lo8(-12)
	mov r13,r21
	add r13,r24
.L50:
	lds r24,hours
	movw r10,r28
	ldi r25,35
	add r10,r25
	adc r11,__zero_reg__
	ldi r22,lo8(.LC1)
	ldi r23,hi8(.LC1)
	cpi r24,lo8(12)
	brlo .L80
	ldi r22,lo8(.LC2)
	ldi r23,hi8(.LC2)
.L80:
	movw r24,r10
	call strcpy
	lds r25,seconds
	lds r24,minutes
	push r11
	push r10
	push __zero_reg__
	push r25
	push __zero_reg__
	push r24
	push __zero_reg__
	push r13
	ldi r24,lo8(.LC3)
	ldi r25,hi8(.LC3)
	push r25
	push r24
	push __zero_reg__
	ldi r24,lo8(17)
	push r24
	push r17
	push r16
	call snprintf
.L81:
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	lds r19,month
	cp r19, __zero_reg__
	breq .L54
	lds r18,day
	cp r18, __zero_reg__
	breq .L54
	lds r24,year
	lds r25,year+1
	sbiw r24,0
	brne .L55
.L54:
	ldi r22,lo8(.LC5)
	ldi r23,hi8(.LC5)
	movw r24,r14
	call strcpy
.L57:
	ldi r24,lo8(-128)
	call LCD_Command
	movw r24,r16
	call LCD_String
	ldi r24,lo8(-64)
	call LCD_Command
	movw r24,r14
	call LCD_String
/* epilogue start */
	adiw r28,37
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r11
	pop r10
	ret
.L66:
	ldi r20,lo8(12)
	mov r13,r20
	rjmp .L50
.L49:
	lds r18,seconds
	lds r25,minutes
	lds r24,hours
	push __zero_reg__
	push r18
	push __zero_reg__
	push r25
	push __zero_reg__
	push r24
	ldi r24,lo8(.LC4)
	ldi r25,hi8(.LC4)
	push r25
	push r24
	push __zero_reg__
	ldi r24,lo8(17)
	push r24
	push r17
	push r16
	call snprintf
	rjmp .L81
.L55:
	push r25
	push r24
	push __zero_reg__
	push r19
	push __zero_reg__
	push r18
	ldi r24,lo8(.LC6)
	ldi r25,hi8(.LC6)
.L84:
	push r25
	push r24
	push __zero_reg__
	ldi r24,lo8(17)
	push r24
	push r15
	push r14
	call snprintf
.L83:
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	rjmp .L57
.L48:
	lds r30,month
	cp r30, __zero_reg__
	breq .L58
	lds r18,day
	cp r18, __zero_reg__
	breq .L58
	lds r24,year
	lds r25,year+1
	sbiw r24,0
	brne .L59
.L58:
	ldi r22,lo8(.LC7)
	ldi r23,hi8(.LC7)
	movw r24,r16
	call strcpy
.L60:
	lds r13,hours
	ldi r24,lo8(32)
	ldi r25,lo8(32)
	std Y+35,r24
	std Y+36,r25
	std Y+37,__zero_reg__
	lds r24,mode_12hr
	cp r24, __zero_reg__
	brne .+2
	rjmp .L61
	lds r24,hours
	cp r24, __zero_reg__
	brne .+2
	rjmp .L67
	lds r24,hours
	cpi r24,lo8(13)
	brlo .L62
	lds r24,hours
	ldi r25,lo8(-12)
	mov r13,r25
	add r13,r24
.L62:
	lds r24,hours
	movw r10,r28
	ldi r25,35
	add r10,r25
	adc r11,__zero_reg__
	ldi r22,lo8(.LC1)
	ldi r23,hi8(.LC1)
	cpi r24,lo8(12)
	brlo .L82
	ldi r22,lo8(.LC2)
	ldi r23,hi8(.LC2)
.L82:
	movw r24,r10
	call strcpy
	lds r24,minutes
	push r11
	push r10
	push __zero_reg__
	push r24
	push __zero_reg__
	push r13
	ldi r24,lo8(.LC9)
	ldi r25,hi8(.LC9)
	rjmp .L84
.L59:
	push r25
	push r24
	ldi r31,0
	lsl r30
	rol r31
	subi r30,lo8(-(month_names))
	sbci r31,hi8(-(month_names))
	ldd r24,Z+1
	push r24
	ld r24,Z
	push r24
	push __zero_reg__
	push r18
	ldi r24,lo8(.LC8)
	ldi r25,hi8(.LC8)
	push r25
	push r24
	push __zero_reg__
	ldi r24,lo8(17)
	push r24
	push r17
	push r16
	call snprintf
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	rjmp .L60
.L67:
	ldi r24,lo8(12)
	mov r13,r24
	rjmp .L62
.L61:
	lds r25,minutes
	lds r24,hours
	push __zero_reg__
	push r25
	push __zero_reg__
	push r24
	ldi r24,lo8(.LC10)
	ldi r25,hi8(.LC10)
	push r25
	push r24
	push __zero_reg__
	ldi r24,lo8(17)
	push r24
	push r15
	push r14
	call snprintf
	rjmp .L83
	.size	update_display, .-update_display
.global	LCD_String_xy
	.type	LCD_String_xy, @function
LCD_String_xy:
	push r28
	push r29
	rcall .
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 2 */
/* stack size = 4 */
.L__stack_usage = 4
	std Y+1,r20
	std Y+2,r21
	cpi r24,lo8(1)
	brsh .L86
	mov r24,r22
	andi r24,lo8(15)
	ori r24,lo8(-128)
	cpi r22,lo8(16)
	brlt .L88
.L87:
	ldd r24,Y+1
	ldd r25,Y+2
/* epilogue start */
	pop __tmp_reg__
	pop __tmp_reg__
	pop r29
	pop r28
	jmp LCD_String
.L86:
	brne .L87
	cpi r22,lo8(16)
	brge .L87
	mov r24,r22
	andi r24,lo8(15)
	ori r24,lo8(-64)
.L88:
	call LCD_Command
	rjmp .L87
	.size	LCD_String_xy, .-LCD_String_xy
.global	LCD_PutCharAt
	.type	LCD_PutCharAt, @function
LCD_PutCharAt:
	push r28
	push r29
	push __tmp_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	std Y+1,r24
	mov r24,r20
	cpi r22,lo8(1)
	brsh .L90
	cpi r20,lo8(16)
	brsh .L91
	ori r24,lo8(-128)
.L92:
	call LCD_Command
.L91:
	ldd r24,Y+1
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	jmp LCD_Char
.L90:
	brne .L91
	cpi r20,lo8(16)
	brsh .L91
	ori r24,lo8(-64)
	rjmp .L92
	.size	LCD_PutCharAt, .-LCD_PutCharAt
.global	LCD_Print_Center
	.type	LCD_Print_Center, @function
LCD_Print_Center:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	movw r20,r24
	mov r24,r22
	movw r30,r20
	0:
	ld __tmp_reg__,Z+
	tst __tmp_reg__
	brne 0b
	dec r30
	sub r30,r20
	cpi r30,lo8(17)
	brlo .L94
	ldi r30,lo8(16)
.L94:
	ldi r22,lo8(16)
	ldi r23,0
	sub r22,r30
	sbc r23,__zero_reg__
	asr r23
	ror r22
	jmp LCD_String_xy
	.size	LCD_Print_Center, .-LCD_Print_Center
.global	LCD_Print_Full_Line
	.type	LCD_Print_Full_Line, @function
LCD_Print_Full_Line:
	push r16
	push r17
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,17
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 17 */
/* stack size = 21 */
.L__stack_usage = 21
	movw r26,r24
	mov r24,r22
	movw r30,r26
	0:
	ld __tmp_reg__,Z+
	tst __tmp_reg__
	brne 0b
	dec r30
	mov r16,r30
	sub r16,r26
	cpi r16,lo8(17)
	brlo .L96
	ldi r16,lo8(16)
.L96:
	ldi r18,lo8(16)
	ldi r19,0
	sub r18,r16
	sbc r19,__zero_reg__
	asr r19
	ror r18
	mov r25,r18
	movw r20,r28
	subi r20,-1
	sbci r21,-1
	movw r22,r20
	ldi r17,lo8(32)
.L97:
	mov r31,r22
	sub r31,r20
	cp r31,r25
	brlo .L98
	add r18,r16
.L99:
	cpse r25,r18
	rjmp .L100
	movw r30,r20
	add r30,r18
	adc r31,__zero_reg__
	ldi r25,lo8(32)
.L101:
	cpi r18,lo8(16)
	brlo .L102
	std Y+17,__zero_reg__
	ldi r22,0
	call LCD_String_xy
/* epilogue start */
	adiw r28,17
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	pop r17
	pop r16
	ret
.L98:
	movw r30,r22
	st Z+,r17
	movw r22,r30
	rjmp .L97
.L100:
	ld r19,X+
	movw r30,r20
	add r30,r25
	adc r31,__zero_reg__
	st Z,r19
	subi r25,lo8(-(1))
	rjmp .L99
.L102:
	subi r18,lo8(-(1))
	st Z+,r25
	rjmp .L101
	.size	LCD_Print_Full_Line, .-LCD_Print_Full_Line
	.section	.rodata.str1.1
.LC11:
	.string	"12-HOUR MODE"
.LC12:
	.string	"24-HOUR MODE"
	.text
.global	toggle_12hr_mode
	.type	toggle_12hr_mode, @function
toggle_12hr_mode:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(1)
	lds r25,mode_12hr
	cpse r25,__zero_reg__
	ldi r24,0
.L104:
	sts mode_12hr,r24
	call LCD_Clear
	lds r24,mode_12hr
	ldi r22,0
	cp r24, __zero_reg__
	breq .L105
	ldi r24,lo8(.LC11)
	ldi r25,hi8(.LC11)
.L110:
	call LCD_Print_Full_Line
	sbi 0x12,5
	ldi r18,lo8(119999)
	ldi r24,hi8(119999)
	ldi r25,hlo8(119999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	cbi 0x12,5
	jmp LCD_Clear
.L105:
	ldi r24,lo8(.LC12)
	ldi r25,hi8(.LC12)
	rjmp .L110
	.size	toggle_12hr_mode, .-toggle_12hr_mode
.global	keycheck
	.type	keycheck, @function
keycheck:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	in r24,0x15
	andi r24,lo8(-16)
	ori r24,lo8(14)
	out 0x15,r24
	ldi r24,lo8(749)
	ldi r25,hi8(749)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	sbis 0x13,4
	rjmp .L113
	sbis 0x13,5
	rjmp .L114
	sbis 0x13,6
	rjmp .L115
	sbis 0x13,7
	rjmp .L116
	in r24,0x15
	andi r24,lo8(-16)
	ori r24,lo8(13)
	out 0x15,r24
	ldi r24,lo8(749)
	ldi r25,hi8(749)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	sbis 0x13,4
	rjmp .L117
	sbis 0x13,5
	rjmp .L118
	sbis 0x13,6
	rjmp .L119
	sbis 0x13,7
	rjmp .L120
	in r24,0x15
	andi r24,lo8(-16)
	ori r24,lo8(11)
	out 0x15,r24
	ldi r24,lo8(749)
	ldi r25,hi8(749)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	sbis 0x13,4
	rjmp .L121
	sbis 0x13,5
	rjmp .L122
	sbis 0x13,6
	rjmp .L123
	sbis 0x13,7
	rjmp .L124
	in r24,0x15
	andi r24,lo8(-16)
	ori r24,lo8(7)
	out 0x15,r24
	ldi r24,lo8(749)
	ldi r25,hi8(749)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	sbis 0x13,4
	rjmp .L125
	sbis 0x13,5
	rjmp .L126
	sbis 0x13,6
	rjmp .L127
	sbis 0x13,7
	rjmp .L128
	in r24,0x15
	ori r24,lo8(15)
	out 0x15,r24
	ldi r24,lo8(97)
	ret
.L113:
	ldi r24,lo8(49)
	ret
.L114:
	ldi r24,lo8(50)
	ret
.L115:
	ldi r24,lo8(51)
	ret
.L116:
	ldi r24,lo8(65)
	ret
.L117:
	ldi r24,lo8(52)
	ret
.L118:
	ldi r24,lo8(53)
	ret
.L119:
	ldi r24,lo8(54)
	ret
.L120:
	ldi r24,lo8(66)
	ret
.L121:
	ldi r24,lo8(55)
	ret
.L122:
	ldi r24,lo8(56)
	ret
.L123:
	ldi r24,lo8(57)
	ret
.L124:
	ldi r24,lo8(67)
	ret
.L125:
	ldi r24,lo8(42)
	ret
.L126:
	ldi r24,lo8(48)
	ret
.L127:
	ldi r24,lo8(35)
	ret
.L128:
	ldi r24,lo8(68)
/* epilogue start */
	ret
	.size	keycheck, .-keycheck
.global	scankey
	.type	scankey, @function
scankey:
	push r28
/* prologue: function */
/* frame size = 0 */
/* stack size = 1 */
.L__stack_usage = 1
.L130:
	call keycheck
	mov r28,r24
	cpi r24,lo8(97)
	brne .L131
	ldi r24,lo8(1249)
	ldi r25,hi8(1249)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	rjmp .L130
.L131:
	ldi r24,lo8(2499)
	ldi r25,hi8(2499)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	call keycheck
	cpse r24,r28
	rjmp .L130
.L133:
	call keycheck
	cp r24,r28
	breq .L134
	ldi r24,lo8(2499)
	ldi r25,hi8(2499)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	mov r24,r28
/* epilogue start */
	pop r28
	ret
.L134:
	ldi r24,lo8(1249)
	ldi r25,hi8(1249)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
	rjmp .L133
	.size	scankey, .-scankey
	.section	.rodata.str1.1
.LC13:
	.string	"SET TIME"
.LC14:
	.string	"HH:MM:SS AM/PM"
.LC15:
	.string	"HH:MM:SS"
.LC16:
	.string	"ENTER TIME:"
.LC17:
	.string	"__:__:__"
.LC18:
	.string	"SELECT:"
.LC19:
	.string	"A=AM    B=PM"
.LC20:
	.string	"TIME SET!"
	.text
.global	set_time_12hr
	.type	set_time_12hr, @function
set_time_12hr:
	push r16
	push r17
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,8
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 8 */
/* stack size = 12 */
.L__stack_usage = 12
/* #APP */
 ;  521 "main.c" 1
	cli
 ;  0 "" 2
/* #NOAPP */
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC13)
	ldi r25,hi8(.LC13)
	call LCD_Print_Full_Line
	lds r24,mode_12hr
	ldi r22,lo8(1)
	cp r24, __zero_reg__
	brne .+2
	rjmp .L137
	ldi r24,lo8(.LC14)
	ldi r25,hi8(.LC14)
.L168:
	call LCD_Print_Full_Line
	ldi r18,lo8(159999)
	ldi r24,hi8(159999)
	ldi r25,hlo8(159999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC16)
	ldi r25,hi8(.LC16)
	call LCD_Print_Full_Line
	ldi r24,lo8(-62)
	call LCD_Command
	ldi r24,lo8(.LC17)
	ldi r25,hi8(.LC17)
	call LCD_String
	ldi r17,0
.L146:
	call scankey
	mov r16,r24
	ldi r24,lo8(-48)
	add r24,r16
	cpi r24,lo8(10)
	brlo .+2
	rjmp .L139
	ldi r24,lo8(1)
	cpi r17,lo8(2)
	brsh .L140
	ldi r24,0
.L140:
	ldi r20,lo8(2)
	add r20,r17
	add r20,r24
	ldi r24,lo8(1)
	cpi r17,lo8(4)
	brsh .L141
	ldi r24,0
.L141:
	add r20,r24
	ldi r22,lo8(1)
	mov r24,r16
	call LCD_PutCharAt
	movw r30,r28
	adiw r30,1
	add r30,r17
	adc r31,__zero_reg__
	st Z,r16
	cpi r17,lo8(5)
	breq .+2
	rjmp .L156
	ldd r18,Y+1
	subi r18,48
	sbc r19,__zero_reg__
	ldi r24,lo8(10)
	ldd r16,Y+2
	mul r24,r18
	add r16,r0
	clr __zero_reg__
	ldi r17,lo8(-48)
	add r17,r16
	ldd r18,Y+3
	subi r18,48
	sbc r19,__zero_reg__
	ldd r25,Y+4
	subi r25,lo8(-(-48))
	mul r24,r18
	add r25,r0
	clr __zero_reg__
	sts minutes,r25
	ldd r18,Y+5
	subi r18,48
	ldd r25,Y+6
	subi r25,lo8(-(-48))
	mul r24,r18
	add r25,r0
	clr __zero_reg__
	sts seconds,r25
	lds r24,mode_12hr
	cp r24, __zero_reg__
	breq .L147
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC18)
	ldi r25,hi8(.LC18)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC19)
	ldi r25,hi8(.LC19)
	call LCD_Print_Full_Line
.L148:
	call scankey
	std Y+8,r24
	subi r24,lo8(-(-65))
	cpi r24,lo8(2)
	brsh .L148
	call buzzer_beep
	cpi r17,lo8(12)
	breq .+2
	rjmp .L149
	ldd r18,Y+8
	cpi r18,lo8(65)
	brne .L147
	ldi r17,0
.L147:
	sts hours,r17
	sts milliseconds+1,__zero_reg__
	sts milliseconds,__zero_reg__
	lds r24,hours
	cpi r24,lo8(24)
	brlo .L153
	ldi r24,lo8(23)
	sts hours,r24
.L153:
	lds r24,minutes
	cpi r24,lo8(60)
	brlo .L154
	ldi r24,lo8(59)
	sts minutes,r24
.L154:
	lds r24,seconds
	cpi r24,lo8(60)
	brlo .L155
	ldi r24,lo8(59)
	sts seconds,r24
.L155:
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC20)
	ldi r25,hi8(.LC20)
	call LCD_Print_Full_Line
	sbi 0x12,3
	sbi 0x12,5
	ldi r25,lo8(159999)
	ldi r18,hi8(159999)
	ldi r24,hlo8(159999)
1:	subi r25,1
	sbci r18,0
	sbci r24,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
	call LCD_Clear
/* #APP */
 ;  617 "main.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
/* epilogue start */
	adiw r28,8
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	pop r17
	pop r16
	ret
.L137:
	ldi r24,lo8(.LC15)
	ldi r25,hi8(.LC15)
	rjmp .L168
.L139:
	cpi r16,lo8(42)
	breq .+2
	rjmp .L146
	cp r17, __zero_reg__
	brne .+2
	rjmp .L146
	ldi r16,lo8(-1)
	add r16,r17
	ldi r24,lo8(1)
	cpi r16,lo8(2)
	brsh .L144
	ldi r24,0
.L144:
	ldi r20,lo8(1)
	add r20,r17
	add r20,r24
	ldi r24,lo8(1)
	cpi r16,lo8(4)
	breq .L145
	ldi r24,0
.L145:
	add r20,r24
	ldi r22,lo8(1)
	ldi r24,lo8(95)
	call LCD_PutCharAt
	mov r17,r16
	rjmp .L146
.L156:
	subi r17,lo8(-(1))
	rjmp .L146
.L149:
	ldd r24,Y+8
	cpi r24,lo8(65)
	brne .+2
	rjmp .L147
	ldi r17,lo8(-36)
	add r17,r16
	rjmp .L147
	.size	set_time_12hr, .-set_time_12hr
	.section	.rodata.str1.1
.LC21:
	.string	"SET DATE"
.LC22:
	.string	"DD-MM-YYYY"
.LC23:
	.string	"ENTER DATE:"
.LC24:
	.string	"__-__-____"
.LC25:
	.string	"LEAP YEAR!"
.LC26:
	.string	"DATE SET!"
.LC27:
	.string	"INVALID DATE!"
.LC28:
	.string	"INVALID MONTH!"
	.text
.global	set_date
	.type	set_date, @function
set_date:
	push r15
	push r16
	push r17
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,10
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 10 */
/* stack size = 15 */
.L__stack_usage = 15
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC21)
	ldi r25,hi8(.LC21)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC22)
	ldi r25,hi8(.LC22)
	call LCD_Print_Full_Line
	ldi r18,lo8(159999)
	ldi r24,hi8(159999)
	ldi r25,hlo8(159999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC23)
	ldi r25,hi8(.LC23)
	call LCD_Print_Full_Line
	ldi r24,lo8(-63)
	call LCD_Command
	ldi r24,lo8(.LC24)
	ldi r25,hi8(.LC24)
	call LCD_String
	ldi r17,0
.L177:
	call scankey
	mov r16,r24
	ldi r24,lo8(-48)
	add r24,r16
	cpi r24,lo8(10)
	brlo .+2
	rjmp .L170
	clr r15
	inc r15
	add r15,r17
	ldi r20,lo8(1)
	cpi r17,lo8(2)
	brsh .L171
	ldi r20,0
.L171:
	ldi r24,lo8(1)
	cpi r17,lo8(4)
	brsh .L172
	ldi r24,0
.L172:
	add r20,r24
	add r20,r15
	ldi r22,lo8(1)
	mov r24,r16
	call LCD_PutCharAt
	movw r30,r28
	adiw r30,1
	add r30,r17
	adc r31,__zero_reg__
	st Z,r16
	ldi r18,lo8(8)
	cpse r15,r18
	rjmp .L183
	ldd r20,Y+3
	subi r20,48
	sbc r21,__zero_reg__
	ldi r18,lo8(10)
	ldd r24,Y+4
	mul r18,r20
	add r24,r0
	clr __zero_reg__
	ldi r25,lo8(-49)
	add r25,r24
	cpi r25,lo8(12)
	brlo .+2
	rjmp .L178
	ldd r20,Y+1
	subi r20,48
	ldd r25,Y+2
	subi r25,lo8(-(-48))
	mov r15,r25
	mul r18,r20
	add r15,r0
	clr __zero_reg__
	cp r15, __zero_reg__
	brne .+2
	rjmp .L179
	subi r24,lo8(-(-48))
	std Y+10,r24
	ldd r24,Y+5
	mov r25,r24
	lsl r25
	sbc r25,r25
	sbiw r24,48
	ldi r20,lo8(-24)
	ldi r21,lo8(3)
	mul r24,r20
	movw r16,r0
	mul r24,r21
	add r17,r0
	mul r25,r20
	add r17,r0
	clr r1
	ldd r24,Y+6
	mov r25,r24
	lsl r25
	sbc r25,r25
	sbiw r24,48
	ldi r19,lo8(100)
	mul r19,r24
	movw r20,r0
	mul r19,r25
	add r21,r0
	clr __zero_reg__
	add r16,r20
	adc r17,r21
	ldd r24,Y+7
	mov r25,r24
	lsl r25
	sbc r25,r25
	sbiw r24,48
	mul r18,r24
	movw r20,r0
	mul r18,r25
	add r21,r0
	clr __zero_reg__
	add r16,r20
	adc r17,r21
	ldd r24,Y+8
	mov r25,r24
	lsl r25
	sbc r25,r25
	sbiw r24,48
	add r16,r24
	adc r17,r25
	movw r22,r16
	ldd r24,Y+10
	call days_in_month
	cp r24,r15
	brsh .+2
	rjmp .L179
	movw r24,r16
	subi r24,-48
	sbci r25,7
	cpi r24,100
	cpc r25,__zero_reg__
	brlo .+2
	rjmp .L179
	sts day,r15
	ldd r24,Y+10
	sts month,r24
	sts year,r16
	sts year+1,r17
	call LCD_Clear
	lds r24,year
	lds r25,year+1
	call is_leap_year
	ldi r22,0
	cp r24, __zero_reg__
	breq .L180
	lds r24,month
	cpi r24,lo8(2)
	brne .L180
	ldi r24,lo8(.LC25)
	ldi r25,hi8(.LC25)
.L194:
	call LCD_Print_Full_Line
	sbi 0x12,4
	sbi 0x12,5
	ldi r25,lo8(159999)
	ldi r18,hi8(159999)
	ldi r24,hlo8(159999)
1:	subi r25,1
	sbci r18,0
	sbci r24,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
.L182:
/* epilogue start */
	adiw r28,10
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	jmp LCD_Clear
.L170:
	cpi r16,lo8(42)
	breq .+2
	rjmp .L177
	cp r17, __zero_reg__
	brne .+2
	rjmp .L177
	ldi r16,lo8(-1)
	add r16,r17
	ldi r20,lo8(1)
	cpi r16,lo8(2)
	brsh .L175
	ldi r20,0
.L175:
	ldi r24,lo8(1)
	cpi r16,lo8(4)
	brsh .L176
	ldi r24,0
.L176:
	add r20,r24
	add r20,r17
	ldi r22,lo8(1)
	ldi r24,lo8(95)
	call LCD_PutCharAt
	mov r17,r16
	rjmp .L177
.L183:
	mov r17,r15
	rjmp .L177
.L180:
	ldi r24,lo8(.LC26)
	ldi r25,hi8(.LC26)
	rjmp .L194
.L179:
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC27)
	ldi r25,hi8(.LC27)
.L195:
	call LCD_Print_Full_Line
	ldi r25,lo8(159999)
	ldi r18,hi8(159999)
	ldi r24,hlo8(159999)
1:	subi r25,1
	sbci r18,0
	sbci r24,0
	brne 1b
	rjmp .
	nop
	rjmp .L182
.L178:
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC28)
	ldi r25,hi8(.LC28)
	rjmp .L195
	.size	set_date, .-set_date
	.section	.rodata.str1.1
.LC29:
	.string	"INITIAL SETUP"
.LC30:
	.string	"Please Wait..."
.LC31:
	.string	"SELECT FORMAT:"
.LC32:
	.string	"A=12HR  B=24HR"
.LC33:
	.string	"SELECTED"
.LC34:
	.string	"STEP 1 OF 2:"
.LC35:
	.string	"STEP 2 OF 2:"
.LC36:
	.string	"SETUP COMPLETE!"
.LC37:
	.string	"Starting..."
	.text
.global	initial_setup
	.type	initial_setup, @function
initial_setup:
	push r28
/* prologue: function */
/* frame size = 0 */
/* stack size = 1 */
.L__stack_usage = 1
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC29)
	ldi r25,hi8(.LC29)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC30)
	ldi r25,hi8(.LC30)
	call LCD_Print_Full_Line
	sbi 0x12,5
	sbi 0x12,4
	ldi r18,lo8(179999)
	ldi r24,hi8(179999)
	ldi r25,hlo8(179999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC31)
	ldi r25,hi8(.LC31)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC32)
	ldi r25,hi8(.LC32)
	call LCD_Print_Full_Line
.L197:
	call scankey
	mov r28,r24
	ldi r24,lo8(-65)
	add r24,r28
	cpi r24,lo8(2)
	brsh .L197
	call buzzer_beep
	ldi r24,lo8(1)
	cpi r28,lo8(65)
	breq .L198
	ldi r24,0
.L198:
	sts mode_12hr,r24
	call LCD_Clear
	lds r24,mode_12hr
	ldi r22,0
	cp r24, __zero_reg__
	brne .+2
	rjmp .L199
	ldi r24,lo8(.LC11)
	ldi r25,hi8(.LC11)
.L205:
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC33)
	ldi r25,hi8(.LC33)
	call LCD_Print_Full_Line
	sbi 0x12,3
	ldi r18,lo8(159999)
	ldi r24,hi8(159999)
	ldi r25,hlo8(159999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	cbi 0x12,3
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC34)
	ldi r25,hi8(.LC34)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC13)
	ldi r25,hi8(.LC13)
	call LCD_Print_Full_Line
	ldi r18,lo8(179999)
	ldi r24,hi8(179999)
	ldi r25,hlo8(179999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	call set_time_12hr
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC35)
	ldi r25,hi8(.LC35)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC21)
	ldi r25,hi8(.LC21)
	call LCD_Print_Full_Line
	ldi r18,lo8(179999)
	ldi r24,hi8(179999)
	ldi r25,hlo8(179999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	call set_date
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC36)
	ldi r25,hi8(.LC36)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC37)
	ldi r25,hi8(.LC37)
	call LCD_Print_Full_Line
	in r24,0x12
	ori r24,lo8(56)
	out 0x12,r24
	ldi r18,lo8(239999)
	ldi r24,hi8(239999)
	ldi r25,hlo8(239999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
/* epilogue start */
	pop r28
	jmp LCD_Clear
.L199:
	ldi r24,lo8(.LC12)
	ldi r25,hi8(.LC12)
	rjmp .L205
	.size	initial_setup, .-initial_setup
	.section	.rodata.str1.1
.LC38:
	.string	"RESET SYSTEM?"
.LC39:
	.string	"A=YES B=CANCEL"
.LC40:
	.string	"RESETTING..."
.LC41:
	.string	"RESET COMPLETE!"
.LC42:
	.string	"RESTARTING..."
.LC43:
	.string	"CANCELLED"
	.text
.global	system_reset
	.type	system_reset, @function
system_reset:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
/* #APP */
 ;  270 "main.c" 1
	cli
 ;  0 "" 2
/* #NOAPP */
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC38)
	ldi r25,hi8(.LC38)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC39)
	ldi r25,hi8(.LC39)
	call LCD_Print_Full_Line
	ldi r24,lo8(5)
.L207:
	in r25,0x12
	ori r25,lo8(56)
	out 0x12,r25
	sbi 0x12,6
	ldi r30,lo8(-28037)
	ldi r31,hi8(-28037)
1:	sbiw r30,1
	brne 1b
	rjmp .
	nop
	in r25,0x12
	andi r25,lo8(-57)
	out 0x12,r25
	cbi 0x12,6
	ldi r30,lo8(-28037)
	ldi r31,hi8(-28037)
1:	sbiw r30,1
	brne 1b
	rjmp .
	nop
	subi r24,lo8(1)
	brne .L207
.L208:
	call scankey
	ldi r25,lo8(-65)
	add r25,r24
	cpi r25,lo8(2)
	brsh .L208
	cpi r24,lo8(65)
	breq .+2
	rjmp .L209
	call buzzer_long_beep
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC40)
	ldi r25,hi8(.LC40)
	call LCD_Print_Full_Line
	sbi 0x12,4
	sts hours,__zero_reg__
	sts minutes,__zero_reg__
	sts seconds,__zero_reg__
	sts milliseconds+1,__zero_reg__
	sts milliseconds,__zero_reg__
	sts day,__zero_reg__
	sts month,__zero_reg__
	sts year,__zero_reg__
	sts year+1,__zero_reg__
	ldi r24,lo8(1)
	sts mode_12hr,r24
	sts display_mode,__zero_reg__
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC41)
	ldi r25,hi8(.LC41)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC42)
	ldi r25,hi8(.LC42)
	call LCD_Print_Full_Line
	in r24,0x12
	ori r24,lo8(56)
	out 0x12,r24
	ldi r31,lo8(239999)
	ldi r18,hi8(239999)
	ldi r24,hlo8(239999)
1:	subi r31,1
	sbci r18,0
	sbci r24,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
	call initial_setup
	call update_display
/* #APP */
 ;  324 "main.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
/* epilogue start */
	ret
.L209:
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC43)
	ldi r25,hi8(.LC43)
	call LCD_Print_Full_Line
	sbi 0x12,5
	ldi r25,lo8(159999)
	ldi r30,hi8(159999)
	ldi r31,hlo8(159999)
1:	subi r25,1
	sbci r30,0
	sbci r31,0
	brne 1b
	rjmp .
	nop
	cbi 0x12,5
	call LCD_Clear
/* #APP */
 ;  334 "main.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
	jmp update_display
	.size	system_reset, .-system_reset
	.section	.rodata.str1.1
.LC44:
	.string	"DIGITAL CLOCK"
.LC45:
	.string	"WITH DATE"
	.section	.text.startup,"ax",@progbits
.global	main
	.type	main, @function
main:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(-1)
	out 0x17,r24
	in r24,0x11
	ori r24,lo8(7)
	out 0x11,r24
	sbi 0x11,3
	sbi 0x11,4
	sbi 0x11,5
	sbi 0x11,6
	in r24,0x14
	andi r24,lo8(15)
	out 0x14,r24
	in r24,0x14
	ori r24,lo8(15)
	out 0x14,r24
	in r24,0x15
	ori r24,lo8(-16)
	out 0x15,r24
	in r24,0x15
	ori r24,lo8(15)
	out 0x15,r24
	call LCD_Init
	call timer_init
/* #APP */
 ;  195 "main.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
	call LCD_Clear
	ldi r22,0
	ldi r24,lo8(.LC44)
	ldi r25,hi8(.LC44)
	call LCD_Print_Full_Line
	ldi r22,lo8(1)
	ldi r24,lo8(.LC45)
	ldi r25,hi8(.LC45)
	call LCD_Print_Full_Line
	sbi 0x12,5
	sbi 0x12,3
	ldi r18,lo8(239999)
	ldi r24,hi8(239999)
	ldi r25,hlo8(239999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	in r24,0x12
	andi r24,lo8(-57)
	out 0x12,r24
	call LCD_Clear
	call initial_setup
	call update_display
	ldi r18,lo8(99999)
	ldi r24,hi8(99999)
	ldi r25,hlo8(99999)
1:	subi r18,1
	sbci r24,0
	sbci r25,0
	brne 1b
	rjmp .
	nop
	call LCD_Clear
	lds r17,seconds
	ldi r29,0
	ldi r16,lo8(1)
.L215:
	lds r24,seconds
	cp r24,r17
	breq .L216
	lds r17,seconds
	call update_display
	mov r24,r29
	eor r24,r16
	cpi r29,lo8(1)
	breq .L217
	sbi 0x12,3
.L218:
	lds r25,minutes
	cpse r25,__zero_reg__
	rjmp .L219
	lds r25,seconds
	cpi r25,lo8(3)
	brsh .L219
	sbi 0x12,5
.L220:
	mov r29,r24
.L216:
	call keycheck
	mov r28,r24
	cpi r24,lo8(97)
	breq .L215
	ldi r24,lo8(4999)
	ldi r25,hi8(4999)
1:	sbiw r24,1
	brne 1b
	rjmp .
	nop
.L222:
	call keycheck
	cpi r24,lo8(97)
	brne .L222
	call buzzer_beep
	cpi r28,lo8(66)
	breq .L223
	brge .L224
	cpi r28,lo8(35)
	breq .L225
	cpi r28,lo8(65)
	brne .L215
	call set_time_12hr
	rjmp .L215
.L217:
	cbi 0x12,3
	rjmp .L218
.L219:
	cbi 0x12,5
	rjmp .L220
.L224:
	cpi r28,lo8(67)
	brne .L239
	call toggle_12hr_mode
.L231:
	call update_display
	rjmp .L215
.L223:
	call set_date
	rjmp .L215
.L239:
	lds r24,display_mode
	ldi r25,lo8(1)
	cpse r24,__zero_reg__
	ldi r25,0
.L229:
	sts display_mode,r25
	cpse r24,__zero_reg__
	rjmp .L230
	sbi 0x12,4
	rjmp .L231
.L230:
	cbi 0x12,4
	rjmp .L231
.L225:
	call system_reset
	rjmp .L215
	.size	main, .-main
.global	month_names
	.section	.rodata.str1.1
.LC46:
	.string	"---"
.LC47:
	.string	"JAN"
.LC48:
	.string	"FEB"
.LC49:
	.string	"MAR"
.LC50:
	.string	"APR"
.LC51:
	.string	"MAY"
.LC52:
	.string	"JUN"
.LC53:
	.string	"JUL"
.LC54:
	.string	"AUG"
.LC55:
	.string	"SEP"
.LC56:
	.string	"OCT"
.LC57:
	.string	"NOV"
.LC58:
	.string	"DEC"
	.data
	.type	month_names, @object
	.size	month_names, 26
month_names:
	.word	.LC46
	.word	.LC47
	.word	.LC48
	.word	.LC49
	.word	.LC50
	.word	.LC51
	.word	.LC52
	.word	.LC53
	.word	.LC54
	.word	.LC55
	.word	.LC56
	.word	.LC57
	.word	.LC58
.global	second_flag
	.section .bss
	.type	second_flag, @object
	.size	second_flag, 1
second_flag:
	.zero	1
.global	tick_flag
	.type	tick_flag, @object
	.size	tick_flag, 1
tick_flag:
	.zero	1
.global	display_mode
	.type	display_mode, @object
	.size	display_mode, 1
display_mode:
	.zero	1
.global	mode_12hr
	.data
	.type	mode_12hr, @object
	.size	mode_12hr, 1
mode_12hr:
	.byte	1
.global	year
	.section .bss
	.type	year, @object
	.size	year, 2
year:
	.zero	2
.global	month
	.type	month, @object
	.size	month, 1
month:
	.zero	1
.global	day
	.type	day, @object
	.size	day, 1
day:
	.zero	1
.global	milliseconds
	.type	milliseconds, @object
	.size	milliseconds, 2
milliseconds:
	.zero	2
.global	seconds
	.type	seconds, @object
	.size	seconds, 1
seconds:
	.zero	1
.global	minutes
	.type	minutes, @object
	.size	minutes, 1
minutes:
	.zero	1
.global	hours
	.type	hours, @object
	.size	hours, 1
hours:
	.zero	1
	.ident	"GCC: (GNU) 15.1.0"
.global __do_copy_data
.global __do_clear_bss
