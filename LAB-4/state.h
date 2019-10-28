#include <stdint.h>

typedef enum { TECLADO, POTENCIOMETRO, TERMINAL } Input;
typedef enum { INICIAL, GIRANDO, FINAL } Nome;
typedef enum { HORARIO, ANTIHORARIO } Sentido;

typedef struct {
  Nome nome;
  Sentido sentido;
  uint16_t velocidade;
} Estado;
