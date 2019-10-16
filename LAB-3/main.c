// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado da chave USR_SW2 e acende os LEDs 1 e 2 caso esteja pressionada
// Prof. Guilherme Peron

#include <stdint.h>
#include <math.h>

enum Estados {INICIAL, GIRANDO};
enum Sentido {HORARIO,ANTIHORARIO};
enum Velocidade {PASSO_COMPLETO, MEIO_PASSO};

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);

uint32_t PortJ_Input(void);
void PortN_Output(uint32_t leds);


void LCD_Init(void);
void LCD_ImprimeString(char* string);
void LCD_SetaCursor(uint8_t linha, uint8_t coluna);
void LCD_Clear(void);

uint16_t LeTeclado(void);

char* int2char(uint16_t num);

char* msg1 = "N de voltas:";

// Estado global
uint8_t estado = 0;
uint8_t sentido = HORARIO;
uint8_t velocidade = PASSO_COMPLETO;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	LCD_Init();
	
	uint16_t tecla;
	char* digito;
	uint16_t numDeVoltas;
	
	
	switch(estado) {
		case INICIAL:
			numDeVoltas = 0;
			LCD_ImprimeString(msg1);
			for(int i=0;i<2;i++){
				tecla = LeTeclado();
				digito = int2char(tecla);
				numDeVoltas += (int) tecla * pow(10,i);
				LCD_ImprimeString(digito);
			}
			SysTick_Wait1ms(500);
			LCD_Clear();
			LCD_SetaCursor(0,0);
			LCD_ImprimeString("Horario: *");
			LCD_SetaCursor(1,0);
			LCD_ImprimeString("Antihorario: #");
			tecla = LeTeclado();
			if(tecla == 10){
				sentido = HORARIO;
			}
			if(tecla == 11) {
				sentido = ANTIHORARIO;
			}
			SysTick_Wait1ms(500);
			LCD_Clear();
			LCD_SetaCursor(0,0);
			LCD_ImprimeString("Full step: *");
			LCD_SetaCursor(1,0);
			LCD_ImprimeString("Half step: #");
			break;
		default:
			break;
	}
}

char* int2char(uint16_t num) {
	switch(num) {
		case 0:
			return "0";
		case 1:
			return "1";
		case 2:
			return "2";
		case 3:
			return "3";
		case 4:
			return "4";
		case 5:
			return "5";
		case 6:
			return "6";
		case 7:
			return "7";
		case 8:
			return "8";
		case 9:
			return "9";
		case 10:
			return "*";
		case 11:
			return "#";
		default:
			return "x";
	}
}
