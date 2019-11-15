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

// Assumes a 80 MHz bus clock, creates 9600 baud rate
void UART_Init(void) {          // should be called only once
  SYSCTL_RCGCUART_R |= 0x00000001; // activate UART0
  while(SYSCTL_PRUART_R != 0x00000001) // wait for UART0
  UART0_CTL_R &= ~0x00000001;   // disable UART
  UART0_IBRD_R = 520; // IBRD = int(80,000,000/(16*9600)) = int(520.83333)
  UART0_FBRD_R = 53; // FBRD = round(0.83333 * 64) = 53
  UART0_LCRH_R = 0x00000070;  // 8 bit, no parity bits, one stop, FIFOs
  UART0_CC_R = 0x00;
  UART0_CTL_R |= 0x00000001;  // enable UART
  
  //GPIO_PORTC_AFSEL_R |= 0x30; // enable alt funct on PC5-4
  //GPIO_PORTC_DEN_R |= 0x30;   // configure PC5-4 as UART0
  //GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R & 0xFF00FFFF) + 0x00220000;
  //GPIO_PORTC_AMSEL_R &= ~0x30; // disable analog on PC5-4
}

// Wait for new input, then return ASCII code
unsigned char UART_InChar(void) {
  while ((UART0_FR_R & 0x0010) != 0)
    ; // wait until RXFE is 0
  return ((unsigned char)(UART0_DR_R & 0xFF));
}

// Wait for buffer to be not full, then output
void UART_OutChar(unsigned char data) {

  while ((UART0_FR_R & 0x0020) != 0)
    ; // wait until TXFF is 0

  UART0_DR_R = data;
}

// Immediately return input or 0 if no input
unsigned char UART_InCharNonBlocking(void) {

  if ((UART0_FR_R & UART_FR_RXFE) == 0) {
    return ((unsigned char)(UART0_DR_R & 0xFF));

  } else {
    return 0;
  }
}

// Print string to serial port
void UART_PrintString(char * string){
 while(*string){
  UART_OutChar(*(string++));
 }   
}
