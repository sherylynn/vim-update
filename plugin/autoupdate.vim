"need to config vimrc path
let $DOTFILE=expand("$HOME/.vim")
"source vimrc的时候会重新定义一下fuck，所以要想不触发错误，得在定义时加入判断
if !exists("*Fuck")
function! Fuck()
  :cd $DOTFILE
  "想尝试通过--git-dir 或者 -C的方式直接pull，似乎不行
  :!git pull
  "back to before dir
  :cd -
  "上面的回车是没用的，还是得进回车
  source $MYVIMRC
  echom "已更新"
endfunction
else
  echom "updated"
endif

augroup autoupdate
  "-------------------------------------------------------
  if has("job")
    autocmd VimEnter * nested call Update()
  elseif has("nvim#还没兼容好")
    function! s:OnEvent(job_id, data, event) dict
      echom "nvim jobstart"
      if a:event == 'stdout'
        let str = self.shell.' stdout: '.join(a:data)
      elseif a:event == 'stderr'
        let str = self.shell.' stderr: '.join(a:data)
      else
        let str = self.shell.' exited'
      endif

      call append(line('$'), str)
    endfunction
    let s:callbacks = {
    \ 'on_stdout': function('s:OnEvent'),
    \ 'on_stderr': function('s:OnEvent'),
    \ 'on_exit': function('s:OnEvent')
    \ }
    "let job1 = jobstart(['bash'], extend({'shell': 'shell 1'}, s:callbacks))
    let job2 = jobstart(["git -C " . $DOTFILE . " pull"], extend({'shell': 'shell 2'}, s:callbacks))
  else
    autocmd VimEnter * nested call Fuck()
  endif
  "-------------------------------------------------------------------------
augroup END
"vimscript中用.而不是+链接字符串
if !exists("*Update")
  func Update()
    let git_pull_job=job_start("git -C " . $DOTFILE . " pull",{"out_cb":"SourceHandler","err_cb":"ErrHandler"})
  endfunc
else
  echom "updated"
endif
if !exists("*PlugHandler")
func PlugHandler(channel,msg)
  echo "Plug" . a:msg
endfunc
endif

if !exists("*ErrHandler")
func ErrHandler(channel,msg)
  echo "Err" . a:msg
endfunc
endif
if !exists("*SourceHandler")
func SourceHandler(channel,msg)
  echo "Suc" . a:msg
  source $MYVIMRC
endfunc
endif

