function mcpanel::server::info
{
  abs::notice "Usage: mcpanel server ${STYLE_COMMENT}[command]"
  abs::writeln
  abs::writeln "Manages Minecraft server"
  abs::writeln
  abs::writeln "Available commands:"
  abs::info "start" "Starts Minecraft server using visibility: ${STYLE_COMMENT}[local|lan|public]"
  abs::info "logs" "Shows latest logs"
  abs::info "edit" "Edit server configuration"
  abs::info "explore" "Explore server files"
  abs::info "help" "Shows this message"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::server::start
{
  local visibility=${1:-${SERVER_DEFAULT_VISIBILITY}}
  local gateway=

  abs::notice "Starting Minecraft server"

  case $visibility in
    local) gateway="lo";;
    lan) gateway=${IFCONFIG_GATEWAY};;
    public) gateway=;;
    *) abs::error "Invalid server visibility: ${visibility}"; return 1;;
  esac

  abs::writeln "Synchronizing server IPs"
  mcpanel::synchronize_ip_address $visibility $gateway

  cd ${MCPANEL_DIRECTORY}/process/server/
  if [[ ${SERVER_AUTO_EULA} ]] && [[ ! -e "eula.txt" ]]; then
    abs::writeln "Agreeing with eula.txt automatically"
    echo "eula=true" > eula.txt
  fi

  java -Xmx${SERVER_MEMORY}M -jar "${SERVER_API}-${SERVER_VERSION}.jar" nogui
  if [[ $? -ne 0 ]]; then
    abs::error "Server startup failed"
    return $?
  fi

  return 0
}

function mcpanel::server::logs
{
  abs::notice "Opening server logs..."
  sleep 5

  less "${MCPANEL_DIRECTORY}/process/server/logs/latest.log"
  wait
  abs::success "Logs read complete!"
}

function mcpanel::server::edit
{
  abs::notice "Starting edit mode..."
  sleep 5

  editor "${MCPANEL_DIRECTORY}/process/server/server.properties"
  wait
  abs::success "Edit complete!"
}

function mcpanel::server::explore
{
  if [[ -z $XDG_CURRENT_DESKTOP ]]; then
      abs::error "This command is available only under a desktop environment (e.g.: KDE, Gnome, XFCE,...)"

      if [[ -e /usr/bin/mc ]]; then
          abs::notice "However, it seems that you have installed \x1B[33mMidnight Commander\x1B[36m on your system."
          read -p "Do you want to use it? " yn

          case $yn in
              y|Y) mc ${MCPANEL_DIRECTORY}/process/server;;
              n|N) abs::error "Aborting command execution as it's not supported outside XDG session"; return 1;;
              *) return 1;;
          esac
      fi
  else
    abs::notice "Exploring server's directory..."
    xdg-open "${MCPANEL_DIRECTORY}/process/server"
    wait
  fi

  abs::success "Explore completed!"
}

function mcpanel::server::main
{
  local action=$1

  case $action in
    start) mcpanel::server::start $2;;
    edit) mcpanel::server::edit;;
    logs) mcpanel::server::logs;;
    explore) mcpanel::server::explore;;
    help|*) mcpanel::server::info;;
  esac

  return 0
}
