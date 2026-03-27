local M = {}

local function is_blink_window(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype

  return filetype == "blink-cmp-menu"
    or filetype == "blink-cmp-documentation"
    or filetype == "blink-cmp-signature"
end

function M.close()
  local closed = false

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())) do
    local config = vim.api.nvim_win_get_config(win)

    if config.relative ~= "" and not is_blink_window(win) then
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
