/*
	Assembler tryout for Beglebone Black Core PLL and Peripheral PLL
	Mainly for UART0 function
*/


	.set CM_WKUP_BASE,			0x44E00400
	.set CM_CLKMODE_DPLL_CORE_OFFS,		0x90
	.set CM_IDLEST_DPLL_CORE_OFFS,		0x5C
	.set CM_CLKSEL_DLL_CORE_OFFS,		0x68
	.set CM_DIV_M4_DPLL_CORE_OFFS,		0x80
	.set CM_DIV_M5_DPLL_CORE_OFFS,		0x84
	.set CM_DIV_M6_DPLL_CORE_OFFS,		0xD8
	.set HS_DIVIDER_CLKOUT1_DIVCHACK,	5
	.set HS_DIVIDER_CLKOUT1_DIV,		0
	.set DPLL_EN,				0
	.set ST_MN_BYPASS,			8
	.set ST_DPLL_CLK,			0
	.set DPLL_MULT,				8
	.set DPLL_DIV,				0

	.global SetCorePLL
	.global SetPerPLL

	.text
	
	.code 32
	/*
	Multiply val (M) in R0, divide val (N) in R1
	
	However, here it will be hard coded acc to TRM table 8-22 OPP100 col
	M4 HS divider DIV val: 10 (==>200MHz)
	M5 HS divider DIV val: 8  (==>250MHz)
	M6 HS divider DIV val: 4  (==>500MHz)
	This means Core DPLL must have 2GHz output from a 24MHz crystal freq (CLKINP)
	TRM 8.1.6.3.1 table 8-17 says CLKDCOLDO = 2*(M/(N+1))*CLKINP
	Following M and N seems to give a perfect 2GHz output.
	m:  125, n:  2
	m:  250, n:  5
	m:  375, n:  8
	m:  500, n: 11
	m:  625, n: 14
	m:  750, n: 17
	m:  875, n: 20
	m: 1000, n: 23
	m: 1125, n: 26
	m: 1250, n: 29
	m: 1375, n: 32
	m: 1500, n: 35
	m: 1625, n: 38
	m: 1750, n: 41
	m: 1875, n: 44
	m: 2000, n: 47

	for simplicity, 1st val pair will be used for starters
	*/
SetCorePLL:
	/* set PLL to bypass */
	LDR	R2,=CM_WKUP_BASE
	LDR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]
	ORR	R3,#(0x4<<DPLL_EN)
	STR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]

CheckCorePLLBypass:
	LDR	R3,[R2,#CM_IDLEST_DPLL_CORE_OFFS]
	ANDS	R3,#(1<<ST_MN_BYPASS)
	BEQ	CheckCorePLLBypass
	LDR	R3,[R2,#CM_IDLEST_DPLL_CORE_OFFS]
	ANDS	R3,#(1<<ST_DPLL_CLK)
	BEQ	CheckCorePLLBypass

	/* set mult and div, 1st mask off any existing bits */	
/*	
	LDR	R3,[R2,#CM_CLKSEL_DLL_CORE_OFFS]
	AND	R3,=0xMASK_OUT_MUL_DIV
	LSL	R0,#DPLL_MULT
	LSL	R1,#DPLL_DIV
	ORR	R3,R0
	ORR	R3,R1
*/
	/* Here, hard code R0 (M) and R1 (N) */
	LDR	R0,=125
	LDR	R1,=2
/*
	AND	R0,#0x03FF
	AND	R1,#0x7F
*/
	LSL	R0,#DPLL_MULT
	ORR	R0,R1
	STR	R0,[R2,#CM_CLKSEL_DLL_CORE_OFFS]

	/* set M4, M5, & M6 dividers */
	/* M4 200MHz, M5 250MHz, M6 500MHz */
	/* M4 DIV=10, M5 DIV=8, M6 DIV=4 */
	/* M4 */
	LDR	R3,[R2,#CM_DIV_M4_DPLL_CORE_OFFS]
	AND	R4,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	ORR	R3,#10
	STR	R3,[R2,#CM_DIV_M4_DPLL_CORE_OFFS]
	LDR	R3,[R2,#CM_DIV_M4_DPLL_CORE_OFFS]
set_m4_div:
	ANDS	R3,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	TEQ	R3,R4
	BEQ	set_m4_div

	/* M5 */
	LDR	R3,[R2,#CM_DIV_M5_DPLL_CORE_OFFS]
	AND	R4,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	ORR	R3,#8
	STR	R3,[R2,#CM_DIV_M5_DPLL_CORE_OFFS]
	LDR	R3,[R2,#CM_DIV_M5_DPLL_CORE_OFFS]
set_m5_div:
	ANDS	R3,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	TEQ	R3,R4
	BEQ	set_m5_div

	/* M6 */
	LDR	R3,[R2,#CM_DIV_M6_DPLL_CORE_OFFS]
	AND	R4,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	ORR	R3,#4
	STR	R3,[R2,#CM_DIV_M6_DPLL_CORE_OFFS]
	LDR	R3,[R2,#CM_DIV_M6_DPLL_CORE_OFFS]
set_m6_div:
	ANDS	R3,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	TEQ	R3,R4
	BEQ	set_m6_div

	/* set PLL to lock mode */
	LDR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]
	ORR	R3,#(0x7<<DPLL_EN)
	STR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]

CheckCorePLL_Lock:
	LDR	R3,[R2,#CM_IDLEST_DPLL_CORE_OFFS]
	ANDS	R3,#(1<<ST_MN_BYPASS)
	BEQ	CheckCorePLL_Lock
	LDR	R3,[R2,#CM_IDLEST_DPLL_CORE_OFFS]
	ANDS	R3,#(1<<ST_DPLL_CLK)
	BEQ	CheckCorePLL_Lock
	
	BX	LR


	.set CM_CLKMODE_DPLL_PER_OFFS,		0x8C
	.set CM_IDLEST_DPLL_PER_OFFS,		0x70
	.set CM_CLKSEL_DPLL_PER_OFFS,		0x9C
	.set CM_DIV_M2_DPLL_PER_OFFS,		0xAC
	.set DPLL_SD_DIV,			24
	.set ST_DPLL_CLKOUT,			9

/*
	Multiply val (M) in R0, divide val (N) in R1
	
	However, here it will be hard coded acc to TRM table 8-24 OPP100 col
	M2 divider DIV val: 5 (==>192MHz)
	This means Per DPLL must have 960MHz output (before M2) from a 24MHz crystal freq (CLKINP)
	TRM 8.1.6.4.1 table 8-19 says CLKOUT = (M/(N+1))*CLKINP*(1/M2)
	M=16, N=0 and M2=2 seems to give a perfect 192MHz output wiht above formula

	with using 960MHz as intermediate freq before M2=5 to get 192MHz,
	Following M and N seems to provide perfect 960MHz
	m:   40, n:  0
	m:   80, n:  1
	m:  120, n:  2
	m:  160, n:  3
	m:  200, n:  4
	m:  240, n:  5
	m:  280, n:  6
	m:  320, n:  7
	m:  360, n:  8
	m:  400, n:  9
	m:  440, n: 10
	m:  480, n: 11
	m:  520, n: 12
	m:  560, n: 13
	m:  600, n: 14
	m:  640, n: 15
	m:  680, n: 16
	m:  720, n: 17
	m:  760, n: 18
	m:  800, n: 19
	m:  840, n: 20
	m:  880, n: 21
	m:  920, n: 22
	m:  960, n: 23
	m: 1000, n: 24
	m: 1040, n: 25
	m: 1080, n: 26
	m: 1120, n: 27
	m: 1160, n: 28
	m: 1200, n: 29
	m: 1240, n: 30
	m: 1280, n: 31
	m: 1320, n: 32
	m: 1360, n: 33
	m: 1400, n: 34
	m: 1440, n: 35
	m: 1480, n: 36
	m: 1520, n: 37
	m: 1560, n: 38
	m: 1600, n: 39
	m: 1640, n: 40
	m: 1680, n: 41
	m: 1720, n: 42
	m: 1760, n: 43
	m: 1800, n: 44
	m: 1840, n: 45
	m: 1880, n: 46
	m: 1920, n: 47
	m: 1960, n: 48
	m: 2000, n: 49
	m: 2040, n: 50

	for simplicity, 1st val pair will be used for starters
*/

SetPerPLL:
	/* set PLL to bypass */
	LDR	R2,=CM_WKUP_BASE
	LDR	R3,[R2,#CM_CLKMODE_DPLL_PER_OFFS]
	ORR	R3,#(0x4<<DPLL_EN)
	STR	R3,[R2,#CM_CLKMODE_DPLL_PER_OFFS]

CheckPerPLLBypass:
	LDR	R3,[R2,#CM_IDLEST_DPLL_PER_OFFS]
	ANDS	R3,#(1<<ST_MN_BYPASS)
	BEQ	CheckPerPLLBypass
	LDR	R3,[R2,#CM_IDLEST_DPLL_PER_OFFS]
	ANDS	R3,#(1<<ST_DPLL_CLK)
	BEQ	CheckPerPLLBypass

	/* Here, hard code R0 (M) and R1 (N) */
	LDR	R0,=40
	LDR	R1,=0
/*
	AND	R0,#0x0FFF
	AND	R1,#0xFF
*/
	LSL	R0,#DPLL_MULT
	ORR	R0,R1
	STR	R0,[R2,#CM_CLKSEL_DPLL_PER_OFFS]

	/* set M2 divider */
	/* M2 192MHz, DIV=5, be sure to enable clk */
	LDR	R3,[R2,#CM_DIV_M2_DPLL_PER_OFFS]
	AND	R4,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	ORR	R3,#5
	ORR	R3,#(1<<ST_DPLL_CLKOUT)
	STR	R3,[R2,#CM_DIV_M2_DPLL_PER_OFFS]
	LDR	R3,[R2,#CM_DIV_M4_DPLL_CORE_OFFS]
set_m2_div:
	ANDS	R3,#(1<<HS_DIVIDER_CLKOUT1_DIVCHACK)
	TEQ	R3,R4
	BEQ	set_m2_div

	/* set PLL to lock mode */
	LDR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]
	ORR	R3,#(0x7<<DPLL_EN)
	STR	R3,[R2,#CM_CLKMODE_DPLL_CORE_OFFS]

CheckPerPLL_Lock:
	LDR	R3,[R2,#CM_IDLEST_DPLL_PER_OFFS]
	ANDS	R3,#(1<<ST_MN_BYPASS)
	BEQ	CheckPerPLL_Lock
	LDR	R3,[R2,#CM_IDLEST_DPLL_PER_OFFS]
	ANDS	R3,#(1<<ST_DPLL_CLK)
	BEQ	CheckPerPLL_Lock
	
	BX	LR



	.end
