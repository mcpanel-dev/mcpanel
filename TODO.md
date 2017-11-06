mcpanel todo
============

Linux:
- [x] fix path detection issues:
  - if executing it as `./mcpanel`, `$MCPANEL_DIRECTORY` equals to dot
  - if executing it as `bash mcpanel`, the value is the same
  - if executing it as `mcpanel` (after putting `$MCPANEL_DIRECTORY/bin` in `PATH`, it detects well)
  - while `$PWD` works with the dot-slash method, it won't work for `mcpanel` method
- [ ] performance enhancements

Windows:
- [ ] port this panel to PowerShell

Cross-platform:
- rewrite / port this project to one of following languages:
  - C
  - JavaScript
  - Python
