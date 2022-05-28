
project(bareMetal_am2434_r5)

if (NOT DEFINED AM2434_R5_LINKER_FILE)
    set(SEND_ERROR "Please provide a linker file (AM2434_R5_LINKER_FILE)")
endif()

message("Using linker file: ${AM2434_R5_LINKER_FILE}")


# Workaround: GCC kernel libraries not available yet.
# Build the stuff needed for startup here
file(GLOB _AM243_KERNEL_COMMON_FILES ${MCU_SDK_PATH}/source/kernel/nortos/dpl/common/*.c)
file(GLOB _AM243_KERNEL_R5_C_FILES ${MCU_SDK_PATH}/source/kernel/nortos/dpl/r5/*.c)
file(GLOB _AM243_KERNEL_R5_ASM_FILES ${MCU_SDK_PATH}/source/kernel/nortos/dpl/r5/*.S)

# Add all drivers
file(GLOB_RECURSE _AM243_DRIVER_FILES 
            ${MCU_SDK_PATH}/source/drivers/adc/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/bootloader/v0/*.c
            #${MCU_SDK_PATH}/source/drivers/ddr/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/crc/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/ecap/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/epwm/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/eqep/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/fsi/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/gpio/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/gtc/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/i2c/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/ipc_notify/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/ipc_rpmsg/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/mcan/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/mcspi/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/mmcsd/v0/*.c
            #${MCU_SDK_PATH}/source/drivers/mpu_firewall/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/ospi/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/pinmux/*.c
            ${MCU_SDK_PATH}/source/drivers/pruicss/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/sciclient/*.c
            ${MCU_SDK_PATH}/source/drivers/soc/*.c
            ${MCU_SDK_PATH}/source/drivers/spinlock/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/uart/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/udma/v0/*.c
            ${MCU_SDK_PATH}/source/drivers/watchdog/v0/*.c
)

# Add the library target
add_library(${PROJECT_NAME} STATIC
                ${_AM243_KERNEL_COMMON_FILES}
                ${_AM243_KERNEL_R5_C_FILES}
                ${_AM243_KERNEL_R5_ASM_FILES}
                ${_AM243_DRIVER_FILES}
)

# Set compiler definitions needed to compile for the AM2434
set(AM2434_C_FLAGS 
    -mcpu=cortex-r5 
    -mfpu=vfpv3-d16
    -mfloat-abi=hard
    -marm
    -mlittle-endian
    -DSOC_AM64X
    -DOS_NORTOS
    -D_DEBUG_=1)

# Set assembler definitions
set(AM2434_ASM_FLAGS
    ${AM2434_C_FLAGS} 
    -x assembler-with-cpp)

set(AM2434_CXX_FLAGS 
    ${AM2434_C_FLAGS} 
    -fno-exceptions 
    -fno-rtti)

# Set linker definitions needed to link the binary for the AM2434
set(AM2434_C_LFLAGS 
    ${AM2434_C_FLAGS} 
    -Wl,-entry=_c_int00)

set(AM2434_CXX_LFLAGS
    ${AM2434_CXX_FLAGS}
    -Wl,-entry=_c_int00)

# Set the compiler and linker flags. The public porperty exports these to the targets linking to this interface.
target_compile_options(${PROJECT_NAME}
    PUBLIC
    $<$<COMPILE_LANGUAGE:ASM>:${AM2434_ASM_FLAGS}>
    $<$<COMPILE_LANGUAGE:C>:${AM2434_C_FLAGS}>
    $<$<COMPILE_LANGUAGE:CXX>:${AM2434_CXX_LFLAGS}>)

target_link_options(${PROJECT_NAME}
    PUBLIC 
    $<$<COMPILE_LANGUAGE:C>:${AM2434_C_LFLAGS}>
    $<$<COMPILE_LANGUAGE:CXX>:${AM2434_CXX_LFLAGS}>)

target_include_directories(${PROJECT_NAME}
                            PUBLIC
                            ${MCU_SDK_PATH}/source
                            ${MCU_SDK_PATH}/source/drivers
                            ${MCU_SDK_PATH}/source/hw_include  
                            PRIVATE
                            ${MCU_SDK_PATH}/source/kernel/nortos/dpl/common
                            ${MCU_SDK_PATH}/source/kernel/nortos/dpl/r5)