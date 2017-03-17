function mcpanel::launcher::info()
{
  abs::notice "Usage: mcpanel launcher ${STYLE_COMMENT}[command]"
  abs::writeln
  abs::writeln "Starts Minecraft launcher / game"
  abs::writeln
  abs::writeln "Available commands:"
  abs::info "start" "Starts the Minecraft launcher / game"
  abs::info "help" "Shows this message"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::launcher::start
{
  if [[ ! -d ${HOME}/.minecraft ]]; then
    abs::writeln "Sorry! You don't have Minecraft installed in ${STYLE_COMMENT}${HOME}/.minecraft"
    return 1
  fi

  abs::notice "Starting Minecraft, please wait..."
  cd "${HOME}/.minecraft"
  java -jar "${MINECRAFT_LAUNCHER}"
  wait
  if [[ $? -ne 0 ]]; then
    abs::error "Sorry, there was an error during Minecraft process execution!"
    return $?
  fi
  abs::success "Game execution completed!"
  return 0
}

function mcpanel::launcher::main
{
  local action=$1

  case $action in
    start) mcpanel::launcher::start;;
    help|*) mcpanel::launcher::info;;
  esac

  return 0
}
