set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          arm)

if (NOT DEFINED ARM_TOOLCHAIN_PATH)
    set(ARM_TOOLCHAIN_PATH /opt/toolchain/gcc-arm-none-eabi-9-2020-q2-update/)
endif ()
message("Using arm toolchain in: ${ARM_TOOLCHAIN_PATH}")

# Without this flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_AR                        ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-ar${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_ASM_COMPILER              ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-gcc${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_C_COMPILER                ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-gcc${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER              ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-g++${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_LINKER                    ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-ld${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_OBJCOPY                   ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-objcopy${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_RANLIB                    ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-ranlib${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_SIZE                      ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-size${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_STRIP                     ${ARM_TOOLCHAIN_PATH}bin/arm-none-eabi-strip${CMAKE_EXECUTABLE_SUFFIX})

set(CMAKE_C_FLAGS                   "-fdata-sections -ffunction-sections -Wl,--gc-sections" )
set(CMAKE_CXX_FLAGS                 "${CMAKE_C_FLAGS}  -ffunction-sections -fdata-sections")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g")
set(CMAKE_C_FLAGS_RELEASE           "-O2 -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
