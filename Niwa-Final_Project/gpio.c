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
#define GPIO_PORTE 0x0010

// Interruption parameters
#define GPIO_PORTJ_INTERRUPT_NUMBER 0x00080000
#define GPIO_PORTJ_PRI_LEVEL 0xE0000000

// GPIO Field
void GPIO_Init() {
  uint32_t GPIO_PORTS = GPIO_PORTE;

  // 1a. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO
  SYSCTL_RCGCGPIO_R |= GPIO_PORTS;

  // 1b. Apos isso verifica no PRGPIO se a porta está pronta para uso.
  while ((SYSCTL_PRGPIO_R & (GPIO_PORTS)) != (GPIO_PORTS)) {
  };

  // 2. Limpa o AMSEL para desabilitar a analógica
  GPIO_PORTE_AHB_AMSEL_R = 0x10; // PE4 = Entrada analogica
  
  // 3. Limpa PCTL para selecionar o GPIO
  GPIO_PORTE_AHB_PCTL_R = 0x00;
  
  // 4. DIR para 0 se for entrada, 1 se for saída
  GPIO_PORTE_AHB_DIR_R = 0x10; // PE4 <- Entrada do sensor de umidade
  
  // 5. Limpa os bits AFSEL para 0 para selecionar GPIO sem função alternativa
  GPIO_PORTE_AHB_AFSEL_R = 0x10; // Habilita funcao alternativa no PE4
  
  // 6. Seta os bits de DEN para habilitar I/O digital
  GPIO_PORTE_AHB_DEN_R = 0x00; // PE4 = Entrada analogica
  
  // 7. Habilita resistor de pull-up interno, seta PUR para 1
  
  // 8. Define a rotina para interrupção geral

}

void adcInit(){
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

void adcConvert(){
  ADC0_PSSI_R = 0x8; // Inicia o gatilho de SW, no sequenciador no registrador ADCPSSI (sequenciador 3)
  while(ADC0_RIS_R != 0x8){}; //Faz polling do registrador ADCRIS, para esperar a conversão do sequenciador 3
  uint32_t valor = ADC0_SSFIFO3_R; // Lê o resultado da conversão no registrador ADCSSFIFO3
  ADC0_ISC_R = 0x00080000; // Realiza o ACK no registrador ADCISC para limpar o bit de conversão no registrador ADCRIS (escreve 1 no bit DCINSS3, bit 19)
// return valor;
}
