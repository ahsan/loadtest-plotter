#!/bin/bash

# Usage function for the script
function usage () {
  cat << DELIM__
usage: $(basename $0) [parameters]
Options:
  -a, --address          Address of endpoint under test
  -c, --concurrency      Max number of concurrent requests to make. loadtest
                         is parameterized on this variable. Requests are made
                         with increasing concurrency, starting from 1.
  -h, --help             Display help menu
  -m, --method           HTTP method: GET or POST
  -n, --num_requests     Number of requests to perform
  -p, --post_body        File containing post body if method is POST
DELIM__
}

function check_arguments () {
    echo "Checking arguments"

    if [ ! "$address" ] || [ ! "$concurrency" ] || [ ! "$method" ] || [ ! "$num_requests" ]
    then
        usage
        exit 1
    fi
}

# Extract arguments
if [[ $# -ne 0 ]]; then
  # read the options
  TEMP=$(getopt -o a:c:m:n:h --long address:,concurrency:,method:,num_requests:,help -n 'loadtest_runner.bash' -- "$@")
  if [[ $? -ne 0 ]]; then
    usage
    exit 1
  fi
  eval set -- "$TEMP"
  # extract options
  while true ; do
    case "$1" in
        -a|--address)
        case "$2" in
            "") usage ; exit 1 ;;
            *) address=$2 ; shift 2 ;;
        esac ;;

        -c|--concurrency)
        case "$2" in
            "") usage ; exit 1 ;;
            *) concurrency=$2 ; shift 2 ;;
        esac ;;

        -m|--method)
        case "$2" in
            "") usage ; exit 1 ;;
            *) method=$2 ; shift 2 ;;
        esac ;;

        -n|--num_requests)
        case "$2" in
            "") usage ; exit 1 ;;
            *) num_requests=$2 ; shift 2 ;;
        esac ;;

        -p|--post_body)
        case "$2" in
            "") usage ; exit 1 ;;
            *) post_body=$2 ; shift 2 ;;
        esac ;;

        -h|--help)
        usage
        exit 1 ;;

        --)
        shift ;
        break ;;

        *)
        usage
        exit 1 ;;
    esac
  done
fi

# Check required arguments
check_arguments

# output directory
d="./outputs/loadtest_"$(date +%d.%m.%y_%H.%M.%S)
echo "Output directory: " $d
mkdir -p $d
cd $d

concurrent=1
while [ $concurrent -le $concurrency ]
do
    echo "Concurrency: "$concurrent"/"$concurrency
    file="./output.txt"

    echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#' >> $file
    echo 'CPU  USAGE' >> $file
    mpstat -P ALL >> $file
    echo 'MEMORY USAGE' >> $file
    free -m >> $file
    echo 'HDD USAGE' >> $file
    df -h >> $file
    echo 'LOADTEST' >> $file

    if [ "$method" == "GET" ]
    then
        loadtest $address -n $num_requests -c $concurrent >> $file
    elif [ "$method" == "POST" ]
    then
        loadtest $address -n $num_requests -c $concurrent -T application/json -p '../../'$post_body >> $file
    fi
    echo '#-------------------------------------------------------------------#' >> $file

    concurrent=$((concurrent+1))
done
