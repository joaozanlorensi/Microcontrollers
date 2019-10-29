#include <stdint.h>

typedef enum { INICIAL, GIRANDO, FINAL } Nome;
typedef enum { HORARIO, ANTIHORARIO } Sentido;
typedef enum { Parado, Vel1, Vel2, Vel3, Vel4, Vel5, Vel6 } Velocidade;

typedef struct {
  Nome nome;
  uint8_t passoAtual;
  uint8_t totalPassos;
  uint8_t voltaAtual;
  uint8_t totalVoltas;
  uint8_t leds;
  Sentido sentido;
  Velocidade velocidade;
} Estado;
