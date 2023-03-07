#!/bin/bash

#Set fonts
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

function show_usage () {
    echo -e "${BOLD}Basic usage:${NORM} entrypoint.sh [-vh] parcels-file perimeter-file output-path"
}

function show_help () {
    echo -e "${BOLD}entrypoint.sh${NORM}: converts"\\n
    show_usage
    echo -e "\n${BOLD}Required arguments:${NORM}"
    echo -e "${REV}parcels-path${NORM}\t\t the path of the parcels gpkg file"
    echo -e "${REV}perimeter-path${NORM}\t\t the path of the perimeter gpkg file"
    echo -e "${REV}output-path${NORM}\t\t\t the output path"\\n
    echo -e "${BOLD}Optional arguments:${NORM}"
    echo -e "${REV}-v${NORM}\tSets verbosity level"
    echo -e "${REV}-h${NORM}\tShows this message"
    echo -e "${BOLD}Examples:${NORM}"
    echo -e "./entrypoint.sh -v ./sample-data/input/parcels.gpkg ./sample-data/input/perimeter.gpkg ./sample-data/output/"
}

####################################################################################################
# GETOPTS                                                                                          #
####################################################################################################
# A POSIX variable
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize vars:
verbose=0

# while getopts
while getopts 'hv' OPTION; do
    case "$OPTION" in
        h)
            show_help
            kill -INT $$
            ;;
        v)
            verbose=1
            ;;
        ?)
            show_usage >&2
            kill -INT $$
            ;;
    esac
done

shift "$(($OPTIND -1))"

leftovers=(${@})
fparcels=${leftovers[0]}
fperimeter=${leftovers[1]}
output_path=${leftovers[2]%/}

####################################################################################################
# Input checks                                                                                     #
####################################################################################################
[ $verbose -eq 1 ] && echo -e "parcels    : ${fparcels}"
[ $verbose -eq 1 ] && echo -e "perimeter  : ${fperimeter}"
[ $verbose -eq 1 ] && echo -e "output-path: ${output_path}"

if [ ! -f "${fparcels}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} output parcels file path\n"; show_usage; kill -INT $$
fi
if [ ! -f "${fperimeter}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} output perimeter file path\n"; show_usage; kill -INT $$
fi

if [ ! -d "${output_path}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} output directory\n"; show_usage; exit 1 $$
fi

####################################################################################################
# Execution                                                                                        #
####################################################################################################
python /srv/app/src/convert_parcels.py \
  	--parcels-path ${fparcels} \
  	--perimeter-path ${fperimeter} \
  	--output-path ${output_path} \
  	--operator-id laposte \
  	--center-latitude 45.74263642703923 \
  	--center-longitude 4.819784759902544 \
  	--vehicle-type van \
  	--shipment-type delivery \
  	--consolidation-type none \
  	--driver-salary 136.0

[ $verbose -eq 1 ] && echo -e "output:\n$(ls -ld -1 ${output_path}/*)"
