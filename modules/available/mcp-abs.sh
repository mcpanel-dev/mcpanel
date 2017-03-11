function mcpanel::abs::info
{
  abs::usage "mcpanel" "abs"
  abs::writeln
  abs::writeln "Commands:"
  abs::info "demo" "this command executes the main function body"
  abs::info "help" "shows this message"
  abs::writeln
  abs::developer "hktr92"
}

function mcpanel::abs::demo
{
  abs::writeln "abs::writeln: function for a simple line"
  abs::writeln "abs::writeln: function for a simple line, with support for: ${STYLE_ERROR}red text, ${STYLE_COMMENT}or yellow text, ${STYLE_SUCCESS}or green text, ${STYLE_NOTICE} or some cyan text, ${STYLE_DEFAULT} or even default text formatting!"
  abs::writeln
  abs::error "abs::error: function made for error messages"
  abs::success "abs::success: function made for success messages"
  abs::comment "abs::comment: function made to highlight some progress / dynamic elements"
  abs::notice "abs::notice: function made to highlight the start of command execution"
  abs::writeln
  abs::writeln "abs::usage '[framework-name]' '[module-name]': function to output module usage example:"
  abs::writeln
  abs::usage "mcpanel" "abs"
  abs::writeln
  abs::writeln
  abs::writeln "abs::developer '[developer-name]': function to output developer's name:"
  abs::writeln
  abs::developer "hktr92"
  abs::writeln
  abs::writeln
  abs::writeln "abs::status '[type]' '[message]': function to print some external command execution status, like:"
  abs::status 'ok' "command executed!"
  abs::status 'fail' "command not executed!"
  abs::writeln
  abs::writeln
}

function mcpanel::abs::main
{
  local command=$1

  case $command in
    demo) mcpanel::abs::demo;;
    help|*) mcpanel::abs::info;;
  esac
}
