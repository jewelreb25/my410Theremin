	.text
;The 5K potentiometer VR2 is connected to the PE2 (AIN1) of the ADC port
;port E pin 2 set to upotput for potentiometer
	.global ADC_init
	.global GPIO_init
	.global SS2_init
	.global myTheremin

ADC_init:
	PUSH{r4-r12, lr}
	;enable the clock on the ADC
	MOV r0, #0xE000
	MOVT r0, #0x400F	;WHICH MODULE
	LDRB r1, [r0, #0x638]
	ORR r1, #1			;1 for ADC mod 0
	STRB r1, [r0, #0x638];RCGADC run mode clock gating control ADC
    POP{r4-r12,pc}

GPIO_init:
	PUSH{r4-r12,lr}
	MOV r4, #0xE000	;enable clock for port E and C
	MOVT r4, #0x400F
	LDRB r6, [r4, #0x608]
	MOV r5, #0x14
	ORR r5, r5, r6
	STRB r5, [r4, #0x608]

	MOV r0, #0x4000		;port E base addr
	MOVT r0, #0x4002
	;select ALT function for port E
	;port E pin 1(light sensor), pin 2(potentiometer)
	MOV r2, #0x6		;0110
	STR r2, [r0, #0x420]	;GPIOAFSEL

	;setup pin 1 & 2 as input
	MOV r2, #0x6
	STR r2, [r0, #0x400]

	;setup pin 1 and pin 2 as analog
	LDR r2, [r0, #0x51C]	;GPIODEN
	BFC r2, #1, #2			;disable digital mode
	STR r2, [r0, #0x51C]

	;setup pin 1 and pin 2 in analog mode to disable isolation circuit for ADC input
	MOV r2, #0x6			;GPIOAMSEL
	STR r2, [r0, #0x528]	;analog function enabled, isolation disabled-
							;pin can now perform analopg functions

	;;;;;;;;;;;
	;PWM setup;
	;;;;;;;;;;;
	;connect clock to PWM module 0
	MOV r4, #0xE000
	MOVT r4, #0x400F
	LDRB r5, [r4, #0x640]
	ORR r5, r5, #1
	STR r5, [r4, #0x640]

	;select alt function for Port C pin 4
	MOV r0, #0x6000
	MOVT r0, #0x4000
	MOV r2, #0x10
	STR r2, [r0, #0x420]

	;setup pin 4 as digital
	LDR r2, [r0, #0x51C]	;GPIODEN
	ORR r2, #0x10
	STR r2, [r0, #0x51C]

	;select module 0 PWM 6 on pin 4
	LDR r2, [r0, #0x52C]
	ORR r2, #0x40000
	STR r2, [r0, #0x52C]

	;select the clock to time PWM- enable the PWM clock divisor
	MOV r2, #1
	LDR r6, [r4, #0x60]
	BFI r6, r2, #20, #1	 ;set bit 20 to 1- PWM clock divider is now source for PWM clock
	STR r6, [r4, #0x60]

	;delay of 3 sys clks before PWM module registers are accessed
	NOP
	NOP
	NOP

	;by default, the divisor value is /64 which is good for the sound, so dont change

	;use PWM3 generator A
	MOV r4, #0x8000
	MOVT r4, #0x4002

	;disable PWM generation block(MnPWM6 and MnPWM7) for configuration
	MOV r2, #0
	STR r2, [r4, #0x100] ;PWM3CTL

	MOV r5, #0x8C     	;0x2 for Action for CMPA down, 0x3 for ACTZERO	drive PWMA low when CMPA value hit
	STR r5, [r4, #0x120] ;drive PWMA high when counter hits 0

	;***********************
	MOV r2, #379	;A4
	STR r2, [r4, #0x110]	;load value for gen 3

	MOV r2, #189	;50% duty cycle
	STR r2, [r4, #0x118]	;compare value for gen 3

	;enable PWM6- PWM generator 3 producues PWM6 and PWM7
	MOV r2, #1
	STR r2, [r4, #0x000] ;PWMCTL

	;enable PWM generation block(MnPWM6 and MnPWM7) to produce PWM signals
	MOV r2, #1
	STR r2, [r4, #0x100] ;PWM3CTL

	;enable PWM outputs
	MOV r2, #0x40
	STR r2, [r4, #0x008] ;PWMENABLE for PWM6

	POP{r4-r12, pc}

SS2_init:
	PUSH{r4-r12,lr}
	;ADCACTSS - ADC active sample sequencer
	MOV r0, #0x8000
	MOVT r0, #0x4003
	LDR r1, [r0, #0x000]
	BFC r1, #2, #1	;disable SS2
	STR r1, [r0, #0x000]

	;define event that triggers event sampling sequencer
	;so that sequencer always samples
	LDR r1, [r0, #0x014]	;ADCEMUX- selects event
	MOV r3, #0xF	;trigger select-> continuous
	BFI r1, r3, #8, #4
	STR r1, [r0, #0x014]

	;configure mux to use appropriate input source
	MOV r0, #0x8000
	MOVT r0, #0x4003
	MOV r2, #0x21			;AIN2 for light sensor, AIN1 for potentiometer
	;MUX0 reads first sample from AIN1, MUX1 reads second sample from AIN2
	STR r2, [r0, #0x080]	;ADCSSMUX2

	;configure sample bitsa
	;when configuring, the END1 bit must be set because sample ends after 2 samples
	;ADCSSCTL2
	MOV r2, #32 ;(5th bit=END1->2nd sample is end of sequence)
	STR r2, [r0, #0x084]

	;enable SS2
	MOV r0, #0x8000
	MOVT r0, #0x4003
	LDR r1, [r0, #0x000]
	ORR r1, r1, #4	;enable SS2
	STR r1, [r0, #0x000]

	POP{r4-r12,pc}

