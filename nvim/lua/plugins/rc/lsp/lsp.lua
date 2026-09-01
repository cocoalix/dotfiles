---@diagnostic disable: undefined-global
-- ---------------------------------------------------------------------------
-- LSP COMMON PLUGINS
-- ---------------------------------------------------------------------------

local myutils = require("utils")
local mymason = require("plugins.rc.lsp.mason")

local border = "rounded"

local icons = {
  package_installed = "✓",
  package_uninstalled = "✗",
  package_pending = "⟳",
}

function call_my_mason()
  require("plugins.rc.lsp.mason")
end

function openDiagnostics()
  vim.diagnostic.open_float(nil, {
    focus = false,
    border = border,
  })
end

function openHover()
  vim.lsp.buf.hover({
    focus = false,
    border = border,
  })
end

local function text_document_format(diag)
  -- return string.format("%s (%s: %s)", diag.message, diag.source, diag.code)
  return string.format("💡(%s)", diag.source)
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      -- NOTE: ここで `opts = {}` を付けない。付けると本体 config() の
      --       vim.lsp.config() 登録より先に automatic_enable が走り、
      --       `nvim foo.js` のような直接指定起動で未設定のサーバーが
      --       起動してしまう (setup は mymason:setup() で行う)
      "mason-org/mason-lspconfig.nvim",
      "vim-denops/denops.vim",
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify",
      "mfussenegger/nvim-dap",
    },
    lazy = true,
    --lazy = false,
    event = {
      --"VeryLazy",
      "FileReadPost",
      "FileType",
      --"BufReadPre",
      --"InsertChange",
    },
    cmd = {
      "LspStart",
      "LspRestart",
      "LspStop",
      "LspInstall",
      "LspUninstall",
      "LspInfo",

      "Mason",
    },
    config = function()
      -- general settings
      vim.diagnostic.config({
        float = {
          source = "if_many", -- Or "if_many"
          border = border,
        },
        virtual_text = true,
      })
      vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
        local diag = vim.lsp.diagnostic.get_line_diagnostics()
        config = config or {}
        config.focus_id = ctx.method
        if not (result and result.contents) then
          -- vim.notify("No information available: result")
          return
        end
        -- myutils.io.echo_table("result.contents", result.contents)

        local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)

        local nv = myutils.env.get_nvim_version()


        config.border = border
        config.focus = false
        config.silent = true

        local cid = ctx.client_id
        local client = vim.lsp.get_client_by_id(cid)
        config.title = "hover: " .. client.name

        return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
      end

      local signatureHelpStack = {}
      vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
        local uri = result.uri
        local bufnr = vim.uri_to_bufnr(uri)
        if not bufnr then
          return
        end

        local diagnostics = result.diagnostics
        vim.lsp.diagnostic.set(diagnostics, bufnr, ctx.client_id)
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        local cid = ctx.client_id
        local line = vim.fn["line"](".")
        local key = bufnr .. "_" .. cid .. "_" .. "l" .. line
        if myutils.table.is_key_exists(signatureHelpStack, key) then
          vim.notify("suppress lsp diag: " .. key)
          return
        end
        signatureHelpStack[key] = result

        config.border = border
        config.focus = false
        config.silent = true

        local cid = ctx.client_id
        local client = vim.lsp.get_client_by_id(cid)
        config.title = "sigHelp: " .. client.name

        vim.lsp.diagnostic.show(diagnostics, bufnr, ctx.client_id, config)
      end

      --        You will likely want to reduce updatetime which affects CursorHold
      --        note: this setting is global and should be set only once
      vim.api.nvim_set_option("updatetime", 1000)

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local lspconfig = require("lspconfig")

      -- TODO: 👇 ここ外だししたいが、 `lspconfig.util.root_pattern` に依存しているので考えるのがめんどい
      local util = require 'lspconfig.util'
      local server_preferences = {
        --["astro"] = {},
        ["cssls"] = {},
        ["css_variables"] = {},
        --["cssmodules_ls"] = {},
        --["denols"] = {
        --  filetypes = {
        --    'typescript',
        --  },
        --  root_dir = util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json"),
        --  single_file_support = true,
        --  settings = {
        --    deno = {
        --      enable = true,
        --      lint = true,
        --      unstable = true,
        --      suggest = {
        --        imports = {
        --          hosts = {
        --            ["https://deno.land"] = true,
        --            ["https://cdn.nest.land"] = true,
        --            ["https://crux.land"] = true,
        --          },
        --        },
        --      }
        --    },
        --  },
        --},
        ["csharp_ls"] = {
          cmd = { 'csharp-ls' },
          root_markers = { '.csproj', '.sln', '.git' },
          filetypes = { 'cs' },
          settings = {
            init_options = {
              AutomaticWorkspaceInit = true,
            },
          },
        },
        ["docker_compose_language_service"] = {},
        ["dockerls"] = {},
        ["html"] = {},
        ["intelephense"] = {
          filetypes = { "php" },
          root_markers = { "artisan", "composer.json" },
          init_options = {
            licenceKey = vim.fn.expand('~/.config/nvim/license.intelephense.txt'),
          },
        },
        ["laravel_ls"] = {
          cmd = { "laravel-ls" },
          filetypes = { "php", "blade" },
          root_markers = { "artisan", "composer.json", ".git" },
        },
        ["lua_ls"] = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_markers = {
            { '.luarc.json', '.luarc.jsonc' },
            '.git',
          },
          settings = {
            Lua = {
              hint = { enable = true, },
              completion = { callSnippet = "Replace", },
              runtime = {
                version = 'LuaJIT',
              },
            },
          },
        },
        ["marksman"] = {},
        --["rust_analyzer"] = {
        --  root_dir = util.root_pattern('Cargo.toml'),
        --  filetypes = { "rust" },
        --  cmd = { "ra-multiplex" },
        --  settings = {
        --    ["rust_analyzer"] = {
        --      lru = {
        --        Capacity = 64,
        --      },
        --      assist = {
        --        importGranularity = "module",
        --        importPrefix = "by_crate",
        --      },
        --      procMacro = {
        --        enable = true,
        --      },
        --      checkOnSave = {
        --        command = "clippy",
        --        allTargets = false,
        --      },
        --      cargo = {
        --        loadOutDirsFromCheck = true,
        --        -- allFeatures = true,
        --      },
        --      completion = {
        --        autoimport = {
        --          enable = true,
        --        },
        --      },
        --      diagnostics = {
        --        disabled = {
        --          "unresolved-macro-call",
        --        },
        --      },
        --    },
        --  },
        --},
        --["svelte"] = {},
        ["tailwindcss"] = {},
        ["ts_ls"] = {
          filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
          },
          root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
          init_options = {
            tsserver = {
              -- workspace に typescript が無いプロジェクト用のフォールバック。
              -- mason 同梱の typescript は v7 (tsserver.js 非搭載) のため 5.x を明示指定する
              path = vim.fn.stdpath("data") .. "/ts5/node_modules/typescript/lib",
            },
          },
          settings = {
          },
        },
        ["habit-language-server"] = {
            default_config = {
              -- cargo install --path . でインストールした場合は 'habit-language-server' のみで OK
              -- フルパスを指定する場合: vim.fn.expand('~/.cargo/bin/habit-language-server')
              cmd = { 'habit-language-server' },

              -- 対象ファイルタイプ（追加・削除して調整してください）
              --filetypes = { 'text', 'markdown', 'gitcommit', 'rst' },

              -- ルートディレクトリが不要なサーバーなので常に cwd を使う
              root_dir = function(_)
                return vim.fn.getcwd()
              end,

              -- ファイル単体でも動作させる
              single_file_support = true,

              settings = {},
            },
            docs = {
              description = 'habit-language-server — 入力履歴ベースの補完 LSP',
            },
        },
        --["vtsls"] = {},
        --["vue_ls"] = {},
      }
      -- TODO: 👆 ここ外だししたいが、 `lspconfig.util.root_pattern` に依存しているので考えるのがめんどい
      --require('plugins.rc.lsp.config.server.habit_ls')

      local augroup = vim.api.nvim_create_augroup('LspAttach', { clear = true })
      vim.api.nvim_create_autocmd({ 'LspAttach' }, {
        group = augroup,
        callback = function(args)
          local bufopts = { silent = true, buffer = args.buf, noremap = true }
          vim.keymap.set("n", "<C-j>", vim.lsp.buf.definition, bufopts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
          vim.keymap.set("n", "gk", openHover, bufopts)
          vim.keymap.set("n", "gj", openDiagnostics, bufopts)

          vim.keymap.set("n", "gn", vim.diagnostic.goto_next, bufopts)
          vim.keymap.set("n", "gN", vim.diagnostic.goto_prev, bufopts)

          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
          vim.keymap.set("n", "<F3>", function() vim.lsp.buf.format({ async = true }) end, bufopts)
        end,
      })

      for name, v in pairs(server_preferences) do
        v.capabilities = capabilities
        vim.lsp.config(name, v)
      end

      -- NOTE: mason-lspconfig の automatic_enable (vim.lsp.enable) は
      --       vim.lsp.config() の登録より後に呼ぶこと。
      --       先に enable すると、ファイル直接指定起動 (`nvim foo.js`) の際に
      --       init_options 等が適用される前のサーバーが起動してしまう
      mymason:setup()
    end,
  },
  -- neodev.nvim ------------------------------
  {
    "aznhe21/actions-preview.nvim",
    dependencies = {
      --"kosayoda/nvim-lightbulb",
      "neovim/nvim-lspconfig",
    },
    lazy = true,
    event = { "LspAttach" },
    keys = {
      {
        "<leader><space>",
        "<Cmd>lua require('actions-preview').code_actions()<CR>",
        {
          buffer = bufnr,
          mode = "n",
          desc = "LSP: Code action",
        }
      },
    },
    config = function()
      require("actions-preview").setup({})
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      { "<leader>x", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)", },
      { "<leader>X", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)", },
      --{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)", },
      --{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)", },
      --{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)", },
      --{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)", },
    },
  },
  {
    "jwalton512/vim-blade",
    lazy = true,
    ft = { "blade" },
    config = function()
      -- Define some single Blade directives. This variable is used for highlighting only.
      vim.g.blade_custom_directives = {'datetime', 'javascript'}

      -- Define pairs of Blade directives. This variable is used for highlighting and indentation.
      vim.g.blade_custom_directives_pairs = {
        markdown  = 'endmarkdown',
        cache     = 'endcache',
      }
      end,
    },
  -- blade 内の埋め込み言語 (<script> の javascript 等) に LSP を提供する。
  -- treesitter のインジェクション情報を元にコードを隠しバッファへ抽出し、
  -- そこに attach した LSP (ts_ls) へ定義ジャンプ・補完・hover をプロキシする
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
    },
    lazy = true,
    ft = { "blade" },
    config = function()
      local otter = require("otter")
      otter.setup({
        lsp = {
          -- デフォルトは { "BufWritePost" } (保存時のみ)。
          -- 編集中も blade バッファへ診断が同期されるようにする
          diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" },
        },
      })

      local function activate()
        -- blade パーサー未導入時などにエラーで落ちないよう pcall
        pcall(otter.activate, { "javascript", "css" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("otter-activate", { clear = true }),
        pattern = { "blade" },
        callback = activate,
      })
      -- ft トリガーでロードされた時点では FileType は発火済みのため、
      -- 開いているバッファに対しても activate する
      activate()
    end,
  },
}

