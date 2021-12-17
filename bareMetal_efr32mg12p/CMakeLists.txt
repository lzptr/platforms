# Minimal setup to compile a project for the efr32mg12p platform (Thunderboard Sense 2).
# 
# No sdk features supported here. Use the sdk_support library to include the 
# silicon labs drivers.

# Add the library target
add_library(bareMetal_efr32mg12p INTERFACE)

if (NOT DEFINED EFR32_LINKER_FILE)
	set(EFR32_LINKER_FILE ${CMAKE_CURRENT_LIST_DIR}/efr32mg12p_minimal.ld)
	message("Using default linker file: ${EFR32_LINKER_FILE}")
endif()


# Set C definitions
set(EFR32_C_FLAGS 
	-mthumb 
	-mcpu=cortex-m4
	-mfpu=fpv4-sp-d16 
	-mfloat-abi=hard)

# Set assembler definitions
set(EFR32_ASM_FLAGS
	${EFR32_C_FLAGS} 
	-x assembler-with-cpp)

# Set C++ definitions
set(EFR32_CXX_FLAGS 
	${EFR32_C_FLAGS} 
	-fno-exceptions 
	-fno-rtti)


# Set linker definitions
set(EFR32_C_LFLAGS 
	${EFR32_C_FLAGS} 
	-Wl,-T${EFR32_LINKER_FILE}
	-Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

set(EFR32_CXX_LFLAGS
	${EFR32_CXX_FLAGS}
	-Wl,-T${EFR32_LINKER_FILE}
	-Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)


# Set the compiler and linker flags
target_compile_options(bareMetal_efr32mg12p
	INTERFACE
	$<$<COMPILE_LANGUAGE:ASM>:${EFR32_ASM_FLAGS}>
	$<$<COMPILE_LANGUAGE:C>:${EFR32_C_LFLAGS}>
	$<$<COMPILE_LANGUAGE:CXX>:${EFR32_CXX_LFLAGS}>)

target_link_options(bareMetal_efr32mg12p
	INTERFACE 
	$<$<COMPILE_LANGUAGE:C>:${EFR32_C_LFLAGS}>
	$<$<COMPILE_LANGUAGE:CXX>:${EFR32_CXX_LFLAGS}>)

target_include_directories(bareMetal_efr32mg12p
INTERFACE 
	${CMAKE_CURRENT_SOURCE_DIR}/include
)
