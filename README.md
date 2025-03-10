# JavaScript Runtime Configuration Plugin for Neovim

This Neovim plugin allows users to detect and configure JavaScript runtimes (`node`, `deno`, or `bun`) for their projects. It finds the project root directory based on `package.json` or `deno.json` and provides functions to retrieve the correct root directory for each runtime.

## Installation

Use your preferred package manager to install the plugin. For example, with **lazy.nvim**:

```lua
return { "Yuki-bun/nvim_js_runtime_config" }
 -- or dependency of other plugins (eg: lspconfig)
return {
  "neovim/nvim-lspconfig",
  dependencies = { "Yuki-bun/nvim_js_runtime_config" },
  config = function()
  -- ...
  -- ...



```

Or with **packer.nvim**:

```lua
use { "Yuki-bun/nvim_js_runtime_config" }
```

## Features

**Note:** This plugin does not provide any standalone functionality. It needs to be integrated with another plugin (such as `lspconfig`) or Neovim APIs to have any meaningful effect.

**Note:** This plugin requires a `package.json` or `deno.json` file in the project root. Single-file projects without these files are not supported.

- Detects the nearest root directory based on `package.json` or `deno.json`.
- Provides functions to retrieve the root directory for `node`, `deno`, or `bun` based on configuration.
- Command to configure runtime for a project

## Usage

### **Set JavaScript Runtime**

```vim
:SetJsRuntime
```

When you run this command, you will be prompted to select a runtime (`node`, `deno`, or `bun`). The selected runtime will be stored in `.nvim/js_runtime.lock` within the project root. This ensures that the correct runtime is used when configuring LSP servers, linters, and formatters.

### **Configure LSP, Linters, and Formatters based on runtime**

This plugin exports functions that allow you to retrieve the correct root directory for specified runtime if there is one.

Example usage in Neovim LSP configuration:

```lua
local lspconfig = require("lspconfig")

lspconfig.ts_ls.setup({
  root_dir = require("js-runtime").node_root_dir,
  single_file_support = false,
})

lspconfig.denols.setup({
  root_dir = require("js-runtime").deno_root_dir,
  single_file_suppor = false,
})
```

By configuring LSP this way, only the matching language server (`ts_ls` for Node.js projects and `denols` for Deno projects) will attach, ensuring the correct environment is used.



## API Reference

### **`node_root_dir(file_path: string): string | nil`**

Returns the root directory if the project is configured for Node.js.

### **`deno_root_dir(file_path: string): string | nil`**

Returns the root directory if the project is configured for Deno.

### **`bun_root_dir(file_path: string): string | nil`**

Returns the root directory if the project is configured for Bun.

## Contributing

Pull requests and issues are welcome! Feel free to suggest improvements or report bugs.

## License

MIT License

