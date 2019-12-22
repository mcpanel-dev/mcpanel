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
  if [[ -z ${command} ]]; then
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
  if [[ -z ${1} ]]; then
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

function mcpanel::module::list()
{
  local mode=${1:-'available'}
  local modules=$(ls ${MCPANEL_DIRECTORY}/modules/${mode}/mcp-*.sh 2>/dev/null)

  abs::writeln "MCPanel modules for ${STYLE_COMMENT}${mode}${STYLE_DEFAULT}:"
  if [[ -z ${modules} ]]; then
    abs::error "\tCurrently, there's no any modules in ${STYLE_COMMENT}${mode}"
  else
    for module in ${modules}; do
      local module_full=$(basename ${module} .sh)
      local module_name=$(echo ${module_full} | cut -d'-' -f2)
      abs::writeln "\t- mcp-${STYLE_COMMENT}${module_name}"
    done

    abs::writeln "\nThe module's name is listed with ${STYLE_COMMENT}this color"
  fi
}

function mcpanel::info()
{
  local version_color="${STYLE_SUCCESS}"
  local modules=()

  abs::notice "Minecraft Server Control Panel"
  abs::notice "\tfor Linux"

  case ${MCPANEL_VERSION_CHANNEL} in
    dev) version_color="${STYLE_ERROR}";;
    release) version_color="${STYLE_SUCCESS}";;
    testing) version_color="${STYLE_COMMENT}";;
  esac

  abs::writeln "Version ${version_color}${MCPANEL_VERSION}"
  abs::writeln

  abs::writeln "Core commands:"
  abs::info "enable-module" "Enables a given module."
  abs::info "disable-module" "Disables a given module."
  abs::info "list-modules" "Displays a list of all available modules."
  abs::writeln

  if [[ -z ${MCPANEL_MODULES} ]]; then
    abs::comment "Currently there's no module enabled! Please execute ${STYLE_SUCCESS}mcpanel enable-module [module-name]"
  else
    for module in ${MCPANEL_MODULES[@]}; do
      local module_name=$(echo ${module} | cut -d'-' -f2)
      modules+=(${module_name%.*})
    done
    abs::writeln "List of enabled modules: ${STYLE_COMMENT}[$(mcpanel::toolbox::join_by '|' "${modules[@]}")]"
  fi

  abs::writeln
  abs::writeln "For supplimentary info about each command(s), please check for help:"
  abs::success "\tmcpanel ${STYLE_COMMENT}[command]${STYLE_SUCCESS} help"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::synchronize_ip_address()
{
  local visibility=${1:-${SERVER_DEFAULT_VISIBILITY}}
  local gateway=${2:-${IFCONFIG_GATEWAY}}
  local hostname_param="I"
  local server_ip=
  local host_ip=

  case ${visibility} in
    local)
      hostname_param="i"
      ;;
    lan)
      hostname_param="I"
      ;;
    public)
      hostname_param=
      ;;
    *)
      abs::error "Invalid server visibility: ${visibility}"
      return 1
      ;;
  esac

  if [[ -z ${hostname_param} ]]; then
    host_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
  else
    host_ip=$(hostname -${hostname_param} | cut -d' ' -f1)
  fi

  if [[ ! -e "${serverDirectory}/server.properties" ]]; then
    abs::error "Server configuration file was not found!"
    abs::writeln "Writing server IP manually..."
    echo "server-ip=${host_ip}" > "${serverDirectory}/server.properties"
  fi

  server_ip=$(cat "${serverDirectory}/server.properties" | grep "server-ip" | cut -d'=' -f2)

  abs::writeln "Server visibility level: ${STYLE_COMMENT}${visibility}"
  abs::writeln "Server's IP from configuration: ${STYLE_COMMENT}${server_ip}"
  abs::writeln "Server's hostname: ${STYLE_COMMENT}${host_ip}"

  if [[ "${gateway} == "${IFCONFIG_GATEWAY} ]] && [[ "${server_ip}" != "${host_ip}" ]]; then
    abs::notice "Found new gateway IP address, which is going to be replaced..."
    sed --expression "s/${server_ip}/${host_ip}/g" --in-place "${serverDirectory}/server.properties"
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

function mcpanel::toolbox::join_by()
{
  local d=$1
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}
