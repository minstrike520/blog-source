---
title: "[Notes] Vim Tricks"
date: 2026-01-08 08:44
categories:
  - IT筆記
tags:
---
- Set Indent Width: `:set shiftwidth=4`.
- Use Spaces instead of Tabs: `:set expandtab`.

```vim
" Basic auto-closing for brackets and quotes
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

" Optional: Auto-indent when pressing Enter inside {}
inoremap {<CR> {<CR>}<Esc>O
```

---

[參考](https://www.reddit.com/r/neovim/comments/vg1oli/env_file_not_shown_by_nvim_tree/)

在 Nvimtree 按 `H` 會循環 dotfile 顯示，按 `I` 會循環被 Gitignore 的顯示。