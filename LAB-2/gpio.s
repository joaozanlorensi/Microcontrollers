; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 19/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
; ========================
; Definições de Valores
BIT0	EQU 2_0001
BIT1	EQU 2_0010
; ========================
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Definições dos Ports
	
; PORT J
GPIO_PORTJ_AHB_LOCK_R    	EQU    0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU    0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU    0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU    0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU    0x400603FC
GPIO_PORTJ               	EQU    2_000000100000000

;PORT M
GPIO_PORTM_DATA_R       EQU	0x400633FC
GPIO_PORTM_DIR_R        EQU	0x40063400
GPIO_PORTM_AFSEL_R      EQU	0x40063420
GPIO_PORTM_PUR_R        EQU	0x40063510
GPIO_PORTM_DEN_R        EQU	0x4006351C
GPIO_PORTM_LOCK_R       EQU	0x40063520
GPIO_PORTM_CR_R         EQU	0x40063524
GPIO_PORTM_AMSEL_R      EQU	0x40063528
GPIO_PORTM_PCTL_R       EQU	0x4006352C
GPIO_PORTM				EQU 2_000100000000000

;PORT K
GPIO_PORTK_DATA_R       EQU	0x400613FC
GPIO_PORTK_DIR_R        EQU	0x40061400
GPIO_PORTK_AFSEL_R      EQU	0x40061420
GPIO_PORTK_PUR_R        EQU	0x40061510
GPIO_PORTK_DEN_R        EQU	0x4006151C
GPIO_PORTK_LOCK_R       EQU	0x40061520
GPIO_PORTK_CR_R         EQU	0x40061524
GPIO_PORTK_AMSEL_R      EQU	0x40061528
GPIO_PORTK_PCTL_R       EQU	0x4006152C
GPIO_PORTK				EQU 2_000001000000000
	
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

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
    AREA    |.text|, CODE, READONLY, ALIGN=2

	EXPORT GPIO_Init
	EXPORT LCD_Init
	EXPORT LCD_ImprimeString
	EXPORT LCD_SetaCursor

	IMPORT SysTick_Wait1ms
        								
;--------------------------------------------------------------------------------
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
GPIO_Init
;=====================
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; após isso verificar no PRGPIO se a porta está pronta para uso.
; enable clock to GPIOF at clock gating register
	LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endereço do registrador RCGCGPIO
	MOV		R1, #GPIO_PORTJ                 ;Seta o bit da porta A
	ORR 	R1, #GPIO_PORTM
	ORR 	R1, #GPIO_PORTK
	STR     R1, [R0]						;Move para a memória os bits das portas no endereço do RCGCGPIO
	LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  
	LDR     R1, [R0]						;Lê da memória o conteúdo do endereço do registrador
	MOV     R2, #GPIO_PORTJ                 ;Seta os bits correspondentes às portas para fazer a comparação
	ORR     R2, #GPIO_PORTM
	ORR     R2, #GPIO_PORTK
	TST     R1, R2							;ANDS de R1 com R2
	BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o laço. Senão continua executando
 
; 2. Limpar o AMSEL para desabilitar a analógica
	MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a função analógica
	LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere?o do AMSEL para a porta J
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTM_AMSEL_R		;Carrega o R0 com o endereço do AMSEL para a porta P
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTK_AMSEL_R		;Carrega o R0 com o endereço do AMSEL para a porta P
	STR     R1, [R0]
 
; 3. Limpar PCTL para selecionar o GPIO
	MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
	LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere?o do PCTL para a porta J
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTM_PCTL_R		;Carrega o R0 com o endere?o do PCTL para a porta J
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTK_PCTL_R		;Carrega o R0 com o endere?o do PCTL para a porta J
	STR     R1, [R0]
; 4. DIR para 0 se for entrada, 1 se for saída
	LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere?o do DIR para a porta J
	MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com entrada
	STR     R1, [R0]
	
	LDR     R0, =GPIO_PORTM_DIR_R		;Carrega o R0 com o endere?o do DIR para a porta J
	MOV     R1, #0xFF               		;Colocar 0 no registrador DIR para funcionar com entrada
	STR     R1, [R0]
	
	LDR     R0, =GPIO_PORTK_DIR_R		;Carrega o R0 com o endere?o do DIR para a porta J
	MOV     R1, #0xFF               		;Colocar 0 no registrador DIR para funcionar com entrada
	STR     R1, [R0]
			
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem função alternativa
	MOV 	R1, #0
	LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R		;Carrega o endere?o do AFSEL da porta J
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTM_AFSEL_R		;Carrega o endere?o do AFSEL da porta J
	STR     R1, [R0]
	LDR     R0, =GPIO_PORTK_AFSEL_R		;Carrega o endere?o do AFSEL da porta J
	STR     R1, [R0]
			
; 6. Setar os bits de DEN para habilitar I/O digital
 	LDR     R0, =GPIO_PORTJ_AHB_DEN_R		;Carrega o endere?o do DEN
	LDR     R1, [R0]						;Ler da mem?ria o registrador GPIO_PORTJ_AHB_DEN_R
	MOV     R2, #2_00000011					;Habilitar funcionalidade digital na DEN
	ORR     R1, R2							;Setar bits sem sobrescrever os demais
	STR     R1, [R0]
	
	LDR     R0, =GPIO_PORTM_DEN_R		;Carrega o endere?o do DEN
	LDR     R1, [R0]						;Ler da mem?ria o registrador GPIO_PORTJ_AHB_DEN_R
	MOV     R2, #2_00000111					;Habilitar funcionalidade digital na DEN
	ORR     R1, R2							;Setar bits sem sobrescrever os demais
	STR     R1, [R0]
	
	LDR     R0, =GPIO_PORTK_DEN_R		;Carrega o endere?o do DEN
	LDR     R1, [R0]						;Ler da mem?ria o registrador GPIO_PORTJ_AHB_DEN_R
	MOV     R2, #2_11111111					;Habilitar funcionalidade digital na DEN
	ORR     R1, R2							;Setar bits sem sobrescrever os demais
	STR     R1, [R0]
			
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
	LDR     R0, =GPIO_PORTJ_AHB_PUR_R		;Carrega o endere?o do PUR para a porta J
	MOV     R1, #BIT0						;Habilitar funcionalidade digital de resistor de pull-up 
	ORR     R1, #BIT1						;nos bits 0 e 1
	STR     R1, [R0]						;Escreve no registrador da mem?ria do resistor de pull-up
	
	BX LR;

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
	PUSH {R1}
	; Carrega caracter
	LDRB R1, [R0], #1
	; Verifica por fim da string
	CMP R1, #0
	BEQ Fim
	; Envia dado
	PUSH {R0,LR}
	MOV R0, R1
	BL DadoLCD
	POP {R0,LR}
	B LCD_ImprimeString
Fim
	POP{R1}
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
	; EN, RW e RS zerados
	MOV R3, #2_000
	STR R3, [R1]
	; Insere comando no barramento
	STR R0, [R2]
	; Ativa enable
	MOV R3, #2_100
	STR R3, [R1]
	; Espera 2ms
	PUSH {R0}
	MOV R0, #2
	BL SysTick_Wait1ms
	POP {R0}
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
	; Enable zerado
	MOV R3, #2_001
	STR R3, [R1]
	; Insere dado no barramento
	STR R0, [R2]
	; Enable ativado
	MOV R3, #2_101
	STR R3, [R1]
	; Espera 2ms
	PUSH {R0}
	MOV R0, #2
	BL SysTick_Wait1ms
	POP {R0}
	; Desempilha registradores
	POP{R1,R2,R3,LR}
	; Retorna
	BX LR
	

	ALIGN
	END