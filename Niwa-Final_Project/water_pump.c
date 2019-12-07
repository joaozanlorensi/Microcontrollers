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

// Sentido padrão de rotação da bomba d'água = horário
void WaterPump_ClockwiseRotation(){
      GPIO_PORTE_AHB_DATA_R = 0x2;
}

void WaterPump_EnableOn() {
  GPIO_PORTF_AHB_DATA_R = GPIO_PORTF_AHB_DATA_R | 0x04; 
}

void WaterPump_EnableOff() {
  GPIO_PORTF_AHB_DATA_R = GPIO_PORTF_AHB_DATA_R & ~0x04;
}
