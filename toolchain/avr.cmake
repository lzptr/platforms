set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          avr)

# Without this flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_AR                        avr-ar${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_ASM_COMPILER              avr-gcc${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_C_COMPILER                avr-gcc${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER              avr-g++${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_LINKER                    avr-ld${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_OBJCOPY                   avr-objcopy${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_RANLIB                    avr-ranlib${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_SIZE                      avr-size${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_STRIP                     avr-strip${CMAKE_EXECUTABLE_SUFFIX})

set(CMAKE_C_FLAGS                   "-fdata-sections -ffunction-sections -Wl,--gc-sections" )
set(CMAKE_CXX_FLAGS                 "${CMAKE_C_FLAGS}  -ffunction-sections -fdata-sections")

set(CMAKE_C_FLAGS_DEBUG             "-Os -g")
set(CMAKE_C_FLAGS_RELEASE           "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
