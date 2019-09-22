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
			

MSG1 DCB "Tabuada do ",0
MSG2 DCB "  x   =   ",0
MSG3 DCB "     UTFPR ",0
MSG4 DCB "     Micro ",0

CHAR_0 DCB " 0 ",0
CHAR_1 DCB " 1 ",0
CHAR_2 DCB " 2 ",0
CHAR_3 DCB " 3 ",0
CHAR_4 DCB " 4 ",0
CHAR_5 DCB " 5 ",0
CHAR_6 DCB " 6 ",0
CHAR_7 DCB " 7 ",0
CHAR_8 DCB " 8 ",0
CHAR_9 DCB " 9 ",0
CHAR_10 DCB " * ",0
CHAR_11 DCB " # ",0

; -------------------------------------------------------------------------------
; Função main()
Start  			
	BL PLL_Init					 ;80MHz
	BL SysTick_Init				 ;Inicia SysTick
	BL GPIO_Init   ;Chama a subrotina que inicializa os GPIOs
	BL LCD_Init
	LDR R0, =MSG3
	BL LCD_ImprimeString
	MOV R0, #1
	MOV R1, #0
	BL LCD_SetaCursor
	LDR R0, =MSG4
	BL LCD_ImprimeString
	MOV R0, #2000
	BL SysTick_Wait1ms
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
Loop
	BL LeTeclado	; R0 <- Valor do teclado
	BL DigitToChar	; R0 <- Caracter do dígito em R0
	PUSH{R0}
	MOV R0, #1
	MOV R1, #9
	BL LCD_SetaCursor
	POP{R0}
	BL LCD_ImprimeString
	B Loop
Fim

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


	ALIGN                        
	END                         


