local M = {
  applied_background = nil,
  timer = nil,
}

local function apply(background)
  if M.applied_background == background and vim.g.colors_name == "catppuccin" then
    return
  end

  vim.o.background = background
  vim.cmd.colorscheme("catppuccin")
  M.applied_background = background
end

local function detect_background()
  if vim.uv.os_uname().sysname ~= "Darwin" then
    return vim.o.background == "light" and "light" or "dark"
  end

  local output = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error == 0 and output:match("Dark") then
    return "dark"
  end

  return "light"
end

local function sync_from_system()
  apply(detect_background())
end

function M.setup()
  local group = vim.api.nvim_create_augroup("dotfiles-theme", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "VimResume" }, {
    group = group,
    callback = sync_from_system,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if not M.timer then
        return
      end

      M.timer:stop()
      M.timer:close()
      M.timer = nil
    end,
  })

  M.timer = vim.uv.new_timer()
  M.timer:start(3000, 3000, vim.schedule_wrap(sync_from_system))

  sync_from_system()
end

return M
