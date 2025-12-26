-- ~/.config/nvim/lua/plugins/zettelkasten.lua
return {
  -- Lazy.nvim plugin specification
  config = function()
    -- Function to create a new Zettelkasten note with timestamp
    local function create_zettelkasten_note()
      local timestamp = os.date('%Y-%m-%d-%H%M%S')
      local title = vim.fn.input('Enter note title: ')
      local zk_dir = os.getenv('HOME') .. '/zettelkasten'
      local filename = zk_dir .. '/active/notes/' .. timestamp .. '-' .. title:gsub(' ', '_') .. '.md'

      -- Create directory if needed
      vim.fn.mkdir(vim.fn.fnamemodify(filename, ':h'), 'p')

      -- Create and edit the file
      vim.cmd('edit ' .. filename)

      -- Insert template if available
      local template = zk_dir .. '/templates/note_template.md'
      if vim.fn.filereadable(template) == 1 then
        local lines = vim.fn.readfile(template)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      end

      vim.cmd('ZenMode')
    end

    -- Function to create topic notes
    local function create_topic_note()
      local title = vim.fn.input('Enter topic title: ')
      local filename = os.getenv('HOME') .. '/zettelkasten/active/topics/' .. title:gsub(' ', '_') .. '.md'
      vim.fn.mkdir(vim.fn.fnamemodify(filename, ':h'), 'p')
      vim.cmd('edit ' .. filename)
      vim.cmd('ZenMode')
    end

    -- Function to archive notes
    local function archive_note()
      local current_file = vim.fn.expand('%:p')
      if current_file == '' then return end

      local year = os.date('%Y')
      local archive_path = os.getenv('HOME') .. '/zettelkasten/archive/' .. year
      vim.fn.mkdir(archive_path, 'p')

      local new_path = archive_path .. '/' .. vim.fn.fnamemodify(current_file, ':t')
      os.rename(current_file, new_path)
      vim.cmd('bd')
      vim.notify('Archived to: ' .. new_path, vim.log.levels.INFO)
    end

    -- Create commands
    vim.api.nvim_create_user_command('ZkNewNote', create_zettelkasten_note, {})
    vim.api.nvim_create_user_command('ZkNewTopic', create_topic_note, {})
    vim.api.nvim_create_user_command('ZkArchiveNote', archive_note, {})

    -- Set keymaps
    vim.keymap.set('n', '<leader>zn', '<cmd>ZkNewNote<cr>', { desc = 'New Zettel Note' })
    vim.keymap.set('n', '<leader>zt', '<cmd>ZkNewTopic<cr>', { desc = 'New Topic Note' })
    vim.keymap.set('n', '<leader>za', '<cmd>ZkArchiveNote<cr>', { desc = 'Archive Note' })
  end
}
