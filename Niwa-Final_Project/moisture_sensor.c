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
#include <stdint.h>
#include <stdio.h>

// Leitura de tensão do Sensor de umidade
int32_t MoistureSensor_adcConvert(){ 
  ADC0_PSSI_R = 0x8; // Inicia o gatilho de SW, no sequenciador no registrador ADCPSSI (sequenciador 3)
  while(ADC0_RIS_R != 0x8){}; //Faz polling do registrador ADCRIS, para esperar a conversão do sequenciador 3
  int32_t adcValue = ADC0_SSFIFO3_R; // Lê o resultado da conversão no registrador ADCSSFIFO3
  ADC0_ISC_R = 0x00080000; // Realiza o ACK no registrador ADCISC para limpar o bit de conversão no registrador ADCRIS (escreve 1 no bit DCINSS3, bit 19)
  return adcValue;
}