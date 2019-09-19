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
PASSO0 EQU 0x10000000
PASSO1 EQU 0x01000000
PASSO2 EQU 0x00100000
PASSO3 EQU 0x00010000
PASSO4 EQU 0x00001000
PASSO5 EQU 0x00000100
PASSO6 EQU 0x01000010
PASSO7 EQU 0x01000001
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
		IMPORT  GPIO_Init
		IMPORT Liga_LED
		IMPORT Desliga_LED
		IMPORT Liga_7segDireita
		IMPORT Desliga_7segDireita
		IMPORT Liga_7segEsquerda
		IMPORT Desliga_7segEsquerda
		IMPORT LED_Or_7seg_Output
		IMPORT Decode7seg
		IMPORT DecodePassoCavaleiro
		IMPORT LeBotoes
		IMPORT SysTick_Wait1ms
		IMPORT SysTick_Init
		IMPORT PLL_Init

; -------------------------------------------------------------------------------
; Função main()
Start  			
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	BL PLL_Init					 ;80MHz
	BL SysTick_Init				 ;Inicia SysTick
	
	MOV R8,  #0 ; Passo do cavaleiro
	MOV R9,  #1 ; Incremento
	MOV R10, #0 ; Dígito 0
	MOV R11, #0 ; Dígito 1
	
MainLoop
	MOV R7,  #0 ; Divisor de clock;
MostraDigitos
	BL MostraDigito0
	MOV R0, #5
	BL SysTick_Wait1ms
	
	BL MostraDigito1
	MOV R0, #5
	BL SysTick_Wait1ms
	
	BL MostraPassoCavaleiro
	MOV R0, #5
	BL SysTick_Wait1ms

	ADD R7, R7, #1
	CMP R7, #33
	BNE MostraDigitos
	
	BL Conta
	BL LeBotoes			     
Verifica_SW1	
	CMP R0, #2_00000010	     
	BNE Verifica_SW2             
	BL IncrementaPasso    		     
	B MainLoop                   
Verifica_SW2	
	CMP R0, #2_00000001	     
	BNE MainLoop          
	BL DecrementaPasso   	     
	B MainLoop                                   


IncrementaPasso
	CMP R9, #9
	BEQ MainLoop
	ADD R9, R9, #1
	BX LR

DecrementaPasso
	CMP R9, #1
	BEQ MainLoop
	SUB R9, R9, #1
	BX LR

Conta
	PUSH {R1,LR}
	
	CMP R8, #7
	BNE SomaPassoCavaleiro
	MOV R8, #0

VoltaCavaleiro
	ADD R1, R10, R9
	CMP R1, #10
	BLT SomaPasso
	SUB R1, R1, #10
	MOV R10, R1
	BL IncrementaDezena
Volta
	POP {R1,LR}
	BX LR

SomaPassoCavaleiro
	ADD R8, R8, #1 ; Passo do cavaleiro
	B VoltaCavaleiro

SomaPasso
	ADD R10, R10, R9
	B Volta

IncrementaDezena
	PUSH {LR}
	CMP R11, #9
	BEQ ZeraDezena
	ADD R11, R11, #1
Volta2
	POP {LR}
	BX LR

ZeraDezena
	MOV R11, #0
	B Volta2

; Inputs: R12
MostraPassoCavaleiro
	PUSH {R0,R1,LR}
	BL Desliga_7segDireita
	BL Desliga_7segEsquerda
	MOV R0, R8
	BL DecodePassoCavaleiro ; R1 <= Código do dígito
	MOV R0, R1
	BL LED_Or_7seg_Output
	BL Liga_LED
	POP {R0,R1,LR}
	BX LR

; Inputs: R12
MostraDigito0
	PUSH {R0,R1,LR}
	BL Desliga_LED
	BL Desliga_7segEsquerda
	MOV R0, R10
	BL Decode7seg ; R1 <= Código do dígito
	MOV R0, R1
	BL LED_Or_7seg_Output
	BL Liga_7segDireita
	POP {R0,R1,LR}
	BX LR

; Inputs: R13
MostraDigito1
	PUSH {R0,R1,LR}
	BL Desliga_LED
	BL Desliga_7segDireita
	MOV R0, R11
	BL Decode7seg ; R1 <= Código do dígito
	MOV R0, R1
	BL LED_Or_7seg_Output
	BL Liga_7segEsquerda
	
	POP {R0,R1,LR}
	BX LR



    ALIGN                        
    END                         
