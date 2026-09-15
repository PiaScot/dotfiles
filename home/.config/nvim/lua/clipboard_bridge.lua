-- Talks to windows-host/clipboard-bridge.ps1 over a TCP socket forwarded
-- from the Windows host via `ssh -R` (see ~/.ssh/config on the Windows
-- side). Used only for paste ("+p / plain p with clipboard=unnamedplus);
-- copy keeps using OSC52, which already works.
--
-- Design + rationale: docs/clipboard-bridge-design.md
--
-- This module is only ever required from plugin/option.lua's SSH-only
-- branch, so it doesn't need to re-check "are we over SSH" itself -- but
-- it fails safely (timeout + warning, never a hang) if the bridge isn't
-- reachable for any reason (Windows listener not running, tunnel not
-- forwarded, wrong port, etc).
local M = {}

local HOST = "127.0.0.1"
local PORT = 52599
local TIMEOUT_MS = 1500

-- LuaJIT (Neovim's Lua) has no string.pack/unpack -- confirmed on god77
-- (`attempt to call field 'pack' (a nil value)`), so uint32 LE is by hand.
local function pack_u32le(n)
	return string.char(
		n % 256,
		math.floor(n / 256) % 256,
		math.floor(n / 65536) % 256,
		math.floor(n / 16777216) % 256
	)
end

local function unpack_u32le(s, i)
	i = i or 1
	local b1, b2, b3, b4 = s:byte(i, i + 3)
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

--- @param cmd string  "P" or "C"
--- @param payload string|nil  body to send, only used for "C"
--- @param want_reply boolean  whether to wait for a <len><body> reply
--- @return string|nil  reply body, or nil on failure/timeout
local function request(cmd, payload, want_reply)
	local result = nil
	local finished = false

	local client = vim.uv.new_tcp()
	local function finish()
		finished = true
		pcall(function()
			client:close()
		end)
	end

	local ok = client:connect(HOST, PORT, function(err)
		if err then
			finish()
			return
		end

		local out = cmd
		if payload then
			out = out .. pack_u32le(#payload) .. payload
		end
		client:write(out)

		if not want_reply then
			finish()
			return
		end

		local buf = ""
		client:read_start(function(err2, chunk)
			if err2 or not chunk then
				finish()
				return
			end
			buf = buf .. chunk
			if #buf >= 4 then
				local len = unpack_u32le(buf)
				if #buf >= 4 + len then
					result = buf:sub(5, 4 + len)
					finish()
				end
			end
		end)
	end)
	if not ok then
		finish()
	end

	vim.wait(TIMEOUT_MS, function()
		return finished
	end)
	if not finished then
		finish()
	end

	return result
end

--- vim.g.clipboard.copy target -- defined for symmetry / future use, not
--- currently wired up in option.lua (OSC52 copy already works fine).
function M.copy(lines)
	request("C", table.concat(lines, "\n"), false)
end

--- vim.g.clipboard.paste target
function M.paste()
	local text = request("P", nil, true)
	if not text then
		vim.notify(
			"clipboard-bridge: Windows側に届きませんでした。"
				.. "clipboard-bridge.ps1 が起動しているか、"
				.. "ssh -R のトンネルが張られているか確認してください。",
			vim.log.levels.WARN
		)
		return 0
	end
	if text == "" then
		return 0
	end
	return vim.split(text, "\n")
end

return M
