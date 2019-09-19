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

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
		EXPORT GPIO_Init
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
EsperaGPIO  LDR     R1, [R0]						;Lê da memória o conteúdo do endereço do registrador
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
	
	
; 8. Inicializa o LCD para entrada de dados
	; INICIALIZA OS BITS DE ESCRITA EM DUAS LINHAS
	LDR R1, =GPIO_PORTK_DATA_R
	MOV R0, #0x38 ; D0:D7 <- 0x38, que indica que serao usadas duas linhas
	STR R0, [R1]
	; ATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x04 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; AGUARDA 2 mS
	MOV R0, #2
	BL SysTick_Wait1ms
	; DESATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x00 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; INICIALIZA OS BITS DE ESCRITA COM AUTOINCREMENTO PARA A DIREITA
	LDR R1, =GPIO_PORTK_DATA_R
	MOV R0, #0x06 ; D0:D7 <- 0x06, que indica que sera autoincrementado para a direita
	STR R0, [R1]
	; ATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x04 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; AGUARDA 2 mS
	MOV R0, #2
	BL SysTick_Wait1ms
	; DESATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x00 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 	
	; INICIALIZA OS BITS DE ESCRITA COM O CURSOR PISCANDO NA PRIMEIRA POSICAO
	LDR R1, =GPIO_PORTK_DATA_R
	MOV R0, #0x0F ; D0:D7 <- Piscando
	STR R0, [R1]
	; ATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x04 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; AGUARDA 2 mS
	MOV R0, #2
	BL SysTick_Wait1ms
	; DESATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x00 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; INICIALIZA OS BITS DE ESCRITA LIMPOS
	LDR R1, =GPIO_PORTK_DATA_R
	MOV R0, #0x01 ; D0:D7 <- clear
	STR R0, [R1]
	; ATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x04 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	; AGUARDA 2 mS
	MOV R0, #2
	BL SysTick_Wait1ms
	; DESATIVA O ENABLE
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #0x00 ; ENABLE <- 1, RW <- 0, RS <- 0
	STR R0, [R1] 
	
EscreveCaractere
	MOV R2, #2_11110111
	
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #2_001
	STR R0, [R1]
	
	LDR R1, =GPIO_PORTK_DATA_R
	MOV R0, R2 ; r2 é o caractere
	STR R0, [R1]
	
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #2_101
	STR R0, [R1]

	MOV R0, #2
	BL SysTick_Wait1ms
	
	LDR R1, =GPIO_PORTM_DATA_R
	MOV R0, #2_000
	STR R0, [R1]
            
	BX      LR
	
	
; -------------------------------------------------------------------------------
; Função LeBotoes
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
LeBotoes
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos [J1-J0]
	BX LR									;Retorno

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo