" Author: liuchengxu <xuliuchengxlc@gmail.com>
" Description: Project-wide tags

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:proj_tags = {}

function! s:handle_result_on_typed(result) abort
  if has_key(a:result, 'total')
    call clap#state#refresh_matches_count(a:result.total)
  endif
  if has_key(a:result, 'lines')
    call g:clap.display.set_lines(a:result.lines)
  endif
  if has_key(a:result, 'indices')
    call clap#highlight#add_fuzzy_async_with_delay(a:result.indices)
  endif
endfunction

function! s:proj_tags.on_typed() abort
  " if exists('g:__clap_forerunner_tempfile')
    " call clap#filter#async#dyn#from_tempfile(g:__clap_forerunner_tempfile)
  " elseif exists('g:__clap_forerunner_result')
    " let query = g:clap.input.get()
    " if query ==# ''
      " return
    " endif
    " call clap#filter#on_typed(function('clap#filter#sync'), query, g:__clap_forerunner_result)
  " else
    " call clap#filter#async#dyn#start_directly(clap#maple#build_cmd('tags', g:clap.input.get(), clap#rooter#working_dir()))
  " endif
  call clap#client#call('proj_tags/on_typed', function('s:handle_result_on_typed'), {
        \ 'curline': g:clap.display.getcurline(),
        \ 'query': g:clap.input.get(),
        \ })
endfunction

function! s:handle_result_init(result) abort
  if has_key(a:result, 'total')
    let g:clap.display.initial_size = a:result.total
    call clap#indicator#update_matches_on_forerunner_done()

    let g:__clap_current_forerunner_status = g:clap_forerunner_status_sign.done
    call clap#spinner#refresh()
  endif
  if has_key(a:result, 'lines')
    let cur_lines = g:clap.display.get_lines()
    if empty(cur_lines) || cur_lines == ['']
      call g:clap.display.set_lines(a:result.lines)
    endif
  endif
endfunction

function! s:proj_tags.init() abort
  let g:__clap_builtin_line_splitter_enum = 'TagNameOnly'
  " if clap#maple#is_available()
    " call clap#rooter#try_set_cwd()
    " call clap#job#regular#forerunner#start_command(clap#maple#tags_forerunner_command())
  " endif

  call clap#client#call_on_init('proj_tags/on_init', function('s:handle_result_init'))
endfunction

function! s:extract(tag_row) abort
  let lnum = matchstr(a:tag_row, '^.*:\zs\(\d\+\)')
  let path = matchstr(a:tag_row, '\[.*@\zs\(\f*\)\ze\]')
  return [lnum, path]
endfunction

function! s:proj_tags.sink(selected) abort
  let [lnum, path] = s:extract(a:selected)
  call clap#sink#open_file(path, lnum, 1)
endfunction

function! s:proj_tags.on_move() abort
  let [lnum, path] = s:extract(g:clap.display.getcurline())
  call clap#preview#file_at(path, lnum)
endfunction

function! s:proj_tags.on_exit() abort
  if exists('g:__clap_builtin_line_splitter_enum')
    unlet g:__clap_builtin_line_splitter_enum
  endif
endfunction

let s:proj_tags.enable_rooter = v:true
let s:proj_tags.support_open_action = v:true
let s:proj_tags.syntax = 'clap_proj_tags'

let g:clap#provider#proj_tags# = s:proj_tags

let &cpoptions = s:save_cpo
unlet s:save_cpo
