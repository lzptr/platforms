set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          pru)

if (NOT DEFINED PRU_TOOLCHAIN_PATH)
set(SEND_ERROR "Please provide a path to the pru toolchain (ARM_TOOLCHAIN_PATH)")
endif ()
message("Using arm toolchain in: ${ARM_TOOLCHAIN_PATH}")

# Without this flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_AR                        ${PRU_TOOLCHAIN_PATH}bin/arpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_ASM_COMPILER              ${PRU_TOOLCHAIN_PATH}bin/asmpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_C_COMPILER                ${PRU_TOOLCHAIN_PATH}bin/clpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER              ${PRU_TOOLCHAIN_PATH}bin/clpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_LINKER                    ${PRU_TOOLCHAIN_PATH}bin/clpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_OBJCOPY                   ${PRU_TOOLCHAIN_PATH}bin/hexpru${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_STRIP                     ${PRU_TOOLCHAIN_PATH}bin/strippru${CMAKE_EXECUTABLE_SUFFIX})

set(CMAKE_C_FLAGS                   "" )
set(CMAKE_CXX_FLAGS                 "${CMAKE_C_FLAGS}")

set(CMAKE_C_FLAGS_DEBUG             "-g --keep_asm")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)