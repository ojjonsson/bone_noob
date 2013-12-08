/*
	manage Beaglebone Black leds
*/


	.set CM_PER_BASE,			0x44E00000
	.set CM_PER_GPIO1_CLKCTRL,		0x000000AC
	
	.set GPIO_1_REGBASE,			0x4804C000

/*	
	.set GPIO_1_GDBCLK
*/

	.set GPIO_1_CTRL,			0x00000130
	.set GPIO_1_OE,				0x00000134
	.set GPIO_1_DATAOUT,			0x0000013C
	.set GPIO_1_CLEARDATAOUT,		0x00000190
	.set GPIO_1_SETDATAOUT,			0x00000194
	
	.set GPIO1_21,		21
	.set GPIO1_22,		22
	.set GPIO1_23,		23
	.set GPIO1_24,		24
	
	.set LED_USR0,		GPIO1_21
	.set LED_USR1,		GPIO1_22
	.set LED_USR2,		GPIO1_23
	.set LED_USR3,		GPIO1_24


	.global init_usr_led
	.global light_usr0_led
	.global unlight_usr0_led
	.global light_usr0_ledb
	.global unlight_usr0_ledb
	.global light_usr1_led
	.global unlight_usr1_led
	.global light_usr2_led
	.global unlight_usr2_led
	.global light_usr3_led
	.global unlight_usr3_led

	.global light_usr_led
	.global unlight_usr_led
	
	.global set_usr_led

	.text
	
	.code 32


init_usr_led:
	@ Enable clock to GPIO_1 block
	LDR	R0,=CM_PER_BASE
	LDR	R1,=0x00040002
	STR	R1,[R0,#CM_PER_GPIO1_CLKCTRL]
	
	@ Enable output for all user led's
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,[R0,#GPIO_1_OE]
	BIC	R1,R1,#((1<<LED_USR0)|(1<<LED_USR1)|(1<<LED_USR2)|(1<<LED_USR3))
	STR	R1,[R0,#GPIO_1_OE]
	BX	LR

light_usr0_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR0)
	STR	R1,[R0,#GPIO_1_SETDATAOUT]
	BX	LR

unlight_usr0_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR0)
	STR	R1,[R0,#GPIO_1_CLEARDATAOUT]
	BX	LR

light_usr0_ledb:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
/*	LDR	R1,=(1<<LED_USR0)*/
	LDR	R1,[R0,#GPIO_1_DATAOUT]
	ORR	R1,#(1<<LED_USR0)
	STR	R1,[R0,#GPIO_1_DATAOUT]
	BX	LR

unlight_usr0_ledb:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,[R0,#GPIO_1_DATAOUT]
	AND	R1,#~(1<<LED_USR0)
	STR	R1,[R0,#GPIO_1_DATAOUT]
	BX	LR

light_usr1_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR1)
	STR	R1,[R0,#GPIO_1_SETDATAOUT]
	BX	LR

unlight_usr1_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR1)
	STR	R1,[R0,#GPIO_1_CLEARDATAOUT]
	BX	LR

light_usr2_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR2)
	STR	R1,[R0,#GPIO_1_SETDATAOUT]
	BX	LR

unlight_usr2_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR2)
	STR	R1,[R0,#GPIO_1_CLEARDATAOUT]
	BX	LR

light_usr3_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR3)
	STR	R1,[R0,#GPIO_1_SETDATAOUT]
	BX	LR

unlight_usr3_led:	
	@ Light USR0 led
	LDR	R0,=GPIO_1_REGBASE
	LDR	R1,=(1<<LED_USR3)
	STR	R1,[R0,#GPIO_1_CLEARDATAOUT]
	BX	LR


/*
	takes 0 to 3 as arg in R0
	if R0 > 3 then return -1
	else set USR<R0> and return 0
*/
light_usr_led:
	CMP	R0,#3
	LDRGT	R0,=(-1)
	BGT	end_light_usr_led

	ADD	R0,R0,#LED_USR0
	LDR	R1,=1
	LSL	R1,R0
	
	@ Light USRx led
	LDR	R0,=GPIO_1_REGBASE
	STR	R1,[R0,#GPIO_1_SETDATAOUT]
	LDR	R0,=0
end_light_usr_led:
	BX	LR

/*
	takes 0 to 3 as arg in R0
	if R0 > 3 then return -1
	else unset USR<R0> and return 0
*/
unlight_usr_led:
	CMP	R0,#3
	LDRGT	R0,=(-1)
	BGT	end_unlight_usr_led

	ADD	R0,R0,#LED_USR0
	LDR	R1,=1
	LSL	R1,R0
	
	@ unlight USRx led
	LDR	R0,=GPIO_1_REGBASE
	STR	R1,[R0,#GPIO_1_CLEARDATAOUT]
	LDR	R0,=0
end_unlight_usr_led:
	BX	LR
	
/*
	takes 0 to 15 as arg in R0
	if R0 > 15 then return -1
	else set <R0> as binary on USR leds and return 0
*/
set_usr_led:
	CMP	R0,#15
	LDRGT	R0,=(-1)
	BGT	end_set_usr_led

	LSL	R0,#LED_USR0
	LDR	R1,=GPIO_1_REGBASE
	LDR	R1,[R1,#GPIO_1_DATAOUT]
	AND	R1,#~((1<<LED_USR0)|(1<<LED_USR1)|(1<<LED_USR2)|(1<<LED_USR3))
	ORR	R0,R1
	
	@ set USR led's to <R0> val
	LDR	R1,=GPIO_1_REGBASE
	STR	R0,[R1,#GPIO_1_DATAOUT]
	LDR	R0,=0
end_set_usr_led:
	BX	LR


.end
