#include "state.h"
#include <stdint.h>

// Converte inteiro para seu respectivo char
char *int2char(uint16_t num) {
  switch (num) {
  case 0:
    return "0";
  case 1:
    return "1";
  case 2:
    return "2";
  case 3:
    return "3";
  case 4:
    return "4";
  case 5:
    return "5";
  case 6:
    return "6";
  case 7:
    return "7";
  case 8:
    return "8";
  case 9:
    return "9";
  case 10:
    return "10";
  case 99:
    return "*";
  case 98:
    return "#";
  default:
    return "x";
  }
}

uint8_t nextLed(uint8_t ledAtual, Sentido s) {
  uint8_t nextLed;
  if (s == HORARIO) {
    nextLed = ledAtual >> 1;
    if (nextLed == 0) {
      nextLed = 0x80;
    }
  } else {
    nextLed = ledAtual << 1;
    if (nextLed == 0) {
      nextLed = 0x01;
    }
  }

  return nextLed;
}
