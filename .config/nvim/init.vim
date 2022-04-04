syntax on

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
set completeopt=noinsert,menuone,noselect
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
  Plug 'agude/vim-eldar'

  " Utilities
  Plug 'sheerun/vim-polyglot'
  Plug 'jiangmiao/auto-pairs'
  Plug 'ap/vim-css-color'
  Plug 'preservim/nerdtree'
  Plug 'tpope/vim-fugitive'
call plug#end()

colorscheme eldar

" Change lightline color theme
"let g:lightline = { 'colorscheme': 'wombat' }

" NERDTree show hidden files
let NERDTreeShowHidden=1

nnoremap <F5> :NERDTreeToggle<CR>

" Source a global configuration file if available
"if filereadable("/etc/vim/vimrc.local")
"  source /etc/vim/vimrc.local
"endif
