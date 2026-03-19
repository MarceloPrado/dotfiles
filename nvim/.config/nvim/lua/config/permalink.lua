local M = {}

local function git(cwd, args)
  local command = { "git", "-C", cwd }
  vim.list_extend(command, args)

  local result = vim.system(command, { text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
  end

  return vim.trim(result.stdout)
end

local function parse_remote(remote)
  local host, repo = remote:match("^git@([^:]+):(.+)$")
  if not host then
    host, repo = remote:match("^ssh://git@([^/]+)/(.+)$")
  end
  if not host then
    host, repo = remote:match("^https://([^/]+)/(.+)$")
  end

  if not host or not repo then
    return nil
  end

  repo = repo:gsub("%.git$", "")
  return ("https://%s/%s"):format(host, repo)
end

local function encode_path(path)
  return path:gsub("[^%w%-%._~/]", function(char)
    return string.format("%%%02X", string.byte(char))
  end)
end

local function line_range(visual)
  if not visual then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    return line, line
  end

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line
end

function M.copy(visual)
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.fnamemodify(filepath, ":h")
  local root, root_err = git(cwd, { "rev-parse", "--show-toplevel" })
  if not root then
    vim.notify(root_err, vim.log.levels.ERROR)
    return
  end

  local commit, commit_err = git(root, { "rev-parse", "HEAD" })
  if not commit then
    vim.notify(commit_err, vim.log.levels.ERROR)
    return
  end

  local remote, remote_err = git(root, { "remote", "get-url", "origin" })
  if not remote then
    vim.notify(remote_err, vim.log.levels.ERROR)
    return
  end

  local base_url = parse_remote(remote)
  if not base_url then
    vim.notify("Unsupported git remote: " .. remote, vim.log.levels.ERROR)
    return
  end

  local relative_path = vim.fn.fnamemodify(filepath, ":.")
  if not relative_path:match("^%.%.?/") and not vim.startswith(filepath, root) then
    relative_path = filepath
  else
    relative_path = filepath:sub(#root + 2)
  end

  local start_line, end_line = line_range(visual)
  local fragment = ("#L%d"):format(start_line)
  if start_line ~= end_line then
    fragment = ("%s-L%d"):format(fragment, end_line)
  end

  local url = ("%s/blob/%s/%s%s"):format(base_url, commit, encode_path(relative_path), fragment)
  vim.fn.setreg("+", url)
  vim.fn.setreg('"', url)
  vim.notify("Copied permalink", vim.log.levels.INFO, { title = url })
end

return M
