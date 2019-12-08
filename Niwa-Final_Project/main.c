/*
 * Federal University of Technology - Paraná (UTFPR)
 * Course: Electronic Engineering
 * Class: Microcontrollers
 * Professor: Guilherme Peron
 * Students: Francisco Shigueo Miamoto and João Pedro Zanlorensi Cardoso
 * Final Project: Niwa - Smart Garden
 * Developed for Tiva C Series TM4C1294 microcontroller
 */

#include "ds18b20.h"
#include <stdint.h>
#include <stdio.h>

#define UPPER_BOUND 4095 // ADC reading when dry
#define LOWER_BOUND 2600 // ADC reading when moist

// Functions from gpio.c
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void ADC_Init(void);

// Functions from moisture_sensor.c
int32_t MoistureSensor_adcConvert(void);
double MoistureSensor_adcToMoisture(uint32_t adcValue);

// Functions from water_pump.c
void WaterPump_ClockwiseRotation(void);
void WaterPump_EnableOn(void);
void WaterPump_EnableOff(void);

// Functions from lcd.s
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

// Functions from main.c
void printDataToSerial(float t, float m);
void printDataToLCD(float t, float m);
void delay(uint32_t mili);
float ADCToMoisture(int32_t value);

int main(void) {
  PLL_Init();
  SysTick_Init();
  GPIO_Init();
  ADC_Init();
  LCD_Init();
  UART_Init();

  DS18B20_SetPrecision(9);
  WaterPump_ClockwiseRotation();

  char serialRead;

  while (1) {
    serialRead = UART_InCharNonBlocking();
    if (serialRead == 'e') {
      float moisture = ADCToMoisture(MoistureSensor_adcConvert());
      float temperature = DS18B20_GetTemperature();
      printDataToSerial(temperature, moisture);
      printDataToLCD(temperature, moisture);
    } else if (serialRead == 'l') {
      WaterPump_EnableOn();
    } else if (serialRead == 'd') {
      WaterPump_EnableOff();
    }
  }
}

void delay(uint32_t mili) { SysTick_Wait1ms(mili); }

void printDataToSerial(float t, float m) {
  char str[16];
  sprintf(str, "/%.2f;%.2f/", t, m);
  UART_PrintString(str);
}

void printDataToLCD(float t, float m) {
  char str[16];
  LCD_Clear();

  sprintf(str, "T = %.2f %cC", t, 223);
  LCD_SetaCursor(0, 0);
  LCD_ImprimeString(str);
  sprintf(str, "M = %.2f %%", m);
  LCD_SetaCursor(1, 0);
  LCD_ImprimeString(str);
}

float ADCToMoisture(int32_t value) {
  return (float)100.0 * ((float)UPPER_BOUND - (float)value) /
         ((float)UPPER_BOUND - (float)LOWER_BOUND);
}
