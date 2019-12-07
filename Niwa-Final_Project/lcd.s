; Federal University of Technology - Paraná (UTFPR)
; Course: Electronic Engineering
; Class: Microcontrollers
; Professor: Guilherme Peron
; Students: Francisco Shigueo Miamoto and João Pedro Zanlorensi Cardoso
; Final Project: Niwa - Smart Garden
; Developed for Tiva C Series TM4C1294 microcontroller

; Definicoes - EQUS
GPIO_PORTK_DATA_R       EQU	0x400613FC
GPIO_PORTM_DATA_R       EQU	0x400633FC

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
DISPLAY_MODE   EQU 0x0C ; 0x0F para Cursor e Blink ligados | 0x0C para ambos desligados | 0x0D para Cursor desligado e Blink ligado | 0x0E para Cursor ligado e Blink Desligado
DISPLAY_OFF	   EQU 0x03

BOUNCE_DELAY	EQU 300

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código (ROM)
    AREA    |.text|, CODE, READONLY, ALIGN=2

	EXPORT LCD_Init
	EXPORT LCD_ImprimeString
	EXPORT LCD_SetaCursor
	EXPORT LCD_Clear

	IMPORT SysTick_Wait1ms					
;--------------------------------------------------------------------------------

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
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
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
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
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
;--------------------------------------------------------------------------------
	

; Funções auxiliares ao LCD

;--------------------------------------------------------------------------------
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
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
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
;--------------------------------------------------------------------------------
