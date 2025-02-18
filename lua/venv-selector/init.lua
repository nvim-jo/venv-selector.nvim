local venv = require("venv-selector.venv")
local config = require("venv-selector.config")
local user_commands = require("venv-selector.user_commands")
local dbg = require("venv-selector.utils").dbg
local mytelescope = require("venv-selector.mytelescope")
local hooks = require("venv-selector.hooks")
local utils = require("venv-selector.utils")

local M = {}

-- Called by user when using the plugin.
function M.setup(settings)
  -- Let user config overwrite any default config options.
  config.settings = vim.tbl_deep_extend("force", config.default_settings, settings or {})
  dbg(config.settings)
  -- Create the VenvSelect command.
  user_commands.setup_user_commands("VenvSelect", M.open, "Use VenvSelect to activate a venv")
  user_commands.setup_user_commands("VenvSelectCached", M.retrieve_from_cache,
    "Use VenvSelect to retrieve a venv from cache")
  user_commands.setup_user_commands("VenvSelectCurrent",
    function()
      if M.get_active_venv() ~= nil then
        utils.notify("Activated '" .. (M.get_active_venv()) .. "'")
      else
        utils.notify(
          "No venv has been selected yet.")
      end
    end, "Show currently selected venv")

  -- Check if the user has the requirements to run VenvSelect
  if utils.fd_or_fdfind_exists() == false then
    utils.error("Missing requirement: VenvSelect needs 'fd' to be installed: https://github.com/sharkdp/fd.")
  end
end

-- Gets the system path to current active python in the venv (or nil if its not activated)
function M.get_active_path()
  return venv.current_python_path
end

-- Gets the system path to the current active venv (or nil if its not activated)
function M.get_active_venv()
  return venv.current_venv
end

-- The main function runs when user executes VenvSelect command
function M.open()
  mytelescope.open()
end

function M.deactivate_venv()
  venv.deactivate_venv()
end

function M.retrieve_from_cache()
  return venv.retrieve_from_cache()
end

M.hooks = {
  pyright = hooks.pyright_hook,
  pylsp = hooks.pylsp_hook,
  pylance = hooks.pylance_hook,
}

return M
