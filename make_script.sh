#!/bin/bash
#
# filename  make_script.sh
# author    ryan
# date      20141115
# purpose   Provide a shortcut for making new scripts from the bash script template
# assumes   You have an environment variable called FUNCTION_LIB_DIR and it is a directory
#           You have a file called log.lib in that directory.
#           You have an environment variable called TEMPLATE_DIR and it is a directory with a file 
#           in it called bash_template.sh and a file in it called python_template.py
#           You have an environment variable called SCRIPT_DIR and it is a directory
#           You have an environment variable called MY_BIN_DIR and it is a directory

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

pushd "$FUNCTION_LIB_DIR" > /dev/null
source log.lib
popd > /dev/null

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

# Global symbols that cannot be set by command line arguments

# Global symbols set by command line options
ext='.sh'                                       # -p changes to .py
source_file="$TEMPLATE_DIR/bash_template.sh"    # -p changes to $TEMPLATE_DIR/python_template.py

# Global symbols set by positional arguments

# Global symbols that could be set elsewhere and should not be overwritten
if [ -z "$TEST_FLAG" ]; then TEST_FLAG=0; fi
if [ -z "$VERBOSE_FLAG" ]; then VERBOSE_FLAG=0; fi
if [ -z "$SCRIPT_NAME" ]; then SCRIPT_NAME=$(basename "$0"); fi    # tracks whether script is sourced

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

# echo the file path for the resulting script with the filename ($1) passed in and the destination
# directory ($2)
function new_script_path {
    # echo 0 if must not add .sh to the input filename ($1)
    function must_add_ext {
        local input_filename="$1"
        local name_length=${#input_filename}
        local ext_length=${#ext}
        local ext_start=$(expr $name_length - $ext_length)
        local last_char=$(expr $name_length - 1)
        if [ $ext_length -gt $name_length ] || [ "$ext" != "${script_name:$ext_start:$last_char}" ]; then
            echo 1
        else
            echo 0
        fi
    }

    local script_name="$1"
    if [ 1 -eq $(must_add_ext "$script_name") ]; then
        script_name="$script_name$ext"
    fi

    unset -f must_add_ext
    echo "$2/$script_name"
}

# echo the symlink name for the filepath ($1) of the .sh script passed in
function symlink_path {
    local filename=$(basename "$1")
    local last_char=$(expr ${#filename} - ${#ext})
    local ret="$MY_BIN_DIR/${filename:0:$last_char}"
    echo "$ret"
}

# echo 1 if the symlink ($1) is already in the path and 0 otherwise
function already_in_path {
    if [ -z "$(which $1)" ]; then 
        echo 0
    else
        echo 1
    fi
}

# replace the header information for the file $1
function replace_header_info {
    log 'replace_header_info' "Replacing filename to $(basename $1)"
    sed -i "s/# filename  .*/# filename  $(basename $1)/g" "$1"
    log 'replace_header_info' "Replacing author to $USER"
    sed -i "s/# author    .*/# author    $USER/g" "$1"
    log 'replace_header_info' "Replacing date to $(date +%Y%m%d)"
    sed -i "s/# date      .*/# date      $(date +%Y%m%d)/g" "$1"
    log 'replace_header_info' "Replacing date to TODO: write purpose"
    sed -i "s/# purpose   .*/# purpose   TODO: write purpose/g" "$1"
}

# echo 1 if the source file is a funciton template and 0 otherwise
function is_function_template {
    if [ "$source_file" == "$TEMPLATE_DIR/bash_template.sh" ]; then
        echo 0
    else
        echo 1
    fi
}

# display help text
function help_text {
    echo "$SCRIPT_NAME [-HTV] new_script_name [new_script_name ...]"
    echo "Copy the bash script template to the script directory for each argument inserted"
}

# run tests of the script functions and echo variable values
function test_script {
    echo "Running test of $SCRIPT_NAME"
    echo "Global Variable Values:"
    echo -e "\tTEST_FLAG: $TEST_FLAG"
    echo -e "\tVERBOSE_FLAG: $VERBOSE_FLAG"
    echo -e "\tPositional Arguments: $*"
    echo "help_text returns: $(help_text)"
    echo "new_script_path gobbledygook $SCRIPT_DIR returns: $(new_script_path gobbledygook $SCRIPT_DIR)"
    echo "new_script_path gobbledygook.sh $SCRIPT_DIR returns: $(new_script_path gobbledygook.sh $SCRIPT_DIR)"
    echo "new_script_path a.sh $FUNCTION_LIB_DIR returns: $(new_script_path a.sh $FUNCTION_LIB_DIR)"
    echo "new_script_path a.py $SCRIPT_DIR returns: $(new_script_path a.py $SCRIPT_DIR)"
    echo "new_script_path .sh $FUNCTION_LIB_DIR returns: $(new_script_path .sh $FUNCTION_LIB_DIR)"
    echo "symlink_path $SCRIPT_DIR/a.sh returns: $(symlink_path "$SCRIPT_DIR/a.sh")"
    echo "symlink_path $SCRIPT_DIR/a.py returns: $(symlink_path "$SCRIPT_DIR/a.py")"
    echo "already_in_path git returns: $(already_in_path git)"
    echo "already_in_path aueirgurg returns: $(already_in_path aueirgurg)"
    echo "is_function_template returns: $(is_function_template)"
}

# pass in all arguments (no options) from command line and then perform script behaviors
function main {
    log_title "Running $SCRIPT_NAME"
    for script_name in $@; do

        # get the new script details
        local output_dir="$SCRIPT_DIR"
        if [ 1 -eq $(is_function_template) ]; then
            output_dir="$FUNCTION_LIB_DIR"
        fi
        local new_script_path="$(new_script_path "$script_name" "$output_dir")"
        local new_script_name="$(basename $new_script_path)"

        # perform the copy
        if [ 1 -eq $(is_function_template) ]; then    # there will be no symlink
            if [ -f "$new_script_path" ]; then
                log_error 'main' "Function library at $new_script_path already exists"
            else
                log 'main' "Creating new function library at $new_script_path from $source_file"
                cp  "$source_file" "$new_script_path"
                replace_header_info "$new_script_path"
            fi
        else    # Need to symlink this into the bin directory and make it executable
            local symlink="$(symlink_path "$new_script_path")"
            if [ 1 -eq $(already_in_path "$symlink") ]; then
                log_error "main" "Name $symlink already in path. Pick a new name."
            else
                log 'main' "Creating new script at $new_script_path from $source_file"
                cp  "$source_file" "$new_script_path"
                log 'main' "making $new_script_name executable"
                chmod +x "$new_script_path"
                log 'main' "Creating symlink $symlink"
                ln -s "$new_script_path" "$symlink"
                log 'main' "run which $new_script_name to ensure script created in path."
                replace_header_info "$new_script_path"
            fi
        fi
    done
}

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options
while getopts ":FHpTV" opt; do
    case $opt in
        F) source_file="$TEMPLATE_DIR/bash_function_template.sh"; ext='.lib';;
        H) help_text; exit 0;;
        p) ext='.py';
           source_file="$TEMPLATE_DIR/python_template.py";;
        T) TEST_FLAG=1;;
        V) VERBOSE_FLAG=1;;
        \?) help_text; echo "Invalid option: -$OPTARG" >&2; exit 1;;
      esac
done
shift $((OPTIND-1))

# Get command line positional arguments

# Validate sanity of options/arguments
if [ 1 -ne $TEST_FLAG ]; then     # don't exit early when testing
    if [ -z "$1" ]; then
        help_text; exit 2
    fi
fi

# Run main or test
if [ 1 -ne $TEST_FLAG ]; then
    main $*
else
    test_script $*
fi

# cleanup
if [ "$BASH_SOURCE" == "$SCRIPT_NAME" ]; then # the script was not sourced, so must clean up
    # unset all global values here
    unset TEST_FLAG
    unset VERBOSE_FLAG
    unset SCRIPT_NAME
    unset ext
    unset source_file

    # unset all functions here
    unset -f help_text
    unset -f test_script
    unset -f main
    unset -f new_script_path
    unset -f symlink_path
    unset -f already_in_path
    unset -f replace_header_info
    unset -f is_function_template
fi

####################################################################################################
#                                              BODY                                                #
####################################################################################################
