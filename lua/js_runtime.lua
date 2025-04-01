--- find root directory by look for package.json, deno.json
--- @param file_path string
--- @return string | nil
local function find_root_dir(file_path)
	return vim.fs.root(file_path, { "package.json", "deno.json" })
end

--- @alias Runtime 'node' | 'deno' | 'bun'

--- @class RuntimInfo
--- @field runtime Runtime
--- @field root_dir string

--- @param file_path string
--- @return RuntimInfo | nil
local function read_js_runtime_config(file_path)
	local root_dir = find_root_dir(file_path)

	if root_dir == nil then
		return nil
	end

	local lock_file = root_dir .. "/.nvim/js_runtime.lock"
	if vim.fn.filereadable(lock_file) == 0 then
		return nil
	end

	local runtime = vim.fn.readfile(lock_file)[1]
	if runtime == "node" or runtime == "deno" or runtime == "bun" then
		return {
			runtime = runtime,
			root_dir = root_dir,
		}
	else
		print("Invalid runtime was found in " .. lock_file .. " please set runtime with SetJsRuntime")
		return nil
	end
end

--- @param file_path string
--- @param runtime Runtime
local function write_js_runtime_config(file_path, runtime)
	local root_dir = find_root_dir(file_path)
	if root_dir == nil then
		print("Javascript root pattern was not found")
	end

	local config_dir = root_dir .. "/.nvim"
	local lock_file = root_dir .. "/.nvim/js_runtime.lock"

	if vim.fn.isdirectory(config_dir) == 0 then
		vim.fn.mkdir(config_dir)
	end

	vim.fn.writefile({ runtime }, lock_file)
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
	local current_file = vim.fn.expand("%:p")
	if find_root_dir(current_file) == nil then
		error("Javascript root pattern was not found")
	end

	local runtime = vim.fn.input({
		prompt = "Set javascript runtime (node, deno, bun): ",
		options = { "node", "deno", "bun" },
	})

	write_js_runtime_config(current_file, runtime)
end, {
	desc = "Set javascript runtime",
})

return {
	node_root_dir = create_runtime_function("node"),
	deno_root_dir = create_runtime_function("deno"),
	bun_root_dir = create_runtime_function("bun"),
	js_runtime_config = read_js_runtime_config,
}
