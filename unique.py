#!/usr/bin/python
#
# Filename  unique.py
# Author:   Ryan Scott
# Date:     20141120
# Purpose:  Filter output for uniqueness

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

# TODO: write the functions 

def main(args):
    ''' read lines from stdin and print each unique line as read '''

    line_count_dict = {}

    # 
    for line in sys.stdin.readlines():
        line = line.strip("\n")
        if line not in line_count_dict:
            line_count_dict[line] = 1
            print(line)
        else:
            line_count_dict[line] += 1

    # 
    if args.VERBOSE:
        print
        print("Line Counts:")
        for line, count in line_count_dict.items():
            print(str(count) +"\t" + line)

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options and arguments
parser = argparse.ArgumentParser(description='print each unique line as read from stdin')
parser.add_argument('-V', dest='VERBOSE', action='store_true', help='print counts of each line')
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