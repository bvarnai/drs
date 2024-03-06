#!/bin/bash

# shellcheck disable=SC1091
source "${DRS_HOME}/common.sh"

function help()
{
  drs::common::show_help_and_exit "Get the current (local) branch name" "name";
}

function main()
{
  # preconditions
  drs::common::read_repository

  # process arguments
  drs::common::no_args "$@"

  # diplay branch name
  git rev-parse --abbrev-ref HEAD
}

main "$@"
