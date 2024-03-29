-- ---------------------------------------------------------------------------
-- denols - deno/typescript LSP SERVER CONFIG
-- ---------------------------------------------------------------------------

local M = {}

M.setup = function(baseLc, lc, opts)
  opts = opts or {}
  opts.root_dir = baseLc.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json")
  opts.init_options = {
    lint = true,
    unstable = true,
    suggest = {
      imports = {
        hosts = {
          ["https://deno.land"] = true,
          ["https://cdn.nest.land"] = true,
          ["https://crux.land"] = true,
        },
      },
    },
  }
  lc.setup(opts)
end

return M
