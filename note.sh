#!/bin/bash
#
# filename  bash_template.sh
# author    Ryan Scott
# date      20141115
# purpose   Organize files into the notes folder by date the note was created and search both the
#           files and the filenames for interesting content
# assumes   You have an environment variable called FUNCTION_LIB_DIR and it is a directory
#           You have a file called log.lib in that directory.
#           You have an environment variable called NOTE_DIR and it is a directory

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
SEARCH_FLAG=0                                    # search notes directory instead of move files
FIND_ALERTS=0                                    # search notes directory for must_see.txt files

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

# echo the directory for today
function day_directory {
    echo "$NOTE_DIR/$(date +%Y/%m/%d)"
}

# moves the file at filename input ($1) to the notes directory
function make_note {
    if [ -f "$filename" ]; then
        log "$SCRIPT_NAME.make_note" "Moving $filename to $(day_directory)"
        mv "$filename" "$(day_directory)/"
    else
        log_error "$SCRIPT_NAME.make_note" "$filename does not exist--cannot make note"
    fi
}

# display filename matches and 
function search_for {
    local search_string="$1"
    function search_filenames {
        find "$NOTE_DIR" -name "*$search_string*" | sort | while read filepath; do
            echo -e "\t\t$filepath"
        done
    }

    function search_files {
        grep -Rl "$search_string" "$NOTE_DIR" | sort | while read filepath; do
            echo -e "\t\t$filepath"
        done
    }

    log "$SCRIPT_NAME.search_for" "Searching for string $search_string"

    echo "$search_string matches:"
    echo -e "\tfilename matches:"
    search_filenames
    echo -e "\tfile text matches:"
    search_files

    unset -f search_filenames
    unset -f search_files
}

# print files in the notes directory with the name must_see.txt
function print_alerts {
    log "$SCRIPT_NAME.print_alerts" "Finding all must_see.txt files in $NOTE_DIR"
    find "$NOTE_DIR" -name "must_see.txt"
}

# display help text
function help_text {
    echo "$SCRIPT_NAME [-AHSTV] filename [filename ...]"
    echo "if A flag is set, then you don't need to pass in any arguments"
    echo "Organize files into the notes folder by date the note was created and search both the "
    echo "files and the filenames for interesting content."
    echo "find alerts you've set for yourself (files named must_see.txt) in the notes directory"
}

# run tests of the script functions and echo variable values
function test_script {
    echo "Running test of $SCRIPT_NAME"
    echo "Global Variable Values:"
    # TODO: echo Global Variable values here
    echo -e "\tTEST_FLAG: $TEST_FLAG"
    echo -e "\tVERBOSE_FLAG: $VERBOSE_FLAG"
    echo -e "\tPositional Arguments: $*"
    # TODO: Put test output for other functions here 
    echo "help_text returns: $(help_text)"
    echo "day_directory returns: $(day_directory)"
}

# pass in all arguments (no options) from command line--then perform script behaviors
function main {
    log_title "Running $SCRIPT_NAME"

    today_dir="$(day_directory)"
    if [ ! -d "$today_dir" ]; then
        log 'main' "Today's directory does not exist, so creating it now: $today_dir"
        mkdir -p "$today_dir"
    fi

    if [ 1 -eq $SEARCH_FLAG ]; then
        for search_string in $@; do
            search_for "$search_string"
        done
    else    # making a note by moving a some files
        for filename in $@; do
            make_note "$filename"
        done
    fi

    if [ 1 -eq $FIND_ALERTS ]; then
        print_alerts
    fi
}

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options
while getopts ":AHTVS" opt; do
    case $opt in
        A) FIND_ALERTS=1;;
        H) help_text; exit 0;;
        T) TEST_FLAG=1;;
        S) SEARCH_FLAG=1;;
        V) VERBOSE_FLAG=1;;
        \?) help_text; echo "Invalid option: -$OPTARG" >&2; exit 1;;
      esac
done
shift $((OPTIND-1))

# Get command line positional arguments

# Validate sanity of options/arguments
if [ 1 -ne $TEST_FLAG ]; then
    if [ 1 -ne $FIND_ALERTS ] && [ -z "$1" ]; then
        help_text; exit 2
    fi
fi

# Run main or test
if [ 1 -ne $TEST_FLAG ]; then
    main $@
else
    test_script $@
fi

# cleanup
if [ "$BASH_SOURCE" == "$SCRIPT_NAME" ]; then # the script was not sourced, so must clean up
    # TODO: unset all global values here
    unset TEST_FLAG
    unset VERBOSE_FLAG
    unset SCRIPT_NAME
    unset SEARCH_FLAG
    unset FIND_ALERTS

    # TODO: unset all functions here
    unset -f help_text
    unset -f test_script
    unset -f main
    unset -f day_directory
    unset -f make_note
    unset -f print_alerts
fi

####################################################################################################
#                                              BODY                                                #
####################################################################################################