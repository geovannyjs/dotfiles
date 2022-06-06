syntax on

set t_Co=256
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Hidden chars
"set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
set listchars=trail:·,tab:»»
set list

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
filetype plugin indent on

" Tab config
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Python should respect my style
let g:python_recommended_style = 0

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set noshowmode " Disable show mode, the lightline plugin show the mode alredy
set showcmd " Show (partial) command in status line.
set showmatch " Show matching brackets.
"set ignorecase " Do case insensitive matching
"set smartcase " Do smart case matching
"set incsearch " Incremental search
"set autowrite " Automatically save before commands like :next and :make
set mouse=a " Enable mouse usage (all modes)

set clipboard=unnamedplus
set completeopt=menu,menuone,noselect
"set cursorline
set hidden " Hide buffers when they are abandoned
set number
"set relativenumber
set splitbelow splitright
set title
set ttimeoutlen=0
set wildmenu


" Plugins
call plug#begin()

  " Appearance
  Plug 'itchyny/lightline.vim'
  Plug 'NLKNguyen/papercolor-theme'

  " Utilities
  Plug 'sheerun/vim-polyglot'
  Plug 'jiangmiao/auto-pairs'
  Plug 'ap/vim-css-color'
  Plug 'preservim/nerdtree'
  Plug 'jistr/vim-nerdtree-tabs'
  Plug 'tpope/vim-fugitive'

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

call plug#end()

colorscheme PaperColor

" Change lightline color theme
let g:lightline = { 'colorscheme': 'PaperColor', 'active': { 'left': [[ 'mode', 'paste' ], [ 'readonly', 'relativepath', 'modified' ]] }}


" NERDTree show hidden files
let NERDTreeShowHidden=1

nnoremap <F5> :NERDTreeMirrorToggle<CR>


" Lua
lua << EOF

  require'lspconfig'.tsserver.setup{}

  vim.diagnostic.config({
    virtual_text = false
  })

  -- Show line diagnostics automatically in hover window
  vim.o.updatetime = 250
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]


  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local map = function(type, key, value)
    vim.api.nvim_buf_set_keymap(0,type,key,value,{noremap = true, silent = true});
  end

  local custom_attach = function(client)
    print("LSP started.");

    map('n','md','<cmd>lua vim.lsp.buf.definition()<CR>')
    map('n','mh','<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n','ms','<cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('n','mt','<cmd>lua vim.lsp.buf.type_definition()<CR>')

  end

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  require('lspconfig')['tsserver'].setup {
    on_attach = custom_attach,
    root_dir = vim.loop.cwd,
    capabilities = capabilities
  }

EOF



" Source a global configuration file if available
"if filereadable("/etc/vim/vimrc.local")
"  source /etc/vim/vimrc.local
"endif
