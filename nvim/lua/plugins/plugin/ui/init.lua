-- ---------------------------------------------------------------------------
-- UI PLUGINS
-- ---------------------------------------------------------------------------

local M = {}

local editor = require("plugins.plugin.ui.editor")
local filer = require("plugins.plugin.ui.filer")
local notify = require("plugins.plugin.ui.notify")
local nui = require("plugins.plugin.ui.nui")
local statusline = require("plugins.plugin.ui.statusline")
local window = require("plugins.plugin.ui.window")

table.insert(M, editor)
table.insert(M, filer)
table.insert(M, notify)
table.insert(M, nui)
table.insert(M, statusline)
table.insert(M, window)

return M
