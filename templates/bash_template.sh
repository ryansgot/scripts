#!/bin/bash
#
# filename  bash_template.sh
# author    Ryan Scott
# date      20141115
# purpose   Provide boilerplate code for all bash scripts
# assumes   You have an environment variable called FUNCTION_LIB_DIR and it is a directory
#           You have a file called log.lib in that directory.

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

pushd "$FUNCTION_LIB_DIR" > /dev/null
# TODO: put all source commands here (before the popd command) to pull in other functionality
source log.lib
popd > /dev/null

####################################################################################################
#                                             SOURCES                                              #
####################################################################################################

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

# TODO: Put all global symbols here, but be sure to unset them in the cleanup section of the body.
#		If the variables have default values, set them here

# Global symbols that cannot be set by command line arguments

# Global symbols set by command line options

# Global symbols set by positional arguments

# Global symbols that could be set elsewhere and should not be overwritten
if [ -z "$TEST_FLAG" ]; then TEST_FLAG=0; fi
if [ -z "$VERBOSE_FLAG" ]; then VERBOSE_FLAG=0; fi
if [ -z "$SCRIPT_NAME" ]; then SCRIPT_NAME=$(basename "$0"); fi	# tracks whether script is sourced

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

# TODO: Put user-defined functions here. As you write them, be sure to unset them in the cleanup
#		section of the body

# display help text
function help_text {
	echo "$SCRIPT_NAME [-HTV]"
	echo "The description of the script should go here."
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
}

# pass in all arguments (no options) from command line and then perform script behaviors
function main {
	echo > /dev/null
}

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options
while getopts ":HTV" opt; do
	case $opt in
    	H) help_text; exit 0;;
		T) TEST_FLAG=1;;
		V) VERBOSE_FLAG=1;;
    	\?) help_text; echo "Invalid option: -$OPTARG" >&2; exit 1;;
  	esac
done
shift $((OPTIND-1))

# Get command line positional arguments
# TODO: For each expected positional argument, do something like the below
#if [ -z "$1" ]; then
#	help_text; exit 2
#else
#	position_1_var=$1
#fi

# Validate sanity of options/arguments

# Run main or test
if [ 1 -ne $TEST_FLAG ]; then
	main $*
else
	test_script $*
fi

# cleanup
if [ "$BASH_SOURCE" == "$SCRIPT_NAME" ]; then # the script was not sourced, so must clean up
	# TODO: unset all global values here
	unset TEST_FLAG
	unset VERBOSE_FLAG
	unset SCRIPT_NAME

	# TODO: unset all functions here
	unset -f help_text
	unset -f test_script
	unset -f main
fi

####################################################################################################
#                                              BODY                                                #
####################################################################################################