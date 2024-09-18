#include <Keyboard.h>
#include <TimerOne.h>  // Biblioteca para gestionar el temporizador

// Pines del joystick
const int pinX = A0;
const int pinY = A1;
const int pinSW = 2;  // Pulsador del joystick en pin de interrupción (D2)

// Pulsador para la tecla 'E', para el exit del juego
const int pinPulsadorE = 3;  // Pulsador para la tecla 'E' (D3) para el exit

// Rangos para detectar movimiento del joystick
int centroX = 512;
int centroY = 512;
int umbral = 200;

// Variables para gestionar la interrupción del botón
volatile bool botonPresionado = false;
volatile bool pulsadorEPresionado = false;

void setup() {
  // Iniciar la simulación del teclado
  Keyboard.begin();

  // Configuración del pulsador del joystick como entrada con resistencia pull-up
  pinMode(pinSW, INPUT_PULLUP);
  
  // Configuración del pulsador como entrada con resistencia pull-up
  pinMode(pinPulsadorE, INPUT_PULLUP);

  // Configuración de la interrupción externa en el pulsador del joystick (D2)
  attachInterrupt(digitalPinToInterrupt(pinSW), manejarBotonJoystick, FALLING);  // Interrupción para el pulsador del joystick
  
  // Configuración de la interrupción externa para el nuevo pulsador 'E' (D3)
  attachInterrupt(digitalPinToInterrupt(pinPulsadorE), manejarPulsadorE, FALLING);  // Interrupción para el pulsador 'E'

  // Configuración del temporizador para leer los ejes del joystick cada 100ms
  Timer1.initialize(100000);  // 100000 microsegundos = 100ms
  Timer1.attachInterrupt(lecturaJoystick);  // Configura la interrupción del temporizador

  // Leer los valores iniciales para centrar el joystick
  centroX = analogRead(pinX);
  centroY = analogRead(pinY);
}

void loop() {
  // Si el botón del joystick fue presionado (gestionado por la interrupción)
  if (botonPresionado) {
    Keyboard.press('r');
    delay(100);  // Delay para evitar múltiples presiones no deseadas
    Keyboard.release('r');
    botonPresionado = false;  // Reiniciamos el flag del botón
  }

  // Si el pulsador 'E' fue presionado (gestionado por la interrupción)
  if (pulsadorEPresionado) {
    Keyboard.press('e');
    delay(100);  // Delay para evitar múltiples presiones no deseadas
    Keyboard.release('e');
    pulsadorEPresionado = false;  // Reiniciamos el flag del pulsador
  }

  // El código principal no hace nada hasta que ocurra una interrupción.
  delay(10);  // Colocamos un delay para que el loop no esté vacío
}

// Función de interrupción para manejar el botón del joystick
void manejarBotonJoystick() {
  botonPresionado = true;  // Pone el botón como presionado
}

// Función de interrupción para manejar el nuevo pulsador (tecla 'E')
void manejarPulsadorE() {
  pulsadorEPresionado = true;  // Pone el pulsador como presionado
}

// Función de interrupción periódica para leer los ejes del joystick
void lecturaJoystick() {
  int valorX = analogRead(pinX);
  int valorY = analogRead(pinY);

  // Movimiento en el eje X
  if (valorX < centroX - umbral) {
    Keyboard.press(KEY_LEFT_ARROW);
  } else if (valorX > centroX + umbral) {
    Keyboard.press(KEY_RIGHT_ARROW);
  } else {
    Keyboard.release(KEY_LEFT_ARROW);
    Keyboard.release(KEY_RIGHT_ARROW);
  }

  // Movimiento en el eje Y
  if (valorY < centroY - umbral) {
    Keyboard.press(KEY_UP_ARROW);ee
  } else if (valorY > centroY + umbral) {
    Keyboard.press(KEY_DOWN_ARROW);
  } else {
    Keyboard.release(KEY_UP_ARROW);
    Keyboard.release(KEY_DOWN_ARROW);
  }
}
