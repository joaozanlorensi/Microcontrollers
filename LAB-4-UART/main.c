#include "state.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include "tm4c1294ncpdt.h"


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

unsigned char UART_InChar(void);
unsigned char UART_InCharNonBlocking(void);
void UART_Init(void);
void UART_PrintString(char *string);
void UART_OutChar(unsigned char data);


Sentido GetSentido(void);
Velocidade GetVelocidade(void);
void ImprimeStatus(void);
void PWM(void);
void ligaEnable(void);
void desligaEnable(void);
void habilitaTimer(void);
void deshabilitaTimer(void);
void Timer2_init(void);
void setaSentido(Sentido sentido);
uint32_t converteTempoParaTimer(uint32_t tempoEmUs);

// Utils
char *int2char(uint16_t num);

Estado estado = {.nome = INICIAL};

int main(void) {
  // Inicialização
  PLL_Init();
  SysTick_Init();
  GPIO_Init();
  LCD_Init();
  UART_Init();
  Timer2_init();
  LedEnable();

  LCD_ImprimeString("   Controlador");
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString("    de Motor");

  // delay(1000);

  char incomingChar;
  
  while (1) {
    switch (estado.nome) {
    case INICIAL:
      LCD_Clear();
      desligaEnable();
      deshabilitaTimer();
      UART_PrintString("Bem vindo ao controlador de velocidade!\n\r");
      UART_PrintString("Motor: Parado\n\r");
      estado.sentido = GetSentido();
      estado.velocidade = GetVelocidade();
      estado.nome = GIRANDO;
      TIMER2_TAILR_R = converteTempoParaTimer(1000 - estado.velocidade * 100);
      habilitaTimer();
      break;
    case GIRANDO:
      LCD_Clear();
      LCD_ImprimeString("Girando...");
      ImprimeStatus();
      // Chamada para motor girar;
      // giraMotor(estado.velocidade);
      setaSentido(estado.sentido);
      
      incomingChar = UART_InCharNonBlocking();
      if(incomingChar == 'h')
        estado.sentido = HORARIO;
      else if(incomingChar == 'a')
        estado.sentido = ANTIHORARIO;
      else if(incomingChar == '0')
        estado.velocidade = Parado;
      else if(incomingChar == '1')
        estado.velocidade = Vel1;
      else if(incomingChar == '2')
        estado.velocidade = Vel2;
      else if(incomingChar == '3')
        estado.velocidade = Vel3;
      else if(incomingChar == '4')
        estado.velocidade = Vel4;
      else if(incomingChar == '5')
        estado.velocidade = Vel5;
      else if(incomingChar == '6')
        estado.velocidade = Vel6;
    default:
      break;
    }
  }
}

Sentido GetSentido(void) {
  char incomingChar;
  Sentido sentido;
  UART_PrintString("\nSentido de rotacao:\n\rh para Horario e a para "
                   "Antihorario (Enter para confirmar)\n\r");

  LCD_Clear();
  LCD_ImprimeString("    Sentido");
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString("   de rotacao");

  // Echo de caracteres diferentes de Enter
  while (incomingChar != '\r') {
    incomingChar = UART_InChar();
    if (incomingChar != '\r')
      UART_OutChar(incomingChar);
    if (incomingChar == 'h')
      sentido = HORARIO;
    else if (incomingChar == 'a')
      sentido = ANTIHORARIO;
    else
      UART_PrintString("\n\r");
  }

  UART_PrintString("\nSentido selecionado: ");
  if (sentido == HORARIO)
    UART_PrintString("Horario\n\n\r");
  else
    UART_PrintString("Antihorario\n\n\r");

  return sentido;
}

Velocidade GetVelocidade(void) {
  char incomingChar;
  Velocidade velocidade;

  UART_PrintString("Velocidade de rotacao:\n\r");
  UART_PrintString("0 - Parado:\n\r");
  UART_PrintString("1 - 50% da velocidade maxima\n\r");
  UART_PrintString("2 - 60% da velocidade maxima\n\r");
  UART_PrintString("3 - 70% da velocidade maxima\n\r");
  UART_PrintString("4 - 80% da velocidade maxima\n\r");
  UART_PrintString("5 - 90% da velocidade maxima\n\r");
  UART_PrintString("6 - Velocidade maxima\n\r");

  LCD_Clear();
  LCD_ImprimeString("   Velocidade");
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString("   de rotacao");

  // Echo de caracteres diferentes de Enter
  while (incomingChar != '\r') {
    incomingChar = UART_InChar();
    if (incomingChar != '\r')
      UART_OutChar(incomingChar);
    else
      UART_PrintString("\n\r");

    switch (incomingChar) {
    case '0':
      velocidade = Parado;
      break;
    case '1':
      velocidade = Vel1;
      break;
    case '2':
      velocidade = Vel2;
      break;
    case '3':
      velocidade = Vel3;
      break;
    case '4':
      velocidade = Vel4;
      break;
    case '5':
      velocidade = Vel5;
      break;
    case '6':
      velocidade = Vel6;
      break;
    }
  }

  UART_PrintString("\nVelocidade selecionada: ");
  switch (velocidade) {
  case Parado:
    UART_PrintString("0 - Parado\n\n\r");
    break;
  case Vel1:
    UART_PrintString("1 - 50%\n\n\r");
    break;
  case Vel2:
    UART_PrintString("2 - 60%\n\n\r");
    break;
  case Vel3:
    UART_PrintString("3 - 70%\n\n\r");
    break;
  case Vel4:
    UART_PrintString("4 - 80%\n\n\r");
    break;
  case Vel5:
    UART_PrintString("5 - 90%\n\n\r");
    break;
  case Vel6:
    UART_PrintString("6 - Velocidade maxima\n\n\r");
    break;
  }

  return velocidade;
}

void ImprimeStatus(){
  if(estado.velocidade != Parado)
    UART_PrintString("Motor: Girando\n\r");
  else
    UART_PrintString("Motor: Parado\n\r");
  
  switch (estado.velocidade) {
  case Parado:
    UART_PrintString("Velocidade: Parado\n\r");
    break;
  case Vel1:
    UART_PrintString("Velocidade: 50%\n\r");
    break;
  case Vel2:
    UART_PrintString("Velocidade: 60%\n\r");
    break;
  case Vel3:
    UART_PrintString("Velocidade: 70%\n\r");
    break;
  case Vel4:
    UART_PrintString("Velocidade: 80%\n\r");
    break;
  case Vel5:
    UART_PrintString("Velocidade: 90%\n\r");
    break;
  case Vel6:
    UART_PrintString("Velocidade: Maxima\n\r");
    break;
  }
  
  if(estado.sentido == HORARIO)
    UART_PrintString("Sentido: Horario\n\n\r");
  else
    UART_PrintString("Sentido: Antihorario\n\n\r");
  
}

void InterruptHandler() {
  estado.nome = INICIAL;
}
void delay(uint32_t mili) { SysTick_Wait1ms(mili); }

void HandlePWM(){
    if(GPIO_PORTF_AHB_DATA_R == 0x0004){
      deshabilitaTimer();
      TIMER2_TAILR_R = converteTempoParaTimer(1000 - estado.velocidade * 100);
      desligaEnable();
    } else {
      deshabilitaTimer();
      TIMER2_TAILR_R = converteTempoParaTimer(estado.velocidade * 100);
      ligaEnable();
    }
    habilitaTimer();
}

uint32_t converteTempoParaTimer(uint32_t tempoEmUs){
  return 80 * tempoEmUs  - 1;
}
