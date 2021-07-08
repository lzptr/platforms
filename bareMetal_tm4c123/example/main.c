#include <stdint.h>
#include "tm4c123gh6pm.h"


// Color    LED(s) PortF
// dark     ---    0
// red      R--    0x02
// blue     --B    0x04
// green    -G-    0x08
// yellow   RG-    0x0A
// sky blue -GB    0x0C
// white    RGB    0x0E
// pink     R-B    0x06
#define LED_R 0x02 // PF1
#define LED_B 0x04 // PF2
#define LED_G 0x08 // PF3

#define SW1 0x10 // PF4


int main(void)
{
	SYSCTL_RCGC2_R |= 0x00000020;     // 1) F clock
	uint32_t delay = SYSCTL_RCGC2_R;           // delay

	// Set PF3 pin as output pin an enable digital function
	GPIO_PORTF_DIR_R |= LED_R;
	GPIO_PORTF_DEN_R |= LED_R;

	while(1)
	{
		GPIO_PORTF_DATA_R |= LED_R;

		for(int i = 0; i < 2000000; i++)
		{
		}

		GPIO_PORTF_DATA_R &= ~(LED_R);

		for(int i = 0; i < 2000000; i++)
		{
		}

	}
}
