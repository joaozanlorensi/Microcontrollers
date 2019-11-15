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

// Define ports
#define GPIO_PORTA 0x0001

// Interruption parameters
#define GPIO_PORTJ_INTERRUPT_NUMBER 0x00080000
#define GPIO_PORTJ_PRI_LEVEL 0xE0000000

// GPIO Field
void GPIO_Init() {
  uint32_t GPIO_PORTS = GPIO_PORTA;

  // 1a. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO
  // 1b. Apos isso verifica no PRGPIO se a porta está pronta para uso.

  // 2. Limpa o AMSEL para desabilitar a anal�gica

  // 3. Limpa PCTL para selecionar o GPIO

  // 4. DIR para 0 se for entrada, 1 se for saída

  // 5. Limpa os bits AFSEL para 0 para selecionar GPIO sem função alternativa

  // 6. Seta os bits de DEN para habilitar I/O digital

  // 7. Habilita resistor de pull-up interno, seta PUR para 1

  // 8. Define a rotina para interrupção geral

}