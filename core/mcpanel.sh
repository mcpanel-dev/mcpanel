function mcpanel::banner()
{
  if [[ -e /usr/bin/figlet ]]; then
    figlet "MCPanel"
  else
    abs::comment "MCPanel"
  fi
}

function mcpanel::info()
{
  local version_color="${STYLE_SUCCESS}"
  local modules=()
  local ifs=$IFS

  abs::notice "Minecraft Server Control Panel"
  abs::notice "\tfor Linux"

  case ${MCPANEL_VERSION_CHANNEL} in
    dev) version_color="${STYLE_ERROR}";;
    release) version_color="${STYLE_SUCCESS}";;
    testing) version_color="${STYLE_COMMENT}";;
  esac

  abs::writeln "Version ${version_color}${MCPANEL_VERSION}"
  abs::writeln

  if [[ -z ${MCPANEL_MODULES} ]]; then
    abs::comment "Currently there's no available commands!"
  else
    for module in ${MCPANEL_MODULES[@]}; do
      local module_name=$(echo $module | cut -d'-' -f2)
      modules+=(${module_name%.*})
    done
    IFS='|'; abs::writeln "List of available commands: ${STYLE_COMMENT}[${modules[*]// /|}]"; IFS=$ifs
  fi

  abs::writeln
  abs::writeln "For supplimentary info about each command(s), please check for help:"
  abs::success "\tmcpanel ${STYLE_COMMENT}[command]${STYLE_SUCCESS} help"
  abs::writeln
  abs::writeln "Written by ${STYLE_COMMENT}hktr92"
}

function mcpanel::synchronize_ip_address()
{
  local visibility=${1:-${SERVER_DEFAULT_VISIBILITY}}
  local gateway=${2:-${IFCONFIG_GATEWAY}}
  local hostname_param="I"
  local server_ip=
  local host_ip=

  case $visibility in
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

  if [[ ! -e "${MCPANEL_DIRECTORY}/process/server/server.properties" ]]; then
    abs::error "Server configuration file was not found!"
    abs::writeln "Writing server IP manually..."
    echo "server-ip=${host_ip}" > "${MCPANEL_DIRECTORY}/process/server/server.properties"
  fi

  server_ip=$(cat "${MCPANEL_DIRECTORY}/process/server/server.properties" | grep "server-ip" | cut -d'=' -f2)

  abs::writeln "Server visibility level: ${STYLE_COMMENT}${visibility}"
  abs::writeln "Server's IP from configuration: ${STYLE_COMMENT}${server_ip}"
  abs::writeln "Server's hostname: ${STYLE_COMMENT}${host_ip}"

  if [[ "${gateway} == "${IFCONFIG_GATEWAY} ]] && [[ "${server_ip}" != "${host_ip}" ]]; then
    abs::notice "Found new gateway IP address, which is going to be replaced..."
    sed --expression "s/${server_ip}/${host_ip}/g" --in-place "${MCPANEL_DIRECTORY}/process/server/server.properties"
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
