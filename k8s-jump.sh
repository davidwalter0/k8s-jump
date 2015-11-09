#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
. ${dir}/.cfg/functions
main ${@}
