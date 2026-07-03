" ============================================================================
" Neovim configuration (init.vim)
"
" Layout:
"   1. Core editor options (Vimscript `set`)
"   2. Leader key & basic mappings
"   3. FZF mappings
"   4. Plugin list (vim-plug)
"   5. `Find` ripgrep command
"   6. Lua block: plugin setup, completion, LSP, Copilot, misc keymaps
"   7. Colorscheme (must run after plugins are loaded)
"
" Requires Neovim 0.11+ (uses vim.lsp.config / vim.lsp.enable and
" vim.lsp.inline_completion). A snapshot of a previous version lives in
" init.backup next to this file.
" ============================================================================

" Enable syntax highlighting (treesitter augments this below).
syntax enable

" Use the dark variant of colorschemes.
set background=dark

" Show otherwise-invisible characters: trailing spaces as ·, tabs as »».
" Helps catch stray whitespace and accidental tabs.
set listchars=trail:·,tab:»»
set list

" Indentation: two spaces, no real tabs, for every filetype.
"   expandtab    - insert spaces when pressing <Tab>
"   shiftwidth   - spaces per indent step (>>, <<, autoindent)
"   softtabstop  - spaces a <Tab>/<BS> feels like while editing
"   tabstop      - display width of a literal tab character
" These are global options, so a plain `set` at startup is enough (the old
" `autocmd VimEnter *` wrapper was unnecessary).
set expandtab shiftwidth=2 softtabstop=2 tabstop=2

" Completion menu behavior:
"   menu/menuone - always show the popup menu (even for a single match)
"   noselect     - never auto-select an entry; the user picks explicitly
set completeopt=menu,menuone,noselect

" Enable 24-bit RGB color (required by nvim-colorizer.lua and Tokyonight).
set termguicolors

" Use the system clipboard for all yank/delete/paste operations.
set clipboard=unnamedplus

" --- General UI / behavior -------------------------------------------------
set number                  " absolute line numbers
set splitbelow splitright   " new splits open below / to the right
set signcolumn=yes          " always show the sign column (no text shifting)
set updatetime=300          " faster CursorHold / swap-write (default 4000ms)
set scrolloff=8             " keep 8 lines of context above/below the cursor
set ignorecase smartcase    " case-insensitive search, unless the query has caps
set undofile                " persist undo history across sessions

" Highlight the current line, but only in the active window. Wrapped in a
" cleared augroup so re-sourcing this file doesn't stack duplicate autocmds.
" http://vim.wikia.com/wiki/Highlight_current_line
augroup nvim_cursorline
  autocmd!
  autocmd BufEnter,WinEnter * setlocal cursorline
  autocmd BufLeave,WinLeave * setlocal nocursorline
augroup END

" Change the leader key from "\" to ";".
let mapleader=";"

" Use ;; as an alternative to <Esc> in insert mode.
" http://vim.wikia.com/wiki/Avoid_the_escape_key
inoremap ;; <Esc>

" --- FZF mappings ----------------------------------------------------------
" All commands are namespaced with the FZF prefix (see g:fzf_command_prefix).
nnoremap <silent> <leader>fb :FZFBuffers<CR>   " open buffers
" Ex commands
nnoremap <silent> <leader>fc :FZFCommands<CR>
" files in cwd
nnoremap <silent> <leader>ff :FZF<CR>
nnoremap <silent> <leader>fh :FZFHistory<CR>   " file history
nnoremap <silent> <leader>fr :FZFRg<CR>        " ripgrep live search
nnoremap <silent> <leader>fw :FZFWindows<CR>   " windows

" Prefix every fzf.vim command with "FZF" (e.g. :FZFBuffers).
let g:fzf_command_prefix = 'FZF'

" ============================================================================
" Plugins (vim-plug)
" ============================================================================
call plug#begin()

  " Code AST / syntax-aware highlighting and more.
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

  " Appearance
  Plug 'folke/tokyonight.nvim'       " colorscheme
  Plug 'nvim-lualine/lualine.nvim'   " statusline

  " Utilities
  Plug 'catgoose/nvim-colorizer.lua' " highlight color codes inline

  " LSP client configs (server defaults for vim.lsp.enable).
  Plug 'neovim/nvim-lspconfig'

  " Auto completion (nvim-cmp + sources).
  Plug 'hrsh7th/cmp-nvim-lsp'  " LSP source
  Plug 'hrsh7th/cmp-buffer'    " current-buffer words
  Plug 'hrsh7th/cmp-path'      " filesystem paths
  Plug 'hrsh7th/cmp-cmdline'   " command-line completion
  Plug 'hrsh7th/nvim-cmp'      " the completion engine itself

  " Snippet engine + cmp source (required by nvim-cmp's snippet config).
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'

  " Auto pairs and tags.
  Plug 'windwp/nvim-autopairs'  " auto-close brackets/quotes
  Plug 'windwp/nvim-ts-autotag' " auto-close/rename HTML/JSX tags

  " GitHub Copilot as an nvim-cmp source (instead of native ghost text).
  Plug 'zbirenbaum/copilot.lua'  " Copilot client (ghost text disabled below)
  Plug 'zbirenbaum/copilot-cmp'  " exposes Copilot as a cmp completion source

  " Fuzzy search. To update the fzf binary: :PlugUpdate fzf
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

call plug#end()

" ============================================================================
" Custom :Find command — ripgrep search piped through fzf
" ============================================================================
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

" ============================================================================
" Lua configuration block
" ============================================================================
lua <<EOF

  -- Surround the word under the cursor with quotes.
  -- ciw deletes the word into a register, types the quotes, then P pastes the
  -- word back between them.
  vim.keymap.set("n", '<leader>"', 'ciw""<Esc>P', { desc = "Double quote word under cursor" })
  vim.keymap.set("n", "<leader>'", "ciw''<Esc>P", { desc = "Single quote word under cursor" })

  -- --- Treesitter ----------------------------------------------------------
  -- Parser-based highlighting and indentation. Parsers in ensure_installed are
  -- auto-installed on first launch.
  require('nvim-treesitter.config').setup({
    ensure_installed = {
      'javascript', 'typescript', 'tsx',
      'haskell',
      'html', 'css', 'json',
      'lua', 'bash', 'markdown', 'markdown_inline', 'vim', 'vimdoc',
    },
    highlight = {
      enable = true
    },
    indent = {
      enable = true  -- treesitter-based `=` indentation
    }
  })

  -- --- Colorscheme setup ---------------------------------------------------
  -- (The actual `colorscheme` command runs at the very bottom of this file.)
  require'tokyonight'.setup({
    transparent = true,           -- use the terminal background
    style = "night",              -- darkest Tokyonight variant
    styles = {
      comments = { italic = true },
      keywords = { bold = true },
    },
    on_colors = function(colors)
      colors.comment = "#777777"  -- brighten comments for readability
    end,
    on_highlights = function(hl, c)
      -- Make comments brighter for better readability
      hl.Comment = { fg = c.comment, italic = true }
      hl.LineNr = { fg = c.comment }  -- dim line numbers
      hl.TabLine = { fg = c.comment }  -- dim inactive tabline
      hl.DiagnosticUnnecessary = { fg = c.comment }  -- dim unnecessary diagnostics
    end,
  })

  -- --- Statusline ----------------------------------------------------------
  require'lualine'.setup {
    options = {
      icons_enabled = true,
      theme = 'tokyonight',
    }
  }

  -- --- Inline color previews -----------------------------------------------
  require('colorizer').setup({
    filetypes = {
      "*", -- Matches all file types
      html = {
        parsers = {
          oklch = { enable = true },
        },
      },
      css = {
        parsers = {
          oklch = { enable = true },
        },
      },
      markdown = {
        parsers = {
          oklch = { enable = true },
        },
      },
    },
    user_default_options = {
      mode = "background" -- "background" | "foreground" | "virtualtext"
    }
  })

  -- --- Completion (nvim-cmp) ------------------------------------------------
  local cmp = require'cmp'

  -- True only when there is non-whitespace text before the cursor. Guards the
  -- <Tab> mapping so Tab still indents on empty lines instead of grabbing a
  -- Copilot completion. (Modern replacement for the README's deprecated
  -- nvim_buf_get_option call.)
  local has_words_before = function()
    if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match('^%s*$') == nil
  end

  cmp.setup({
    snippet = {
      -- Expand snippets via vsnip.
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),  -- scroll docs up
      ['<C-f>'] = cmp.mapping.scroll_docs(4),   -- scroll docs down
      ['<C-Space>'] = cmp.mapping.complete(),   -- trigger completion
      ['<C-e>'] = cmp.mapping.abort(),          -- close the menu
      -- Confirm the selected item. select=false means <CR> only confirms an
      -- item the user explicitly selected (a bare <CR> stays a newline).
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
      -- Move selection to the next menu item (e.g. a Copilot suggestion) when
      -- the menu is open and there's text before the cursor; otherwise fall
      -- through to a literal <Tab>.
      ['<Tab>'] = vim.schedule_wrap(function(fallback)
        if cmp.visible() and has_words_before() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
          fallback()
        end
      end),
    }),
    -- Rank Copilot entries at the top via copilot-cmp's `prioritize` comparator,
    -- then fall back to cmp's standard ordering.
    sorting = {
      priority_weight = 2,
      comparators = {
        require('copilot_cmp.comparators').prioritize,
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
    sources = cmp.config.sources({
      { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'vsnip' }
    }, {
      { name = 'buffer' }
    })
  })

  -- Search (`/`, `?`): complete from buffer contents.
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Command line (`:`): complete paths, then commands.
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- --- LSP (Neovim 0.11+ native API) ---------------------------------------
  -- Global defaults applied to every server: advertise nvim-cmp's extra
  -- completion capabilities to all language servers.
  vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })

  -- LSP keymaps, set once per buffer when any server attaches. Replaces the
  -- old per-server `on_attach` callback.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local opts = { buffer = bufnr, noremap = true, silent = true }

      -- Go to definition in a new tab.
      vim.keymap.set('n', '<leader>ld', function()
        vim.cmd('tab split')
        vim.lsp.buf.definition()
      end, opts)
      vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, opts)
      -- Go to type definition in a new tab.
      vim.keymap.set('n', '<leader>lt', function()
        vim.cmd('tab split')
        vim.lsp.buf.type_definition()
      end, opts)
      vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, opts)
      -- Jump between diagnostics (vim.diagnostic.jump replaces the deprecated
      -- goto_prev / goto_next).
      vim.keymap.set('n', '<leader>lp', function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, opts)
      vim.keymap.set('n', '<leader>ln', function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, opts)
      vim.keymap.set('n', '<leader>lf', function()
        vim.lsp.buf.format({ async = true })
      end, opts)

      -- eslint: auto-fix on save. EslintFixAll is provided by
      -- nvim-lspconfig's eslint config.
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == 'eslint' then
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          command = 'EslintFixAll',
        })
      end
    end,
  })

  -- Enable the language servers (configs ship with nvim-lspconfig). Defaults
  -- and keymaps above apply automatically.
  vim.lsp.enable({
    'ts_ls',        -- TypeScript / JavaScript
    'hls',          -- Haskell
    'tailwindcss',  -- Tailwind CSS
    'cssls',        -- CSS
    'html',         -- HTML
    'eslint',       -- ESLint
  })

  -- --- Auto pairs & tags ---------------------------------------------------
  require('nvim-autopairs').setup{}
  -- Insert the matching pair after confirming a cmp completion (e.g. a "(").
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

  -- Auto-close and auto-rename HTML/JSX tags.
  require('nvim-ts-autotag').setup{}

  -- =====================================
  -- GitHub Copilot (as an nvim-cmp source via copilot-cmp)
  -- =====================================
  -- copilot.lua drives the Copilot client. Its own ghost-text `suggestion` and
  -- `panel` surfaces are disabled so that suggestions flow exclusively through
  -- nvim-cmp (via copilot-cmp, set up next) — this is what keeps them from
  -- fighting nvim-autopairs the way native inline ghost text did.
  -- copilot.lua 1.515+ bundles GitHub's Copilot Language Server, which requires
  -- Node.js 22+. The nvm-default `node` here is still v20 (and project .nvmrc
  -- files may pin older versions), so instead of relying on PATH, point Copilot
  -- at the newest installed Node >= 22. Falls back to plain "node".
  local function copilot_node()
    local newest, newest_major = nil, 21
    for _, dir in ipairs(vim.fn.glob("~/.nvm/versions/node/v*", true, true)) do
      local major = tonumber(dir:match("/v(%d+)%."))
      if major and major > newest_major then
        newest, newest_major = dir .. "/bin/node", major
      end
    end
    return newest or "node"
  end

  require('copilot').setup({
    copilot_node_command = copilot_node(),
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
  -- Register the 'copilot' cmp source (referenced in cmp.setup above). Its
  -- default `fix_pairs` stops Copilot from doubling closing brackets that
  -- nvim-autopairs already inserts.
  require('copilot_cmp').setup()

  -- Sign in with :Copilot auth (device flow) if Copilot reports NotAuthorized.

  -- --- Misc keymaps & autocmds ---------------------------------------------

  -- Copy the absolute path of the current file to the system clipboard.
  vim.keymap.set("n", "<leader>pa", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
    vim.print("Absolute path copied to clipboard!")
  end, { noremap = true, silent = true, desc = "Copy absolute file path" })

  -- Auto-reload files changed on disk (e.g. by Claude Code / git). autoread
  -- only takes effect when something triggers a check, so :checktime is run on
  -- common focus/cursor events.
  vim.o.autoread = true

  vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI" }, {
    group = vim.api.nvim_create_augroup("ClaudeCodeAutoReload", { clear = true }),
    callback = function()
      vim.cmd("checktime")
    end,
  })

EOF

" ============================================================================
" Colorscheme — must come after plug#end() so the plugin is on the runtimepath.
" ============================================================================
colorscheme tokyonight-night
