if (NOT DEFINED AVR_MCU)
        message(SEND_ERROR "Please set a ATTINY variant (e.g. attiny25, attiny85) and set  ${AVR_MCU}.")
endif()

if (NOT DEFINED CPU_FREQ)
        message("Warning CPU frequency not set.")
endif()

add_library(bareMetal_attiny INTERFACE)

# Set compiler definitions needed to compile for the chip
set(ATTINY_C_FLAGS 
        --std=c11
        -mmcu=${AVR_MCU}
        -DF_CPU=${CPU_FREQ})


# Set linker definitions for the project linking to this library
set(ATTINY_C_LFLAGS 
        ${ATTINY_C_FLAGS}
        -Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

target_link_libraries(bareMetal_attiny INTERFACE gcc c m )

# Set the compiler and linker flags. The public porperty exports these to the targets linking to this library.
target_compile_options(bareMetal_attiny
INTERFACE
        $<$<COMPILE_LANGUAGE:C>:${ATTINY_C_FLAGS}>)

target_link_options(bareMetal_attiny
        INTERFACE 
        $<$<COMPILE_LANGUAGE:C>:${ATTINY_C_LFLAGS}>)