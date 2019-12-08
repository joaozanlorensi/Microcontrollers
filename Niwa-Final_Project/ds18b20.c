#include "ds18b20.h"

void SysTick_Wait1us(uint32_t delay);
void SysTick_Wait1ms(uint32_t delay);

// Change to input or output of the DS18B20 pin
void DS18B20_PinMode(PinMode mode) {
  uint32_t portPinDirection = PORT_DIR;

  if (mode == INPUT) {
    portPinDirection &= ~PORT_BIT;
  } else if (mode == OUTPUT) {
    portPinDirection |= PORT_BIT;
  }

  PORT_DIR = portPinDirection;
}

// Write a bit on the DS18B20 line
void DS18B20_BitWrite(uint8_t bit) {
  uint32_t portData = PORT_DATA;

  if (bit == 1) {
    DS18B20_PinMode(INPUT);
    return;
  }

  // Write the bit friendly
  portData &= ~PORT_BIT;
  portData |= bit;

  PORT_DATA = portData;
}

// Reads the current bit on the sensor line
uint8_t DS18B20_BitRead() { return (uint8_t)PORT_DATA & PORT_BIT; }

// Write a byte to the temperature sensor
void DS18B20_ByteWrite(uint8_t byteToSend) {
  uint8_t i;
  uint8_t bitToSend;

  for (i = 0; i < 8; i++) {
    bitToSend = byteToSend & 0x01;

    if (bitToSend == 1) {
      DS18B20_PinMode(OUTPUT);
      DS18B20_BitWrite(0);
      SysTick_Wait1us(6);
      // Change to input to yank the line high via the pull-up resistor
      DS18B20_PinMode(INPUT);
      SysTick_Wait1us(64);
    } else {
      DS18B20_PinMode(OUTPUT);
      DS18B20_BitWrite(0);
      SysTick_Wait1us(60);
      // Yank high again
      DS18B20_PinMode(INPUT);
      SysTick_Wait1us(10);
    }

    byteToSend >>= 1;
  }
}

// Reset the temperature sensor
uint8_t DS18B20_Reset() {
  uint8_t hasResponded;

  DS18B20_PinMode(OUTPUT);
  DS18B20_BitWrite(0);
  SysTick_Wait1us(500);
  DS18B20_PinMode(INPUT);
  SysTick_Wait1us(70);
  // 0 means the device responded
  hasResponded = !DS18B20_BitRead();
  SysTick_Wait1us(430);

  return hasResponded;
}

// Read a byte from the temperature sensor
uint8_t DS18B20_ReadByte() {
  uint8_t byte = 0x00;
  uint8_t i;

  for (i = 0; i < 8; i++) {
    DS18B20_PinMode(OUTPUT);
    DS18B20_BitWrite(0);
    SysTick_Wait1us(5);
    DS18B20_PinMode(INPUT);
    SysTick_Wait1us(15);
    byte |= DS18B20_BitRead() << i;
  }

  return byte;
}

// Sets the sensor for the desired number of bits of precision
void DS18B20_SetPrecision(uint8_t numOfBits) {
  uint8_t precision;
  switch (numOfBits) {
  case 9:
    precision = PRECISION_9;
    break;
  case 10:
    precision = PRECISION_10;
    break;
  case 11:
    precision = PRECISION_11;
    break;
  case 12:
    precision = PRECISION_12;
    break;
  default:
    precision = PRECISION_9;
  }

  DS18B20_Reset();
  DS18B20_ByteWrite(SKIP_ROM);
  DS18B20_ByteWrite(WRITE_SCRATCH);

  // Ignore alarm registers
  DS18B20_ByteWrite(0x00);
  DS18B20_ByteWrite(0x00);

  DS18B20_ByteWrite(precision);
}

// Get the current temperature from the sensor
float DS18B20_GetTemperature() {
  uint8_t hasResponded = DS18B20_Reset();
  if (!hasResponded) {
    return -1.0;
  }

  DS18B20_ByteWrite(SKIP_ROM);
  DS18B20_ByteWrite(CONVERT);

  SysTick_Wait1us(10);

  DS18B20_Reset();
  DS18B20_ByteWrite(SKIP_ROM);
  DS18B20_ByteWrite(READ_SCRATCH);

  uint8_t scratchPad[9];
  uint8_t i;

  for (i = 0; i < 9; i++) {
    scratchPad[i] = DS18B20_ReadByte();
  }

  uint16_t rawTemp =
      (uint16_t)scratchPad[TEMP_LSB] + ((uint16_t)scratchPad[TEMP_MSB] << 8);

  float tempInC = (float)rawTemp / (float)2410;

  return tempInC;
}
