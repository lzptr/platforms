/* Minimalistic linker file for a cortex m4 chip
 *
 */

MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x00040000
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

SECTIONS
{
    /* 
     * initial stack pointer pointing to top of stack,starts from higher addresses
     * i.e ORIGIN(RAM) + LENGTH(RAM)-1 in this case 0x20007FFF to lower addesses i.e
     * those lesser than 0x20007FFF to 0x2000000,which is the original address of RAM,
     * until it comes in contact with .bss or .data in which case a buffer overflow occurs
    */
    PROVIDE( _stack_ptr = ORIGIN(SRAM) + LENGTH(SRAM));

    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        __text_end_vma = .;
    } > FLASH

    .data (NOLOAD):
    {
        __data_start_vma = .;
        *(.data*)
        __data_end_vma = .;
    } > SRAM AT > FLASH

    .bss (NOLOAD):
    {
        __bss_start_vma = .;
        *(.bss*)
        *(COMMON)
        __bss_end_vma = .;
    } > SRAM
}