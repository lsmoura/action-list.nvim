local fzf = require("fzf-lua")
local M = {}

M.defaults = {
  opts = {},
  sort = true,
}

---@class ActionOption
---@field [1] string                           # command description
---@field description (string|fun(ActionOption):string)? # alternate description to show instead of the first option
---@field vimcmd string?                       # optional vim command to run
---@field command fun()?                       # optional Lua function executed
---@field status (fun():string)?               # optional function returning status text

---@class ActionListSetupOptions
---@field opts ActionOption[]?
---@field sort boolean?

M.opts = vim.deepcopy(M.defaults)

---@param opt ActionOption
---@return string
local function description(opt)
  ---@type (string | fun(ActionOption):string)?
  local desc = opt.description

  if desc then
    if type(desc) == "function" then
      return desc(opt)
    end

    return desc
  end

  return opt[1]
end

---@param opts ActionOption[]
---@return string[] entries                    # list of display lines
---@return table<string, ActionOption> lookup  # mapping line -> option
local function build_entries(opts)
  local entries = {}
  local lookup = {}

  local max_len = 0
  for _, opt in ipairs(opts) do
    local desc = description(opt)
    max_len = math.max(max_len, #desc)
  end

  for _, opt in ipairs(opts) do
    local status = ""

    local desc = description(opt)
    local padding = string.rep(" ", max_len - #desc + 2)
    if opt.status then
      status = "\x1b[90m" .. padding .. opt.status() .. "\x1b[0m"
    end

    local line = desc .. status

    table.insert(entries, line)
    lookup[line] = opt
  end

  if M.sorted then
    table.sort(entries, function(a, b)
      local a_name = a:match("^(%S+)")
      local b_name = b:match("^(%S+)")

      return a_name < b_name
    end)
  end

  return entries, lookup
end

---@param opt ActionOption
---@return nil
local function execute_option(opt)
  if opt.vimcmd then
    vim.cmd(opt.vimcmd)
    return
  end

  if opt.command then
    opt.command()
    return
  end

  print("no command")
end

function M.open()
  local items, lookup = build_entries(M.opts)

  fzf.fzf_exec(items, {
    winopts = {
      title = "Actions",
    },
    prompt = "❯ ",
    right_prompt = function(item)
      print("right_prompt")
      local opt = lookup[item]
      if opt.status then
        return " " .. opt.status()
      end

      return ""
    end,
    actions = {
      ["default"] = function(selected)
        local entry = lookup[selected[1]]
        if entry then
          execute_option(entry)
        end
     end,
    },
  })
end

--- Merge user configuration with defaults
---@param settings ActionListSetupOptions?
function M.setup(settings)
  settings = settings or {}

  if settings.opts then
    M.opts = settings.opts
  end
  if settings.sort ~= nil then
    M.sort = settings.sort
  end
end

--- Adds new entries to the list of actions
---@param new_opts ActionOption[]
function M.add_options(new_opts)
  if type(new_opts) ~= "table" then
    error("add_options() requires a table of ActionOption")
  end

  for _, opt in ipairs(new_opts) do
    table.insert(M.opts, opt)
  end
end

return M

