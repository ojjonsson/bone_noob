/*
	Assembler tryout for Beglebone Black UART0
*/




/*
UART0:
PD_WKUP_L4_WKUP_GCLK (OCP)
PD_WKUP_UART0_GFCLK (Func)
*/

	.set CM_WKUP_BASE,			0x44E00400
	.set CM_WKUP_UART0_CLKCTRL_OFFS,	0xB4

	.set UART0_BASE,			0x44E09000
	.set UART0_RHR_THR_DLL_OFFS,		0x00
	.set UART0_IER_DLH_OFFS,		0x04
	.set UART0_IIR_FCR_EFR_OFFS,		0x08
	.set UART0_SYSC,			0x54
	.set UART0_SYSS,			0x58
	.set UART0_LCR_OFFS,			0x0C
	.set UART0_MCR_OFFS,			0x10
	.set UART0_MDR1_OFFS,			0x20
	.set UART0_TCR_OFFS,			0x18

	.set SOFTRESET,				1
	.set RESETDONE,				0
	.set ENHANCED_EN,			4
	.set TCR_TLR,				6
	.set FIFO_ENABLE,			0
	
	/* DLH/DLL values for 115200 baud rate at 48MHz clock */
	.set DLH_VALUE_115200,			0x00
	.set DLL_VALUE_115200,			0x1A

	.global init_uart0
	.global set_uart0_mux
	.global set_uart0_pwr_clk

	.text
	
	.code 32

set_uart0_mux:
	/* uart mux (CONF_UART0_RXD & CONF_UART0_TXD) */
	/* 
	BBB has a XAM3359AZCZ100, and UART0 J1 header 
	connects TXD to ASIC pin E16 and RXD to pin E15
	This means that mux mode 0 needs to be set for 
	E16/E15 for UART0 mode according to data sheet
	for this asic
	TRM 9.3 table 9-10 states that control module reg
	for rxd is offset 0x970 and txd is offset 0x974
	TMR 9.3.51 states how to set up these and lot of
	ohter similar registers
	For TXD on pin E16
	*/
	.set CONTROL_MODULE_BASE,		0x44E10000
	.set CONF_UART0_CTSN_OFFS,		0x968
	.set CONF_UART0_RTSN_OFFS,		0x96C
	.set CONF_UART0_RXD_OFFS,		0x970
	.set CONF_UART0_TXD_OFFS,		0x974
	.set SLEW_RATE_BIT,			6
	.set REC_ENABLE_BIT,			5
	.set PU_SELECT_BIT,			4
	.set PU_PD_ENABLE_BIT,			3

	/*
	setting mode 0 (bit2:0==0),
	PU/PD enabled (bit3=0),
	PU selected (bit4=1)
	enable receiver for RXD (bit5=1)
	slow slewrate (bit6=0)
	*/
	LDR	R2,=CONTROL_MODULE_BASE
	LDR	R3,=(1<<REC_ENABLE_BIT)
	STR	R3,[R2,#CONF_UART0_RXD_OFFS]
	/*
	setting mode 0 (bit2:0==0),
	PU/PD enabled (bit3=0),
	PD selected (bit4=0)
	disable receiver for RXD (bit5=0)
	slow slewrate (bit6=0)
	*/	
	LDR	R3,=0
	STR	R3,[R2,#CONF_UART0_TXD_OFFS]

	BX	LR


set_uart0_pwr_clk:
	/* CM_WKUP_CLKSTCTRL */
	/* uart clk (CM_PER_L4HS_CLKSTCTRL) (?) */
	
	/* enable module */
	LDR	R2,=CM_WKUP_BASE
	/* bitfield 1-0 set to 0x2 enables module */
	LDR	R3,=0x2 
	STR	R3,[R2,#CM_WKUP_UART0_CLKCTRL_OFFS]

	/* uart0 per clk (CM_PER_UART0_CLKCTRL) */

	BX	LR


init_uart0:
	/* SW reset 19.4.1.1.1 */
	LDR	R2,=UART0_BASE
	LDR	R3,=(1<<SOFTRESET)
	STR	R3,[R2,#UART0_SYSC]
sw_reset_loop:
	LDR	R3,[R2,#UART0_SYSS]
	/* 'S' ind ANDS updates flags, otherwise flags wont be updated... */
	ANDS	R3,R3,#(1<<RESETDONE)
	BEQ	sw_reset_loop
	
	/* FIFO & DMA settings (no FIFO and no DMA)*/
	/* 19.4.1.1.2 step 1 */
	/* Save LCR reg to R4 */
	LDR	R4,[R2,#UART0_LCR_OFFS]
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.2 step 2 */
	/* save EFR:ENHANCED_EN val to R5 */
	LDR	R5,[R2,#UART0_IIR_FCR_EFR_OFFS]
	AND	R5,#(1<<ENHANCED_EN)
	/* set EFR:ENHANCED_EN val */
	ORR	R3,R5,#(1<<ENHANCED_EN)
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	/* 19.4.1.1.2 step 3 */
	LDR	R3,=0x0080
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.2 step 4 */
	/* save MCR:TCR_TLR val to R6 */
	LDR	R6,[R2,#UART0_MCR_OFFS]
	ORR	R3,R6,#(1<<TCR_TLR)
	STR	R6,[R2,#UART0_MCR_OFFS]
	/* 19.4.1.1.2 step 5 */
	LDR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	/* here, FIFO is disabled */
	BIC	R3,R3,#(1<<FIFO_ENABLE)
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	/* 19.4.1.1.2 step 6 */
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.2 step 7 */
	/* since no FIFO/DMA, step 7 is omitted */
	/* 19.4.1.1.2 step 8 */
	/* since no FIFO/DMA, step 8 is omitted */
	/* 19.4.1.1.2 step 9 */
	TST	R5,#0
	BNE	no_restore_1
	LDR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	ORR	R3,#(1<<ENHANCED_EN)
	/* restore EFR:ENHANCED_EN */
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
no_restore_1:
	/* 19.4.1.1.2 step 10 */
	LDR	R3,=0x0080
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.2 step 11 */
	/* restore MCR:TCR_TLR */
	ANDS	R6,#(1<<TCR_TLR)
	ANDEQ	R6,=~(1<<TCR_TLR)
	ORRNE	R6,=(1<<TCR_TLR)
	STR	R6,[R2,#UART0_MCR_OFFS]
	/* 19.4.1.1.2 step 12 */
	/* restore LCR reg val */
	STR	R4,[R2,#UART0_LCR_OFFS]


	/* Protocol, baud rate % interrupt */
	/* 19.4.1.1.3 step 1 */
	LDR	R3,[R2,#UART0_MDR1_OFFS]
	ORR	R3,R3,#0x7
	/* 19.4.1.1.3 step 2 */
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 3 */
	/* save EFR:ENHANCED_EN val to R5 */
	LDR	R5,[R2,#UART0_IIR_FCR_EFR_OFFS]
	AND	R5,#(1<<ENHANCED_EN)
	ORR	R3,R5,#(1<<ENHANCED_EN)
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	/* 19.4.1.1.3 step 4 */
	LDR	R3,=0x0000
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 5 */
	STR	R3,[R2,#UART0_IER_DLH_OFFS]
	/* 19.4.1.1.3 step 6 */
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 7 */
	LDR	R3,=DLL_VALUE
	STR	R3,[R2,#UART0_RHR_THR_DLL_OFFS]
	LDR	R3,=DLH_VALUE
	STR	R3,[R2,#UART0_IER_DLH_OFFS]
	/* 19.4.1.1.3 step 8 */
	LDR	R3,=0x0000
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 9 */
	/* disable all interrupts (write zero to all) */
	STR	R3,[R2,#UART0_IER_DLH_OFFS]
	/* 19.4.1.1.3 step 10 */
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 11 */
	TST	R5,#0
	BNE	no_restore_2
	LDR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	ORR	R3,#(1<<ENHANCED_EN)
	/* restore EFR:ENHANCED_EN */
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
no_restore_2:

#error check done to this point
	/* 19.4.1.1.3 step 12 */
	/* here, set parity, stop bits, char len */
	LDR	R3,[R2,#UART0_LCR_OFFS]
	ORR	R3,R3,#0x3
	AND	R3,R3,#0x3
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.1.3 step 13 */
	LDR	R3,[R2,#UART0_MDR1_OFFS]
	AND	R3,R3,#~0x03
	/* set MDR1 to 16x, no autobaud */
	STR	R3,[R2,#UART0_MDR1_OFFS]

	/* HW flow */
	/* 19.4.1.2.1 step 1 */
	/* save LCR to R7 */
	LDR	R7,[R2,#UART0_LCR_OFFS]
	LDR	R3,=0x0080
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* 19.4.1.2.1 step 2 */
	/* save MCR:TCR_TLR val to R6 */
	LDR	R6,[R2,#UART0_MCR_OFFS]
	ORR	R3,R6,#(1<<TCR_TLR)
	STR	R3,[R2,#UART0_MCR_OFFS]
	LDR	R3,=0x00BF
	STR	R3,[R2,#UART0_LCR_OFFS]
	/* save EFR:ENHANCED_EN val to R5 */
	LDR	R5,[R2,#UART0_IIR_FCR_EFR_OFFS]
	ORR	R3,R5,#(1<<ENHANCED_EN)
	STR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]
	/* 19.4.1.2.1, bullet 5 */
	LDR	R3,=0x0
	STR	R3,[R2,#UART0_TCR_OFFS] 
	/* 19.4.1.2.1, bullet 6 */
	/* save EFR:ENHANCED_EN val to R5 */
	LDR	R3,[R2,#UART0_IIR_FCR_EFR_OFFS]


	.end
