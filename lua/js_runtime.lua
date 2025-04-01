local uv = vim.uv

--- find root directory by look for package.json, deno.json
--- @param file_path string
--- @return string | nil
local function find_config_dir(file_path)
	local function is_root(path)
		local parent = uv.fs_realpath(uv.fs_realpath(path) .. "/..")
		return path == parent
	end

	local function exists(path)
		return uv.fs_stat(path) ~= nil
	end

	local function has_required_files(path)
		return (
			(exists(path .. "/package.json") or exists(path .. "/deno.json"))
			and exists(path .. "/.nvim/js_runtime.lock")
		)
	end

	local dir = uv.fs_realpath(vim.fn.fnamemodify(file_path, ":p:h"))

	while dir do
		if has_required_files(dir) then
			return dir
		end
		if is_root(dir) then
			return nil
		end
		dir = uv.fs_realpath(dir .. "/..")
	end
end

--- @alias Runtime 'node' | 'deno' | 'bun'

--- @class RuntimInfo
--- @field runtime Runtime
--- @field root_dir string

--- @param file_path string
--- @return RuntimInfo | nil
local function read_js_runtime_config(file_path)
	local config_dir = find_config_dir(file_path)

	if config_dir == nil then
		return nil
	end

	local lock_file = config_dir .. "/.nvim/js_runtime.lock"
	if vim.fn.filereadable(lock_file) == 0 then
		return nil
	end

	local runtime = vim.fn.readfile(lock_file)[1]
	if runtime == "node" or runtime == "deno" or runtime == "bun" then
		return {
			runtime = runtime,
			root_dir = config_dir,
		}
	else
		print("Invalid runtime was found in " .. lock_file .. " please set runtime with SetJsRuntime")
		return nil
	end
end

--- @param runtime Runtime
--- @return fun(file_path : string): string | nil
local function create_runtime_function(runtime)
	return function(file_path)
		local runtime_info = read_js_runtime_config(file_path)
		if runtime_info == nil then
			return nil
		end

		if runtime_info.runtime ~= runtime then
			return nil
		end

		return runtime_info.root_dir
	end
end

vim.api.nvim_create_user_command("SetJsRuntime", function()
	local runtime = vim.fn.input({
		prompt = "Set javascript runtime (node, deno, bun): ",
		options = { "node", "deno", "bun" },
	})

	local config_dir = vim.uv.cwd() .. "/.nvim"
	local lock_file = config_dir .. "/js_runtime.lock"

	if vim.fn.isdirectory(config_dir) == 0 then
		vim.fn.mkdir(config_dir)
	end

	vim.fn.writefile({ runtime }, lock_file)
end, {
	desc = "Set javascript runtime",
})

return {
	node_root_dir = create_runtime_function("node"),
	deno_root_dir = create_runtime_function("deno"),
	bun_root_dir = create_runtime_function("bun"),
	js_runtime_config = read_js_runtime_config,
}
