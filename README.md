This is highly a personal plugin.

## install

``` python
import this
```

Install with plug.

``` vim
Plug 'waylonwalker/mdformat.nvim'
```

## init

Require it in your `init.vim` to use it.

``` vim
lua require'mdformat'
```

## Install TreeSitter grammer

``` vim
:TSInstall markdown

" alternatively install all of them
:TSInstall all
```

## Debug

make sure that you don't have any treesitter errors.

``` vim
:checkhealth nvim-treesitter
```
