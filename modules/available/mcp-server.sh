if [[ -z "${SERVER_TEMPLATE}" ]]; then
    declare serverTemplate=true
    declare serverDirectory="${MCPANEL_DIRECTORY}/process/server"
else
    declare serverTemplate=false
    declare serverDirectory="${MCPANEL_DIRECTORY}/server/${SERVER_TEMPLATE}"
fi

function mcpanel::server::info()
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

function mcpanel::server::start()
{
  local visibility=${1:-${SERVER_DEFAULT_VISIBILITY}}
  local gateway=""
  local instancePrefix=""

  if [[ ${SERVER_TMUXED} ]] && [[ ! -n "${TMUX}" ]]; then
    local hasTmux=$(tmux list-session | grep "mcpanel" | cut -d: -f1)

    if [[ ${hasTmux} == 'mcpanel' ]]; then
        tmux kill-session -t ${hasTmux}
    fi

    instancePrefix='tmux new -s mcpanel'

    abs::notice "Instance tmuxed, name=mcpanel"
  fi

  abs::notice "Starting Minecraft server"

  case "${visibility}" in
    private) gateway="lo";;
    lan) gateway="${IFCONFIG_GATEWAY}";;
    public) gateway=;;
    *) abs::error "Invalid server visibility: ${visibility}"; return 1;;
  esac

  abs::writeln "Synchronizing server IPs"
  mcpanel::toolbox::synchronizeIpAddress "${visibility}" "${gateway}"

  cd "${serverDirectory}"
  if [[ ${serverTemplate} ]]; then
    abs::notice "Starting from '${SERVER_TEMPLATE}' server template."
  else
    abs::notice "Starting from legacy server directory."
  fi

  if [[ ${SERVER_AUTO_EULA} ]] && [[ ! -e "eula.txt" ]]; then
    abs::writeln "Agreeing with eula.txt automatically"
    echo "eula=true" > "eula.txt"
  fi

  ${instancePrefix} java -Xms${SERVER_MEMORY_SCALING_STEP}M -Xmx${SERVER_MEMORY_MAX}M -XX:+Use${JAVA_GC}GC -jar "${SERVER_API}-${SERVER_VERSION}.jar" nogui

  if [[ $? -ne 0 ]]; then
    abs::error "Server startup failed"
    return $?
  fi

  return 0
}

function mcpanel::server::logs()
{
  abs::notice "Opening server logs..."
  sleep 5

  less "${serverDirectory}/logs/latest.log"
  wait
  abs::success "Logs read complete!"
}

function mcpanel::server::edit()
{
  abs::notice "Starting edit mode..."
  sleep 5

  editor "${serverDirectory}/server.properties"
  wait
  abs::success "Edit complete!"
}

function mcpanel::server::explore()
{
  if [[ -z "${XDG_CURRENT_DESKTOP}" ]]; then
      abs::error "This command is available only under a desktop environment (e.g.: KDE, Gnome, XFCE,...)"

      if [[ -e "/usr/bin/mc" ]]; then
          abs::notice "However, it seems that you have installed \x1B[33mMidnight Commander\x1B[36m on your system."
          read -p "Do you want to use it? " yn

          case ${yn} in
              y|Y) mc "${serverDirectory}" "${serverDirectory}";;
              n|N) abs::error "Aborting command execution as it's not supported outside XDG session"; return 1;;
              *) return 1;;
          esac
      fi
  else
    abs::notice "Exploring server's directory..."
    xdg-open "${serverDirectory}"
    wait
  fi

  abs::success "Explore completed!"
}

function mcpanel::server::main()
{
  local action=$1
  local localServerTemplate=$2

  if [[ ! -z "${localServerTemplate}" ]]; then
    SERVER_TEMPLATE="${localServerTemplate}"
  fi

  case ${action} in
    start) mcpanel::server::start;;
    edit) mcpanel::server::edit;;
    logs) mcpanel::server::logs;;
    explore) mcpanel::server::explore;;
    help|*) mcpanel::server::info;;
  esac

  return 0
}
