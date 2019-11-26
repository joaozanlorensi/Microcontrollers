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

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);

void delay(uint32_t mili);

void adcConvert(void);
void adcInit(void);

int main(void)
{
	PLL_Init();
  SysTick_Init();
  GPIO_Init();
	adcInit();
	
	while(1){
		adcConvert();
		delay(1000);
	}
}

void delay(uint32_t mili) { SysTick_Wait1ms(mili); }
