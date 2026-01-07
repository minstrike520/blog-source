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

