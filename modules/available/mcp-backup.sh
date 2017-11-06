date=$(date +%Y%m%d)
time=$(date +%H%M%S)

function mcpanel::backup::info()
{
  abs::notice "Usage: mcpanel backup ${STYLE_COMMENT}[command]"
  abs::writeln
  abs::writeln "Creates backup for Minecraft server"
  abs::writeln
  abs::writeln "Available commands:"
  abs::info "complete" "Creates a complete server backup"
  abs::info "world" "Creates backup for your world only"
  abs::info "plugins" "Creates backup for plugins"
  abs::info "help" "Shows this message"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::backup::_compress()
{
  local backup_for=$1
  local subdirectory=$backup_for

  case $backup_for in
    complete)
      subdirectory=
      ;;
    plugins) ;;
    world)
      subdirectory=$(cat ${MCPANEL_DIRECTORY}/process/server/server.properties | grep 'level-name=' | cut -d'=' -f2)
      ;;
    *)
      abs::error "Invalid directory to compress: ${STYLE_COMMENT}${backup_for}"
      return 1
      ;;
  esac

  abs::notice "Creating backup for ${STYLE_COMMENT}${backup_for}"

  if [[ ! -d "${MCPANEL_DIRECTORY}/backup/${backup_for}" ]]; then
    abs::writeln "Creating directory for backups"
    mkdir -p "${MCPANEL_DIRECTORY}/backup/${backup_for}"
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create backup directory!"
      return $?
    fi
  fi

  abs::writeln "Creating backup, using ${STYLE_COMMENT}xz${STYLE_DEFAULT} compression"
  tar Jcf "${MCPANEL_DIRECTORY}/backup/${backup_for}/${backup_for}_${date}_${time}.txz" "${MCPANEL_DIRECTORY}/process/server/${subdirectory}"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to create backup for ${STYLE_COMMENT}${backup_for}"
    return $?
  fi

  abs::writeln "Creating archive checksum for integrity checking"
  sha256sum "${MCPANEL_DIRECTORY}/backup/${backup_for}/${backup_for}_${date}_${time}.txz" > "${MCPANEL_DIRECTORY}/backup/${backup_for}/${backup_for}_${date}_${time}.txz.sha256sum"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to create archive checksum!"
    return $?
  fi

  abs::success "Backup for ${backup_for} successfully created!"
  return 0
}

function mcpanel::backup::plugins()
{
  mcpanel::backup::_compress "plugins"
  return $?
}

function mcpanel::backup::world()
{
  mcpanel::backup::_compress "world"
  return $?
}

function mcpanel::backup::complete()
{
  mcpanel::backup::_compress "complete"
  return $?
}

function mcpanel::backup::main()
{
  local action=$1

  case $action in
    complete) mcpanel::backup::complete;;
    plugins) mcpanel::backup::plugins;;
    world) mcpanel::backup::world;;
    help|*) mcpanel::backup::info;;
  esac

  return 0
}
