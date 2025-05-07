local M = {}
function M.execute_command(cmd)
  local handle = io.popen(cmd .. ' 2>&1', 'r')
  if not handle then
    return false, 'Failed to execute command'
  end
  local output = handle:read '*a'
  local success = handle:close()
  return success, output
end

-- Default configuration
local default_config = {
  m4_path = vim.fn.expand '$HOME/texmf/circuit_macros',
  default_color = 'black',
  default_density = 300,
  default_transparent = 'white',
  keep_pdf = false,
  make_png = false,
  auto_open = true,
}

-- Merge user config with defaults
M.config = vim.tbl_deep_extend('force', default_config, M.config or {})

-- Main function to compile M4 to PNG
function M.compile_m4_to_png()
  local bufname = vim.api.nvim_buf_get_name(0)
  if not bufname:match '%.m4$' then
    vim.notify('Current buffer is not an M4 file', vim.log.levels.ERROR)
    return
  end

  local input_file = vim.fn.expand '%:p'
  local output_base = vim.fn.expand '%:p:r'
  local output_pdf = output_base .. '.pdf'
  local output_png = output_base .. '.png'

  -- Create temporary directory
  local tmp_dir = vim.fn.tempname()
  vim.fn.mkdir(tmp_dir, 'p')
  local tmp_tex = tmp_dir .. '/picture.tex'

  -- Generate LaTeX document
  local latex_content = string.format(
    [[
\documentclass[11pt]{article}
\usepackage{tikz}
\usepackage{xcolor}
\usetikzlibrary{external}
\tikzexternalize
\pagestyle{empty}
\begin{document}
\color{%s}
]],
    'black'
  )

  -- Process with m4 and dpic
  local m4_cmd = string.format('m4 -I%s pgf.m4 libcct.m4 %s', M.config.m4_path, input_file)
  local dpic_cmd = 'dpic -g'

  local success, m4_output = M.execute_command(m4_cmd .. ' | ' .. dpic_cmd)
  if not success then
    vim.notify('Failed to process M4 file: ' .. m4_output, vim.log.levels.ERROR)
    return
  end

  latex_content = latex_content .. m4_output .. [[
\end{document}
]]

  -- Write LaTeX file
  local file = io.open(tmp_tex, 'w')
  if not file then
    vim.notify('Failed to create temporary LaTeX file', vim.log.levels.ERROR)
    return
  end
  file:write(latex_content)
  file:close()

  -- Compile LaTeX
  local latex_cmd = string.format('cd %s && pdflatex -shell-escape -interaction=nonstopmode picture.tex', tmp_dir)
  success, _ = M.execute_command(latex_cmd)
  if not success then
    vim.notify('LaTeX compilation failed', vim.log.levels.ERROR)
    return
  end

  -- Copy PDF output
  local tmp_pdf = tmp_dir .. '/picture-figure0.pdf'
  if vim.fn.filereadable(tmp_pdf) == 1 then
    os.execute(string.format('cp %s %s', tmp_pdf, output_pdf))
  else
    vim.notify('Expected output PDF not found', vim.log.levels.WARN)
  end

  -- Convert to PNG
  if M.config.make_png then
    local magick_cmd = string.format('magick -density %s %s -transparent %s %s', 300, output_pdf, 'white', output_png)
    success, _ = M.execute_command(magick_cmd)
    if not success then
      vim.notify('ImageMagick conversion failed', vim.log.levels.ERROR)
      return
    end
  end
  -- Clean up
  if not M.config.keep_pdf then
    os.remove(output_pdf)
  end
  os.execute(string.format('rm -rf %s', tmp_dir))

  vim.notify(string.format('Successfully generated: %s', output_png), vim.log.levels.INFO)

  -- Auto-open the image if configured
  if M.config.auto_open then
    vim.fn.system(string.format('xdg-open %s &', output_png))
  end
end

-- Setup function
function M.setup(config)
  M.config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Create a command for easy access
  vim.api.nvim_create_user_command('Mkcircuit', M.compile_m4_to_png, {
    desc = 'Compile M4 file to PNG using circuit macros',
  })
end

return M
