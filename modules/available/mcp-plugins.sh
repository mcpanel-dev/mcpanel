declare PLUGIN_DIR="${MCPANEL_DIRECTORY}/process/server/plugins"
declare PLUGIN_LIST="${PLUGIN_DIR}/spigot_plugins.list"

function mcpanel::plugins::info()
{
  abs::notice "Usage: mcpanel plugins ${STYLE_COMMENT}[command]"
  abs::writeln
  abs::writeln "Downloads and sets up basic plugins:"
  abs::writeln "\tWorldEdit, and AsyncWorldEdit plugin"
  abs::writeln "\tEssentials: AntiBuild, Protect, Spawn"
  abs::writeln
  abs::writeln "Available commands:"
  abs::info "get" "Downloads all given plugins"
  abs::info "help" "Shows this message"
  abs::writeln
  abs::developer "hktr92"
}

## Creates a list of downloadable jars for server.
function mcpanel::plugins::generateDownloadList_AsyncWorldEdit()
{
  abs::writeln "Getting latest AsyncWorldEdit build list..."
  curl --silent "${plugin_AsyncWorldEdit_baseUrl}" | jq --raw-output ".assets[] | select(.name | test(\"(${plugin_AsyncWorldEdit_jars}).jar\")) | .browser_download_url" >> "${PLUGIN_LIST}"
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to cURL GitHub API to fetch latest AsyncWorldEdit build!"
    return $?
  fi
  return 0
}

function mcpanel::plugins::generateDownloadList_Essentials()
{
  for jar in "${plugin_Essentials_jars[@]}"; do
    printf "${plugin_Essentials_baseUrl}\n" "${jar}" "${jar}" >> "${PLUGIN_LIST}"
  done
}

function mcpanel::plugins::generateDownloadList()
{
  echo > "${PLUGIN_LIST}"
  mcpanel::plugins::generateDownloadList_AsyncWorldEdit
  mcpanel::plugins::generateDownloadList_Essentials
}

function mcpanel::plugins::download()
{
  mcpanel::plugins::generateDownloadList

  abs::writeln "Getting WorldEdit.jar..."
  wget ${plugin_WorldEdit} --output-document="${PLUGIN_DIR}/WorldEdit.jar" --quiet --show-progress
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to wget WorldEdit jar!"
    return $?
  fi
  abs::writeln "WorldEdit.jar: DONE!"

  abs::writeln "Downloading plugins from list..."
  cd "${PLUGIN_DIR}"
  wget --input-file="${PLUGIN_LIST}" --quiet --show-progress --timestamping
  if [[ $? -ne 0 ]]; then
    abs::error "Unable to download plugins."
    return $?
  else
    abs::success "Plugins were downloaded successfully!"
    return 0
  fi
}

## @todo skip download if exists
function mcpanel::plugins::install()
{
  mcpanel::plugins::download
}

function mcpanel::plugins::update()
{
  mcpanel::plugins::download
}

function mcpanel::plugins::main()
{
  local action=$1

  if [[ -z $(which jq) ]]; then
    abs::error "In order to use this feature, you must install ${STYLE_SUCCESS}jq${STYLE_ERROR} CLI JSON parser."
    abs::error "https://github.com/stedolan/jq"
    return 1
  fi

  case ${action} in
     get) mcpanel::plugins::install;;
    help|*) mcpanel::plugins::info;;
  esac

  return 0
}
