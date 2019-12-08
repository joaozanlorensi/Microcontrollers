#ifndef DS18B20__H
#define DS18B20__H

#include "tm4c1294ncpdt.h"
#include <stdint.h>

// Using GPIO Port L Pin 0 for the OneWire Pin
// Adjust here for your settings!
#define PORT_DATA GPIO_PORTL_DATA_R
#define PORT_DIR GPIO_PORTL_DIR_R
#define PORT_BIT 0x01

// Commands for the DS18B20
#define SKIP_ROM 0xCC
#define CONVERT 0x44
#define READ_SCRATCH 0xBE
#define WRITE_SCRATCH 0x4E
#define PRECISION_9 0;
#define PRECISION_10 32;
#define PRECISION_11 64;
#define PRECISION_12 96;

// Index for bytes in the scratchpad
#define TEMP_MSB 1
#define TEMP_LSB 0

typedef enum { INPUT, OUTPUT } PinMode;

uint8_t DS18B20_Reset(void);
void DS18B20_SetPrecision(uint8_t numOfBits);
void DS18B20_PinMode(PinMode mode);
void DS18B20_BitWrite(uint8_t bit);
void DS18B20_ByteWrite(uint8_t byte);
uint8_t DS18B20_BitRead(void);
uint8_t DS18B20_ByteRead(void);
float DS18B20_GetTemperature(void);
#endif
