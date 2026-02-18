---@type ActionOption[]
local options = {
 {
    "Split horizontally",
    vimcmd = "split",
  },
  {
    "Split vertically",
    vimcmd = "vsplit",
  },
  {
    "Toggle line numbers",
    command = function()
      vim.wo.number = not vim.wo.number
      if not vim.wo.number then
        vim.wo.relativenumber = false
      end
    end,
    status = function()
      return vim.wo.number and "ON" or "OFF"
    end,
  },
  {
    "Toggle relative line numbers",
    command = function()
      local new = not vim.wo.relativenumber
      vim.wo.relativenumber = new
      vim.wo.number = new or vim.wo.number
    end,
    status = function()
      return vim.wo.relativenumber and "ON" or "OFF"
    end,
  },
}

return options

