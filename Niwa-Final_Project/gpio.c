/* 
 * Federal University of Technology - Paraná (UTFPR)
 * Course: Electronic Engineering
 * Class: Microcontrollers
 * Professor: Guilherme Peron
 * Students: Francisco Shigueo Miamoto and João Pedro Zanlorensi Cardoso
 * Final Project: Niwa - Smart Garden
 * Developed for Tiva C Series TM4C1294 microcontroller
 */

#include "tm4c1294ncpdt.h"
#include "state.h"
#include <stdint.h>
#include <stdint.h>

// Define ports
#define GPIO_PORTA 0x0001 // UART
#define GPIO_PORTM 0x0800 // LCD Display
#define GPIO_PORTK 0x0200 // LCD Display
#define GPIO_PORTE 0x0010 // Moisture sensor and Water Pump
#define GPIO_PORTF 0x0020 // Water Pump
#define GPIO_PORTP 0x2000 // UART
#define GPIO_PORTL 0x0400 // Temperature sensor

// GPIO Field
void GPIO_Init() {
  uint32_t GPIO_PORTS = GPIO_PORTA;
	GPIO_PORTS |= GPIO_PORTE;
	GPIO_PORTS |= GPIO_PORTF;
	GPIO_PORTS |= GPIO_PORTK;
	GPIO_PORTS |= GPIO_PORTM;
	GPIO_PORTS |= GPIO_PORTP;
  GPIO_PORTS |= GPIO_PORTL;

  // 1a. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO
  SYSCTL_RCGCGPIO_R |= GPIO_PORTS;

  // 1b. Apos isso verifica no PRGPIO se a porta está pronta para uso.
  while ((SYSCTL_PRGPIO_R & (GPIO_PORTS)) != (GPIO_PORTS)) {
  };

  // 2. Limpa o AMSEL para desabilitar a analógica
  GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTE_AHB_AMSEL_R = 0x10; // PE4 = Entrada analogica
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
	GPIO_PORTK_AMSEL_R = 0x00;
	GPIO_PORTM_AMSEL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0x00;
  GPIO_PORTL_AMSEL_R = 0x00;
  
  // 3. Limpa PCTL para selecionar o GPIO
  GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTE_AHB_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;
	GPIO_PORTK_PCTL_R = 0x00;
  GPIO_PORTM_PCTL_R = 0x00;
	GPIO_PORTP_PCTL_R = 0x00;
  GPIO_PORTL_PCTL_R = 0x00;

  // 4. DIR para 0 se for entrada, 1 se for saída
  GPIO_PORTA_AHB_DIR_R = 0xF0;
	GPIO_PORTE_AHB_DIR_R = 0x1F; // PE4 <- Entrada do sensor de umidade, PE0-PE3 <- Sentido de rotacao da bomba d'água
  GPIO_PORTF_AHB_DIR_R = 0x0C; // PF2-PF3 <- Enable para motores usado na bomba d'água
	GPIO_PORTK_DIR_R = 0xFF;
	GPIO_PORTM_DIR_R = 0xFF;
	GPIO_PORTP_DIR_R = 0x00;
  GPIO_PORTL_DIR_R = 0x00;

	
  // 5. Limpa os bits AFSEL para 0 para selecionar GPIO sem função alternativa
  GPIO_PORTA_AHB_AFSEL_R = 0x03;
	GPIO_PORTE_AHB_AFSEL_R = 0x10; // Habilita funcao alternativa no PE4
  GPIO_PORTF_AHB_AFSEL_R = 0x00;
	GPIO_PORTK_AFSEL_R = 0x00;
	GPIO_PORTM_AFSEL_R = 0x00;
	GPIO_PORTP_AFSEL_R = 0x00;
  GPIO_PORTL_AFSEL_R = 0x00;
	
  // 6. Seta os bits de DEN para habilitar I/O digital
  GPIO_PORTA_AHB_DEN_R = 0xF3;
	GPIO_PORTE_AHB_DEN_R = 0x0F; // PE4 = Entrada analogica, PE0-PE3 = Entradas digitais
  GPIO_PORTF_AHB_DEN_R = 0xFF; // PF2-PF3 = Entradas digitais
	GPIO_PORTK_DEN_R = 0xFF;
	GPIO_PORTM_DEN_R = 0xF7;
	GPIO_PORTP_DEN_R = 0x20;
  GPIO_PORTL_DEN_R = 0x01;
}

// Inicializacao do ADC do sensor de umidade
void ADC_Init(){ 
  // Utilizando o ADC0 
  SYSCTL_RCGCADC_R = 0x00000001; // Habilita o clock no módulo ADC no registrador RCGCADC
  while (SYSCTL_PRADC_R0 != 1){}; // Espera até que a ADC0 esteja pronta para ser acessada no registrador PRADC
  ADC0_PC_R = 0x0000007; // Escolhe a máxima taxa de amostragem no registrador ADCPC = 7
  ADC0_SSPRI_R =  0x00000123; // Configura a prioridade de cada um dos sequenciadores no ADCSSPRI (todos os sequenciadores estao com prioridade máxima = 0)
  ADC0_ACTSS_R = 0x00000000; // Desabilita o sequenciador no registrador ADCACTSS para configurá-lo (sequenciador utilizado = 3, no bit 3)
  ADC0_EMUX_R = 0x00000000; // Configura o tipo de gatilho para cada conversão analógica no registrador ADCEMUX (amostragem continua com o sequenciador 3)
  ADC0_SSMUX3_R = 0x00000009; // Para cada amostra na sequência de amostragem, configura a fonte de entrada analógica no registrador ADCSSMUXn (configurada para a entrada analogica 0)
  ADC0_SSCTL3_R = 0x6; // Para cada amostra na sequência de amostragem configura os bits de controle no nibble correspondente no registrador ADCSSCTLn (ultimos quatro bits), end0 habilitado pois ha apenas uma amostra no sequenciador 3
  ADC0_ACTSS_R = 0x00000008;  // Habilita o sequenciador no registrador ADCACTSS para configurá-lo (1 no bit asen3)
}
