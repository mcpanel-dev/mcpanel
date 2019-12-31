declare -r date=$(date +%Y%m%d)
declare -r time=$(date +%H%M%S)

if [[ -z ${SERVER_TEMPLATE} ]]; then
    declare serverTemplate=true
    declare serverDirectory="${MCPANEL_DIRECTORY}/process/server"
else
    declare serverTemplate=false
    declare serverDirectory="${MCPANEL_DIRECTORY}/server/${SERVER_TEMPLATE}"
fi

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

function mcpanel::toolkit::compress()
{
  local backupFor=$1
  local subdirectory="${backupFor}"

  case "${backupFor}" in
    complete)
      subdirectory=
      ;;
    plugins)
      ;;
    world)
        if [[ "${serverTemplate}" ]]; then
            subdirectory=$(cat "${serverDirectory}/server.properties" | grep 'level-name=' | cut -d'=' -f2)
        else
            subdirectory=$(cat "${serverDirectory}/server.properties" | grep 'level-name=' | cut -d'=' -f2)
        fi

        local worldContainer=$(yq r "${serverDirectory}/bukkit.yml" "settings.world-container")

        if [[ "${worldContainer}" != "null" ]]; then
            subdirectory="${worldContainer}/${subdirectory}"
        fi
      ;;
    *)
      abs::error "Invalid directory to compress: ${STYLE_COMMENT}${backupFor}"
      return 1
      ;;
  esac

  abs::notice "Creating backup for ${STYLE_COMMENT}${backupFor}"

  if [[ ! -d "${MCPANEL_DIRECTORY}/backup/${backupFor}" ]]; then
    abs::writeln "Creating directory for backups"
    mkdir -p "${MCPANEL_DIRECTORY}/backup/${backupFor}"
    if [[ $? -ne 0 ]]; then
      abs::error "Unable to create backup directory!"
      return $?
    fi
  fi

  abs::writeln "Creating backup, using ${STYLE_COMMENT}xz${STYLE_DEFAULT} compression"
  tar Jcf "${MCPANEL_DIRECTORY}/backup/${backupFor}/${backupFor}_${date}_${time}.txz" "${serverDirectory}/${subdirectory}"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to create backup for ${STYLE_COMMENT}${backupFor}"
    return $?
  fi

  abs::writeln "Creating archive checksum for integrity checking"
  sha256sum "${MCPANEL_DIRECTORY}/backup/${backupFor}/${backupFor}_${date}_${time}.txz" > "${MCPANEL_DIRECTORY}/backup/${backupFor}/${backupFor}_${date}_${time}.txz.sha256sum"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to create archive checksum!"
    return $?
  fi

  abs::success "Backup for ${backupFor} successfully created!"
  return 0
}

function mcpanel::backup::main()
{
  local action=$1

  case "${action}" in
    complete|plugins|world)
        mcpanel::toolkit::compress "${action}"
        return $?
        ;;
    help|*) mcpanel::backup::info;;
  esac

  return 0
}
