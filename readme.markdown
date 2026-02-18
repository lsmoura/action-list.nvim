# action-list.nvim

Shows a list of actions based on a pre-defined list, which can be changed or extended. Uses `fzf-lua` to display the options.

## usage

Using *lazy.nvim*, the plugin can be imported using:

```lua
return {
  "lsmoura/action-list.nvim",
  config = function()
    local actions = require("action-list.actions")
    require('action-list').setup({
      opts = actions,
      sort = true,
    })

    vim.keymap.set(
      { "n", "i", "v" },
      "<C-S-A>",
      require('action-list').open,
      { desc = "Action Picker (fzf)", silent = true }
    )
  end,
}
```

## showcase

![][doc/action-list.png]

# Author

- Sergio Moura <https://sergio.moura.ca>

