local M = {}

local function is_protected_window(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype

  return filetype == "blink-cmp-menu"
    or filetype == "blink-cmp-documentation"
    or filetype == "blink-cmp-signature"
    or filetype:match("^snacks_picker") ~= nil
end

function M.close()
  local closed = false

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())) do
    local config = vim.api.nvim_win_get_config(win)

    if config.relative ~= "" and not is_protected_window(win) then
      local ok = pcall(vim.api.nvim_win_close, win, true)
      closed = ok or closed
    end
  end

  return closed
end

function M.toggle_lsp_hover()
  if M.close() then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })
  local severity_label = {
    [vim.diagnostic.severity.ERROR] = "✘ error",
    [vim.diagnostic.severity.WARN] = "⚠ warning",
    [vim.diagnostic.severity.INFO] = "ℹ info",
    [vim.diagnostic.severity.HINT] = "○ hint",
  }

  local params = vim.lsp.util.make_position_params(0, "utf-16")
  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
    local lines = {}

    for _, d in ipairs(diagnostics) do
      local label = severity_label[d.severity] or "info"
      local source = d.source and (" (" .. d.source .. ")") or ""
      table.insert(lines, ("%s%s: %s"):format(label, source, d.message))
    end

    if result and result.contents then
      local hover_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      hover_lines = vim.lsp.util.trim_empty_lines(hover_lines)
      if #hover_lines > 0 then
        if #lines > 0 then
          table.insert(lines, "")
          table.insert(lines, "---")
          table.insert(lines, "")
        end
        vim.list_extend(lines, hover_lines)
      end
    end

    if #lines == 0 then
      return
    end

    vim.lsp.util.open_floating_preview(lines, "markdown", {
      border = "rounded",
      focusable = true,
      focus_id = "lsp-hover",
    })
  end)
end

return M
