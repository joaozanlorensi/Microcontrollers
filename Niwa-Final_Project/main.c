/* 
 * Federal University of Technology - Paraná (UTFPR)
 * Course: Electronic Engineering
 * Class: Microcontrollers
 * Professor: Guilherme Peron
 * Students: Francisco Shigueo Miamoto and João Pedro Zanlorensi Cardoso
 * Final Project: Niwa - Smart Garden
 * Developed for Tiva C Series TM4C1294 microcontroller
 */

#include <stdint.h>

// Functions from gpio.c
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void adcConvert(void);
void adcInit(void);

// Functions from gpio.s
void LCD_Init(void);
void LCD_ImprimeString(char *string);
void LCD_SetaCursor(uint8_t linha, uint8_t coluna);
void LCD_Clear(void);

// Functions from uart.c
unsigned char UART_InChar(void);
unsigned char UART_InCharNonBlocking(void);
void UART_Init(void);
void UART_PrintString(char *string);
void UART_OutChar(unsigned char data);

// Other useful functions
void delay(uint32_t mili);

int main(void)
{
	PLL_Init();
  SysTick_Init();
  GPIO_Init();

	adcInit();
	LCD_Init();
	
	LCD_Clear();
	LCD_SetaCursor(1,1);
	LCD_ImprimeString("UTFPR");
}

void delay(uint32_t mili) { SysTick_Wait1ms(mili); }
