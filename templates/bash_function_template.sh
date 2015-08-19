#!/bin/bash
#
# filename  bash_function_template.sh
# author    Ryan Scott
# date      20141115
# purpose   Provide boilerplate code for all bash function scripts.
# assumes   Nothing

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

# TODO: put all source commands here to pull in other functionality

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

# Global symbols that could be set elsewhere and should not be overwritten
if [ -z "$VERBOSE_FLAG" ]; then VERBOSE_FLAG=0; fi
if [ -z "$SCRIPT_NAME" ]; then SCRIPT_NAME=$(basename "$0"); fi    # tracks whether script is sourced

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

# TODO: Put user-defined functions here. As you write them, be sure to unset them in the cleanup
#        section of the body

# run tests of the script functions and echo variable values
function test_script_functions {
    echo "Running test of functions defined in $(basename $0)"
    echo -e "\tVERBOSE_FLAG: $VERBOSE_FLAG"
    # TODO: Put test output for other functions here
}

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Validate sanity of options/arguments

# cleanup
if [ "$BASH_SOURCE" == "$SCRIPT_NAME" ]; then # the script was not sourced, so must clean up
    test_script_functions $*
    unset VERBOSE_FLAG
fi
unset -f test_script_functions    # we want to unset this regardless of whether the script was sourced

####################################################################################################
#                                              BODY                                                #
####################################################################################################