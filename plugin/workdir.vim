"why run twice ?
"autocmd twice ?
augroup WorkDirUpdate
  autocmd BufNewFile,BufRead * call GitPullable(expand('%:h'))
  autocmd DirChanged * call GitPullable(".")
  if !exists("*GitHandler")
    func GitHandler(channel,msg)
      echom a:msg
    endfunc
  endif
  if !exists("*GitPullable")
    func GitPullable(dir)
      let l:dir_command="ls " . a:dir . "/.git"
      let l:status=matchstr(system(l:dir_command),'\v(config)|(such)')
      if l:status=="config"
        echom "updateable"
        let l:gitpulljob=job_start("git -C " . expand(a:dir) . " pull",{"callback":"GitHandler"})
      elseif l:status=="such"
  "      echom system(l:dir_command)
      else
      endif
    endfunc
  endif
augroup End
