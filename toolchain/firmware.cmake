
function(create_hex_output TARGET)
    add_custom_target(${TARGET}.hex ALL DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Oihex ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET}.hex)
endfunction()

function(create_bin_output TARGET)
    add_custom_target(${TARGET}.bin ALL DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Obinary ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET}.bin)
endfunction()



function(print_sizes TARGET)
    add_custom_command(
		TARGET ${TARGET} 
		POST_BUILD 
		COMMAND ${CMAKE_SIZE} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${TARGET}
		COMMENT "Section sizes of the elf file.")
endfunction()

#TODO Add Flash commands for different programmers