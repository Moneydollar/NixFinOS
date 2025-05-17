''
  return {
    { "equalsraf/neovim-gui-shim", lazy = false },
    { "lervag/vimtex", lazy = false },
    { "nvim-lua/plenary.nvim" },
    {
      "xeluxee/competitest.nvim",
      dependencies = "MunifTanjim/nui.nvim",
      config = function()
        require("competitest").setup()
      end,
    },
    {
      "goolord/alpha-nvim",
      config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("nvim-autopairs").setup()
      end,
    },
    {
    "3rd/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("image").setup({
        backend = "kitty", -- or "ueberzug"
        processor = "magick_cli", -- or "magick_rock"
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            only_render_image_at_cursor_mode = "popup",
            floating_windows = false,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = {
            enabled = true,
            filetypes = { "norg" },
          },
          typst = {
            enabled = true,
            filetypes = { "typst" },
          },
          html = {
            enabled = false,
          },
          css = {
            enabled = false,
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
      })
    end,
  },

    {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end,
    },
    {
      "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup()
      end,
    },
    { "nvim-tree/nvim-web-devicons" },
    {
      "f-person/git-blame.nvim",
      config = function()
        vim.g.gitblame_enabled = 0
      end,
    },
    { "kdheepak/lazygit.nvim" },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup()
      end,
    },
    {
      "karb94/neoscroll.nvim",
      config = function()
        require("neoscroll").setup()
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup()
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      dependencies = "nvim-lua/plenary.nvim",
      config = function()
        require("telescope").setup()
      end,
    },
  }
''
