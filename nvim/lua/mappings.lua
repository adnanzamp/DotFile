require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle & focus" })

-- Tmux/Vim seamless navigation (overrides NvChad's <C-hjkl> window-only maps)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { desc = "tmux/vim: navigate left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { desc = "tmux/vim: navigate down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { desc = "tmux/vim: navigate up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "tmux/vim: navigate right" })

-- Octo (GitHub PR review)
map("n", "<leader>op", "<cmd>Octo pr list<CR>",                                     { desc = "octo: list PRs" })
map("n", "<leader>or", "<cmd>Octo pr search is:open review-requested:@me<CR>",      { desc = "octo: PRs awaiting my review" })
map("n", "<leader>om", "<cmd>Octo pr search is:open author:@me<CR>",                { desc = "octo: my open PRs" })
map("n", "<leader>oc", "<cmd>Octo pr checkout<CR>",                                 { desc = "octo: checkout current PR" })
map("n", "<leader>ob", "<cmd>Octo pr browser<CR>",                                  { desc = "octo: open PR in browser" })
map("n", "<leader>os", "<cmd>Octo review start<CR>",                                { desc = "octo: start review" })
map("n", "<leader>oS", "<cmd>Octo review submit<CR>",                               { desc = "octo: submit review" })
map("n", "<leader>oR", "<cmd>Octo review resume<CR>",                               { desc = "octo: resume pending review" })
map("n", "<leader>oa", "<cmd>Octo comment add<CR>",                                 { desc = "octo: add comment" })
map("n", "<leader>ot", "<cmd>Octo thread resolve<CR>",                              { desc = "octo: resolve thread" })
map("n", "<leader>oT", "<cmd>Octo thread unresolve<CR>",                            { desc = "octo: unresolve thread" })
map("n", "<leader>oi", "<cmd>Octo issue list<CR>",                                  { desc = "octo: list issues" })

-- Diffview
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>",                                     { desc = "diffview: open" })
map("n", "<leader>gD", "<cmd>DiffviewClose<CR>",                                    { desc = "diffview: close" })
map("n", "<leader>gb", "<cmd>DiffviewOpen origin/main...HEAD<CR>",                  { desc = "diffview: branch vs main" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",                            { desc = "diffview: file history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>",                              { desc = "diffview: branch history" })

-- Tab navigation
map("n", "<leader>tn", "<cmd>tabnext<CR>",                                          { desc = "tab: next" })
map("n", "<leader>tp", "<cmd>tabprevious<CR>",                                      { desc = "tab: previous" })
map("n", "<leader>tc", "<cmd>tabclose<CR>",                                         { desc = "tab: close" })
map("n", "<leader>tN", "<cmd>tabnew<CR>",                                           { desc = "tab: new" })
map("n", "<leader>to", "<cmd>tabonly<CR>",                                          { desc = "tab: close all others" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
