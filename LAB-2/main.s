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
		IMPORT LCD_Init
		IMPORT LCD_ImprimeString
		IMPORT LCD_SetaCursor
			
MSG1_STR DCB "Tabuada do 3",0
MSG2_STR DCB "3 x 1 = 3 ",0

; -------------------------------------------------------------------------------
; Função main()
Start  			
	BL PLL_Init					 ;80MHz
	BL SysTick_Init				 ;Inicia SysTick
	BL GPIO_Init   ;Chama a subrotina que inicializa os GPIOs
	BL LCD_Init
	LDR R0, =MSG1_STR
	BL LCD_ImprimeString
	MOV R0, #1
	MOV R1, #0
	BL LCD_SetaCursor
	LDR R0, =MSG2_STR
	BL LCD_ImprimeString
	
	ALIGN                        
	END                         


