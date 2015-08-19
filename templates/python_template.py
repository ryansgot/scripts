#!/usr/bin/python
#
# filename	python_template.py
# author	Ryan Scott
# date		20141120
# purpose	Provide boilerplate code for all python scripts
# assumes	Python 2

####################################################################################################
#                                             IMPORTS                                              #
####################################################################################################

import sys, argparse

####################################################################################################
#                                             IMPORTS                                              #
####################################################################################################

####################################################################################################
#                                             CLASSES                                              #
####################################################################################################

####################################################################################################
#                                             CLASSES                                              #
####################################################################################################

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

# Global symbols that cannot be set by command line arguments

# Global symbols set by command line options

# Global symbols set by positional arguments

# Global symbols that could be set elsewhere and should not be overwritten

####################################################################################################
#                                             GLOBALS                                              #
####################################################################################################

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

def main(args):
	''' pass in all arguments (no options) from command line--then perform script behaviors '''
	pass

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options and arguments
parser = argparse.ArgumentParser(description='Boilerplate code for all python scripts')
parser.add_argument('-V', dest='VERBOSE', action='store_true', help='verbose mode switch')
# TODO: add arguments and options here
args = parser.parse_args()

# Validate sanity of options/arguments

# Run main
main(args)

# cleanup
args = None

####################################################################################################
#                                              BODY                                                #
####################################################################################################