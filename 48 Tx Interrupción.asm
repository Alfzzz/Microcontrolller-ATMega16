/*EjercicioRealice un programa que transmita por puerto serial un arreglo de 50 caracteresASCII ubicados en SRAM a partir de la direcci�n 0x60.
La transmisi�n serial ser�A 9600 baudios con el siguiente formato:
-8 bits de datos
-1 bit de parada
- Sin paridad*/

.INCLUDE "m16def.inc"
.ORG 0
RJMP main
.ORG 0x18
RJMP tx

main:
	;Pila
	LDI R16,HIGH(RAMEND)
	OUT SPH,R16
	LDI R16,LOW(RAMEND)
	OUT SPL,R16

	SBI DDRD,1	;Salida de Tx

	;UCSRC=|URSEL|UMSEL|UPM1|UPM2|USBS|UCSZ1|UCSZ0|UCPOL|=10000110
	;Seleccionar UCSRC,as�ncrono, sin paridad, un bit de parada, 8 bits de datos, sin polaridad de clock
	LDI R16,0b10000110		
	OUT UCSRC,R16	
	
	;UCSRB=|RXCIE|TXCIE|UDRIE|RXEN|TXEN|UCSZ2|RXB8|TXB8|=00101000	
	;Habilitar transmisi�n, habilitar interrupci�n por buffer de transmisi�n vac�o
	LDI R16,0b00101000	;
	OUT UCSRB,R16

	;Baudrate=9600------>UBRRH|UBRRL=51
	LDI R16,HIGH(51)
	OUT UBRRH,R16
	LDI R16,LOW(51)
	OUT UBRRL,R16

	;Preparaci�n para transmisi�n
	LDI XH,HIGH(0x60)
	LDI XL,LOW(0x60)
	LDI R25,50	;Contador de 50 datos
	
	SEI	;Empieza la transmisi�n porque el buffer empieza vac�o
	fin:
		RJMP fin
tx:
	IN R15,SREG
	PUSH R15

	enviar:
		LD R16,X+
		OUT UDR,R16	;Transmitir
		DEC R25
		BRNE txRETI
		CLR R16	;termina la transmisi�n y se inhabilitan transmisi�n e interrupciones 
		OUT UCSRB,R16
	
	txRETI:
		POP R15
		OUT SREG,R15
		RETI
		