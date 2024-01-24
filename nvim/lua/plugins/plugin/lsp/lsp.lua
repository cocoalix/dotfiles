-- ---------------------------------------------------------------------------
-- LSP COMMON PLUGINS
-- ---------------------------------------------------------------------------

local g = vim.g
local o = vim.o
--local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
--local opt = vim.opt
local keymap = vim.keymap
local diagnostic = vim.diagnostic

local myutils = require("utils")
--local nvim_lsputils = require("plugins.plugin.lsp.config.util")
local myserver = require("plugins.plugin.lsp.config.server")

local myignore = require("plugins.plugin.lsp.config.ignore")

local border = "rounded"

--local function on_cursor_hold()
--  if lsp.buf.server_ready() then
--    diagnostic.open_float()
--  end
--end

--local diagnostic_hover_augroup_name = "lspconfig-diagnostic"

local icons = {
  package_installed = "✓",
  package_uninstalled = "✗",
  package_pending = "⟳",
}

--local function enable_diagnostics_hover()
--  api.nvim_create_augroup(diagnostic_hover_augroup_name, { clear = true })
--  api.nvim_create_autocmd({ "CursorHold" }, { group = diagnostic_hover_augroup_name, callback = on_cursor_hold })
--end
--
--local function disable_diagnostics_hover()
--  api.nvim_clear_autocmds({ group = diagnostic_hover_augroup_name })
--end

--local function on_hover()
--  disable_diagnostics_hover()
--
--  lsp.buf.hover()
--
--  api.nvim_create_augroup("lspconfig-enable-diagnostics-hover", { clear = true })
--  -- ウィンドウの切り替えなどのイベントが絡んでくるとおかしくなるかもしれない
--  api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
--    group = "lspconfig-enable-diagnostics-hover",
--    callback = function()
--      api.nvim_clear_autocmds({ group = "lspconfig-enable-diagnostics-hover" })
--      enable_diagnostics_hover()
--    end,
--  })
--end

--local formatting_callback = function(client, bufnr)
--  keymap.set("n", "<Leader>f", function()
--    local params = require("vim.lsp.util").make_formatting_params({})
--    client.request("textDocument/formatting", params, nil, bufnr)
--  end, { buffer = bufnr })
--end
--
local function text_document_format(diag)
  return string.format("%s (%s: %s)", diag.message, diag.source, diag.code)
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    cmd = {
      "LspInstall",
      "LspUninstall",
      "LspInfo",
    },
    config = function()
      g.mason_ready = false

      -- general settings
      diagnostic.config({
        float = {
          source = "if_many", -- Or "if_many"
          border = border,
        },
      })
      lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
          format = text_document_format,
        },
      })
      lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = border,
        virtual_text = false,
        focus = false,
        silent = true,
      })
      --lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
      --  local diag = vim.lsp.diagnostic.get_line_diagnostics()
      --  config = config or {}
      --  config.focus_id = ctx.method
      --  if not (result and result.contents) then
      --    -- vim.notify("No information available")
      --    return
      --  end
      --  myutils.io.echo_table("result.contents", result.contents)

      --  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      --  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
      --  if vim.tbl_isempty(markdown_lines) and myutils.string.is_null_or_empty(diag) then
      --    -- vim.notify('No information available')
      --    return
      --  end

      --  --local floatWndWidth = config.width
      --  --local separator = string.rep("-", floatWndWidth)

      --  config.border = border

      --  return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
      --end

      lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = border,
      })
      --local signatureHelpStack = {}
      --lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
      --  local bufnr = myutils.window.getBufnr(ctx.bufnr)
      --  local cid = ctx.client_id
      --  local line = vim.fn["line"](".")
      --  signatureHelpStack[bufnr .. "_" .. cid .. "_" .. "l" .. line] = result
      --end

      --        You will likely want to reduce updatetime which affects CursorHold
      --        note: this setting is global and should be set only once
      o.updatetime = 1000
      api.nvim_set_option("updatetime", 1000)

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- ここに `textDocument/hover` で表示させたくないファイルタイプを指定する
          if not myignore.isShowable(args) then
            return
          end

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = function(t)
              if myignore.isShowable(t) then
                vim.diagnostic.open_float(nil, { focus = false })
              end
            end,
          })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = function(t)
              if myignore.isShowable(t) then
                vim.lsp.buf.hover()
              end
            end,
          })
        end,
      })

      local capabilities = lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      require("mason").setup()
      local lspconfig = require("lspconfig")
      local malspconfig = require("mason-lspconfig")

      -- my lsp server setting setup
      myserver.setup()

      local on_attach = function(client, bufnr)
        local async = require("plenary.async")
        myutils.io.debug_echo("LSP started" .. client.name)
        async.run(function()
          vim.notify("LSP started: " .. client.name, vim.log.levels.INFO)
        end)

        -- auto hover popup for loaded filetypes
        if client.filetypes then
          for _, v in ipairs(client.filetypes) do
            vim.cmd([[autocmd CursorHold,CursorHoldI ]] .. v .. [[ lua vim.diagnostic.open_float(nil, {focus=false})]])
            vim.cmd([[autocmd CursorHold,CursorHoldI ]] .. v .. [[ silent lua vim.lsp.buf.hover()]])
          end
        end

        local bufopts = { silent = true, buffer = bufnr }
        keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
        keymap.set("n", "<F3>", function()
          vim.lsp.buf.format({ async = true })
        end, bufopts)
        -- keymap.set('n', 'gX', vim.lsp.buf.references, bufopts)
        -- keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        -- keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        -- keymap.set('n', 'gx', vim.lsp.buf.type_definition, bufopts)
        -- keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      end

      -- mason-lspconfig setup
      malspconfig.setup({
        --ensure_installed = servers,
        ensure_installed = myserver.servers,
        automatic_installation = true,
      })

      -- setup ensure installed LSP servers in mason registry
      local opts = {
        on_attach = on_attach,
        capabilities = capabilities,
      }
      malspconfig.setup_handlers({
        function(server_name)
          myserver.setupToServerByName(lspconfig, server_name, opts)
        end,
      })

      -- setup ensure installed LSP servers out of mason registry
      myserver.setupToServerForNoMasons(lspconfig, opts)

      g.mason_ready = true

      myutils.io.end_debug("ddu ff")
    end,
  },
  {
    --lazy = true,
    "williamboman/mason.nvim",
    dependencies = {
      "vim-denops/denops.vim",
      "mfussenegger/nvim-dap",
    },
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
    keys = {
      { "<F12>", "<Cmd>Mason<CR>", { mode = "n", silent = true, desc = "mason" } },
    },
    opts = {
      ui = {
        icons = icons,
      },
    },
    config = function() end,
  },
  {
    --lazy = true,
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "vim-denops/denops.vim",
      "mfussenegger/nvim-dap",
    },
    --    opts = function(_, opts)
    --      if not opts.handlers then
    --        opts.handlers = {}
    --      end
    --      opts.handlers[1] = function(server)
    --        require("myutils.lsp").setup(server)
    --      end
    --    end,
    config = function() end,
  },
  -- neodev.nvim ------------------------------
  {
    lazy = true,
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
  },
  {
    -- vscode like 💡 sign
    lazy = true,
    condition = false,
    "kosayoda/nvim-lightbulb",
    event = { "BufRead" },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      --local default_config = require("plugins.lsp.config.lightbulb")
      local default_config = {}
      require("nvim-lightbulb").setup(default_config)
    end,
  },
  {
    lazy = true,
    "aznhe21/actions-preview.nvim",
    event = { "LspAttach" },
    dependencies = {
      "kosayoda/nvim-lightbulb",
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Setup code action preview",
        callback = function(args)
          local bufnr = args.buf

          vim.keymap.set("n", "<leader><space>", function()
            require("actions-preview").code_actions()
          end, { buffer = bufnr, desc = "LSP: Code action" })
        end,
      })
    end,
    config = function()
      require("actions-preview").setup({})
    end,
  },
}
