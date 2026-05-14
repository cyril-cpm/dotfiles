	vim.cmd("highlight clear")

	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	vim.g.colors_name = "solarpunk"

	local function hl(group, options)
		vim.api.nvim_set_hl(0, group, options)
	end

	-- Fenêtre et base
	hl("Normal",           { fg = "{foreground}", bg = "NONE" })
	hl("NormalFloat",      { fg = "{foreground}", bg = "{gray_light}" }) -- Fenêtres flottantes (LSP)
	hl("FloatBorder",      { fg = "{color4}" })
	hl("ColorColumn",      { bg = "{gray_light}" })
	hl("Cursor",           { fg = "{background}", bg = "{cursor}" })
	hl("CursorLine",       { bg = "{bg1}" })
	hl("CursorColumn",     { bg = "{gray_light}" })

	-- Bordures et Séparateurs
	hl("VertSplit",        { fg = "{gray_light}" })
	hl("WinSeparator",     { fg = "{gray_light}" })

	-- Menus et Listes
	hl("Pmenu",            { fg = "{foreground}", bg = "{gray_light}" })
	hl("PmenuSel",         { fg = "{background}", bg = "{color4}", bold = true })
	hl("PmenuSbar",        { bg = "{gray_light}" })
	hl("PmenuThumb",       { bg = "{color8}" })
	hl("Question",         { fg = "{color4}" })
	hl("QuickFixLine",     { bg = "{blue_light}" })

	-- Recherches et Sélection
	hl("Visual",           { bg = "{bg1}" })
	hl("Search",           { fg = "{background}", bg = "{color3}", bold = true })
	hl("IncSearch",        { fg = "{background}", bg = "{color1}" })
	hl("CurSearch",        { fg = "{background}", bg = "{color1}" })

	-- Messages et État
	hl("StatusLine",       { fg = "{foreground}", bg = "{green_light}" })
	hl("StatusLineNC",     { fg = "{color8}", bg = "{gray_light}" }) -- Fenêtre inactive
	hl("WildMenu",         { fg = "{background}", bg = "{color4}" })
	hl("ErrorMsg",         { fg = "{color1}", bold = true })
	hl("WarningMsg",       { fg = "{color3}", bold = true })
	hl("MoreMsg",          { fg = "{color4}", bold = true })


	-- Numéros et Gouttière (Gutter)
	hl("LineNr",           { fg = "{color8}" })
	hl("CursorLineNr",     { fg = "{color2}", bold = true })
	hl("SignColumn",       {{ bg = "NONE" }})
	hl("Folded",           { fg = "{color8}", bg = "{gray_light}" })
	hl("FoldColumn",       { fg = "{color8}" })

	hl("Comment",          { fg = "{color8}", italic = true })
	hl("Constant",         { fg = "{color14}" })
	hl("String",           { fg = "{color2}" })
	hl("Character",        { fg = "{color2}" })
	hl("Number",           { fg = "{color11}" })
	hl("Boolean",          { fg = "{color14}", bold = true })
	hl("Float",            { fg = "{color11}" })

	hl("Identifier",       { fg = "{foreground}" })
	hl("Function",         { fg = "{color12}", bold = true })
	hl("Statement",        { fg = "{color5}", bold = true })
	hl("Conditional",      { fg = "{color5}" })
	hl("Repeat",           { fg = "{color5}" })
	hl("Label",            { fg = "{color5}" })
	hl("Operator",         { fg = "{color15}" })
	hl("Keyword",          { fg = "{color5}", bold = true })
	hl("Exception",        { fg = "{color1}" })

	hl("PreProc",          { fg = "{color1}" })
	hl("Include",          { fg = "{color1}" })
	hl("Define",           { fg = "{color1}" })
	hl("Macro",            { fg = "{color1}" })
	hl("PreCondit",        { fg = "{color1}" })

	hl("Type",             { fg = "{color6}", bold = true })
	hl("StorageClass",     { fg = "{color3}" })
	hl("Structure",        { fg = "{color6}" })
	hl("Typedef",          { fg = "{color0}" })

	hl("Special",          { fg = "{color1}", bold = true })
	hl("SpecialChar",      { fg = "{color1}", bold = true })
	hl("Tag",              { fg = "{color3}" })
	hl("Delimiter",        { fg = "{color15}" })
	hl("Debug",            { fg = "{color1}" })

	hl("Underlined",       {{ underline = true }})
	hl("Bold",             {{ bold = true }})
	hl("Italic",           {{ italic = true }})
	hl("Ignore",           { fg = "{color8}" })
	hl("Error",            { fg = "{color1}", reverse = true })
	hl("Todo",             { fg = "{background}", bg = "{color3}", bold = true })

	hl("@variable",            { fg = "{foreground}" })
	hl("@variable.builtin",    { fg = "{magenta_light}", italic = true })
	hl("@variable.parameter",  { fg = "{foreground}", italic = true })
	hl("@field",               { fg = "{color6}" })
	hl("@property",            { fg = "{color6}" })
	hl("@constructor",         { fg = "{color6}", bold = true })

	hl("@method",              { fg = "{color4}", italic = true })
	hl("@method.call",         { fg = "{color4}" })
	hl("@function.builtin",    { fg = "{color4}", bold = true })
	hl("@function.macro",      { fg = "{color1}", bold = true })

	hl("@keyword.import",      { fg = "{color1}", bold = true }) -- #include
	hl("@keyword.operator",    { fg = "{color5}" })
	hl("@keyword.return",      { fg = "{color5}", bold = true })

	hl("@type.builtin",        { fg = "{color6}", bold = true })
	hl("@type.qualifier",      { fg = "{color5}" }) -- const, static

	hl("@punctuation.bracket", { fg = "{color15}" })
	hl("@punctuation.delimiter",{ fg = "{color15}" })

	-- Python
	hl("@attribute.python",    { fg = "{yellow_light}" }) -- Décorateurs

	-- Markup (Markdown)
	hl("@text.title",          { fg = "{color4}", bold = true })
	hl("@text.uri",            { fg = "{color6}", underline = true })
	hl("@text.reference",      { fg = "{color2}" })
	hl("@text.strong",         {{ bold = true }})
	hl("@text.emphasis",       {{ italic = true }})

	-- Diagnostic Signaux
	hl("DiagnosticError",      { fg = "{color1}" })
	hl("DiagnosticWarn",       { fg = "{color3}" })
	hl("DiagnosticInfo",       { fg = "{color4}" })
	hl("DiagnosticHint",       { fg = "{color14}" })

	-- Texte souligné (Underline)
	hl("DiagnosticUnderlineError", { undercurl = true, sp = "{color1}" })
	hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = "{color3}" })
	hl("DiagnosticUnderlineInfo",  { undercurl = true, sp = "{color4}" })
	hl("DiagnosticUnderlineHint",  { undercurl = true, sp = "{color14}" })

	-- LSP
	hl("LspReferenceText",     { bg = "{gray_light}" })
	hl("LspReferenceRead",     { bg = "{gray_light}" })
	hl("LspReferenceWrite",    { bg = "{gray_light}" })

	hl("DiffAdd",              { fg = "{color2}", bg = "{green_light}" })
	hl("DiffChange",           { fg = "{color3}", bg = "{yellow_light}" })
	hl("DiffDelete",           { fg = "{color1}", bg = "{red_light}" })
	hl("DiffText",             { fg = "{background}", bg = "{color4}" })

	hl("SignColumnSB",         {{ bg = "NONE" }})
	hl("GitSignsAdd",          { fg = "{color2}" })
	hl("GitSignsChange",       { fg = "{color3}" })
	hl("GitSignsDelete",       { fg = "{color1}" })
