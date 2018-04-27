"echom matchstr("okO",'\m\(ok\)*')
"echom matchstr("okOdjsj",'\v(ok)|(js)\g')
"echom matchstr("okOdjsj",'\v(ok)?|(js)?\g')
"echom matchstr("okOdjsj",'\m\[\(ok\)\(js\)\]')
"echom matchstr("okOdjsj",'\m\[\(ok\)\]')
"echom system("ls -al")
"实际.git后不是空白,是^@
"echom matchstr(system("ls .git"),'\vconfig')
"echom system("ls -a")
if matchstr(system("ls .git"),'\vconfig')=="config"
"  call system("git pull")
"  echo system("git pull")
  call GitPull("./")
endif
func! GitPull(path)
  let l:gitpulljob=job_start("git -C " . a:path . " pull","callback":"GitHandler")
endfunc
func! GitHandler(channel,msg)
  echom a:msg
endfunc
