-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    {
      '<leader>e',
      function()
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd 'wincmd p' -- jump back to previous window
        else
          vim.cmd 'Neotree focus'
        end
      end,
      desc = 'Toggle focus: [E]xplorer ↔ editor',
    },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = {
        with_markers = true,
        with_expanders = true,
      },
    },
    window = {
      position = 'left',
      width = 35,
      mappings = {
        ['\\'] = 'close_window',
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = false, -- when true, shows hidden files dimmed instead of hiding
        hide_dotfiles = false, -- be explicit via hide_by_name instead
        hide_gitignored = true, -- hides anything in .gitignore
        hide_hidden = false, -- Windows-only, no-op on macOS/Linux
        hide_by_name = {
          '.git',
          '.DS_Store',
          'thumbs.db',
          '__pycache__',
          '.pytest_cache',
          '.mypy_cache',
          '.ruff_cache',
          'node_modules',
          '.next',
          'dist',
          'build',
          '.venv',
          'venv',
        },
        hide_by_pattern = {
          '*.pyc',
          '*.pyo',
        },
        always_show = { -- visible even if matched by hide_* above
          '.gitignore',
          '.env.example',
          '.dockerignore',
          '.env',
        },
        never_show = { -- hidden even when toggled visible
          '.DS_Store',
        },
      },
    },
  },
  init = function()
    local group = vim.api.nvim_create_augroup('NeoTreeBehaviour', { clear = true })

    -- Auto-open Neo-tree on startup.
    vim.api.nvim_create_autocmd('VimEnter', {
      group = group,
      callback = function()
        local arg = vim.fn.argv(0)
        local has_arg = type(arg) == 'string' and arg ~= ''
        if has_arg and vim.fn.isdirectory(arg) == 1 then
          -- Opening a directory — neo-tree handles this natively, skip.
          return
        end
        if has_arg then
          -- A file was passed: show sidebar but keep focus on the file.
          vim.cmd 'Neotree show'
        else
          -- No argument: focus the sidebar so you can browse.
          vim.cmd 'Neotree focus'
        end
      end,
    })

    -- Quit Neovim if Neo-tree is the only remaining window.
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function()
        if vim.fn.winnr '$' == 1 and vim.bo.filetype == 'neo-tree' then vim.cmd 'quit' end
      end,
    })
  end,
}
