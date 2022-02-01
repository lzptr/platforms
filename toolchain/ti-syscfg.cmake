function(generate_syscfg_bsp_files 
            TARGET
            SYSCONFIG_TOOL
            SYSCONFIG_MANIFEST
            SYSCONFIG_OUTPUT_DIRECTORY
            SYSCONFIG_CONFIG_FILE
            SYSCONFIG_CONTEXT
            SYSCONFIG_PART
            SYSCONFIG_PACKAGE)

    if(NOT DEFINED SYSCONFIG_TOOL)
        set(SEND_ERROR "Please provide a path to the syscfg script (SYSCONFIG_TOOL)")
    endif()
    if(NOT DEFINED SYSCONFIG_MANIFEST)
        set(SEND_ERROR "Please provide a path to the syscfg manifest (SYSCONFIG_MANIFEST)")
    endif()
    if(NOT DEFINED SYSCONFIG_OUTPUT_DIRECTORY)
        set(SEND_ERROR "Please specify an oputput folder for the syscfg generated files (SYSCONFIG_OUTPUT_DIRECTORY)")
    endif()
    if(NOT DEFINED SYSCONFIG_CONFIG_FILE)
        set(SEND_ERROR "Please provide a valid syscfg configuration for the given platform (SYSCONFIG_CONFIG_FILE)")
    endif()
    if(NOT DEFINED SYSCONFIG_CONTEXT)
        set(SEND_ERROR
            "Please provide a valid syscfg context (e.g. core for multicore setup) for the given platform (SYSCONFIG_CONTEXT)"
        )
    endif()
    if(NOT DEFINED SYSCONFIG_PART)
        set(SEND_ERROR "Please provide a valid part name for the given platform (SYSCONFIG_PART)")
    endif()
    if(NOT DEFINED SYSCONFIG_PACKAGE)
        set(SEND_ERROR "Please provide a valid package for the given platform (SYSCONFIG_PACKAGE)")
    endif()

    message("Using syscfg in: ${SYSCONFIG_TOOL}")
    message("Using syscfg manifest from: ${SYSCONFIG_MANIFEST}")
    message("Using syscfg output dir: ${SYSCONFIG_OUTPUT_DIRECTORY}")
    message("Using syscfg config: ${SYSCONFIG_CONFIG_FILE}")
    message("Using syscfg context: ${SYSCONFIG_CONTEXT}")
    message("Using syscfg part: ${SYSCONFIG_PART}")
    message("Using syscfg package: ${SYSCONFIG_PACKAGE}")

    # Generate syscfg files
    execute_process(
        COMMAND
            ${SYSCONFIG_TOOL} 
            -s "${SYSCONFIG_MANIFEST}" 
            --script ${SYSCONFIG_CONFIG_FILE} 
            -o ${SYSCONFIG_OUTPUT_DIRECTORY} 
            --context ${SYSCONFIG_CONTEXT} 
            --part ${SYSCONFIG_PART} 
            --package ${SYSCONFIG_PACKAGE} 
            --compiler gcc
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endfunction()
