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
-- Use `<base>...HEAD` (symmetric/merge-base diff) so we see ONLY what this
-- branch added — the true PR diff — even when release/main has advanced past
-- the point we branched off. A plain `<rev>` would also show unrelated commits
-- that landed on the base branch since.
-- `--imply-local` makes diffview put the working-tree file on the right side
-- (because the right rev is HEAD), so LSP still attaches (gd/K/hover/diagnostics)
-- and uncommitted changes show too — the reason we'd previously avoided `...HEAD`.
map("n", "<leader>gb", "<cmd>DiffviewOpen origin/release...HEAD --imply-local<CR>", { desc = "diffview: PR diff vs release" })
map("n", "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD --imply-local<CR>",    { desc = "diffview: PR diff vs main" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>",                            { desc = "diffview: file history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>",                              { desc = "diffview: branch history" })

-- Window resizing (hold the key to keep resizing — auto-repeats)
-- Alt+hjkl: home-row and conflict-free. Avoids Ctrl+arrows (grabbed by macOS
-- Mission Control for switching Spaces) and Ctrl+Shift+letter (needs CSI-u
-- that iTerm2 doesn't send). Requires iTerm2:
--   Settings → Profiles → Keys → General → Left Option key = "Esc+".
map("n", "<M-h>", "<cmd>vertical resize -2<CR>", { desc = "window: decrease width" })
map("n", "<M-l>", "<cmd>vertical resize +2<CR>", { desc = "window: increase width" })
map("n", "<M-j>", "<cmd>resize -2<CR>",          { desc = "window: decrease height" })
map("n", "<M-k>", "<cmd>resize +2<CR>",          { desc = "window: increase height" })

-- Buffer navigation (overrides default H/L screen-line motions)
map("n", "<S-l>", function() require("nvchad.tabufline").next() end, { desc = "buffer: go to next" })
map("n", "<S-h>", function() require("nvchad.tabufline").prev() end, { desc = "buffer: go to previous" })
map("n", "<leader>bd", function() require("nvchad.tabufline").close_buffer() end, { desc = "buffer: delete/close" })

-- Tab navigation
map("n", "<leader>tn", "<cmd>tabnext<CR>",                                          { desc = "tab: next" })
map("n", "<leader>tp", "<cmd>tabprevious<CR>",                                      { desc = "tab: previous" })
map("n", "<leader>tc", "<cmd>tabclose<CR>",                                         { desc = "tab: close" })
map("n", "<leader>tN", "<cmd>tabnew<CR>",                                           { desc = "tab: new" })
map("n", "<leader>to", "<cmd>tabonly<CR>",                                          { desc = "tab: close all others" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
