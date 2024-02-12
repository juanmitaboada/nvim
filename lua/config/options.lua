local opt = vim.opt

opt.autoread=true -- Reload file if changed
opt.autowrite = true -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
-- opt.colorcolumn = 80  -- Set red column at 80 characters
opt.cursorline = false -- Enable highlighting of the current line
opt.encoding = "utf-8"  -- Set encoding to utf-8
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.incsearch = true  -- Incremental search
opt.hlsearch = true
opt.hidden = true
opt.history = 100  -- Keep 100 lines of command line history
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3 -- global statusline
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = false -- Relative line numbers
opt.ruler = true  -- Show the cursor position all the time
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 4 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showcmd = true -- Show (partial) command in status line
opt.showmatch = true -- Show matcing brackets
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 4 -- Number of spaces tabs count for
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 4 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.textwidth = 80 -- Don't wrap lines at 80 columns (or use 79)
opt.tabstop = 4
opt.tw = 0 -- Don't wrap lines at 80 columns (or use 79)
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = true -- Disable line wrap
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Copilot
vim.g.copilot_no_tab_map = false
vim.g.copilot_assume_mapped = false

-- OLD VIM configuration
vim.cmd([[

set lcs=extends:$,tab:/.,eol:$
ab usetab :set noet ci pi sts=0 sw=4 ts=4 " Show tab character

" Hightlight 80 column
highlight ColorColumn ctermbg=magenta guibg=magenta
call matchadd('ColorColumn', '\%81v', 100)

" Cursor shows as a block all the time
set guicursor = "n-v-c:block,o:hor50,i-ci:hor15,r-cr:hor30,sm:block"

" Ligther visual block selection
highlight Visual term=reverse cterm=reverse guibg=Grey"

autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif

let g:black_linelength = 79

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:deoplete#enable_at_startup = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#ale#enabled = 1

let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
" let g:javascript_plugin_flow = 1

" default folding settings
" set foldmethod=marker   " Using markers: {{{1  ...  }}}1
set foldmethod=indent   " Just perfect for Python
set foldnestmax=10
set nofoldenable
set foldlevel=1

" Clear screen on exist (it will avoid putting colors from vim on your screen)
au VimLeave * :!clear

" Tagbar and NERDTree Toggle
nmap <F3> :TagbarToggle<CR>
imap <F3> <Esc>:TagbarToggle<CR>
map <F4> :NERDTreeToggle<CR>
imap <F4> <Esc>:NERDTreeToggle<CR>

" Ultisnipts controls
let g:UltiSnipsExpandTrigger="<F2>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" ctags controls
" for ctags to work you must make a 'tags' file inside some of your projects
" folder from the list of vim-tags plugin: ['.git', '.hg', '.svn', '.bzr', '_darcs', 'CSV']
" let g:vim_tags_auto_generate = 1
let g:vim_tags_use_language_field = 1
map <cr> <c-]>
map <bs> <c-t>

" Buffer management management
map  <A-Up> :BufExplorer<CR>
map! <A-Up> <Esc>:BufExplorer<CR>
map  <A-Right> :bnext<CR>
map! <A-Right> <Esc>:bnext<CR>
map  <A-Left> :bprevious<CR>
map! <A-Left> <Esc>:bprevious<CR>
map  <A-Down> :bd<CR>
map! <A-Down> <Esc>:bd<CR>

" move lines up and down from grendel-arsenal.googlecode.com
nnoremap <C-Down> :m+<CR>==
nnoremap <C-Up> :m-2<CR>==
inoremap <C-Down> <Esc>:m+<CR>==gi
inoremap <C-Up> <Esc>:m-2<CR>==gi
vnoremap <C-Down> :m'>+<CR>gv=gv
vnoremap <C-Up> :m-2<CR>gv=gv
" move lines right and left several times
nnoremap <C-Left> v<<Esc>
nnoremap <C-Right> v><Esc>
inoremap <C-Left> <Esc>v<<Esc>gi
inoremap <C-Right> <Esc>v><Esc>gi
vnoremap <C-Left> <gv
vnoremap <C-Right> >gv
vnoremap < <gv
vnoremap > >gv

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Save session
nmap <F8> :mks! .session.vim<CR>

" === LINTERS === ==========================================

" SH
" E003: Indent not multiple of 4
" E006: Line too long
" E042: local declaration hides errors

" PYTHON
" E203: Whitespace before ':'
" E501: Line too long
" E503: Line break occurred before a binary operator

" ALE configuration (Asynchronous Linter Engine)
let g:ale_c_cpplint_options = '--filter=-legal/copyright,-readability/casting,-runtime/int,-build/include_subdir'
let g:ale_cpp_cpplint_options = '--filter=-legal/copyright'
let g:ale_c_clangtidy_options = '-system-headers'
let g:ale_c_clangtidy_checks = ['-clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling']
let g:ale_cpp_clangtidy_options = '-system-headers'
let g:ale_cpp_clangtidy_checks = ['-clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling']
let g:ale_c_cppcheck_options = '--force --inline-suppr'
let g:ale_cpp_cppcheck_options = '--force'
let g:ale_sign_column_always = 1
let g:ale_python_pycodestyle_options = '--ignore=E203,W503'
let g:ale_python_flake8_options = '--ignore=E203,W503'
let g:ale_sh_bashate_options = '--ignore "E003,E006"'
" let g:ale_python_pylint_executable = 'pylint'
" let g:ale_python_pylint_options = '--rcfile ~/.pylintrc'
" let g:ale_linters = { 'python': ['pyflakes3', 'pycodestyle'] , }
" let g:ale_linters = { 'python': ['pyflakes3', 'pycodestyle', 'pylint', 'mypy', 'flake8'] , }
" let g:ale_linters = { 'python': ['pyflakes3', 'pycodestyle', 'flake8', 'pep8', "pylint", "mypy"] , 'sh': ['bashate', 'shellcheck']}

" Unpaired configuration for ALE
:nmap ]a :ALENextWrap<CR>
:nmap [a :ALEPreviousWrap<CR>
:nmap ]A :ALELast
:nmap [A :ALEFirst

" Syntactic
" let g:syntastic_python_flake8_args='--ignore=F821,E302'
" let g:syntastic_python_flake8_args='--ignore=E203'
let g:syntastic_python_flake8_args='--ignore=E203,W503'
let g:syntastic_sh_checkers = ['bashate', 'shellcheck']
let g:syntastic_sh_bashate_args = '--ignore "E003,E006"'

let g:pymode_lint_ignore='--ignore=E203,W503'

" ==========================================================


nmap <silent> <C-S-Left> <Plug>(ale_previous_wrap)
nmap <silent> <C-S-Right> <Plug>(ale_next_wrap)

" Show messages in a different manner
" let g:ale_echo_msg_error_str = 'E'
" let g:ale_echo_msg_warning_str = 'W'
" let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" Add support for prospector
" autocmd FileType python setlocal makeprg=prospector\ -8\ -o\ pylint\ % errorformat=%f:%l:\ %m
" let g:makejob_hide_preview_window = 1
" map  <C-x> :MakeJob<CR>:copen<CR><C-w><Up>
" map! <C-x> <Esc>:MakeJob<CR>:copen<CR><C-w><Up>

" Add to .vimrc to enable project-specific vimrc
set exrc
set secure
" exrc allows loading local executing local rc files.
" secure disallows the use of :autocmd, shell and write commands in local .vimrc files.

" Vim diff special configuration
if &diff
    set cursorline
    map ] ]c
    map [ [c
    " hi DiffAdd    ctermfg=233 ctermbg=LightGreen guifg=#003300 guibg=#DDFFDD gui=none cterm=none
    " hi DiffChange ctermbg=white  guibg=#ececec gui=none   cterm=none
    " hi DiffText   ctermfg=233  ctermbg=yellow  guifg=#000033 guibg=#DDDDFF gui=none cterm=none
    " hi DiffAdd      gui=none    guifg=NONE          guibg=#bada9f
    " hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
    " hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
    " hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
endif

" Black support
augroup black_on_save
 autocmd!
 autocmd BufWritePre *.py Black
augroup end
" nnoremap <F9> :Black<CR>

" ISort
"augroup isort_on_save
" autocmd!
" autocmd BufWritePre *.py Isort
"augroup end
" nnoremap <F10> :Isort<CR>
" let g:isort_vim_options = '--profile black'

" JSON Format
nnoremap <C-j> :%!python -m json.tool<CR>

" RADON
let g:radon_always_on=1

" uncrustify
" --replace, -q, --no-backup, --set, "indent_columns=4", --set, "indent_with_tabs=0"]
"
" clang-format configuration
let g:clang_format#auto_format = 1
let g:clang_format#style_options = {
            \ "BasedOnStyle": "Google",
            \ "BinPackArguments": "false",
            \ "BinPackParameters": "false",
            \ "AccessModifierOffset" : -4,
            \ "AlignOperands": "Align",
            \ "AlignArrayOfStructures": "Left",
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AllowShortBlocksOnASingleLine": "Empty",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "IndentWidth": 4,
            \ "PointerAlignment": "Right",
            \ "QualifierAlignment": "Left",
            \ "RemoveBracesLLVM": "false",
            \ "SeparateDefinitionBlocks": "Always",
            \ "Standard" : "Auto",
            \ "SpaceAfterCStyleCast": "true",
            \ "SpaceAfterLogicalNot": "false",
            \ "SpaceAfterTemplateKeyword": "true",
            \ "SpaceAroundPointerQualifiers": "Default",
            \ "SpaceBeforeAssignmentOperators": "true",
            \ "SpaceBeforeCaseColon": "false",
            \ "SpaceBeforeCpp11BracedList": "true",
            \ "SpaceBeforeCtorInitializerColon": "false",
            \ "SpaceBeforeInheritanceColon": "false",
            \ "SpaceBeforeParens": "ControlStatements",
            \ "SpaceBeforeRangeBasedForLoopColon": "true",
            \ "SpaceBeforeSquareBrackets": "false",
            \ "SpaceInEmptyBlock": "false",
            \ "SpacesBeforeTrailingComments": "2",
            \ "SpacesInAngles": "Never",
            \ "SpacesInContainerLiterals": "false",
            \ "SpacesInCStyleCastParentheses": "false",
            \ }

            " \ "AllowAllArgumentsOnNextLine": "false",
            " \ "AllowAllParametersOfDeclarationOnNextLine": "false",
            " \ "BraceWrapping": {
            " \   "AfterCaseLabel":  "false",
            " \   "AfterClass":      "false",
            " \   "AfterControlStatement": "false",
            " \   "AfterEnum":       "false",
            " \   "AfterFunction":   "false",
            " \   "AfterNamespace":  "false",
            " \   "AfterObjCDeclaration": "false",
            " \   "AfterStruct":     "false",
            " \   "AfterUnion":      "false",
            " \   "AfterExternBlock": "false",
            " \   "BeforeCatch":     "false",
            " \   "BeforeElse":      "false",
            " \   "BeforeLambdaBody": "false",
            " \   "BeforeWhile": "false",
            " \   "IndentBraces":    "true",
            " \   "SplitEmptyFunction": "false",
            " \   "SplitEmptyRecord": "false",
            " \   "SplitEmptyNamespace": "false",
            " \  },
            " \ "BreakBeforeBraces": "Custom",
            "
            " \ "InsertBraces": "true",
            " \ "RemoveParentheses": "RPS_ReturnStatement",
            " \ "RemoveSemicolon": "true",
            " \ "SpaceBeforeJsonColon": "false",
]])
