OUTPUT_EXECUTABLE_NAME := "mwe_section_logging";

#run {

    set_build_options_dc(.{do_output = false});

    args := get_build_options().compile_time_command_line;

    target_x64     := array_find(args, "-x64");
    target_arm     := array_find(args, "-arm64");

    cpu_target := CPU;
    os_target  := OS;
    if target_x64  cpu_target = .X64;
    if target_arm  cpu_target = .ARM64;

    target_triple_with_sdk: string;
    lib_path: string;

    log("Compiling for % %", os_target, cpu_target);

    build_output_directory := "bin";
    resources_output_directroy := "bin";

    make_directory_if_it_does_not_exist(build_output_directory,     recursive = true);
    make_directory_if_it_does_not_exist(resources_output_directroy, recursive = true);

    w := compiler_create_workspace("Target workspace");
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.cpu_target = cpu_target;
    options.os_target  = os_target;
    options.output_executable_name = OUTPUT_EXECUTABLE_NAME;
    if target_arm {
        options.backend = .LLVM;
        options.llvm_options.target_system_features = "+lse";
    }

    options.output_path = tprint("%/", build_output_directory);

    import_path: [..] string;
    array_add(*import_path, ..options.import_path);
    array_add(*import_path, "src/");
    options.import_path = import_path;

    set_build_options(options, w);

    compiler_begin_intercept(w);
    add_build_file("src/main.jai", w);
    while true {
        message := compiler_wait_for_message();
        if message.kind == {
            case .PHASE;
                phase_message := cast(*Message_Phase) message;

            case .ERROR;
                exit(1);

            case .COMPLETE;
                break;
        }
    }
    compiler_end_intercept(w);

};

#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
