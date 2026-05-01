-- ~/.config/nvim/lua/core/commands.lua
-- User-command registry. Implementations live in lua/core/commands/.

require("core.commands.execution").setup()
require("core.commands.diagnostics").setup()
require("core.commands.scratch").setup()
require("core.commands.toggles").setup()
require("core.commands.writing").setup()
require("core.commands.help").setup()
require("core.commands.backup").setup()
