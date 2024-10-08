local myutils = require("utils")

return {
  {
    lazy = true,
    "nvim-telescope/telescope-fzf-native.nvim",
    event = {
      "VimEnter",
    },
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      if not myutils.depends.has("fzf") then
        myutils.depends.install("fzf", { winget = "junegunn.fzf" })
      end
      if not myutils.depends.has("cmake") then
        myutils.depends.install("cmake", { winget = "Kitware.CMake" })
      end
    end,
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  --{
  --  lazy = true,
  --  "nvim-telescope/telescope-frecency.nvim",
  --  event = {
  --    "VimEnter",
  --  },
  --  dependencies = {
  --    "nvim-telescope/telescope.nvim",
  --  },
  --  init = function() end,
  --  config = function()
  --    require("telescope").load_extension("frecency")
  --  end,
  --},
}
