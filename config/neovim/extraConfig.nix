''
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.isdirectory(vim.fn.argv()[1]) == 1 then
        require("nvim-tree.api").tree.open()
      end
    end
  })

  vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
   
  vim.opt.shell = vim.fn.executable("fish") == 1 and "fish" or vim.opt.shell:get()

  require("nvim-tree").setup({
    update_cwd = true,
    respect_buf_cwd = true,
    sync_root_with_cwd = true,
  })

  require("image").enable()
  local lspconfig = require("lspconfig")

  lspconfig.nil_ls.setup {
    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixpkgs-fmt" }, -- or "alejandra" / "nixfmt"
        },
        nix = {
          maxMemoryMB = 12560,
          flake = {
            autoEvalInputs = true,
            nixpkgsInputName = nixpkgs,
          },
        },
      },
    },
  }


  local lspconfig = require("lspconfig")
  -- Python
  lspconfig.pyright.setup({})

  -- C/C++
  local lspconfig = require("lspconfig")
  lspconfig.clangd.setup({
  	 	cmd = { "clangd", "--background-index", "--clang-tidy", "--log=verbose" },
  	 	init_options = {
  	 		fallbackFlags = { "-std=c++17" },
    },
  })
  lspconfig.opts = {
  	servers = {
  		clangd = {
  			mason = false,
  		},
  	},
  }
''
