declare buildDirectory="${MCPANEL_DIRECTORY}/process/build"

if [[ ! -z ${SERVER_TEMPLATE} ]]; then
    declare serverTemplate=true
    declare serverDirectory="${MCPANEL_DIRECTORY}/server/${SERVER_TEMPLATE}"
else
    declare serverTemplate=false
    #@deprecated
    declare serverDirectory="${MCPANEL_DIRECTORY}/process/server"
    #@enddeprecated
fi

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

function mcpanel::build::update()
{
  if [[ ! -d "${buildDirectory}" ]]; then
    abs::writeln "Creating build directory"
    mkdir -p "${buildDirectory}"
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create directory for build tools!"
      return $?
    fi
  fi

  abs::notice "Fetching BuildTools, please wait..."
  cd "${buildDirectory}"
  wget --quiet --show-progress --timestamping "${BUILD_SERVER}"
  if [[ $? -ne 0 ]]; then
    abs::error "Sorry, the download of build tools failed!"
    return $?
  fi
  abs::success "Build tools downloaded!"
  return 0
}

function mcpanel::build::new()
{
  local server_binary="${SERVER_API}-${SERVER_VERSION}.jar"
  abs::notice "Starting Minecraft server build process..."

  if [[ ! -e "${buildDirectory}/BuildTools.jar" ]]; then
    abs::error "Unable to find BuildTools.jar into build directory!"
    mcpanel::build::update
  fi

  cd "${buildDirectory}"

  abs::writeln "Selected API: ${STYLE_COMMENT}${SERVER_API}"
  abs::writeln "Selected API version: ${STYLE_COMMENT}${SERVER_VERSION}"

  abs::writeln "Executing BuildTools for ${SERVER_VERSION}..."
  java -jar "BuildTools.jar" --rev ${SERVER_VERSION}
  if [[ $? -ne 0 ]]; then
    abs::error "Build process failed."
    return $?
  fi
  abs::success "Server build finished without errors!"

  #@deprecated
  if [[ ! -e "${serverDirectory}" ]] && [[ ! ${serverTemplate} ]]; then
    abs::notice "Creating server directory..."
    mkdir -p "${serverDirectory}"
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create server directory!"
      return $?
    fi
    abs::success "Server directory created successfully!"
  fi
  #@enddeprecated

  abs::writeln "Copying binary to server directory"
  cp "${buildDirectory}/${server_binary}" "${serverDirectory}"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to copy server binary into destination!"
    return $?
  fi

  if [[ ${serverTemplate} ]]; then
    abs::comment "Server binary copied to '${SERVER_TEMPLATE}' server template."
  else
    abs::notice "Server binary copied to '${serverDirectory}'"
  fi
  return 0
}

function mcpanel::build::main()
{
  local action=$1

  case ${action} in
    new) mcpanel::build::new;;
    update) mcpanel::build::update;;
    help|*) mcpanel::build::info;;
  esac

  return 0
}
