syntax enable

" background
set background=dark

" Hidden chars
set listchars=trail:·,tab:»»
set list

" Tab config - force two spaces for any language/content
autocmd VimEnter * set expandtab | set shiftwidth=2 | set softtabstop=2 | set tabstop=2

"" completion behavior
set completeopt=menu,menuone,noselect

" required by nvim-colorizer.lua
set termguicolors

"" General
set number
set splitbelow splitright

" http://vim.wikia.com/wiki/Highlight_current_line
autocmd BufEnter * setlocal cursorline
autocmd WinEnter * setlocal cursorline
autocmd BufLeave * setlocal nocursorline
autocmd WinLeave * setlocal nocursorline

" change the leader key from "\" to ";"
let mapleader=";"

" use ;; for escape
" http://vim.wikia.com/wiki/Avoid_the_escape_key
inoremap ;; <Esc>

" FZF Utils
nnoremap <silent> <leader>fb :FZFBuffers<CR>
nnoremap <silent> <leader>fc :FZFCommands<CR>
nnoremap <silent> <leader>ff :FZF<CR>
nnoremap <silent> <leader>fh :FZFHistory<CR>
nnoremap <silent> <leader>fr :FZFRg<CR>
nnoremap <silent> <leader>fw :FZFWindows<CR>

" FZF namespace
let g:fzf_command_prefix = 'FZF'
"
" Plugins
call plug#begin()

  " Code AST
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

  " Appearance
  Plug 'folke/tokyonight.nvim'
  Plug 'nvim-lualine/lualine.nvim'

  " Utilities
  Plug 'norcalli/nvim-colorizer.lua'

  " LSP
  Plug 'neovim/nvim-lspconfig'

  " Auto completion
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'

  " For vsnip users.
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'

  " Fuzzy search
  " To update: :PlugUpdate fzf
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

call plug#end()

" =====================================
" Custom find
" =====================================
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

lua <<EOF

  require'nvim-treesitter.configs'.setup {
    ensure_installed = { 'javascript', 'haskell', 'lua', 'typescript', 'tsx' },
    highlight = {
      enable = true
    }
  }

  require'tokyonight'.setup({
    transparent = true
  })

  require'lualine'.setup()

  require'colorizer'.setup()

  -- Set up nvim-cmp.
  local cmp = require'cmp'

  -- haskell
  require'lspconfig'.hls.setup{}

  -- typescript
  require'lspconfig'.ts_ls.setup{}

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' } -- For vsnip users.
    }, {
      { name = 'buffer' }
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  local map = function(type, key, value)
    vim.api.nvim_buf_set_keymap(0,type,key,value,{noremap = true, silent = true});
  end

  local custom_attach = function(client)
    print("LSP started.");

    map('n','<leader>ld','<cmd>tab split | lua vim.lsp.buf.definition()<CR>')
    map('n','<leader>lh','<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n','<leader>ls','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('n','<leader>lt','<cmd>tab split | lua vim.lsp.buf.type_definition()<CR>')

    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next, opts)

  end

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require'lspconfig'.ts_ls.setup {
    on_attach = custom_attach,
    root_dir = vim.loop.cwd,
    capabilities = capabilities
  }
  require'lspconfig'.hls.setup {
    on_attach = custom_attach,
    root_dir = vim.loop.cwd,
    capabilities = capabilities
  }

EOF

" Color scheme
colorscheme tokyonight-night
