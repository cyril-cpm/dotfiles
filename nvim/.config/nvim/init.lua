
-- -- Set color scheme when open Vim
vim.cmd.colorscheme("solarpunk")
vim.go.background = "light"
-- -- vim.go.termguicolors = true
--
-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','

-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

-- Print the line number in front of each line
vim.o.number = true

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.o.clipboard = 'unnamedplus'
	end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight the line where the cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Show <tab> and trailing spaces
vim.o.list = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.o.confirm = true

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<A-Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
	local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
	local filename = vim.api.nvim_buf_get_name(0)
	print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
vim.cmd('packadd! nohlsearch')

-- Set tab width to 4
-- ~/.config/nvim/init.lua
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = false
	end,
})

vim.o.autoindent = true

-- Install treesitter configs for language syntax highlight
require("nvim-treesitter.configs").setup {
	ensure_installed = { "c", "lua", "python", "cpp" }, -- adapte à tes langages
	highlight = { enable = true },
}

-- Telescope
local t = require("telescope")
local z_utils = require("telescope._extensions.zoxide.utils")
local actions = require("telescope.actions")

t.setup({
	defaults = {
		mappings = {
			i = {
				["<C-h>"] = function(prompt_buffer)
					actions.file_vsplit(prompt_buffer)
				end,
				["<C-v>"] = function(prompt_buffer)
					actions.file_split(prompt_buffer)
				end,
			},
		},
	},
	extensions = {
		zoxide = {
			prompt_title = "[ Zoxide List ]",

			-- Zoxide list command with score
			list_command = "zoxide query -ls",
			mappings = {
				default = {
					action = function(selection)
						vim.cmd.cd(selection.path)
					end,
					after_action = function(selection)
						vim.notify("Directory changed to " .. selection.path)
					end,
				},
				["<C-v>"] = { action = z_utils.create_basic_command("split") },
				["<C-h>"] = { action = z_utils.create_basic_command("vsplit") },
				["<C-e>"] = { action = z_utils.create_basic_command("edit") },
				["<C-f>"] = {
					keepinsert = true,
					action = function(selection)
						builtin.find_files({ cwd = selection.path })
					end,
				},
				["<C-t>"] = {
					action = function(selection)
						vim.cmd.tcd(selection.path)
					end,
				},
			}
		},
		file_browser = {
			theme = "ivy",
			hijack_netwr = true,
			mappings = {}
		},
	}
})
t.load_extension('fzf')
t.load_extension('zoxide')
t.load_extension('file_browser')

vim.keymap.set("n", "t", t.extensions.zoxide.list)

-- Yazi
require('yazi').setup({
	keymaps = {
		open_file_in_vertical_split = "<c-h>",
		open_file_in_horizontal_split = "<c-v>",
	}
})

-- BLINK.CMP

local blink = require("blink.cmp")
blink.setup {
	keymap = {
		preset = 'default',

		['<C-k>'] = { 'select_prev', 'fallback' },
		['<C-j>'] = { 'select_next', 'fallback' },
		['<Tab>'] = { 'select_and_accept', 'fallback' },
	},
	fuzzy = {
		implementation = "lua",
	},
}

local capabilities = blink.get_lsp_capabilities()
-- LSP
vim.lsp.config('clangd', {
	cmd = {
		'/home/cpm/.espressif/tools/esp-clang/esp-19.1.2_20250312/esp-clang/bin/clangd',
		'--background-index',
	},
	capabilities = capabilities,
	root_dir = vim.uv.cwd(),
})

vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
--
-- TOGGLETERM
require("toggleterm").setup()

-- CUSTOM workflow
local wf = require("workflow")
wf.setup()

-- LUALINE
function lualine_themes(color)
	return {
		a = {
			bg = color,
			fg = global_colors.foreground,
			gui = "bold"
		},
		b = { bg = global_colors.bg2 },
		c = { bg = global_colors.background },
		x = { bg = global_colors.background },
		y = { bg = global_colors.color5 },
		z = { bg = global_colors.color6 }
	}
end

vim.opt.showmode = false
vim.opt.shortmess:append("S") -- Désactive le message "search count" natif
vim.opt.cmdheight = 1

require('lualine').setup{
	options = {
		theme = {
			normal = lualine_themes(global_colors.color1),
			insert = lualine_themes(global_colors.color4),
			visual = lualine_themes(global_colors.color3),
			command = lualine_themes(global_colors.color2),
			replace = lualine_themes(global_colors.color5),
			inactive = {
				a = {
					bg = global_colors.bg2,
					fg = global_colors.foreground,
				},
				b = { bg = global_colors.bg2 },
				c = { bg = global_colors.bg2 },
			}
		},
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'filename'},
		lualine_c = { wf.printMode },
		lualine_x = {'diagnostics'},
		lualine_y = {'branch', 'diff'},
		lualine_z = {'location', 'searchcount', 'selectioncount'},
	},
	tabline = {
		lualine_a = {
			{
				'tabs',
				mode = 1,
				fmt = function(name, context)
					if context.tabnr == 1 then
						return "1: Code"
					end
					return tostring(context.tabnr) .. ": Devices"
				end
			}
		},
	},
}



-- DEBUGGER
require("dap-python").setup("python3")

--- CSVVIEW
require('csvview').setup({
  parser = {
    --- The number of lines that the asynchronous parser processes per cycle.
    --- This setting is used to prevent monopolization of the main thread when displaying
	--- large files.
    --- If the UI freezes, try reducing this value.
    --- @type integer
    async_chunksize = 50,

    --- Specifies the delimiter character to separate columns.
    --- This can be configured in one of three ways:
    ---
    --- 1. As a single string for a fixed delimiter.
    ---    e.g., delimiter = ","
    ---
    --- 2. As a function that dynamically returns the delimiter.
    ---    e.g., delimiter = function(bufnr) return "\t" end
    ---
    --- 3. As a table for advanced configuration:
    ---    - `ft`: Maps filetypes to specific delimiters. This has the highest priority.
    ---    - `fallbacks`: An ordered list of delimiters to try for automatic detection
    ---      when no `ft` rule matches. The plugin will test them in sequence and use
    ---      the first one that highest scores based on the number of fields in each line.
    ---
    --- Note: Only fixed-length strings are supported as delimiters.
    --- Regular expressions (e.g., `\s+`) are not currently supported.
    --- @type CsvView.Options.Parser.Delimiter
    delimiter = {
      ft = {
        tsv = "\t",
      },
      fallbacks = {
        ",",
        "\t",
        ";",
        "|",
        ":",
        " ",
      },
    },

    --- The quote character
    --- If a field is enclosed in this character, it is treated as a single field and the delimiter in it will be ignored.
    --- e.g:
    ---  quote_char= "'"
    --- You can also specify it on the command line.
    --- e.g:
    --- :CsvViewEnable quote_char='
    --- @type string
    quote_char = '"',

    --- The comment prefix characters
    --- If the line starts with one of these characters, it is treated as a comment.
    --- Comment lines are not displayed in tabular format.
    --- You can also specify it on the command line.
    --- e.g:
    --- :CsvViewEnable comment=#
    --- @type string[]
    comments = {
      -- "#",
      -- "--",
      -- "//",
    },

    --- The number of lines at the beginning of the file to treat as comments.
    --- Lines from 1 to this number will be treated as comment lines regardless of their content.
    --- This is useful for files that have a fixed header/metadata section at the top.
    --- You can also specify it on the command line.
    --- e.g:
    --- :CsvViewEnable comment_lines=2
    --- @type integer?
    comment_lines = nil,

    --- Maximum lookahead for multi-line fields
    --- This limits how many lines ahead the parser will look when trying to find 
    --- the closing quote of a multi-line field. Setting this too high may cause
    --- performance issues when editing files with unmatched quotes.
    --- @type integer
    max_lookahead = 50,
  },
  view = {
    --- minimum width of a column
    --- @type integer
    min_column_width = 5,

    --- spacing between columns
    --- @type integer
    spacing = 2,

    --- The display method of the delimiter
    --- "highlight" highlights the delimiter
    --- "border" displays the delimiter with `│`
    --- You can also specify it on the command line.
    --- e.g:
    --- :CsvViewEnable display_mode=border
    ---@type CsvView.Options.View.DisplayMode
    display_mode = "border",

    --- The line number of the header row
    --- Controls which line should be treated as the header for the CSV table.
    --- This affects both visual styling and the sticky header feature.
    ---
    --- Values:
    --- - `true`: Automatically detect the header line (default)
    --- - `integer`: Specific line number to use as header (1-based)
    --- - `false`: No header line, treat all lines as data rows
    ---
    --- When a header is defined, it will be:
    --- - Highlighted with the CsvViewHeaderLine highlight group
    --- - Used for the sticky header feature if enabled
    --- - Excluded from normal data processing in some contexts
    ---
    --- See also: `view.sticky_header`
    --- @type integer|false|true
    header_lnum = true,

    --- The sticky header feature settings
    --- If `view.header_lnum` is set, the header line is displayed at the top of the window.
    sticky_header = {
      --- Whether to enable the sticky header feature
      --- @type boolean
      enabled = true,

      --- The separator character for the sticky header window
      --- set `false` to disable the separator
      --- @type string|false
      separator = "─",
    },
  },

  --- Keymaps for csvview.
  --- These mappings are only active when csvview is enabled.
  --- You can assign key mappings to each action defined in `opts.actions`.
  --- For example:
  --- ```lua
  --- keymaps = {
  ---   -- Text objects for selecting fields
  ---   textobject_field_inner = { "if", mode = { "o", "x" } },
  ---   textobject_field_outer = { "af", mode = { "o", "x" } },
  ---
  ---   -- Excel-like navigation:
  ---   -- Use <Tab> and <S-Tab> to move horizontally between fields.
  ---   -- Use <Enter> and <S-Enter> to move vertically between rows.
  ---   -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
  ---   jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
  ---   jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
  ---   jump_next_row = { "<Enter>", mode = { "n", "v" } },
  ---   jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
  ---
  ---   -- Custom key mapping example:
  ---   { "<leader>h", function() print("hello") end, mode = "n" },
  --- }
  --- ```
  --- @type CsvView.Options.Keymaps
  keymaps = {},

  --- Actions for keymaps.
  ---@type CsvView.Options.Actions
  actions = {
    -- See lua/csvview/config.lua
  },
})

-- TOGGLE OVERLENGTH
local overlength = require("toggle-overlength")
overlength.setup({
	column_length = 90,
	ctermbg = "blue",
	guibg = global_colors.color9,
})

overlength.toggle_hi_overlength()

-- ALL CUSTOM KEYMAP --
-- vim.keymap.set({mode}, {lhs}, {rhs}, {opts})
-- lhs is the shortcut and rhs is the key sequence to be applied
-- It can be used to bind shortcut to another shortcut, to write text and so one.
-- Note just to bind function
vim.keymap.set('', 'Y', ':Y<Enter>') -- Open Yazi inside of nvim
vim.keymap.set('', 'ty', ':Telescope lsp_definitions<Enter>') -- Go To definition
vim.keymap.set('', 'tu', ':Telescope find_files<Enter>') -- Fuzzy seach file in projet (cwd) with Telescope
vim.keymap.set('', 'ti', ':Telescope lsp_references<Enter>') -- Get References list with Telescope
vim.keymap.set('', 'to', ':Telescope zoxide list<Enter>') -- Open zoxide list with Telescope
vim.keymap.set('', 'tk', ':Telescope keymaps<Enter>') -- See Keymap list with Telescope
vim.keymap.set('', 'th', ':Telescope live_grep<Enter>') -- Grep in whole cwd file
vim.keymap.set('', 'tj', ':Telescope grep_string<Enter>') -- Grep in file
vim.keymap.set('', 'tl', ':Telescope diagnostics<Enter>') -- See LSP diagnostics

vim.keymap.set('', 'mc', ':CsvViewToggle<Enter>') -- Toggle Csv View

vim.keymap.set('', 'fy', function() vim.diagnostic.open_float() end) -- Open buble with diagnostics at cursor
-- vim.keymap.set('', 'fh', ':SPioSelectEnv<Enter>') -- Select pio environment
-- vim.keymap.set('', 'fj', ':SPioBuild<Enter>') -- Build pio project
-- vim.keymap.set('', 'fk', ':SPioUpload<Enter>') -- Upload pio project

-- ESPIDF-LAZYGIT HANDLING WITH TOGGLETERM
vim.keymap.set('', 'fh', function() wf.execBuildFlash() end)
vim.keymap.set('', 'fj', function() wf.execMonitor() end)
vim.keymap.set('', 'fk', function() wf.execBuildFlashMonitor() end)
vim.keymap.set('', 'fl', function() wf.execFullClean() end)
vim.keymap.set('', 'fp', function() wf.choosePort() end)
vim.keymap.set('', 'fm', function() wf.toggleDualMode() end)

vim.keymap.set('', 'ffh', function() wf.toggleBFM() end)
vim.keymap.set('', 'ffj', function() wf.toggleMC() end)
vim.keymap.set('', 'ffk', function() wf.toggleLG() end)
vim.keymap.set('', 'ffl', function() wf.toggleLG() end)

vim.keymap.set('', '<esc>', function() wf.closeActive(true) end)
-- vim.keymap.set('', '<C-Esc>', function() wf.closeActive(true) end)

vim.keymap.set('', 'fij', function() wf.moveMCVert() end)
vim.keymap.set('', 'fuj', function() wf.moveMCHori() end)
vim.keymap.set('', 'foj', function() wf.moveMCFloat() end)

vim.keymap.set('', 'fil', function() wf.moveLGVert() end)
vim.keymap.set('', 'ful', function() wf.moveLGHori() end)
vim.keymap.set('', 'fol', function() wf.moveLGFloat() end)
vim.keymap.set('', 'fil', function() wf.moveLGVert() end)
vim.keymap.set('', 'fuk', function() wf.moveLGHori() end)
vim.keymap.set('', 'fok', function() wf.moveLGFloat() end)

vim.keymap.set('', 'fih', function() wf.moveBFMVert() end)
vim.keymap.set('', 'fuh', function() wf.moveBFMHori() end)
vim.keymap.set('', 'foh', function() wf.moveBFMFloat() end)

vim.keymap.set('', 'gh', ':DapStepOut<Enter>') -- Debugger step out
vim.keymap.set('', 'gj', ':DapStepOver<Enter>') -- Debugger step over
vim.keymap.set('', 'gk', ':DapRestartFrame<Enter>') -- Debugger restart frame
vim.keymap.set('', 'gl', ':DapStepInto<Enter>') -- Debugger step into
vim.keymap.set('', 'gy', ':DapToggleBreakpoint<Enter>') -- DebuggerToggleBreakPoint
vim.keymap.set('', 'gu', ':DapNew<Enter>') -- Debugger start
vim.keymap.set('', 'gi', ':DapContinue<Enter>') -- Debugger Continue
vim.keymap.set('', 'go', ':DapToggleRepl<Enter>') -- Debugger toggle console
vim.keymap.set('', 'gp', ':DapTerminate<Enter>') -- Debuger terminate
