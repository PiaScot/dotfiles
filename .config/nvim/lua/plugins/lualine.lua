return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")

    -- Color table for highlights
    -- stylua: ignore
    local colors = {
      bg       = '#202328',
      fg       = '#bbc2cf',
      yellow   = '#ECBE7B',
      cyan     = '#008080',
      darkblue = '#081633',
      green    = '#98be65',
      orange   = '#FF8800',
      violet   = '#a9a1e1',
      magenta  = '#c678dd',
      blue     = '#51afef',
      red      = '#ec5f67',
    }

		local conditions = {
			buffer_not_empty = function()
				return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
			end,
			hide_in_width = function()
				return vim.fn.winwidth(0) > 80
			end,
			check_git_workspace = function()
				local filepath = vim.fn.expand("%:p:h")
				local gitdir = vim.fn.finddir(".git", filepath .. ";")
				return gitdir and #gitdir > 0 and #gitdir < #filepath
			end,
		}

		-- Config
		local config = {
			options = {
				component_separators = "",
				section_separators = "",
				-- NvimTree の場合に背景のみ表示させたい場合、テーマ設定が重要になります
				-- 以下のテーマ設定例を参考に、背景色を指定できます
				theme = {
					normal = { c = { fg = colors.fg, bg = colors.bg } }, -- lualine_c セクションのデフォルト
					inactive = { c = { fg = colors.fg, bg = colors.bg } },
					-- 必要に応じて他のセクション (a, b, x, y, z) の normal/inactive 時の背景も設定
				},
				-- disabled_filetypes = {
				--   statusline = { 'NvimTree' },
				--   winbar = {},
				-- },
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_y = {},
				lualine_z = {},
				lualine_c = {},
				lualine_x = {},
			},
		}

		local function is_nvim_tree_active()
			return vim.bo.filetype == "NvimTree"
		end

		-- 既存の条件とNvimTreeでないという条件を組み合わせる関数
		local function combine_conditions(original_cond_fn)
			if original_cond_fn == nil then
				return not is_nvim_tree_active()
			end
			-- 元の条件がtrueの場合のみ、NvimTreeでないかのチェックも行う
			return original_cond_fn() and (not is_nvim_tree_active())
		end

		-- コンポーネントを lualine_c (左側) に追加する修正版ヘルパー関数
		local function ins_left(component_definition)
			local comp = type(component_definition) == "string" and { component_definition } or component_definition

			-- 元のcondを保持し、新しいcondでラップする
			local original_cond = comp.cond
			comp.cond = function()
				-- NvimTreeのバッファではコンポーネントを表示しない
				if is_nvim_tree_active() then
					return false
				end
				-- 元のcondがあればそれを評価、なければtrue (表示)
				if original_cond == nil then
					return true
				elseif type(original_cond) == "function" then
					return original_cond()
				else -- boolean の場合
					return original_cond
				end
			end
			table.insert(config.sections.lualine_c, comp)
		end

		-- コンポーネントを lualine_x (右側) に追加する修正版ヘルパー関数
		local function ins_right(component_definition)
			local comp = type(component_definition) == "string" and { component_definition } or component_definition

			local original_cond = comp.cond
			comp.cond = function()
				if is_nvim_tree_active() then
					return false
				end
				if original_cond == nil then
					return true
				elseif type(original_cond) == "function" then
					return original_cond()
				else
					return original_cond
				end
			end
			table.insert(config.sections.lualine_x, comp)
		end

		-- 以下、既存のコンポーネント追加処理 (ins_left と ins_right を使用)
		-- これらの呼び出しは変更不要です。修正された ins_left/ins_right が自動で条件を付加します。

		ins_left({
			function()
				return "▊"
			end,
			color = { fg = colors.blue },
			padding = { left = 0, right = 1 },
		})

		ins_left({
			function()
				return ""
			end,
			color = function()
				local mode_color = {
					n = colors.red,
					i = colors.green,
					v = colors.blue,
					[""] = colors.blue,
					V = colors.blue,
					c = colors.magenta,
					no = colors.red,
					s = colors.orange,
					S = colors.orange,
					[""] = colors.orange,
					ic = colors.yellow,
					R = colors.violet,
					Rv = colors.violet,
					cv = colors.red,
					ce = colors.red,
					r = colors.cyan,
					rm = colors.cyan,
					["r?"] = colors.cyan,
					["!"] = colors.red,
					t = colors.red,
				}
				return { fg = mode_color[vim.fn.mode()] }
			end,
			padding = { right = 1 },
		})

		ins_left({
			"filesize",
			cond = conditions.buffer_not_empty, -- この既存のcondも考慮されます
		})

		ins_left({
			"filename",
			cond = conditions.buffer_not_empty, -- この既存のcondも考慮されます
			color = { fg = colors.magenta, gui = "bold" },
		})

		ins_left({ "location" })

		ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

		ins_left({
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = { error = " ", warn = " ", info = " " },
			diagnostics_color = {
				error = { fg = colors.red },
				warn = { fg = colors.yellow },
				info = { fg = colors.cyan },
			},
		})

		ins_left({
			function()
				return "%="
			end,
		})

		ins_left({
			function()
				local msg = "No Active Lsp"
				local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
				local clients = vim.lsp.get_clients()
				if next(clients) == nil then
					return msg
				end
				for _, client in ipairs(clients) do
					local filetypes = client.config.filetypes
					if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
						return client.name
					end
				end
				return msg
			end,
			icon = "  LSP:",
			color = { fg = "#ffffff", gui = "bold" },
		})

		ins_left({
			function()
				local linters = require("lint").get_running() -- lint.nvimを想定
				if not linters or #linters == 0 then -- nilチェックを追加
					return "󰦕"
				end
				return "󱉶 " .. table.concat(linters, ", ")
			end,
		})

		ins_right({
			function()
				local icon = "🕒"
				local time = os.date("%H:%M")
				return icon .. " " .. time
			end,
			color = { fg = colors.cyan, gui = "bold" },
			padding = { left = 1, right = 1 },
		})

		ins_right({
			"o:encoding",
			fmt = string.upper,
			cond = conditions.hide_in_width, -- この既存のcondも考慮されます
			color = { fg = colors.green, gui = "bold" },
		})

		ins_right({
			"fileformat",
			fmt = string.upper,
			icons_enabled = false,
			color = { fg = colors.green, gui = "bold" },
		})

		ins_right({
			"branch",
			icon = "",
			color = { fg = colors.violet, gui = "bold" },
		})

		ins_right({
			"diff",
			symbols = { added = " ", modified = "󰝤 ", removed = " " },
			diff_color = {
				added = { fg = colors.green },
				modified = { fg = colors.orange },
				removed = { fg = colors.red },
			},
			cond = conditions.hide_in_width, -- この既存のcondも考慮されます
		})

		ins_right({
			function()
				return "▊"
			end,
			color = { fg = colors.blue },
			padding = { left = 1 },
		})

		lualine.setup(config)
	end,
}
