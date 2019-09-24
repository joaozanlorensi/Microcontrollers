; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Rev1: 10/03/2018
; Rev2: 10/04/2019
; Este programa espera o usuário apertar a chave USR_SW1 e/ou a chave USR_SW2.
; Caso o usuário pressione a chave USR_SW1, acenderá o LED3 (PF4). Caso o usuário pressione 
; a chave USR_SW2, acenderá o LED4 (PF0). Caso as duas chaves sejam pressionadas, os dois 
; LEDs acendem.

		

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
DIG_0 EQU 0x20000000
DIG_1 EQU 0x20000001
DIG_2 EQU 0x20000002
DIG_3 EQU 0x20000003
DIG_4 EQU 0x20000004
DIG_5 EQU 0x20000005
DIG_6 EQU 0x20000006
DIG_7 EQU 0x20000007
DIG_8 EQU 0x20000008
DIG_9 EQU 0x20000009


; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT GPIO_Init
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait1ms
		IMPORT LCD_Init
		IMPORT LCD_ImprimeString
		IMPORT LCD_SetaCursor
		IMPORT LeTeclado
		IMPORT LED_On
		IMPORT LED_Off
		IMPORT LED_Output
		EXPORT ZeraRAM






MUL

; -------------------------------------------------------------------------------
; Função main()
Start  			
	BL PLL_Init					 ;80MHz
	BL SysTick_Init				 ;Inicia SysTick
	BL GPIO_Init   				 ;Chama a subrotina que inicializa os GPIOs
	BL LCD_Init
	LDR R0, =MSG3
	BL LCD_ImprimeString
	MOV R0, #1
	MOV R1, #0
	BL LCD_SetaCursor
	LDR R0, =MSG4
	BL LCD_ImprimeString

	BL ZeraRAM
	MOV R5, #0
	MOV R3, #0
	
	BL LeTeclado
	BL VerificaTecla ; R3 <- Multiplicador
	MOV R2, R0 ; R2 <- R0
	
	; Corpo da mensagem inicial
	MOV R0, #0
	MOV R1, #0
	BL LCD_SetaCursor
	LDR R0, =MSG1
	BL LCD_ImprimeString
	MOV R0, #1
	MOV R1, #0
	BL LCD_SetaCursor
	LDR R0, =MSG2
	BL LCD_ImprimeString
	B TeclaTitulo
	
Loop
	BL LeTeclado	; R0 <- Valor do teclado
	BL VerificaTecla ; R3 <- Multiplicador
	MOV R2, R0 ; R2 <- R0

TeclaTitulo
; Imprime a tecla no titulo
	MOV R0, #0
	MOV R1, #11
	BL LCD_SetaCursor 
	MOV R0, R2
	BL DigitToChar	; R0 <- Caracter do dígito em R0
	BL LCD_ImprimeString
	
; Imprime a tecla na conta
	MOV R0, #1
	MOV R1, #0
	BL LCD_SetaCursor
	MOV R0, R2
	BL DigitToChar	; R0 <- Caracter do dígito em R0
	BL LCD_ImprimeString
	
; Imprime o fator multiplicativo na conta
	MOV R0, #1
	MOV R1, #4
	BL LCD_SetaCursor
	MOV R0, R3
	BL DigitToChar	; R0 <- Caracter do dígito em R0
	BL LCD_ImprimeString

; Imprime o resultado da conta
	MOV R11, #0
	MUL R0, R2, R3
Compara
	CMP R0, #10
	BLT SoTemUnidade
	SUB R0, #10
	ADD R11, #1
	B Compara
	
	
SoTemUnidade
	MOV R12, R0

; Digito de dezenas : R11
	MOV R0, #1
	MOV R1, #8
	BL LCD_SetaCursor
	MOV R0, R11
	BL DigitToChar
	BL LCD_ImprimeString
	
; Digito de unidades : R12
	MOV R0, #1
	MOV R1, #9
	BL LCD_SetaCursor
	MOV R0, R12
	BL DigitToChar
	BL LCD_ImprimeString
	
	CMP R3, #9
	BNE Loop
	BL PiscaLEDs
	B Loop
Fim

; VerificaTecla
; Entrada: R0 - Dígito (Tecla)
; Saída: R3 - Dígito (Multiplicador)
VerificaTecla

; R4 Armazena o endereco os enderecos na RAM
; R5 Armazena o valor lido da ram, e depois o valor a ser colocado na RAM

	PUSH{R0,R4,R5,LR}
	MOV R5, #0
	
	CMP R0, #0
	BNE Um
	LDR R4, =DIG_0
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Um	
	CMP R0, #1
	BNE Dois
	LDR R4, =DIG_1
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Dois
	CMP R0, #2
	BNE Tres
	LDR R4, =DIG_2
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Tres	
	CMP R0, #3
	BNE Quatro
	LDR R4,=DIG_3
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Quatro	
	CMP R0, #4
	BNE Cinco
	LDR R4, =DIG_4
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Cinco	
	CMP R0, #5
	BNE Seis
	LDR R4,=DIG_5
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Seis	
	CMP R0, #6
	BNE Sete
	LDR R4,=DIG_6
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Sete	
	CMP R0, #7
	BNE Oito
	LDR R4,=DIG_7
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Oito	
	CMP R0, #8
	BNE Nove
	LDR R4,=DIG_8
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
	B SalvaRAM
Nove	
	CMP R0, #9
	BNE Volta
	LDR R4,=DIG_9
	LDRB R5, [R4]
	MOV R3, R5
	ADD R5, #1
	CMP R5, #10
	BNE SalvaRAM
	MOV R5, #0
SalvaRAM
	STRB R5, [R4]
Volta
	POP{R0,R4,R5,LR}
	BX LR

; DigitToChar
; Entrada: R0 - Dígito
; Saída: R0 - Endereço da string equivalente do dígito
DigitToChar
Char0
	CMP R0, #0
	BNE Char1
	LDR R0, =CHAR_0
	B RetornaChar
Char1
	CMP R0, #1
	BNE Char2
	LDR R0, =CHAR_1
	B RetornaChar
Char2
	CMP R0, #2
	BNE Char3
	LDR R0, =CHAR_2
	B RetornaChar
Char3
	CMP R0, #3
	BNE Char4
	LDR R0, =CHAR_3
	B RetornaChar
Char4
	CMP R0, #4
	BNE Char5
	LDR R0, =CHAR_4
	B RetornaChar
Char5
	CMP R0, #5
	BNE Char6
	LDR R0, =CHAR_5
	B RetornaChar
Char6
	CMP R0, #6
	BNE Char7
	LDR R0, =CHAR_6
	B RetornaChar
Char7
	CMP R0, #7
	BNE Char8
	LDR R0, =CHAR_7
	B RetornaChar
Char8
	CMP R0, #8
	BNE Char9
	LDR R0, =CHAR_8
	B RetornaChar
Char9
	CMP R0, #9
	BNE Char10
	LDR R0, =CHAR_9
Char10
	CMP R0, #10
	BNE Char11
	LDR R0, =CHAR_10
Char11
	CMP R0, #11
	BNE RetornaChar
	LDR R0, =CHAR_11
RetornaChar
	BX LR	

; PiscaLED
; Entradas: Nenhuma
; Saídas: Nenhuma
PiscaLEDs
	PUSH {R0,R1,LR}
	MOV R1, #0
	MOV R0, #0xFF
	BL LED_Output
ComparaLEDs
	CMP R1, #5
	BEQ FimPiscaLEDs
	BL LED_On
	MOV R0,#500
	BL SysTick_Wait1ms
	BL LED_Off
	MOV R0,#500
	BL SysTick_Wait1ms
	ADD R1, #1
	B ComparaLEDs
FimPiscaLEDs
	POP{R0,R1,LR}
	BX LR
	
; ZeraRAM
; Entradas: Nenhuma
; Saídas: Nenhuma
; Zera os valores no Inicio da RAM
ZeraRAM
	MOV R0, #0
	LDR R5, =DIG_0
	STR R0, [R5]
	LDR R5, =DIG_1
	STR R0, [R5]
	LDR R5, =DIG_2
	STR R0, [R5]
	LDR R5, =DIG_3
	STR R0, [R5]
	LDR R5, =DIG_4
	STR R0, [R5]
	LDR R5, =DIG_5
	STR R0, [R5]
	LDR R5, =DIG_6
	STR R0, [R5]
	LDR R5, =DIG_7
	STR R0, [R5]
	LDR R5, =DIG_8
	STR R0, [R5]
	LDR R5, =DIG_9
	STR R0, [R5]
	BX LR


MSG1 DCB "Tabuada do ",0
MSG2 DCB "  x   =   ",0
MSG3 DCB "     UTFPR ",0
MSG4 DCB "     Micro ",0

CHAR_0 DCB "0 ",0
CHAR_1 DCB "1 ",0
CHAR_2 DCB "2 ",0
CHAR_3 DCB "3 ",0
CHAR_4 DCB "4 ",0
CHAR_5 DCB "5 ",0
CHAR_6 DCB "6 ",0
CHAR_7 DCB "7 ",0
CHAR_8 DCB "8 ",0
CHAR_9 DCB "9 ",0
CHAR_10 DCB "*",0
CHAR_11 DCB "#",0

	ALIGN                        
	END                         