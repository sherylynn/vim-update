"why run twice ?
"autocmd twice ?
"不知道为啥这个绑定激活两次
"或许和nerdtree本身的特性有关系
" 判断后无关
" 有没有nested也是一样
augroup WorkDirUpdate
  "清除组内不该有的命令
  autocmd!
  autocmd BufNewFile,BufRead * nested call GitPullable(expand('%:h'))
"  autocmd DirChanged * call GitPullable(".")
  if has("nvim")
    if !exists("*GitHandler")
      func g:GitHandler(job_id, data, event) dict
        echom string(a:data)
      endfunc
    endif
    let s:callbacks = {
    \ 'on_stdout': 'GitHandler',
    \ 'stdout_buffered':v:true
    \ }
    if !exists("*GitPullable")
      func g:GitPullable(dir)
        if isdirectory(expand(a:dir) . "/.git")==1
          let l:gitpulljob= jobstart(["git","-C",expand(a:dir),"pull"],s:callbacks)
        endif
      endfunc
    endif
  elseif has("job")
    if !exists("*GitHandler")
      func g:GitHandler(channel,msg)
        echom a:msg
      endfunc
    endif
    if !exists("*GitPullable")
      func g:GitPullable(dir)
        if isdirectory(expand(a:dir) . "/.git")==1
          let l:gitpulljob=job_start("git -C " . expand(a:dir) . " pull",{"callback":"GitHandler"})
        endif
      endfunc
  "    func GitPullable(dir)
  "      let l:dir_command="ls " . a:dir . "/.git"
  "      let l:status=matchstr(system(l:dir_command),'\v(config)|(such)')
  "      if l:status=="config"
  "        let l:gitpulljob=job_start("git -C " . expand(a:dir) . " pull",{"callback":"GitHandler"})
  "      elseif l:status=="such"
  "  "      echom system(l:dir_command)
  "      else
  "      endif
  "    endfunc
    endif
  endif
"  command! -bar Test echom "test"
"  command! -bar Test2 echom expand('%:h')
"  command! -bar Test4 echom expand('%:p:h/../')
"  command! -bar GitPullable4 call GitPullable("~/vimcode")
  command! -bar GitPullable call GitPullable(expand('%:p:h'))
"  command! -bar GitPullable2 GitPullable(expand('%:h'))
"  command! -bar GitPullable call g:GitPullable(expand('%:h'))
augroup END
