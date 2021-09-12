#!/bin/sh

DtoDir=/config/device-tree/overlays
RbfDir=/lib/firmware

function init () {
  # Create directory if doesn't exist
  mkdir -p ${RbfDir}
  mkdir -p /config

  # Mount Configfs
  mount -t configfs configfs /config
}

function add_dto () {
  # Check if files exist
  if [[ ! -e $ModuleName.dtbo || ! -e $ModuleName.rbf ]]; then
    echo "Pass correct full path to ${ModuleName}.dtbo and ${ModuleName}.rbf"
    exit 1
  fi

  # Copy dtbo and rbf to new folder
  cp "${ModuleName}.dtbo" "${ModuleName}.rbf" ${RbfDir}
  mkdir "${DtoDir}/${ModuleName}"

  # Activate DTO
  echo -n "${ModuleName}.dtbo" > "${DtoDir}/${ModuleName}/path"
}

function enable_dto () {
  echo "enable_dto function"

  # Check if files exist in /lib/firmware
  if [[ ! -e "${RbfDir}/${ModuleName}.dtbo" ||  ! -e "${RbfDir}/${ModuleName}.rbf" ]]; then
    echo "Module ${ModuleName} not in ${RbfDir}"
    exit 1
  fi

  mkdir "${DtoDir}/${ModuleName}"

  # Activate DTO
  echo -n "${ModuleName}.dtbo" > "${DtoDir}/${ModuleName}/path"
}

function remove_dto () {
  if [[ ! -d "${DtoDir}/${ModuleName}" ]]; then
    echo "${ModuleName} not on DTO directory"
  else
    rmdir "${DtoDir}/${ModuleName}"
  fi
}

function wipeout_dto () {
  rmdir "${DtoDir}/${ModuleName}"
  rm "${RbfDir}/${ModuleName}.dtbo" "${RbfDir}/${ModuleName}.rbf"
}

FunctionName="$1"
ModuleName="$2"

case $FunctionName in

  init)
    init
    ;;

  add_dto)
    add_dto
    ;;
  
  enable_dto)
    enable_dto
    ;;

  remove_dto)
    remove_dto
    ;;

  wipeout_dto)
    wipeout_dto
    ;;

  *)
    echo "Inexistent function"
    ;;
esac
