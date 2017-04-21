function mcpanel::build::info()
{
  abs::notice "Usage: mcpanel build ${STYLE_COMMENT}[command]"
  abs::writeln
  abs::writeln "Builds Minecraft server"
  abs::writeln
  abs::writeln "Available commands:"
  abs::info "new" "Creates a new build"
  abs::info "update" "Updates the BuildTools utility"
  abs::info "help" "Shows this message"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::build::update
{
  if [[ ! -d ${MCPANEL_DIRECTORY}/build ]]; then
    abs::writeln "Creating build directory"
    mkdir -p ${MCPANEL_DIRECTORY}/process/build
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create directory for build tools!"
      return $?
    fi
  fi

  abs::notice "Fetching BuildTools, please wait..."
  wget --output-document="${MCPANEL_DIRECTORY}/process/build/BuildTools.jar" ${BUILD_SERVER}
  if [[ $? -ne 0 ]]; then
    abs::error "Sorry, the download of build tools failed!"
    return $?
  fi
  abs::success "Build tools downloaded!"
  return 0
}

function mcpanel::build::new
{
  local server_binary="${SERVER_API}-${SERVER_VERSION}.jar"
  abs::notice "Starting Minecraft server build process..."

  if [[ ! -e BuildTools.jar ]]; then
    abs::error "Unable to find BuildTools.jar into build directory!"
    mcpanel::build::update
  fi

  cd ${MCPANEL_DIRECTORY}/process/build/

  abs::writeln "Selected API: ${STYLE_COMMENT}${SERVER_API}"
  abs::writeln "Selected API version: ${STYLE_COMMENT}${SERVER_VERSION}"

  abs::writeln "Executing BuildTools..."
  java -jar "BuildTools.jar"
  if [[ $? -ne 0 ]]; then
    abs::error "Build process failed."
    return $?
  fi
  abs::success "Server build finished without errors!"

  if [[ ! -e "${MCPANEL_DIRECTORY}/process/server" ]]; then
    abs::notice "Creating server directory..."
    mkdir -p ${MCPANEL_DIRECTORY}/process/server
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create server directory!"
      return $?
    fi
    abs::success "Server directory created successfully!"
  fi

  abs::writeln "Copying binary to server directory"
  cp ${MCPANEL_DIRECTORY}/process/build/${server_binary} ${MCPANEL_DIRECTORY}/process/server
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to copy server binary into destination!"
    return $?
  fi

  abs::success "Server build process completed and binary placed at destination!"
  return 0
}

function mcpanel::build::main
{
  local action=$1

  case $action in
    new) mcpanel::build::new;;
    update) mcpanel::build::update;;
    help|*) mcpanel::build::info;;
  esac

  return 0
}
