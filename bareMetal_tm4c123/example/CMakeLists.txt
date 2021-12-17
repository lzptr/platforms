# EFR32 bare metal example
# Copy this to your main projects src folder and build it using cmake
#
# You also need a cmake file for the poject where you link against the bare metal libary.

set(CMAKE_PROJECT_NAME tm4c123_baremetal_example)

# Create the executable target
add_executable(${CMAKE_PROJECT_NAME}
                    startup_tm4c123.c 
                    main.c
)

# Link the libraries
target_link_libraries (${CMAKE_PROJECT_NAME} 
                        PUBLIC 
                            bareMetal_tm4c123
)

# Add the binary for flashing
create_bin_output(${CMAKE_PROJECT_NAME})

# Show the section sizes of the elf file
print_sizes(${CMAKE_PROJECT_NAME})