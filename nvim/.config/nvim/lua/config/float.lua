local M = {}

function M.close()
  local closed = false

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())) do
    local config = vim.api.nvim_win_get_config(win)

    if config.relative ~= "" then
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

  vim.lsp.buf.hover()
end

return M
