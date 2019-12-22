# Awesome Bash Stylizer

function abs::writeln
{
  local output=$1
  local style=${2:-${STYLE_DEFAULT}}
  local logfile=${3:-"${MCPANEL_DIRECTORY}/logs/mcpanel.log"}

  if [[ ! -d $(dirname ${logfile}) ]]; then
    mkdir -p $(dirname ${logfile})
  fi

  echo -e "${style}${output}${STYLE_DEFAULT}" | tee --append ${logfile}
}

function abs::info
{
  local cmd_name=$1
  local cmd_info=$2

  printf "${STYLE_COMMENT}\t%s${STYLE_DEFAULT}\t\t%b\n" "${cmd_name}" "${cmd_info}"
}

function abs::usage
{
  local program=$1
  local command=$2

  abs::notice "Usage: ${program} ${command} ${STYLE_COMMENT}[command]"
}

function abs::status
{
  local status_type=$1
  local status_msg=$2

  if [[ "${status_type}" == "ok" ]]; then
    local out_message=" OK "
    local out_style="${STYLE_SUCCESS}"
  elif [[ "${status_type}" == "fail" ]]; then
    local out_message="FAIL"
    local out_style="${STYLE_ERROR}"
  fi

  printf "\t[${out_style}%s${STYLE_DEFAULT}]\t\t%b\n" "${out_message}" "${status_msg}"
}

function abs::developer
{
  local author=$1
  abs::success "Written by ${STYLE_COMMENT}$author"
}

function abs::error
{
  local output=$1

  abs::writeln "${output}" "${STYLE_ERROR}"
}

function abs::success
{
  local output=$1

  abs::writeln "${output}" "${STYLE_SUCCESS}"
}

function abs::notice
{
  local output=$1

  abs::writeln "${output}" "${STYLE_NOTICE}"
}

function abs::comment
{
  local output=$1

  abs::writeln "${output}" "${STYLE_COMMENT}"
}
