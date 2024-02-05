# My NVIM configuration

This is my actual Neovim configuration.

## Screenshots

Gitgutter + Linting + Inline warnings and errors

![gitgutter_errors_linting](https://github.com/juanmitaboada/nvim/assets/1763207/66716a29-1973-47ec-80d3-9221acd1a826)

GitHub Copilot & Buffer Explorer:

![copilot_bufferexplorer](https://github.com/juanmitaboada/nvim/assets/1763207/71af9ea2-5300-4bf2-8fde-1ddb351fa76a)

Ack:

![ack](https://github.com/juanmitaboada/nvim/assets/1763207/d51a2716-512a-4426-906c-588872024761)

Tagbar and Nerdtree:

![tagbar_nerdtree](https://github.com/juanmitaboada/nvim/assets/1763207/464ae798-7bcb-45c8-8e81-b2d531c1a8e0)

Radeon and Control+P:

![radeon_controlp](https://github.com/juanmitaboada/nvim/assets/1763207/e311a46d-58f6-45ef-9cbc-9812971ea10b)

## Installation

Before you go with the installation, make sure you make a backup of your current Neovim configuration, go to your home folder and rename both .config/nvim/ to different name:

    cd ~/.config/ && mv nvim nvim.backup

Let's install:

1. Go to your home folder inside '.config/', clone this repository, and rename it to .vim:

    `cd ~/.config/ && git clone https://github.com/juanmitaboada/nvim`

2. Install dependencies (it will request your sudo password):

    `~/.config/nvim/vim_install_plugins.sh`

3. Start Neovim and it should install all depedencies

4. You may get errors with the YouCompleteMe plugin not loading, the error says: "The ycmd server SHUT DOWN (restart with :YcmRestartServer)". To solve this problem you must execute the install script from YCM inside the plugin folder. Follow the next steps:

    `cd ~/.local/share/nvim/lazy/YouCompleteMe`

    `./install.py --clang-completer`

5. You probably want to setup Github Copilot, you will need a working 'node' installation in your computer and then launch the setup using:

    `:Copilot setup`

6. You are ready to go


## Shortcuts


There are plenty of shortcuts but, these are the basic ones: (default <leader> is <space> and <localleader> is "\")

| Shortcut        | Description                                                                                                 | Provided by     |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| *               | Search forward word under the cursor                                                                        | vim             |
| n               | Search next word using the same criteria                                                                    | vim             |
| Shift+n         | Search the previous word using the same criteria                                                            | vim             |
| #               | Search backward word under the cursor                                                                       | vim             |
| K               | Search for the word inside man                                                                              | vim             |
| gd              | Go to the first definition of the element under the cursor                                                  | vim             |
| F2              | Start writing and, ultisnips will fill the basic skeleton (check examples)                                  | ultisnips       |
| F3              | Tagbar panel (on/off)                                                                                       | tagbar          |
| F4              | NERD Tree (on/off)                                                                                          | nerdtree        |
| F8              | Save the current session on the current folder                                                              | vim             |
| Ctrl+J          | Beautify the buffer using JSON format                                                                       | vim             |
| Alt+up          | Show all buffers                                                                                            | BufferExplorer  |
| Alt+down        | Close current buffer                                                                                        | vim             |
| Alt+left        | Move to previous buffer                                                                                     | vim             |
| Alt+right       | Move to next buffer                                                                                         | vim             |
| Ctrl+up         | Move current line/block up                                                                                  | vim             |
| Ctrl+down       | Move current line/block down                                                                                | vim             |
| Ctrl+right      | Indent current line/block one level                                                                         | vim             |
| Ctrl+left       | Unindent current line/block one level                                                                       | vim             |
| Enter           | Go to function definition                                                                                   | ctags           |
| Backspace       | Go back from function definition                                                                            | ctags           |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| [a              | Go to previous error                                                                                        | ALE             |
| ]a              | Go to next error                                                                                            | ALE             |
| [A              | Go to first error                                                                                           | ALE             |
| ]A              | Go to last error                                                                                            | ALE             |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| :Ack colors     | Search everywhere in the project for the word "colors"                                                      | Ack             |
| Ctrl+P colors   | Search for files with the word "colors" in all the project                                                  | ctrlp           |
| <Leader>ff      | Find files                                                                                                  | Telescope       |
| <Leader>fg      | Fidd live grep                                                                                              | Telescope       |
| <Leader>fb      | Find buffers                                                                                                | Telescope       |
| <Leader>fh      | Find help tags                                                                                              | Telescope       |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| :TagsGenerate!  | Will generate one or more tags files                                                                        | vim-tags        |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| gc{motion}      | Comment or uncomment lines that {motion} moves over                                                         | Commentary      |
| {Visual}gc      | Comment or uncomment the highlighted lines                                                                  | Commentary      |
| gc?             | Comment or uncomment [?=count] lines. (Example: gc4)                                                        | Commentary      |
| gcu | gcgc      | Uncomment the current and adjacent commented lines                                                          | Commentary      |
| :7,17Commentary | Comment/Uncomment from line 7 to line 17 both included                                                      | Commentary      |
|:---------------:|:------------------------------------------------------------------------------------------------------------|:---------------:|
| Copilot Chat    | Copy code with "y" and then:                                                                                |                 |
| <Leader>cce     | Explain code                                                                                                | Copilot Chat    |
| <Leader>cct     | Generate tests                                                                                              | Copilot Chat    |


#### Ultistnips

if:

    if condition:
        pass

ife:

    if condition:
        pass
    else:
        pass

ei:

    elif condition:
        ...

el:

    else:
        ...

for:

    for item in iterable:
        pass

wl:

    while condition:
        ...

cl:

    class ClassName(object):
        """doctstring for ClassName"""
        def __init__(self, args):
            super(ClassName, self).__init__()
            self.arg = arg

def:

    def function(arg1):
        """TODO: Docstring for function.

        :arg1: TODO
        :returns: TODO

        """



## Plugins in use

| Plugin name                                                                     | Description                                                                                                                                 |
|:-------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------|
| [Ack](https://github.com/mileszs/ack.vim)                                       | Search tool with an enhanced results list                                                                                                   |
| [Airline](https://github.com/vim-airline/vim-airline)                           | Lean & mean status/tabline for Vim that's light as air                                                                                      |
| [ALE](https://github.com/w0rp/ale)                                              | ALE (Asynchronous Lint Engine) is a plugin providing linting (sytax checking and semantic errors)                                           |
| [Arduino Snippets](https://github.com/sudar/vim-arduino-snippets)               | Snippets files for Arduino                                                                                                                  |
| [Arduino Syntax](https://github.com/sudar/vim-arduino-syntax)                   | Syntax file and get syntax highlighting for Arduino functions                                                                               |
| [Black](https://github.com/psf/black)                                           | Uncompromising Python code formatter                                                                                                        |
| [Bufexplorer](https://github.com/jlanzarotta/bufexplorer)                       | Quickly and easily switches between buffers                                                                                                 |
| [CCLS](https://github.com/MaskRay/ccls)                                         | Ccls, which originates from cquery, is a C/C++/Objective-C language server                                                                  |
| [CCTree](https://github.com/hari-rangarajan/CCTree)                             | Plugin generates a symbol dependency tree (aka call tree, call graph) in real-time                                                          |
| [Clang](https://github.com/justmao945/vim-clang)                                | Use of clang to parse and complete C/C++ source files                                                                                       |
| [Clang Format](https://github.com/rhysd/vim-clang-format)                       | Format your C family code                                                                                                                   |
| [Commentary](https://github.com/tpope/vim-commentary)                           | Comment stuff out                                                                                                                           |
| [Copilot](https://github.com/github/copilot.vim)                                | GitHub Copilot support                                                                                                                      |
| [Copilot Chat](https://github.com/jellydn/CopilotChat.nvim)                     | GitHub Copilot Chat support                                                                                                                 |
| [CtrlP](https://github.com/kien/ctrlp.vim)                                      | Full path fuzzy file, buffer, mru, tag, ... finder                                                                                          |
| [DelimitMate](https://github.com/Raimondi/delimitMate)                          | This plug-in provides automatic closing of quotes, parentheses, brackets, etc.                                                              |
| [Dispatch](https://github.com/tpope/vim-dispatch)                               | Leverage the power of Vim's compiler plugins without being bound by synchronicity                                                           |
| [Gitgutter](https://github.com/airblade/vim-gitgutter)                          | Shows a git diff in the sign column                                                                                                         |
| [ISort](https://github.com/fisadev/vim-isort)                                   | Sort python imports                                                                                                                         |
| [Javascript](https://github.com/pangloss/vim-javascript)                        | Syntax highlighting and improved indentation for JavaScript                                                                                 |
| [Lazy](https://github.com/folke/lazy.nvim)                                      | A moren plugin manager for Neovim                                                                                                           |
| [LSP](https://github.com/prabirshrestha/vim-lsp)                                | Async Language Server Protocol                                                                                                              |
| [Markdown](https://github.com/plasticboy/vim-markdown)                          | Syntax highlighting, matching rules and mappings for the original Markdown and extensions                                                   |
| [NerdTree](https://github.com/scrooloose/nerdtree)                              | File system explorer                                                                                                                        |
| [Platform.io](https://github.com/normen/vim-pio)                                | This is a collection of helper commands to ease the use of PlatformIO                                                                       |
| [Platform.io Neomake](https://github.com/coddingtonbear/neomake-platformio)     | Easily configure neomake to recognize your PlatformIO project's include path                                                                |
| [Plenary](https://github.com/nvim-lua/plenary.nvim)                             | All the lua functions I don't want to write twice                                                                                           |
| [Radon](https://github.com/rubik/vim-radon)                                     | Show the cyclomatic complexity of Python code (we will use a slightly modified version at juanmitaboada/vim-radon)                          |
| [Repeat](https://github.com/tpope/vim-repeat)                                   | Remaps . in a way that plugins can tap into it                                                                                              |
| [Ripgrep](https://github.com/BurntSushi/ripgrep)                                | A line-oriented search tool that recursively searches the current directory for a regex pattern                                             |
| [Rust](https://github.com/rust-lang/rust.vim)                                   | Rust file detection, syntax highlighting, formatting, Syntastic integration, and more                                                       |
| [Signify](https://github.com/mhinz/vim-signify)                                 | Uses the sign column to indicate added, modified and removed lines in a file that is managed by a VCS                                       |
| [Shellcheck](https://github.com/itspriddle/vim-shellcheck)                      | Vim wrapper for ShellCheck, a static analysis tool for shell scripts                                                                        |
| [Snippets](https://github.com/honza/vim-snippets)                               | Snippets files for various programming languages                                                                                            |
| [Surround](https://github.com/tpope/vim-surround)                               | Is all about "surroundings": parentheses, brackets, quotes, XML tags, and more                                                              |
| [Tagbar](https://github.com/majutsushi/tagbar)                                  | Provides an easy way to browse the tags of the current file and get an overview of its structure                                            |
| [Tags](https://github.com/szw/vim-tags)                                         | The Ctags generator                                                                                                                         |
| [Telescope](https://github.com/nvim-telescope/telescope.nvim)                   | A highly extendable fuzzy finder                                                                                                            |
| [Typescript](https://github.com/leafgarland/typescript-vim)                     | Syntax file and other settings for TypeScript                                                                                               |
| [Ultisnips](https://github.com/SirVer/ultisnips)                                | The ultimate solution for snippets                                                                                                          |
| [Unimparired](https://github.com/tpope/vim-unimpaired)                          | Collection of handy keymappings designed to improve efficency and accesibiilty within the editor                                            |
| [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)                      | A code-completion engine                                                                                                                    |
| [Zig](https://github.com/ziglang/zig.vim)                                       | File detection and syntax highlighting for the zig programming language                                                                     |

## Author

[Juanmi Taboada](https://juanmitaboada.github.io/)
