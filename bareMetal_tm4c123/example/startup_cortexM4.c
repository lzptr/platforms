#include <stdint.h>

// FPU regiter (CoProcessor Access Control register)
#define CPAC_REG (*(volatile uint32_t *)0xe000ed88)


//*****************************************************************************
//
// Forward declaration of the default fault handlers.
//
//*****************************************************************************
void ResetISR(void);
static void NmiSR(void);
static void FaultISR(void);
static void IntDefaultHandler(void);

//*****************************************************************************
//
// The entry point for the application.
//
//*****************************************************************************
extern int main(void);

//*****************************************************************************
//
// The following are constructs created by the linker, indicating where the
// the "data" and "bss" segments reside in memory.  The initializers for the
// for the "data" segment resides immediately following the "text" segment.
//
//*****************************************************************************
extern uint32_t _stack_ptr;
extern uint32_t __text_end_vma;
extern uint32_t __data_start_vma;
extern uint32_t __data_end_vma;
extern uint32_t __bss_start_vma;
extern uint32_t __bss_end_vma;

//*****************************************************************************
//
// The vector table.  Note that the proper constructs must be placed on this to
// ensure that it ends up at physical address 0x0000.0000.
//
//*****************************************************************************
__attribute__ ((section(".isr_vector")))
uintptr_t isrVectorTable[] =
{
	(uintptr_t )&_stack_ptr,                            // The initial stack pointer
	(uintptr_t )ResetISR,                               // The reset handler
	(uintptr_t )NmiSR,                                  // The NMI handler
	(uintptr_t )FaultISR,                               // The hard fault handler
	(uintptr_t )IntDefaultHandler,                      // The MPU fault handler
	(uintptr_t )IntDefaultHandler,                      // The bus fault handler
	(uintptr_t )IntDefaultHandler,                      // The usage fault handler
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // SVCall handler
	(uintptr_t )IntDefaultHandler,                      // Debug monitor handler
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // The PendSV handler
	(uintptr_t )IntDefaultHandler,                      // The SysTick handler
	(uintptr_t )IntDefaultHandler,                      // GPIO Port A
	(uintptr_t )IntDefaultHandler,                      // GPIO Port B
	(uintptr_t )IntDefaultHandler,                      // GPIO Port C
	(uintptr_t )IntDefaultHandler,                      // GPIO Port D
	(uintptr_t )IntDefaultHandler,                      // GPIO Port E
	(uintptr_t )IntDefaultHandler,                      // UART0 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART1 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // SSI0 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // I2C0 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // PWM Fault
	(uintptr_t )IntDefaultHandler,                      // PWM Generator 0
	(uintptr_t )IntDefaultHandler,                      // PWM Generator 1
	(uintptr_t )IntDefaultHandler,                      // PWM Generator 2
	(uintptr_t )IntDefaultHandler,                      // Quadrature Encoder 0
	(uintptr_t )IntDefaultHandler,                      // ADC Sequence 0
	(uintptr_t )IntDefaultHandler,                      // ADC Sequence 1
	(uintptr_t )IntDefaultHandler,                      // ADC Sequence 2
	(uintptr_t )IntDefaultHandler,                      // ADC Sequence 3
	(uintptr_t )IntDefaultHandler,                      // Watchdog timer
	(uintptr_t )IntDefaultHandler,                      // Timer 0 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 0 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Timer 1 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 1 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Timer 2 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 2 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Analog Comparator 0
	(uintptr_t )IntDefaultHandler,                      // Analog Comparator 1
	(uintptr_t )IntDefaultHandler,                      // Analog Comparator 2
	(uintptr_t )IntDefaultHandler,                      // System Control (PLL, OSC, BO)
	(uintptr_t )IntDefaultHandler,                      // FLASH Control
	(uintptr_t )IntDefaultHandler,                      // GPIO Port F
	(uintptr_t )IntDefaultHandler,                      // GPIO Port G
	(uintptr_t )IntDefaultHandler,                      // GPIO Port H
	(uintptr_t )IntDefaultHandler,                      // UART2 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // SSI1 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // Timer 3 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 3 subtimer B
	(uintptr_t )IntDefaultHandler,                      // I2C1 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // Quadrature Encoder 1
	(uintptr_t )IntDefaultHandler,                      // CAN0
	(uintptr_t )IntDefaultHandler,                      // CAN1
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // Hibernate
	(uintptr_t )IntDefaultHandler,                      // USB0
	(uintptr_t )IntDefaultHandler,                      // PWM Generator 3
	(uintptr_t )IntDefaultHandler,                      // uDMA Software Transfer
	(uintptr_t )IntDefaultHandler,                      // uDMA Error
	(uintptr_t )IntDefaultHandler,                      // ADC1 Sequence 0
	(uintptr_t )IntDefaultHandler,                      // ADC1 Sequence 1
	(uintptr_t )IntDefaultHandler,                      // ADC1 Sequence 2
	(uintptr_t )IntDefaultHandler,                      // ADC1 Sequence 3
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // GPIO Port J
	(uintptr_t )IntDefaultHandler,                      // GPIO Port K
	(uintptr_t )IntDefaultHandler,                      // GPIO Port L
	(uintptr_t )IntDefaultHandler,                      // SSI2 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // SSI3 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART3 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART4 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART5 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART6 Rx and Tx
	(uintptr_t )IntDefaultHandler,                      // UART7 Rx and Tx
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // I2C2 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // I2C3 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // Timer 4 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 4 subtimer B
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // Timer 5 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Timer 5 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 0 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 0 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 1 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 1 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 2 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 2 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 3 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 3 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 4 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 4 subtimer B
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 5 subtimer A
	(uintptr_t )IntDefaultHandler,                      // Wide Timer 5 subtimer B
	(uintptr_t )IntDefaultHandler,                      // FPU
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // I2C4 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // I2C5 Master and Slave
	(uintptr_t )IntDefaultHandler,                      // GPIO Port M
	(uintptr_t )IntDefaultHandler,                      // GPIO Port N
	(uintptr_t )IntDefaultHandler,                      // Quadrature Encoder 2
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )0,                                      // Reserved
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P (Summary or P0)
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P1
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P2
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P3
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P4
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P5
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P6
	(uintptr_t )IntDefaultHandler,                      // GPIO Port P7
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q (Summary or Q0)
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q1
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q2
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q3
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q4
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q5
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q6
	(uintptr_t )IntDefaultHandler,                      // GPIO Port Q7
	(uintptr_t )IntDefaultHandler,                      // GPIO Port R
	(uintptr_t )IntDefaultHandler,                      // GPIO Port S
	(uintptr_t )IntDefaultHandler,                      // PWM 1 Generator 0
	(uintptr_t )IntDefaultHandler,                      // PWM 1 Generator 1
	(uintptr_t )IntDefaultHandler,                      // PWM 1 Generator 2
	(uintptr_t )IntDefaultHandler,                      // PWM 1 Generator 3
	(uintptr_t )IntDefaultHandler                       // PWM 1 Fault
};

//*****************************************************************************
//
// This is the code that gets called when the processor first starts execution
// following a reset event.  Only the absolutely necessary set is performed,
// after which the application supplied entry() routine is called.  Any fancy
// actions (such as making decisions based on the reset cause register, and
// resetting the bits in that register) are left solely in the hands of the
// application.
//
//*****************************************************************************
void ResetISR(void)
{
	uint32_t *memSrc, *memDestination;

	//
	// Copy the data segment initializers from flash to SRAM.
	//
	memSrc = &__text_end_vma;
	memDestination = &__data_start_vma;
	while(memDestination < &__data_end_vma)
	{
		*memDestination++ = *memSrc++;
	}

	memDestination = &__bss_start_vma;
	while(memDestination < &__bss_end_vma) 
	{
		*memDestination++ = 0;
	}

	// Enable the floating-point unit (Datasheet p. 134)
	CPAC_REG |= (0xf << 20);
	
	__asm__ volatile (
	"dsb\r\n"        // force memory writes before continuing
	"isb\r\n" );     // reset the pipeline

	//
	// Call the application's entry point.
	//
	main();
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a NMI.  This
// simply enters an infinite loop, preserving the system state for examination
// by a debugger.
//
//*****************************************************************************
static void NmiSR(void)
{
	//
	// Enter an infinite loop.
	//
	while(1)
	{
	}
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a fault
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void FaultISR(void)
{
	//
	// Enter an infinite loop.
	//
	while(1)
	{
	}
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives an unexpected
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void IntDefaultHandler(void)
{
	//
	// Go into an infinite loop.
	//
	while(1)
	{
	}
}
