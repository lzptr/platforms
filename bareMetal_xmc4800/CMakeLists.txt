project(bareMetal_xmc4800)

if (NOT DEFINED XMC4800_LINKER_FILE)
        set(XMC4800_LINKER_FILE ${CMAKE_CURRENT_LIST_DIR}/mtb-xmclib-cat3/CMSIS/Infineon/COMPONENT_XMC4800/Source/TOOLCHAIN_GCC_ARM/XMC4800x2048.ld)
        message("Using default linker file: ${XMC4800_LINKER_FILE}")
endif()


# Add the library target
add_library(bareMetal_xmc4800 INTERFACE)

## CPU Platform specific stuff
        
# Set compiler definitions
set(XMC4800_C_FLAGS 
        -mthumb 
        -DXMC4800_F144x2048
        -mcpu=cortex-m4 
        -mfpu=fpv4-sp-d16 
        -mfloat-abi=hard)

# Set assembler definitions
set(XMC4800_ASM_FLAGS
        ${XMC4800_C_FLAGS} 
        -x assembler-with-cpp
)

set(XMC4800_CXX_FLAGS 
        ${XMC4800_C_FLAGS} 
        -fno-exceptions 
        -fno-rtti)

# Set linker definitions
set(XMC4800_C_LFLAGS 
        ${XMC4800_C_FLAGS} 
        -Wl,-T${XMC4800_LINKER_FILE}
)

set(XMC4800_CXX_LFLAGS
        ${XMC4800_CXX_FLAGS}
        -Wl,-T${XMC4800_LINKER_FILE}
)

# Set the compiler and linker flags and push them down to targets linking to the library
target_compile_options(${PROJECT_NAME}
INTERFACE
        $<$<COMPILE_LANGUAGE:ASM>:${XMC4800_ASM_FLAGS}> 
        $<$<COMPILE_LANGUAGE:C>:${XMC4800_C_FLAGS}>
        $<$<COMPILE_LANGUAGE:CXX>:${XMC4800_CXX_FLAGS}>)

target_link_options(${PROJECT_NAME}
        INTERFACE 
        $<$<COMPILE_LANGUAGE:C>:${XMC4800_C_LFLAGS}>
        $<$<COMPILE_LANGUAGE:CXX>:${XMC4800_CXX_FLAGS}>)

