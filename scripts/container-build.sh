#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the GNU MCU Eclipse distribution.
#   (https://gnu-mcu-eclipse.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

# Inner script to run inside Docker containers to build the 
# GNU MCU Eclipse Windows Build Tools distribution packages.

defines_script_path="${script_folder_path}/defs-source.sh"
echo "Definitions source script: \"${defines_script_path}\"."
source "${defines_script_path}"

# This file is generated by the host build script.
host_defines_script_path="${script_folder_path}/host-defs-source.sh"
echo "Host definitions source script: \"${host_defines_script_path}\"."
source "${host_defines_script_path}"

common_helper_functions_script_path="${script_folder_path}/helper/common-functions-source.sh"
echo "Common helper functions source script: \"${common_helper_functions_script_path}\"."
source "${common_helper_functions_script_path}"

container_functions_script_path="${script_folder_path}/helper/container-functions-source.sh"
echo "Container helper functions source script: \"${container_functions_script_path}\"."
source "${container_functions_script_path}"

container_libs_functions_script_path="${script_folder_path}/${CONTAINER_LIBS_FUNCTIONS_SCRIPT_NAME}"
echo "Container lib functions source script: \"${container_libs_functions_script_path}\"."
source "${container_libs_functions_script_path}"

container_app_functions_script_path="${script_folder_path}/${CONTAINER_APP_FUNCTIONS_SCRIPT_NAME}"
echo "Container app functions source script: \"${container_app_functions_script_path}\"."
source "${container_app_functions_script_path}"


# -----------------------------------------------------------------------------

if [ ! -z "#{DEBUG}" ]
then
  echo $@
fi

WITH_STRIP="y"
WITHOUT_MULTILIB=""
WITH_PDF="y"
WITH_HTML="n"
IS_DEVELOP=""
IS_DEBUG=""
LINUX_INSTALL_PATH=""

JOBS=""

while [ $# -gt 0 ]
do

  case "$1" in

    --disable-strip)
      WITH_STRIP="n"
      shift
      ;;

    --without-pdf)
      WITH_PDF="n"
      shift
      ;;

    --with-pdf)
      WITH_PDF="y"
      shift
      ;;

    --without-html)
      WITH_HTML="n"
      shift
      ;;

    --with-html)
      WITH_HTML="y"
      shift
      ;;

    --jobs)
      JOBS=$2
      shift 2
      ;;

    --develop)
      IS_DEVELOP="y"
      shift
      ;;

    --debug)
      IS_DEBUG="y"
      WITH_STRIP="n"
      shift
      ;;

    *)
      echo "Unknown action/option $1"
      exit 1
      ;;

  esac

done

# -----------------------------------------------------------------------------

start_timer

detect_container

prepare_xbb_env

prepare_xbb_extras

# -----------------------------------------------------------------------------

echo
echo "Here we go..."
echo

# Test to build guile
if false
then

  do_gmp
  do_libtool
  do_libunistring
  do_libffi
  do_bdwgc
  do_libiconv

  do_guile
fi

do_make

do_busybox

# -----------------------------------------------------------------------------

copy_binaries
check_binaries
copy_gme_files

create_archive

# Change ownership to non-root Linux user.
fix_ownership

# -----------------------------------------------------------------------------

stop_timer

exit 0

# -----------------------------------------------------------------------------
