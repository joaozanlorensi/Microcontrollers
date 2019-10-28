#include "state.h"
#include <math.h>
#include <stdint.h>

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

void gira(uint32_t velocidade, uint32_t sentido);
void PortH_Output(uint32_t);

void InterruptHandler(void);

// Utils
char *int2char(uint16_t num);

void mensagemInicial();
void mostraStatus(sentido s, Velocidade v);

Sentido leSentido(void);
Velocidade leVelocidade(void);
uint16_t tipoInput;


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

  estado.nome = INICIAL;

  while (1) {
    switch (estado.nome) {
    case INICIAL: //*
      mensagemInicial();
      delay(500);
      
      tipoInput = selecionaInput();
      delay(200);

      if (tipoInput == TECLADO){
        estado.velocidade = leVelocidadeTeclado();
        delay(200);
        estado.sentido = leSentidoTeclado();
        delay(200);
      }
      else if(tipoInput == TERMINAL){
        estado.velocidade = leVelocidadeTerminal();
        delay(200);
        estado.sentido = leSentidoTerminal();
        delay(200);
      }
    
      estado.nome = GIRANDO;

      break;
    case GIRANDO: //*
      estado.nome = FINAL;
      
      if(tipoInput == TECLADO){
        gira(estado.velocidade, estado.sentido);
        mostraStatusLCD(estado.sentido, estado.velocidade);
      }
      else if(tipoInput == POTENCIOMETRO){
        giraComPotenciometro(estado.sentido);
        mostraStatusLCD(estado.sentido, estado.velocidade);
      }
      else{
        gira(estado.velocidade, estado.sentido);
        mostraStatusTerminal(estado.sentido, estado.velocidade);
      }
      
      break;
    case FINAL: //*
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

void mensagemInicial() {
  LCD_Clear();
  LCD_SetaCursor(0, 0);
  LCD_ImprimeString("   MOTOR PARADO   ");
};

uint16_t selecionaVelocidadeTeclado() {
  LCD_Clear();
  LCD_SetaCursor(0, 0);

  LCD_ImprimeString("Velocidade: ");
  velocidade = LeTeclado();
  LCD_ImprimeString(int2char(velocidade));

  return velocidade;
};

Sentido leSentidoTeclado() {
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

void mostraStatus(Sentido s, uint16_t velocidade) {
  LCD_Clear();
  LCD_SetaCursor(0, 0);

  LCD_ImprimeString("Velocidade: ");
  LCD_ImprimeString(int2char(velocidade));
  LCD_ImprimeString(" rpm");

  LCD_SetaCursor(1, 0);
  if (s == HORARIO) {
    LCD_ImprimeString("Sentido horario");
  } else {
    LCD_ImprimeString("Sentido anti-horario");
  }
};

void gira(uint32_t tipo, uint32_t sentido){
	
}

void fazPWM(){
  PortF_Output();
}

void InterruptHandler(void) { estado.nome = FINAL; }

void delay(uint32_t mili) { SysTick_Wait1ms(mili); }
