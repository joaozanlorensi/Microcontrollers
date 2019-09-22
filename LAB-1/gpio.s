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

; PORT A
GPIO_PORTA_AHB_DATA_R		EQU    0x400583FC
GPIO_PORTA_AHB_DIR_R		EQU    0x40058400
GPIO_PORTA_AHB_AFSEL_R		EQU    0x40058420
GPIO_PORTA_AHB_PUR_R		EQU    0x40058510
GPIO_PORTA_AHB_DEN_R		EQU    0x4005851C
GPIO_PORTA_AHB_LOCK_R		EQU    0x40058520
GPIO_PORTA_AHB_CR_R			EQU    0x40058524
GPIO_PORTA_AHB_AMSEL_R		EQU    0x40058528
GPIO_PORTA_AHB_PCTL_R		EQU    0x4005852C
GPIO_PORTA					EQU    2_000000000000001

; PORT B
GPIO_PORTB_AHB_DATA_R   	EQU    0x400593FC
GPIO_PORTB_AHB_DIR_R    	EQU    0x40059400
GPIO_PORTB_AHB_AFSEL_R  	EQU    0x40059420
GPIO_PORTB_AHB_PUR_R    	EQU    0x40059510
GPIO_PORTB_AHB_DEN_R    	EQU    0x4005951C
GPIO_PORTB_AHB_LOCK_R   	EQU    0x40059520
GPIO_PORTB_AHB_CR_R     	EQU    0x40059524
GPIO_PORTB_AHB_AMSEL_R  	EQU    0x40059528
GPIO_PORTB_AHB_PCTL_R   	EQU    0x4005952C
GPIO_PORTB					EQU    2_000000000000010
	
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
	
; PORT N
GPIO_PORTN_AHB_LOCK_R    	EQU    0x40064520
GPIO_PORTN_AHB_CR_R      	EQU    0x40064524
GPIO_PORTN_AHB_AMSEL_R   	EQU    0x40064528
GPIO_PORTN_AHB_PCTL_R    	EQU    0x4006452C
GPIO_PORTN_AHB_DIR_R     	EQU    0x40064400
GPIO_PORTN_AHB_AFSEL_R   	EQU    0x40064420
GPIO_PORTN_AHB_DEN_R     	EQU    0x4006451C
GPIO_PORTN_AHB_PUR_R     	EQU    0x40064510	
GPIO_PORTN_AHB_DATA_R    	EQU    0x400643FC
GPIO_PORTN               	EQU    2_001000000000000

;PORT P
GPIO_PORTP_DATA_R       	EQU    0x400653FC
GPIO_PORTP_DIR_R        	EQU    0x40065400
GPIO_PORTP_AFSEL_R      	EQU    0x40065420
GPIO_PORTP_PUR_R        	EQU    0x40065510
GPIO_PORTP_DEN_R        	EQU    0x4006551C
GPIO_PORTP_LOCK_R       	EQU    0x40065520
GPIO_PORTP_CR_R         	EQU    0x40065524
GPIO_PORTP_AMSEL_R      	EQU    0x40065528
GPIO_PORTP_PCTL_R       	EQU    0x4006552C
GPIO_PORTP					EQU    2_010000000000000

;PORT Q
GPIO_PORTQ_DATA_R       	EQU    0x400663FC
GPIO_PORTQ_DIR_R        	EQU    0x40066400
GPIO_PORTQ_AFSEL_R      	EQU    0x40066420
GPIO_PORTQ_PUR_R        	EQU    0x40066510
GPIO_PORTQ_DEN_R        	EQU    0x4006651C
GPIO_PORTQ_LOCK_R       	EQU    0x40066520
GPIO_PORTQ_CR_R         	EQU    0x40066524
GPIO_PORTQ_AMSEL_R      	EQU    0x40066528
GPIO_PORTQ_PCTL_R       	EQU    0x4006652C
GPIO_PORTQ					EQU    2_100000000000000
	
DIGIT_0 EQU 0x3F
DIGIT_1 EQU 0x06
DIGIT_2 EQU 0x5B
DIGIT_3 EQU 0x4F
DIGIT_4 EQU 0x66
DIGIT_5 EQU 0x6D
DIGIT_6 EQU 0x7D
DIGIT_7 EQU 0x07
DIGIT_8 EQU 0x7F
DIGIT_9 EQU 0x6F

PASSO0 EQU 2_10000000
PASSO1 EQU 2_01000000
PASSO2 EQU 2_00100000
PASSO3 EQU 2_00010000
PASSO4 EQU 2_00001000
PASSO5 EQU 2_00000100
PASSO6 EQU 2_00000010
PASSO7 EQU 2_00000001


; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT LeBotoes          ; Permite chamar PortJ_Input de outro arquivo
		EXPORT Liga_LED
		EXPORT Desliga_LED
		EXPORT Liga_7segDireita
		EXPORT Desliga_7segDireita
		EXPORT Liga_7segEsquerda
		EXPORT Desliga_7segEsquerda
		EXPORT LED_Or_7seg_Output
		EXPORT Decode7seg
		EXPORT DecodePassoCavaleiro
									
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
			MOV		R1, #GPIO_PORTA                 ;Seta o bit da porta A
			ORR     R1, #GPIO_PORTB					;Seta o bit da porta B, fazendo com OR
			ORR     R1, #GPIO_PORTP					;Seta o bit da porta P, fazendo com OR
			ORR     R1, #GPIO_PORTQ					;Seta o bit da porta Q, fazendo com OR
            ORR     R1, #GPIO_PORTJ	
			STR     R1, [R0]						;Move para a memória os bits das portas no endereço do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;Lê da memória o conteúdo do endereço do registrador
			MOV     R2, #GPIO_PORTA                 ;Seta os bits correspondentes às portas para fazer a comparação
			ORR     R2, #GPIO_PORTB                 ;Seta o bit da porta B, fazendo com OR
			ORR     R2, #GPIO_PORTJ
			ORR     R2, #GPIO_PORTP                 ;Seta o bit da porta P, fazendo com OR
			ORR     R2, #GPIO_PORTQ                 ;Seta o bit da porta Q, fazendo com OR
            TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o laço. Senão continua executando
 
; 2. Limpar o AMSEL para desabilitar a analógica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a função analógica
            
			LDR     R0, =GPIO_PORTA_AHB_AMSEL_R     ;Carrega o R0 com o endereço do AMSEL para a porta A
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta A da memória
            
			LDR     R0, =GPIO_PORTB_AHB_AMSEL_R		;Carrega o R0 com o endereço do AMSEL para a porta B
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta B da memória
			
			LDR     R0, =GPIO_PORTP_AMSEL_R		;Carrega o R0 com o endereço do AMSEL para a porta P
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta P da memória
			
			LDR     R0, =GPIO_PORTQ_AMSEL_R		;Carrega o R0 com o endereço do AMSEL para a porta Q
            STR     R1, [R0]			;Guarda no registrador AMSEL da porta Q da memória
			
			LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere?o do AMSEL para a porta J
			STR     R1, [R0]
 
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
            LDR     R0, =GPIO_PORTA_AHB_PCTL_R		;Carrega o R0 com o endereço do PCTL para a porta A
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta A da memória
            LDR     R0, =GPIO_PORTB_AHB_PCTL_R      ;Carrega o R0 com o endereço do PCTL para a porta B
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta B da memória
			LDR     R0, =GPIO_PORTP_PCTL_R		;Carrega o R0 com o endereço do PCTL para a porta P
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta P da memória
			LDR     R0, =GPIO_PORTQ_PCTL_R		;Carrega o R0 com o endereço do PCTL para a porta Q
            STR     R1, [R0]			;Guarda no registrador PCTL da porta Q da memória
			LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere?o do PCTL para a porta J
			STR     R1, [R0]
; 4. DIR para 0 se for entrada, 1 se for saída
            LDR     R0, =GPIO_PORTA_AHB_DIR_R		;Carrega o R0 com o endereço do DIR para a porta A
			MOV     R1, #0xFF					;PF4 & PF0 para LED
            STR     R1, [R0]						;Guarda no registrador
			; O certo era verificar os outros bits da PF para não transformar entradas em saídas desnecessárias
            LDR     R0, =GPIO_PORTB_AHB_DIR_R		;Carrega o R0 com o endereço do DIR para a porta B
            MOV     R1, #0xFF               		;Colocar 0 no registrador DIR para funcionar com saída
            STR     R1, [R0]						;Guarda no registrador PCTL da porta B da memória
			;
			LDR     R0, =GPIO_PORTP_DIR_R		;Carrega o R0 com o endereço do DIR para a porta P
			MOV     R1, #0xFF						;PF4 & PF0 para LED
            STR     R1, [R0]						;Guarda no registrador
			;
			LDR     R0, =GPIO_PORTQ_DIR_R		;Carrega o R0 com o endereço do DIR para a porta Q
			MOV     R1, #0xFF						;PF4 & PF0 para LED
            STR     R1, [R0]				;Guarda no registrador

			LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere?o do DIR para a porta J
			MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com entrada
			STR     R1, [R0]
			
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem função alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para não setar função alternativa
            LDR     R0, =GPIO_PORTA_AHB_AFSEL_R		;Carrega o endereço do AFSEL da porta A
            STR     R1, [R0]						;Escreve na porta
            LDR     R0, =GPIO_PORTB_AHB_AFSEL_R     ;Carrega o endereço do AFSEL da porta B
            STR     R1, [R0]                        ;Escreve na porta
			LDR     R0, =GPIO_PORTP_AFSEL_R		;Carrega o endereço do AFSEL da porta P
            STR     R1, [R0]						;Escreve na porta
            LDR     R0, =GPIO_PORTQ_AFSEL_R     ;Carrega o endereço do AFSEL da porta Q
            STR     R1, [R0]                        ;Escreve na porta
			LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R		;Carrega o endere?o do AFSEL da porta J
			STR     R1, [R0]
			
; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTA_AHB_DEN_R			;Carrega o endereço do DEN
			LDR 	R2, [R0]
            MOV     R1, #2_11110000
			ORR 	R2, R1, R2
            STR     R2, [R0]				;Escreve no registrador da memória funcionalidade digital 
			
            LDR     R0, =GPIO_PORTB_AHB_DEN_R			;Carrega o endereço do DEN
			LDR 	R2, [R0]
            MOV     R1, #2_00110000 
			ORR 	R2, R1, R2
            STR     R1, [R0]							;Escreve no registrador da memória funcionalidade digital 
			
			LDR     R0, =GPIO_PORTP_DEN_R			;Carrega o endereço do DEN
            LDR 	R2, [R0]
			MOV     R1, #2_00100000                     
            ORR 	R2, R1, R2
			STR     R1, [R0]				;Escreve no registrador da memória funcionalidade digital 
			
            LDR     R0, =GPIO_PORTQ_DEN_R			;Carrega o endereço do DEN
			LDR 	R2, [R0]
			MOV     R1, #2_00001111                        
            ORR 	R2, R1, R2
			STR     R1, [R0]                            ;Escreve no registrador da memória funcionalidade digital
			
			LDR     R0, =GPIO_PORTJ_AHB_DEN_R		;Carrega o endere?o do DEN
			LDR     R1, [R0]						;Ler da mem?ria o registrador GPIO_PORTJ_AHB_DEN_R
			MOV     R2, #2_00000011					;Habilitar funcionalidade digital na DEN
			ORR     R1, R2							;Setar bits sem sobrescrever os demais
			STR     R1, [R0]
			
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
	LDR     R0, =GPIO_PORTJ_AHB_PUR_R		;Carrega o endere?o do PUR para a porta J
	MOV     R1, #BIT0						;Habilitar funcionalidade digital de resistor de pull-up 
	ORR     R1, #BIT1						;nos bits 0 e 1
	STR     R1, [R0]						;Escreve no registrador da mem?ria do resistor de pull-up
	BX      LR

;retorno            
			BX      LR

; -------------------------------------------------------------------------------
; LED_Or_7seg_Output
; Inputs: R0
LED_Or_7seg_Output
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

; Inputs: Não tem
Liga_LED
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTP_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT A
	ORR R2, R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR

; Inputs: Não tem
Desliga_LED
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTP_DATA_R
	LDR R2, [R1]  ; R2 <= Dados do PORT A
	BIC R2, R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR

; Inputs: Não tem
Liga_7segDireita
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTB_AHB_DATA_R
	LDR R2, [R1]
	ORR R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR
	
; Inputs: Não tem
Desliga_7segDireita
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTB_AHB_DATA_R
	LDR R2, [R1]
	BIC R2, #2_00100000
	STR R2, [R1]
	POP {R1,R2,PC}
	BX LR

; Inputs: Não tem
Liga_7segEsquerda
	PUSH {R1,R2, LR} 
	LDR R1, =GPIO_PORTB_AHB_DATA_R
	LDR R2, [R1]
	ORR R2, #2_00010000
	STR R2, [R1]
	POP {R1,R2,LR}
	BX LR

; Inputs: Não tem
Desliga_7segEsquerda
	PUSH {R1,R2,LR} 
	LDR R1, =GPIO_PORTB_AHB_DATA_R
	LDR R2, [R1]
	BIC R2, #2_00010000
	STR R2, [R1]
	POP {R1,R2,PC}
	BX LR

; Inputs: R0
; Outputs: R1 - Código para 7 segmentos
DecodePassoCavaleiro
	CMP R0, #0
	BNE UmCavaleiro
	MOV R1, #PASSO0
	BX LR
UmCavaleiro
	CMP R0, #1
	BNE DoisCavaleiro
	MOV R1, #PASSO1
	BX LR
DoisCavaleiro
	CMP R0, #2
	BNE TresCavaleiro
	MOV R1, #PASSO2
	BX LR
TresCavaleiro
	CMP R0, #3
	BNE QuatroCavaleiro
	MOV R1, #PASSO3
	BX LR
QuatroCavaleiro
	CMP R0, #4
	BNE CincoCavaleiro
	MOV R1, #PASSO4
	BX LR
CincoCavaleiro
	CMP R0, #5
	BNE SeisCavaleiro
	MOV R1, #PASSO5
	BX LR
SeisCavaleiro
	CMP R0, #6
	BNE SeteCavaleiro
	MOV R1, #PASSO6
	BX LR
SeteCavaleiro
	MOV R1, #PASSO7
	BX LR


Decode7seg
	CMP R0, #0
	BNE Um
	MOV R1, #DIGIT_0
	BX LR
Um	
	CMP R0, #1
	BNE Dois
	MOV R1, #DIGIT_1
	BX LR
Dois
	CMP R0, #2
	BNE Tres
	MOV R1, #DIGIT_2
	BX LR
Tres
	CMP R0, #3
	BNE Quatro
	MOV R1, #DIGIT_3
	BX LR
Quatro
	CMP R0, #4
	BNE Cinco
	MOV R1, #DIGIT_4
	BX LR
Cinco
	CMP R0, #5
	BNE Seis
	MOV R1, #DIGIT_5
	BX LR
Seis
	CMP R0, #6
	BNE Sete
	MOV R1, #DIGIT_6
	BX LR
Sete
	CMP R0, #7
	BNE Oito
	MOV R1, #DIGIT_7
	BX LR
Oito
	CMP R0, #8
	BNE Nove
	MOV R1, #DIGIT_8
	BX LR
Nove
	MOV R1, #DIGIT_9
	BX LR

; -------------------------------------------------------------------------------
; Função LeBotoes
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
LeBotoes
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos [J1-J0]
	BX LR									;Retorno



    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo