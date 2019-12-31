declare serverDirectory="${MCPANEL_DIRECTORY}/process/server"

function mcpanel::banner()
{
  if [[ -e /usr/bin/figlet ]]; then
    figlet "MCPanel"
  else
    abs::notice "MCPanel"
  fi
}

function mcpanel::module::enable()
{
  local command=$1
  if [[ -z "${command}" ]]; then
    abs::error "You must provide a module to enable!"
    return 1
  fi

  if [[ -e "${MCPANEL_DIRECTORY}/modules/enabled/mcp-${command}.sh" ]]; then
    abs::error "Module already enabled: ${STYLE_COMMENT}${command}"
    return 1
  fi

  if [[ ! -e "${MCPANEL_DIRECTORY}/modules/available/mcp-${command}.sh" ]]; then
    abs::error "Module not found: ${STYLE_COMMENT}${command}"
    return 1
  fi

  abs::notice "Enabling module: ${STYLE_COMMENT}${command}"
  ln -s "${MCPANEL_DIRECTORY}/modules/available/mcp-${command}.sh" "${MCPANEL_DIRECTORY}/modules/enabled/mcp-${command}.sh"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to enable module"
    return $?
  fi

  abs::success "Module activated successfully!"
  return 0
}

function mcpanel::module::disable()
{
  local command=$1
  if [[ -z "${command}" ]]; then
    abs::error "You must provide a module to disable!"
    return 1
  fi

  abs::notice "Disabling module: ${STYLE_COMMENT}${command}"
  rm "${MCPANEL_DIRECTORY}/modules/enabled/mcp-${command}.sh"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to disable module"
    return $?
  fi

  abs::success "Module deactivated successfully!"
  return 0
}

function mcpanel::toolbox::getModuleList()
{
  local mode=${1:-'available'}
  local modules=$(ls ${MCPANEL_DIRECTORY}/modules/${mode}/mcp-*.sh 2>/dev/null)

  return ${modules}
}

function mcpanel::module::list()
{
  local mode=${1:-'available'}
  modules=mcpanel::toolbox::getModuleList "${mode}"

  abs::writeln "MCPanel modules for ${STYLE_COMMENT}${mode}${STYLE_DEFAULT}:"
  if [[ -z ${modules} ]]; then
    abs::error "\tCurrently, there's no any modules in ${STYLE_COMMENT}${mode}"
  else
    for module in ${modules}; do
      local moduleName=$(echo $(basename "${module}" .sh) | cut -d'-' -f2)

      abs::writeln "\t- mcp-${STYLE_COMMENT}${moduleName}"
    done

    abs::writeln "\nThe module's name is listed with ${STYLE_COMMENT}this color"
  fi
}

function mcpanel::info()
{
  local versionColor="${STYLE_SUCCESS}"
  local modules=()

  abs::notice "Minecraft Server Control Panel"
  abs::notice "\tfor Linux"

  case ${MCPANEL_VERSION_CHANNEL} in
    dev) versionColor="${STYLE_ERROR}";;
    release) versionColor="${STYLE_SUCCESS}";;
    testing) versionColor="${STYLE_COMMENT}";;
  esac

  abs::writeln "Version ${version_color}${MCPANEL_VERSION}"
  abs::writeln

  abs::writeln "Core commands:"
  abs::info "enable-module" "Enables a given module."
  abs::info "disable-module" "Disables a given module."
  abs::info "list-modules" "Displays a list of all available modules."
  abs::writeln

  local modules=mcpanel::toolbox::getModuleList

  if [[ -z "${modules}" ]]; then
    abs::comment "Currently there's no module enabled! Please execute ${STYLE_SUCCESS}mcpanel enable-module [module-name]"
  else
    for module in ${modules[@]}; do
      local moduleName=$(echo "${module}" | cut -d'-' -f2)
      modules+=(${moduleName%.*})
    done
    abs::writeln "List of enabled modules: ${STYLE_COMMENT}[$(mcpanel::toolbox::joinBy '|' "${modules[@]}")]"
  fi

  abs::writeln
  abs::writeln "For supplimentary info about each command(s), please check for help:"
  abs::success "\tmcpanel ${STYLE_COMMENT}[command]${STYLE_SUCCESS} help"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::toolbox::synchronizeIpAddress()
{
  local visibility=${1:-${SERVER_DEFAULT_VISIBILITY}}
  local gateway=${2:-${IFCONFIG_GATEWAY}}
  local hostnameParam="I"
  local serverAddr=
  local hostAddr=

  case ${visibility} in
    local)
      hostnameParam="i"
      ;;
    lan)
      hostnameParam="I"
      ;;
    public)
      hostnameParam=
      ;;
    *)
      abs::error "Invalid server visibility: ${visibility}"
      return 1
      ;;
  esac

  if [[ -z ${hostnameParam} ]]; then
    hostAddr=$(dig +short myip.opendns.com @resolver1.opendns.com)
  else
    hostAddr=$(hostname -${hostnameParam} | cut -d' ' -f1)
  fi

  if [[ ! -e "${serverDirectory}/server.properties" ]]; then
    abs::error "Server configuration file was not found!"
    abs::writeln "Writing server IP manually..."
    echo "server-ip=${hostAddr}" > "${serverDirectory}/server.properties"
  fi

  serverAddr=$(cat "${serverDirectory}/server.properties" | grep "server-ip" | cut -d'=' -f2)

  abs::writeln "Server visibility level: ${STYLE_COMMENT}${visibility}"
  abs::writeln "Server's IP from configuration: ${STYLE_COMMENT}${serverAddr}"
  abs::writeln "Server's hostname: ${STYLE_COMMENT}${hostAddr}"

  if [[ "${gateway} == "${IFCONFIG_GATEWAY} ]] && [[ "${serverAddr}" != "${hostAddr}" ]]; then
    abs::notice "Found new gateway IP address, which is going to be replaced..."
    sed --expression "s/${serverAddr}/${hostAddr}/g" --in-place "${serverDirectory}/server.properties"
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to replace server's IP address"
      return $?
    fi

    abs::success "Server's IP was updated successfully!"
    return 0
  else
    abs::notice "Host's IP address was not changed, no IP update required!"
  fi
}

function mcpanel::toolbox::joinBy()
{
  local d=$1
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}

function mcpanel::toolbox::download()
{
    local url=$1
    local outputDocument=${2:-${PWD}}
    local downloadTools=( ["wget"]="wget --show-progress --timestamping --output-document=${outputDocument}"
                          ["curl"]="curl --progress-bar --output ${outputDocument}" )

    for tool in ${!downloadTools[@]}; do
        which "${tool}" > /dev/null
        if [[ $? -ne 0 ]]; then
            ${downloadTools["${tool}"]} "${url}"
            return $?
        fi
    done

    abs::error "no download tool detected on this system; please install one of following:"
    for tool in ${!downloadTools[@]}; do
        abs::writeln "\t- ${STYLE_COMMENT}${tool}"
    done
}

function mcpanel::toolbox::fetch()
{
    local url=$1

    which "curl" > /dev/null
    if [[ $? -eq 0 ]]; then
        abs::error "no download tool detected on this system; please install one of following:"
        abs::writeln "\t- ${STYLE_COMMENT}curl"

        return 1
    fi

    curl --silent "${url}"

    return $?
}

function mcpanel::toolbox::parseOptions()
{
    local params=$@
    local _result=()

    for param in ${params[@]}; do
        local _pName=$(echo ${param} | cut -d= -f1)
        local _pValue=$(echo ${param} | cut -d= -f2)

        _result["${_pName}"]="${_pValue}"
    done

    return $_result
}
