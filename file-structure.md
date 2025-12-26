# Updated Neovim Configuration Structure

## Fixed Issues
- Resolved `nvim-dap-ui` dependency error
- Updated all LSP-related plugins to use new API
- Ensured proper loading order for debug tools

## Modified Files
1. `plugins/lsp.lua` - Core LSP configuration
   - Added explicit `nvim-nio` dependency
   - Updated to new LSP API
   - Improved diagnostic setup

2. `utils/debugging.lua` - Debug adapter setup
   - Complete DAP UI configuration
   - Proper event listeners
   - Fixed dependency chain

3. `plugins/init.lua` - Updated plugin loading order

## New Dependency Graph