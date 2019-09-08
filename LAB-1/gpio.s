; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; Defini��es de Valores
BIT0	EQU 2_0001
BIT1	EQU 2_0010
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports
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


; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortN_Output			; Permite chamar PortN_Output de outro arquivo
		EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
									

;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; ****************************************
; Escrever fun��o de inicializa��o dos GPIO
; Inicializar as portas J e N
; ****************************************

			LDR R0, =SYSCTL_RCGCGPIO_R
			MOV R1, #GPIO_PORTN
			ORR R1, #GPIO_PORTJ
			STR R1, [R0]
			LDR R0, =SYSCTL_PRGPIO_R
EsperaGPIO	LDR R1, [R0]
			MOV R2, #GPIO_PORTN
			MOV R2, #GPIO_PORTJ
			TST R1, R2
			BEQ EsperaGPIO
			MOV	R1, #0x00						
			LDR	R0, =GPIO_PORTJ_AHB_AMSEL_R     
			STR R1, [R0]						
			LDR R0, =GPIO_PORTN_AHB_AMSEL_R		
			STR R1, [R0]
			MOV R1, #0x00					    
			LDR R0, =GPIO_PORTJ_AHB_PCTL_R		
			STR R1, [R0]                        
			LDR R0, =GPIO_PORTN_AHB_PCTL_R      
			STR R1, [R0]  
			LDR R0, =GPIO_PORTN_AHB_DIR_R		
			MOV R1, #2_00010001					
			STR R1, [R0]						
			LDR R0, =GPIO_PORTJ_AHB_DIR_R		
			MOV R1, #0x00               		
			STR R1, [R0]						
			MOV R1, #0x00						
			LDR R0, =GPIO_PORTN_AHB_AFSEL_R		
			STR R1, [R0]						
			LDR R0, =GPIO_PORTJ_AHB_AFSEL_R     
			STR R1, [R0] 
			LDR R0, =GPIO_PORTN_AHB_DEN_R			
			MOV R1, #2_00010001                     
			STR R1, [R0]							
			LDR R0, =GPIO_PORTJ_AHB_DEN_R			
			MOV R1, #2_00000011                         
			STR R1, [R0] 
			LDR R0, =GPIO_PORTJ_AHB_PUR_R			
			MOV R1, #2_00000011						
			STR R1, [R0]
			BX LR

; -------------------------------------------------------------------------------
; Fun��o PortN_Output
; Par�metro de entrada: R0 <- Valor a ser escrito na Porta N
; Par�metro de sa�da: N�o tem
PortN_Output
; ****************************************
; Escrever fun��o que acende ou apaga o LED
; ****************************************
	LDR R1, =GPIO_PORTN_AHB_DATA_R
	LDR R2, [R1]
	BIC R2, #2_00000010
	ORR R0, R0, R2
	STR R0, [R1]
	BX LR

; -------------------------------------------------------------------------------
; Fun��o PortJ_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortJ_Input
; ****************************************
; Escrever fun��o que l� a chave e retorna 
; um registrador se est� ativada ou n�o
; ****************************************
	LDR R1, =GPIO_PORTJ_AHB_DATA_R
	LDR R0, [R1]
	BX LR

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
