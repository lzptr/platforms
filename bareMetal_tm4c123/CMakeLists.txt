
if (NOT DEFINED TM4C123_LINKER_FILE)
	set(TM4C123_LINKER_FILE ${CMAKE_CURRENT_LIST_DIR}/TM4C123GH6PM.ld)
	message("Using default linker file: ${TM4C123_LINKER_FILE}")
endif()

# Add the library target
add_library(bareMetal_tm4c123 INTERFACE)

# Set compiler definitions needed to compile for the tm4c123gh6pm
set(TM4C123_C_FLAGS 
        -mthumb 
        -mcpu=cortex-m4 
        -mfpu=fpv4-sp-d16 
        -mfloat-abi=hard)

# Set assembler definitions
set(TM4C123_ASM_FLAGS
        ${TM4C123_C_FLAGS} 
        -x assembler-with-cpp)

set(TM4C123_CXX_FLAGS 
        ${TM4C123_C_FLAGS} 
        -fno-exceptions 
        -fno-rtti)

# Set linker definitions needed to link the binary for the tm4c123
set(TM4C123_C_LFLAGS 
        ${TM4C123_C_FLAGS} 
        -Wl,-entry=ResetISR
        -Wl,-T${TM4C123_LINKER_FILE}
        -Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

set(TM4C123_CXX_LFLAGS
        ${TM4C123_CXX_FLAGS}
        -Wl,-entry=ResetISR
        -Wl,-T${TM4C123_LINKER_FILE}
        -Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

# Set the compiler and linker flags. The public porperty exports these to the targets linking to this interface.
target_compile_options(bareMetal_tm4c123
        INTERFACE
        $<$<COMPILE_LANGUAGE:ASM>:${TM4C123_ASM_FLAGS}>
        $<$<COMPILE_LANGUAGE:C>:${TM4C123_C_FLAGS}>
        $<$<COMPILE_LANGUAGE:CXX>:${TM4C123_CXX_LFLAGS}>)

target_link_options(bareMetal_tm4c123
        INTERFACE 
        $<$<COMPILE_LANGUAGE:C>:${TM4C123_C_LFLAGS}>
        $<$<COMPILE_LANGUAGE:CXX>:${TM4C123_CXX_LFLAGS}>)