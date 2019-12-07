#include "state.h"
#include <math.h>
#include <stdint.h>

const uint16_t PASSOS_POR_VOLTA = 2048;

const uint32_t HOR_PassoCompleto[4] = {0x01,0x02,0x04,0x08};    // Matriz dos bytes das Fases do Motor - sentido Horário Full Step
const uint32_t AHO_PassoCompleto[4] = {0x08,0x04,0x02,0x01};    // Matriz dos bytes das Fases do Motor - sentido Anti-Horário Full Step

const uint32_t HOR_MeioPasso[8] = {0x09,0x01,0x03,0x02,0x06,0x04,0x0c,0x08};    // Matriz dos bytes das Fases do Motor - sentido Horário Half Step
const uint32_t AHO_MeioPasso[8] = {0x08,0x0c,0x04,0x06,0x02,0x03,0x01,0x09}; 	 // Matriz dos bytes das Fases do Motor - sentido Horário Half Step

/* Funções */

// Inicialização
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void delay(uint32_t mili);
void GPIO_Init(void);

// IO
void LedOutput(uint32_t leds);
void LedEnable(void);

void LCD_Init(void);
void LCD_ImprimeString(char *string);
void LCD_SetaCursor(uint8_t linha, uint8_t coluna);
void LCD_Clear(void);

uint16_t LeTeclado(void);

void fazVolta(uint32_t tipo, uint32_t sentido);
void PortH_Output(uint32_t);

void InterruptHandler(void);

// Utils
char *int2char(uint16_t num);
uint8_t nextLed(uint8_t ledAtual, Sentido s);

void mostraStatus(uint16_t volta, Sentido s, Velocidade v, uint8_t leds);

uint16_t leNumeroDeVoltas(void);
Sentido leSentido(void);
Velocidade leVelocidade(void);

Estado estado = {.nome = INICIAL,
                 .voltaAtual = 0,
                 .passoAtual = 0x00,
                 .totalVoltas = 0,
                 .sentido = HORARIO,
                 .velocidade = PASSO_COMPLETO};

int main(void) {
  // Inicialização
  PLL_Init();
  SysTick_Init();
  GPIO_Init();
  LCD_Init();
  LedEnable();
	LCD_ImprimeString("      FIM");
  uint16_t voltasFaltantes;

  while (1) {
    switch (estado.nome) {
    case INICIAL:
      estado.voltaAtual = 0;

      estado.totalVoltas = leNumeroDeVoltas();
      delay(200);
      estado.sentido = leSentido();
      delay(200);
      estado.velocidade = leVelocidade();

      estado.nome = GIRANDO;

      if (estado.sentido == HORARIO) {
        estado.leds = 0x80;
      } else {
        estado.leds = 0x01;
      }

      break;
    case GIRANDO:
      voltasFaltantes = estado.totalVoltas - estado.voltaAtual;

      if (voltasFaltantes == 0) {
        estado.nome = FINAL;
        continue;
      }

      mostraStatus(voltasFaltantes, estado.sentido, estado.velocidade,
                   estado.leds);

      // TODO: Trocar delay por motor girando
      fazVolta(estado.velocidade, estado.sentido);

      estado.voltaAtual++;
      estado.leds = nextLed(estado.leds, estado.sentido);
      break;
    case FINAL:
      LCD_Clear();
      LedOutput(0x00);
      LCD_ImprimeString("      FIM");
      LeTeclado();
      estado.nome = INICIAL;
      break;
    default:
      break;
    }
  }
}

void mostraStatus(uint16_t volta, Sentido s, Velocidade v, uint8_t leds) {
  LCD_Clear();
  LCD_SetaCursor(0, 0);

  LCD_ImprimeString("Volta: ");
  LCD_ImprimeString(int2char(volta));

  LCD_SetaCursor(1, 0);
  if (s == HORARIO) {
    LCD_ImprimeString("Horario - ");
  } else {
    LCD_ImprimeString("Anti - ");
  }

  if (v == PASSO_COMPLETO) {
    LCD_ImprimeString("Full");
  } else {
    LCD_ImprimeString("Half");
  }

  LedOutput(leds);
};

// Lê número de voltas do teclado
uint16_t leNumeroDeVoltas() {
  uint8_t numDeVoltas = 0;
  uint8_t tecla;
  char *digitoChar;

  LCD_Clear();
  LCD_SetaCursor(0, 0);
  LCD_ImprimeString("N. de voltas: ");

  for (int i = 0; i < 2; i++) {
    tecla = LeTeclado();
    digitoChar = int2char(tecla);
    numDeVoltas += (int)tecla * pow(10, 1 - i);
    LCD_ImprimeString(digitoChar);
  }

  return numDeVoltas;
}

// Lê sentido de rotação do teclado
Sentido leSentido() {
  LCD_Clear();
  LCD_SetaCursor(0, 0);
  LCD_ImprimeString("Horario: *");
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString("Antihorario: #");

  uint8_t tecla = LeTeclado();

  // tecla == *
  if (tecla == 99) {
    return HORARIO;
  }

  // tecla == #
  return ANTIHORARIO;
}

// Lê velocidade de rotação do teclado
Velocidade leVelocidade() {
  LCD_Clear();
  LCD_SetaCursor(0, 0);
  LCD_ImprimeString("Full step: *");
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString("Half step: #");

  uint8_t tecla = LeTeclado();

  // tecla == *
  if (tecla == 99) {
    return PASSO_COMPLETO;
  }

  // tecla == #
  return MEIO_PASSO;
}

void fazVolta(uint32_t tipo, uint32_t sentido){
	if(tipo == PASSO_COMPLETO){
		uint32_t atraso_fase = 2;
		if(sentido == HORARIO){
			for(int i = 0; i < 512; i++){      // incrementa o contador i de 0 a 511 - uma volta
				for(int j = 0; j < 4; j++) {     // incrementa o contador j de 0 a 3 
					PortH_Output(HOR_PassoCompleto[j]);               // Carrega bytes da Matriz HOR na Porta B 
					delay (atraso_fase);          // Atraso de tempo entre as fases em milisegundos
				}
			}
		}
		else if(sentido == ANTIHORARIO){
			for(int i = 0; i < 512; i++){      // incrementa o contador i de 0 a 511 - uma volta
				for(int j = 0; j < 4; j++){      // incrementa o contador j de 0 a 3 
					PortH_Output(AHO_PassoCompleto[j]);               // Carrega bytes da Matriz AHO na Porta B 
					delay (atraso_fase);          // Atraso de tempo entre as fases em milisegundos
				}
			}
		}
	}
	else if(tipo == MEIO_PASSO){
		uint32_t atraso_fase = 1;
		if(sentido == HORARIO){
			for(int i = 0; i < 512; i++){      // incrementa o contador i de 0 a 511 - uma volta
				for(int j = 0; j < 8; j++){      // incrementa o contador j de 0 a 7 
					PortH_Output(HOR_MeioPasso[j]);               // Carrega bytes da Matriz HOR na Porta B 
					delay (atraso_fase);          // Atraso de tempo entre as fases em milisegundos
				}
			}
		}
		else if(sentido == ANTIHORARIO){
			for(int i = 0; i < 512; i++){      // incrementa o contador i de 0 a 511 - uma volta
				for(int j = 0; j < 8; j++){      // incrementa o contador j de 0 a 7 
					PortH_Output(AHO_MeioPasso[j]);      // Carrega bytes da Matriz AHO na Porta B 
					delay (atraso_fase);          // Atraso de tempo entre as fases em milisegundos
				}
			}
		}
	}
}

void InterruptHandler(void) { estado.nome = FINAL; }

void delay(uint32_t mili) { SysTick_Wait1ms(mili); }
