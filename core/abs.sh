# Awesome Bash Stylizer

function abs::writeln
{
  local output=$1
  local style=${2:-${STYLE_DEFAULT}}
  local logfile=${3:-"${MCPANEL_DIRECTORY}/logs/mcpanel.log"}

  if [[ ! -d $(dirname "${logfile}") ]]; then
    mkdir -p $(dirname "${logfile}")
  fi

  echo -e "${style}${output}${STYLE_DEFAULT}" | tee --append "${logfile}"
}

function abs::info
{
  local cmdName=$1
  local cmdInfo=$2

  printf "${STYLE_COMMENT}\t%s${STYLE_DEFAULT}\t\t%b\n" "${cmdName}" "${cmdInfo}"
}

function abs::usage
{
  local program=$1
  local command=$2

  abs::notice "Usage: ${program} ${command} ${STYLE_COMMENT}[command]"
}

function abs::status
{
  local statusType=$1
  local statusMsg=$2

  if [[ "${statusType}" == "ok" ]]; then
    local outMessage=" OK "
    local outStyle="${STYLE_SUCCESS}"
  elif [[ "${statusType}" == "fail" ]]; then
    local outMessage="FAIL"
    local outStyle="${STYLE_ERROR}"
  fi

  printf "\t[${outStyle}%s${STYLE_DEFAULT}]\t\t%b\n" "${outMessage}" "${statusMsg}"
}

function abs::developer
{
  local author=$1

  abs::success "Written by ${STYLE_COMMENT}${author}"
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
