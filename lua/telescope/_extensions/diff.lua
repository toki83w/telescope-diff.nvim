local action_state = require("telescope.actions.state")
local action_utils = require("telescope.actions.utils")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

local function create_diff_view(paths)
    vim.cmd.tabnew(paths[1])

    for idx = 2, #paths do
        vim.cmd("vertical diffsplit " .. paths[idx])
    end

    vim.cmd.normal({ args = { "gg" }, bang = true })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

local function diff_files(opts)
    opts = opts or {}

    local local_opts = {
        prompt_title = "Pick the files to compare",
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                local has_multi_selection = (next(current_picker:get_multi_selection()) ~= nil)
                local paths = opts._add_current and { vim.fn.expand(vim.api.nvim_buf_get_name(opts.bufnr)) } or {}

                if has_multi_selection then
                    action_utils.map_selections(prompt_bufnr, function(entry, _)
                        table.insert(paths, entry.path)
                    end)
                else
                    table.insert(paths, action_state.get_selected_entry().path)
                end

                if #paths < 2 then
                    vim.notify("Not enough files to compare", vim.log.levels.WARN)
                    return
                end

                actions.close(prompt_bufnr)

                create_diff_view(paths)
            end)

            return true
        end,
    }

    opts = vim.tbl_extend("force", opts, local_opts)
    builtin.find_files(opts)
end

local function diff_current(opts)
    opts = opts or {}
    opts._add_current = true
    diff_files(opts)
end

return require("telescope").register_extension({
    exports = {
        diff_files = diff_files,
        diff_current = diff_current,
    },
})
