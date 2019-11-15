; Federal University of Technology - Paraná (UTFPR)
; Course: Electronic Engineering
; Class: Microcontrollers
; Professor: Guilherme Peron
; Students: Francisco Shigueo Miamoto and João Pedro Zanlorensi Cardoso
; Final Project: Niwa - Smart Garden
; Developed for Tiva C Series TM4C1294 microcontroller

; -------------------------------------------------------------------------------
        THUMB                        ; Thumb-2 type instructions
; -------------------------------------------------------------------------------

; EQUs

; Program values

; General purpose registers

; Interruption parameters

; Valores para o LCD
LCD_BUS        EQU GPIO_PORTK_DATA_R
LCD_CONTROL    EQU GPIO_PORTM_DATA_R
FUNCTION_SET   EQU 0x38 ; 0x30 para 1 linha | 0x38 para 2 linhas
ENTRY_MODE	   EQU 0x06 ; 0x06 para incrementar endereço | 0x04 para decrementar endereço
LINHA_0        EQU 0x80
LINHA_1		   EQU 0xC0
CLEAR          EQU 0x01
RET_HOME       EQU 0x02
SCURSOR_LEFT   EQU 0x10
SCURSOR_RIGHT  EQU 0x14
SDISPLAY_LEFT  EQU 0x18
SDISPLAY_RIGHT EQU 0x1C
DISPLAY_MODE   EQU 0x0C ; 0x0F cursor and blink on | 0x0C cursor and blink off | 0x0D cursor off, blink on | 0x0E cursor on, blink off
DISPLAY_OFF	   EQU 0x03

; Code field - every piece of code in this field will be stored in ROM Memory
; -------------------------------------------------------------------------------
    AREA    |.text|, CODE, READONLY, ALIGN=2

	EXPORT LCD_Init
	EXPORT LCD_ImprimeString
	EXPORT LCD_SetaCursor
	EXPORT LCD_Clear
	EXPORT LeTeclado
	EXPORT LED_Off
	EXPORT LED_On
	EXPORT LED_Output

	IMPORT SysTick_Wait1ms							
;--------------------------------------------------------------------------------

; LCD_Init
; Entrada: Nenhuma
; Saída: Nenhuma
LCD_Init
	PUSH{LR}
	; Duas linhas
	LDR R0, =FUNCTION_SET
	BL ComandoLCD
	; Incremento para direita
	LDR R0, =ENTRY_MODE
	BL ComandoLCD
	; Cursor piscando
	LDR R0, =DISPLAY_MODE
	BL ComandoLCD
	; Clear
	LDR R0, =CLEAR
	BL ComandoLCD
	POP {LR}
	; Retorna
	BX LR

; LCD_ImprimeString
; Entrada: R0 - Endereço da string a ser escrita
; Saída: Nenhuma
LCD_ImprimeString
	PUSH {R1, LR}
VoltaLCD
	; Carrega caracter
	LDRB R1, [R0], #1
	; Verifica por fim da string
	CMP R1, #0
	BEQ Fim
	; Envia dado
	PUSH{R0}
	MOV R0, R1
	BL DadoLCD
	POP{R0}
	B VoltaLCD
Fim
	POP{R1, LR}
	;Retorna
	BX LR

; LCD_SetaCursor
; Entrada: R0 - Linha, R1 - Coluna
; Saída: Nenhuma
; Obs: Tanto a linha quando a coluna são indexadas a partir 0
LCD_SetaCursor	
	PUSH {R0,R1,LR}
	; Verifica linha a ser escrita
	CMP R0, #0
	BNE Linha1
	; Carrega comando para linha 0
	LDR R0, =LINHA_0
	B EnviaCursor
Linha1
	; Carrega comando para linha 1
	LDR R0, =LINHA_1
EnviaCursor
	; Adiciona valor da coluna
	ADD R0, R1
	BL ComandoLCD
	POP {R0,R1,LR}
	; Retorna
	BX LR

; LCD_Clear 
; Limpa o LCD
; Entrada: Nenhuma
; Saída: Nenhuma
LCD_Clear
	PUSH {R0,LR}
	LDR R0, =CLEAR
	BL ComandoLCD
	POP {R0,LR}
	BX LR
	

; Funções auxiliares ao LCD

; ComandoLCD
; Entrada: R0 - Comando a ser enviado ao LCD	
; Saída: Nenhuma
ComandoLCD
	; Empilha registradores
	PUSH {R1,R2,R3,LR}
	; Carrega endereços	
	LDR R1, =LCD_CONTROL
	LDR R2, =LCD_BUS
	; Insere comando no barramento
	STR R0, [R2]
	; Ativa enable
	MOV R3, #2_100
	STR R3, [R1]
	; Espera 2ms
	PUSH {R0}
	MOV R0, #10
	BL SysTick_Wait1ms
	POP {R0}
	; EN, RW e RS zerados
	MOV R3, #2_000
	STR R3, [R1]
	; Desempilha registradores
	POP{R1,R2,R3,LR}
	; Retorna
	BX LR

; DadoLCD
; Entrada: R0 - Dado a ser enviado ao LCD	
; Saída: Nenhuma
DadoLCD
	; Empilha registradores
	PUSH {R1,R2,R3,LR}
	; Carrega endereços	
	LDR R1, =LCD_CONTROL
	LDR R2, =LCD_BUS	
	; Insere dado no barramento
	STR R0, [R2]
	; Enable ativado
	MOV R3, #2_101
	STR R3, [R1]
	; Espera 2ms
	PUSH {R0}
	MOV R0, #10
	BL SysTick_Wait1ms
	POP {R0}
	; Enable zerado
	MOV R3, #2_001
	STR R3, [R1]
	; Desempilha registradores
	POP{R1,R2,R3,LR}
	; Retorna
	BX LR

; Teclado_Leitura
; Entradas: Nenhuma
; Saída: R0 - Número correspondente à tecla pressionada
LeTeclado
	PUSH {R1,R2,LR}
Col0
	; Escreve 0 na primeira coluna
	LDR R2, =TECLADO_COLS
	LDR R0, [R2]
	BIC R0, #COLS
	ORR R0, #COL_1
	ORR R0, #COL_2
	STR R0, [R2]
	; Delay de 10ms
	MOV R0, #10
	BL SysTick_Wait1ms

	; Lê valor das linhas
	LDR R2, =TECLADO_LINS
	LDR R1, [R2]

Col0_Linha0
	; Verifica se a linha 0 foi pressionada
	CMP R1, #LIN_0
	BNE Col0_Linha1
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col0_Linha0
	CMP R1, #LIN_0
	BNE Espera_Col0_Linha0
	MOV R0, #1
	B RetResultado

Col0_Linha1
	CMP R1, #LIN_1
	BNE Col0_Linha2
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col0_Linha1
	CMP R1, #LIN_1
	BNE Espera_Col0_Linha1
	MOV R0, #4
	B RetResultado

Col0_Linha2
	CMP R1, #LIN_2
	BNE Col0_Linha3
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col0_Linha2
	CMP R1, #LIN_2
	BNE Espera_Col0_Linha2
	MOV R0, #7
	B RetResultado

Col0_Linha3
	CMP R1, #LIN_3
	BNE Col1
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col0_Linha3
	CMP R1, #LIN_3
	BNE Espera_Col0_Linha3
	MOV R0, #99
	B RetResultado

Col1
	; Escreve 0 na segunda coluna
	LDR R2, =TECLADO_COLS
	LDR R0, [R2]
	BIC R0, #COLS
	ORR R0, #COL_0
	ORR R0, #COL_2
	STR R0, [R2]
	; Delay de 10ms
	MOV R0, #10
	BL SysTick_Wait1ms
	; Lê valor das linhas
	LDR R2, =TECLADO_LINS
	LDR R1, [R2]

Col1_Linha0
	CMP R1, #LIN_0
	BNE Col1_Linha1
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col1_Linha0
	CMP R1, #LIN_0
	BNE Espera_Col1_Linha0
	MOV R0, #2
	B RetResultado

Col1_Linha1
	CMP R1, #LIN_1
	BNE Col1_Linha2
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col1_Linha1
	CMP R1, #LIN_1
	BNE Espera_Col1_Linha1
	MOV R0, #5
	B RetResultado

Col1_Linha2
	CMP R1, #LIN_2
	BNE Col1_Linha3
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col1_Linha2
	CMP R1, #LIN_2
	BNE Espera_Col1_Linha2
	MOV R0, #8
	B RetResultado

Col1_Linha3
	CMP R1, #LIN_3
	BNE Col2
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col1_Linha3
	CMP R1, #LIN_3
	BNE Espera_Col1_Linha3
	MOV R0, #0
	B RetResultado

Col2
	; Escreve 0 na terceira coluna
	LDR R2, =TECLADO_COLS
	LDR R0, [R2]
	BIC R0, #COLS
	ORR R0, #COL_0
	ORR R0, #COL_1
	STR R0, [R2]
	; Delay de 10ms
	MOV R0, #10
	BL SysTick_Wait1ms
	; Lê valor das linhas
	LDR R2, =TECLADO_LINS
	LDR R1, [R2]

Col2_Linha0
	CMP R1, #LIN_0
	BNE Col2_Linha1
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col2_Linha0
	CMP R1, #LIN_0
	BNE Espera_Col2_Linha0
	MOV R0, #3
	B RetResultado

Col2_Linha1
	CMP R1, #LIN_1
	BNE Col2_Linha2
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col2_Linha1
	CMP R1, #LIN_1
	BNE Espera_Col2_Linha1
	MOV R0, #6
	B RetResultado

Col2_Linha2
	CMP R1, #LIN_2
	BNE Col2_Linha3
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col2_Linha2
	CMP R1, #LIN_2
	BNE Espera_Col2_Linha2
	MOV R0, #9
	B RetResultado

Col2_Linha3
	CMP R1, #LIN_3
	BNE Col0
	; Espera por bounce
	MOV R0, #BOUNCE_DELAY
	BL SysTick_Wait1ms
Espera_Col2_Linha3
	CMP R1, #LIN_3
	BNE Espera_Col2_Linha3
	MOV R0, #98
	B RetResultado

	MOV R0, #10
RetResultado
	POP {R1,R2,LR}
	BX LR

; LED_Output - Coloca valor de R0 no barremento de LEDs
; Entradas: R0
; Saídas: Nenhuma
LED_Output
	PUSH {R1,R2,R3,LR}
	
	LDR R1, =GPIO_PORTA_AHB_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT A
	BIC R2, #2_11110000
	ORR R3, R0, R2
	STR R3, [R1]  
	
	LDR R1, =GPIO_PORTQ_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT Q
	BIC R2, #2_00001111
	ORR R3, R0, R2
	STR R3, [R1]
	
	POP {R1,R2,R3,LR}
	BX LR

; LED_On - Liga LEDs
; Entradas: Nenhuma
; Saídas: Nenhuma
LED_On
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTP_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT A
	ORR R2, R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR

; LED_Off - Desliga LEDs
; Entradas: Nenhuma
; Saídas: Nenhuma
LED_Off
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTP_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT A
	BIC R2, R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR

	ALIGN
	END