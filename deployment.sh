#!/bin/bash
#
# filename  deployment.sh
# author    ryan
# date      20150119
# purpose   Perform a deployment of an application library to nexus
# assumes   You have an environment variable called FUNCTION_LIB_DIR and it is a directory
#           You have a file called log.lib in that directory.
#           You have an environment variable called COMPANY_GROUP_ID that is used for your company
#           libraries
#           You have an environment variable called NEXUS_RELEASE_SERVER that is used for your 
#           company's releases
#           You have an environment variable called NEXUS_SNAPSHOT_SERVER that is used for your
#           company's snapshots
#           Your repository directory is located at $HOME/repos

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
#        If the variables have default values, set them here
BASE_DIR=$HOME/repos

# Global symbols that cannot be set by command line arguments

# Global symbols set by command line options
debug_build=0                        # -D
repository_id='nexus_release'       # -r {nexus_release|nexus_snapshot}
group_id=$COMPANY_GROUP_ID             # -g {com.bypass[mobile|lane]}.*

# Global symbols set by positional arguments
artifact_id=''

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

# TODO: Put user-defined functions here. As you write them, be sure to unset them in the cleanup
#        section of the body

# echo 1 if repository_id is allowed; if not, echo 0
function is_repository_id {
    if [ "$repository_id" == "nexus_release" ] || [ "$repository_id" == "nexus_snapshot" ]; then
        echo 1
    else
        echo 0
    fi
}

# echo the version of the artifact
function get_version {
    # tr -d " '\"" removes spaces, single quotes, and quotes
    cat "$(get_gradle_build_file "$artifact_id")" | tr -d " '\"" | grep -E '^version=' | cut -f 2 -d =
}

# get the gradle build file for the artifact
function get_gradle_build_file {
    # assumption is that the longer path is the one we want
    find "$BASE_DIR" -name build.gradle | grep "$artifact_id/build.gradle" | tail -1
}

# echo the filename of the aar file artifact given the artifact_id ($1)
function get_aar_file {
    find "$BASE_DIR" -name *.aar | grep "$artifact_id/build" | grep "$(get_build_type)"
}

# echos the string to filter the aar file by type
function get_build_type {
    if [ 1 -eq $debug_build ]; then
        echo 'debug'
    else 
        echo 'release'
    fi
}

# get the server url by means of the repository_id
function get_server_url {
    if [ "nexus_release" == "$repository_id" ]; then
        echo "$NEXUS_RELEASE_SERVER"
    else
        echo "$NEXUS_SNAPSHOT_SERVER"
    fi
}

# display help text
function help_text {
    echo "$SCRIPT_NAME [-DHTV] [-r {nexus_release|nexus_snapshot}] [-g {group_id}] {artifact_id}"
    echo -e "\t-D : debug build; takes no arguments; default is release build"
    echo -e "\t-g : group_id; default: com.bypassmobile"
    echo -e "\t-r : repository_id; default: nexus_release; only other option is nexus_snapshot"
    echo -e "\tPosition 1: the artifact_id of the artifact you're uploading to the server"
}

# run tests of the script functions and echo variable values
function test_script {
    echo "Running test of $SCRIPT_NAME"
    echo "Global Variable Values:"
    # echo Global Variable values here
    echo -e "\tTEST_FLAG: $TEST_FLAG"
    echo -e "\tVERBOSE_FLAG: $VERBOSE_FLAG"
    echo -e "\tPositional Arguments: $*"
    echo -e "\tdebug_build=$debug_build"
    echo -e "\tgroup_id=$group_id"
    echo -e "\trepository_id=$repository_id"
    # Put test output for other functions here 
    echo "help_text returns: $(help_text)"
    echo "get_server_url returns: $(get_server_url)"
    echo "is_repository_id returns: $(is_repository_id)"
    echo "get_build_type returns: $(get_build_type)"
    echo "get_gradle_build_file returns: $(get_gradle_build_file)"
    echo "get_aar_file returns: $(get_aar_file)"
    echo "get_version returns: $(get_version)"
}

# pass in all arguments (no options) from command line and then perform script behaviors
function main {
    log_title "Running $SCRIPT_NAME"
    for artifact_id in $@; do
        local server_url="$(get_server_url)"
        local version="$(get_version)"
        local aar_file="$(get_aar_file)"
        if [ -z "$server_url" ] || [ -z "$version" ] || [ -z "$aar_file" ]; then
            log_error 'main' "Cannot deploy artifact: $artifact_id"
            log_error 'main' "parameters: server_url=$server_url; version=$version; aar_file=$aar_file"
        fi
        log 'main' "running mvn deploy:deploy-file to server=$server_url; artifact_id=$artifact_id; file=$aar_file; version=$version"
        mvn deploy:deploy-file -Durl="$server_url" -DrepositoryId=$repository_id \
                               -DgroupId="$group_id" -DartifactId="$artifact_id" \
                               -Dversion="$version" -Dpackaging=aar -Dfile="$aar_file"
        visual_break
    done
}

####################################################################################################
#                                            FUNCTIONS                                             #
####################################################################################################

####################################################################################################
#                                              BODY                                                #
####################################################################################################

# Get command line options
while getopts ":Dg:Hr:TV" opt; do
    case $opt in
        D) debug_build=1;;
        g) group_id="$OPTARG";;
        H) help_text; exit 0;;
        r) repository_id="$OPTARG"; if [ 0 -eq $(is_repository_id) ]; then help_text; exit 3; fi;;
        T) TEST_FLAG=1;;
        V) VERBOSE_FLAG=1;;
        \?) help_text; echo "Invalid option: -$OPTARG" >&2; exit 1;;
      esac
done
shift $((OPTIND-1))

# Get command line positional arguments
# For each expected positional argument, exit if it is not there
if [ 1 -ne $TEST_FLAG ]; then
    if [ -z "$1" ]; then
        help_text; exit 2
    fi
fi
artifact_id="$1"

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
    unset debug_build
    unset group_id
    unset repository_id
    unset artifact_id

    # TODO: unset all functions here
    unset -f help_text
    unset -f test_script
    unset -f main
    unset -f is_repository_id
    unset -f get_version
    unset -f get_server_url
fi

####################################################################################################
#                                              BODY                                                #
####################################################################################################
