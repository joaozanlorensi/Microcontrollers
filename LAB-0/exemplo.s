; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
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

; -------------------------------------------------------------------------------
; Função main()
Start  
; Comece o código aqui <======================================================

;	LAB 0: BUBBLE SORT
	MOV R1, #0x0500 ; R1 = ENDERECO BASE
	MOVT R1, #0x2000 
	; INSIRA OS NUMEROS NA RAM
	MOV R0, #12
	STRB R0, [R1]
	MOV R0, #67
	STRB R0, [R1, #1]
	MOV R0, #12
	STRB R0, [R1, #2]
	MOV R0, #12
	STRB R0, [R1, #3]
	MOV R0, #47
	STRB R0, [R1, #4]
	MOV R0, #5
	STRB R0, [R1, #5]
	MOV R0, #59
	STRB R0, [R1, #6]
	MOV R0, #9
	STRB R0, [R1, #7]
	MOV R0, #33
	STRB R0, [R1, #8]
	MOV R0, #99
	STRB R0, [R1, #9]
	;
	MOVS R0, #10 ; R0 = QTE DE ELEMENTOS
	SUBS R4, R0, #1 ; N - 1
	MOVS R2, #0 ; R2 = i
	MOVS R3, #0 ; R3 = j
comparaI
	CMP R2, R4
	BGE fim
	SUBS R5, R4, R2 ; R5 <= N - 1 - I
comparaJ
	CMP R3, R5
	BGE aumentaI
	BL resetaR1
	ADD R1, R3
	LDRB R6, [R1] ; PEGA N[J] DA RAM
	LDRB R7, [R1, #1] ; PEGA N[J + 1] DA RAM
	CMP R6, R7
	BLE aumentaJ
	STRB R6, [R1, #1]
	STRB R7, [R1]
	B aumentaJ
aumentaI
	ADD R2, #1 ; I <= I + 1
	MOV R3, #0 ; J <= 0 
	B comparaI
aumentaJ
	ADD	R3, #1
	B comparaJ
resetaR1
	MOV R1, #0x0500 ; R1 = ENDERECO BASE
	MOVT R1, #0x2000 
	BX LR
fim	NOP
	ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo