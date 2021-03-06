" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

" This global variable can be set with a string of comma-seperated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_linters_sh_shellcheck_exclusions = 'SC2002,SC2004'
if !exists('g:ale_linters_sh_shellcheck_exclusions')
    let g:ale_linters_sh_shellcheck_exclusions = ''
endif

let g:ale_sh_shellcheck_executable =
\   get(g:, 'ale_sh_shellcheck_executable', 'shellcheck')

let g:ale_sh_shellcheck_options =
\   get(g:, 'ale_sh_shellcheck_options', '')

function! ale_linters#sh#shellcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'sh_shellcheck_executable')
endfunction

if g:ale_linters_sh_shellcheck_exclusions !=# ''
    let s:exclude_option = '-e ' .  g:ale_linters_sh_shellcheck_exclusions
else
    let s:exclude_option = ''
endif

function! s:GetDialectArgument() abort
    if exists('b:is_bash') && b:is_bash
        return '-s bash'
    elseif exists('b:is_sh') && b:is_sh
        return '-s sh'
    elseif exists('b:is_kornshell') && b:is_kornshell
        return '-s ksh'
    endif

    return ''
endfunction

function! ale_linters#sh#shellcheck#GetCommand(buffer) abort
    return ale_linters#sh#shellcheck#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'sh_shellcheck_options')
    \   . ' ' . s:exclude_option . ' ' . s:GetDialectArgument() . ' -f gcc -'
endfunction

call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable_callback': 'ale_linters#sh#shellcheck#GetExecutable',
\   'command_callback': 'ale_linters#sh#shellcheck#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
