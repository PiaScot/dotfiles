local map = require('config.utils').map

local silent = { silent = true }
-- Navigate buffers and repos
map('n', '\\b', [[<cmd>Telescope buffers show_all_buffers=true theme=get_dropdown<cr>]], silent)
map('n', '\\f', [[<cmd>Telescope frecency theme=get_dropdown<cr>]], silent)
map('n', '\\g', [[<cmd>Telescope git_files theme=get_dropdown<cr>]], silent)
map('n', '\\s', [[<cmd>Telescope find_files theme=get_dropdown<cr>]], silent)
map('n', '\\r', [[<cmd>Telescope live_grep theme=get_dropdown<cr>]], silent)
