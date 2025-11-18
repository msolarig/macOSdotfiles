-- ===============================================================
-- [[ Basic Options ]]
-- ===============================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = 'unnamedplus'

vim.cmd [[
  autocmd FileType * setlocal shiftwidth=4 tabstop=4 softtabstop=4
]]

vim.env.PATH = vim.env.PATH .. ':/Users/matias/Library/Python/3.13/bin'

-- ===============================================================
-- [[ Install lazy.nvim plugin manager ]]
-- ===============================================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- ===============================================================
-- [[ Plugins ]]
-- ===============================================================
require('lazy').setup {

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        zig = { 'zigfmt' },
      },
      formatters = {
        zigfmt = {
          command = 'zig',
          args = { 'fmt', '--stdin' },
          stdin = true,
        },
      },
    },
  },

  { "savq/melange-nvim" },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup {
        view = { width = 30 },
        filters = { dotfiles = false },
      }
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function os_icon()
        local sysname = vim.loop.os_uname().sysname
        if sysname == 'Darwin' then
          return 'Mac'
        elseif sysname == 'Linux' then
          return 'Linux'
        elseif sysname == 'Windows_NT' then
          return 'Win'
        else
          return '?'
        end
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        if next(clients) == nil then
          return 'No LSP'
        end
        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end
        return table.concat(names, ', ')
      end

      require('lualine').setup {
        options = { theme = 'auto', section_separators = '', component_separators = '' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { os_icon, 'filename' },
          lualine_x = { lsp_clients, 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }
    end,
  },

  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup {}
    end,
  },

  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    version = '*',
    config = function()
      require('bufferline').setup {}
    end,
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require('ufo').setup {
        provider_selector = function(_, _, _)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  -- ===============================================================
  -- [[ Noice.nvim ]]
  -- ===============================================================
  {
    'folke/noice.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('noice').setup({
        lsp = {
          hover = { enabled = true },
          signature = { enabled = true },
        },
        presets = {
          bottom_search = false,  -- disable bottom search
          command_palette = false,
        },
        routes = {
          -- skip regular notifications
          {
            filter = { event = "msg_show" },
            opts = { skip = true },
          },
        },
        views = {
          cmdline = {
            position = { row = "10%", col = "50%" },
            size = { width = 50 },
            border = { style = "rounded", padding = { 0, 1 } },
            win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
          },
        },
        cmdline = {
          format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
          },
        },
      })

      -- Brownish background for floating command line
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#5C4033" })
    end,
  },

}

-- ===============================================================
-- [[ Treesitter Setup ]]
-- ===============================================================
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown',
    'markdown_inline', 'query', 'vim', 'vimdoc', 'zig', 'python',
  },
  highlight = { enable = true },
  indent = { enable = true },
}

-- ===============================================================
-- [[ LSP Setup ]]
-- ===============================================================
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.diagnostic.config({
  virtual_text = {
    prefix = "",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      diagnostics = { globals = { 'vim' } },
    },
  },
}

vim.lsp.config.zls = {
  cmd = { 'zls' },
  capabilities = capabilities,
}

vim.lsp.config.pyright = {
  cmd = { 'pyright-langserver', '--stdio' },
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua' },
  callback = function()
    vim.lsp.start(vim.lsp.config.lua_ls)
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'zig' },
  callback = function()
    vim.lsp.start(vim.lsp.config.zls)
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = function()
    vim.lsp.start(vim.lsp.config.pyright)
  end,
})

-- ===============================================================
-- [[ Completion Setup ]]
-- ===============================================================
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
  },
  sources = { { name = 'nvim_lsp' }, { name = 'luasnip' } },
}

-- ===============================================================
-- [[ Colorscheme ]]
-- ===============================================================
vim.cmd.colorscheme 'melange'
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })

-- ===============================================================
-- [[ Keymaps ]]
-- ===============================================================
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>')

vim.keymap.set('n', '<Tab>', ':bnext<CR>')
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>')
