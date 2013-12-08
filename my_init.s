/*
my init func
just try lit some leds, and possible enable uart

Link tryout (with precdeeding object compilation):
	$CC -marm -mfpu=neon -march=armv7-a -c my_init.S -o my_init.o
	$LD -T my_init.lds my_init.o -o my_init.elf -Map my_init.map 
*/
/*	.org 0x402F0400*/
/*	.offset 0x402F0400*/

	.global Entry

	
	.set L4_WKUP_BASE,			0x44C00000


.set INCLUDE_LED_DELAY,	1
.if INCLUDE_LED_DELAY
	.set LOOP_DELAY,	1000000
/*	.set LOOP_DELAY,	1000*/
.endif
/*	
 setting LED_USR0 would be (acc. to Utku)
	*(CM_PER_BASE+CM_PER_GPIO1_CLKCTRL) = 0x00040002 //  the "2" is for enabling module, the "4" is for enabling opt func clock
	tmp = *(GPIO_1_REGBASE+GPIO_1_OE)
	tmp &= ~(1<<LED_USR0)
	*(GPIO_1_REGBASE+GPIO_1_OE) = tmp
	*(GPIO_1_REGBASE+GPIO_1_SETDATAOUT) = (1<<LED_USR0)
*/	
	
/*	.text 0x402F0400*/
	.text
	
	.code 32

/*	.equ Entry, 0x402F0400*/




Entry:


	BL	init_usr_led
	
/*	LDR	R2,=0*/
	LDR	R0,=1
	BL 	set_usr_led
	BL 	SetCorePLL
	LDR	R0,=2
	BL 	set_usr_led
	BL 	SetPerPLL
/*	LDR	R0,=3
	BL 	set_usr_led*/

loop:

/*
	BL 	light_usr0_ledb
	BL	delay_func
	BL 	unlight_usr0_ledb
	BL	delay_func
*/
	
	MOV	R0,R2
	BL set_usr_led
	BL	delay_func
	ADDS	R2,#1
	CMP		R2,#15
	MOVGT	R2,#0
/**/
/*
	LDR	R0,=2
	BL	light_usr_led
	LDR	R0,=0
	BL	light_usr_led

	BL	delay_func

	LDR	R0,=0
	BL	unlight_usr_led
	LDR	R0,=2
	BL	unlight_usr_led

	BL	delay_func

	LDR	R0,=1
	BL	light_usr_led
	LDR	R0,=3
	BL	light_usr_led

	BL	delay_func

	LDR	R0,=1
	BL	unlight_usr_led
	LDR	R0,=3
	BL	unlight_usr_led

	BL	delay_func
*/

	B	loop

delay_func:
	LDR	R4,=LOOP_DELAY
delay_1:
	SUBS	R4,#1
	BNE	delay_1
	BX	LR




/*	
End of file
*/
	.end
