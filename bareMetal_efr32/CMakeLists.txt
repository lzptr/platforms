# Minimal setup to compile a project for the efr32 platform.
# 
# No sdk features supported here. Use the sdk_support library to include the 
# silicon labs drivers.

if (USE_BARE_METAL_EFR32_LINKER_FILE)
	set(EFR32_LINKER_FILE ${CMAKE_CURRENT_LIST_DIR}/efr32_minimal.ld)
	message("Using bare meal linker file: ${EFR32_LINKER_FILE}")
endif()



# Add the library target
add_library(bareMetal_efr32 INTERFACE)

# Set compiler definitions
set(EFR32_C_FLAGS 
	-mthumb 
	-mcpu=cortex-m4
	-mfpu=fpv4-sp-d16
	-mfloat-abi=softfp)

# Set assembler definitions
set(EFR32_ASM_FLAGS
	${EFR32_C_FLAGS} 
	-x assembler-with-cpp)

set(EFR32_CXX_FLAGS 
	${EFR32_C_FLAGS} 
	-fno-exceptions 
	-fno-rtti)


# Set linker definitions
set(EFR32_C_LFLAGS 
	${EFR32_C_FLAGS} 
	-Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

if (USE_BARE_METAL_EFR32_LINKER_FILE)
	set(EFR32_C_LFLAGS ${EFR32_C_LFLAGS} -Wl,-T${EFR32_LINKER_FILE})
endif()

set(EFR32_CXX_LFLAGS
	${EFR32_CXX_FLAGS}
	-Wl,-Map=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_PROJECT_NAME}.map)

if (USE_BARE_METAL_EFR32_LINKER_FILE)
	set(EFR32_CXX_LFLAGS ${EFR32_C_LFLAGS} -Wl,-T${EFR32_LINKER_FILE})
endif()

# Set the compiler and linker flags. The public porperty exports these to the targets linking to this interface.
target_compile_options(bareMetal_efr32
	INTERFACE
	$<$<COMPILE_LANGUAGE:ASM>:${EFR32_ASM_FLAGS}>
	$<$<COMPILE_LANGUAGE:C>:${EFR32_C_LFLAGS}>
	$<$<COMPILE_LANGUAGE:CXX>:${EFR32_CXX_LFLAGS}>)

target_link_options(bareMetal_efr32
	INTERFACE 
	$<$<COMPILE_LANGUAGE:C>:${EFR32_C_LFLAGS}>
	$<$<COMPILE_LANGUAGE:CXX>:${EFR32_CXX_LFLAGS}>)

target_include_directories(bareMetal_efr32
INTERFACE 
	${CMAKE_CURRENT_SOURCE_DIR}/include
)
