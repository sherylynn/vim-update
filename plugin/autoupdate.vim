"need to config vimrc path
"变量的判断引用在viml都带冒号
if !exists("g:VIMHOME")
  let g:VIMHOME=".vim"
endif
let $VIMHOME=expand("$HOME/" . g:VIMHOME)
let $UPDATE=expand("$VIMHOME/plugged/vim-update")
let $ELISP=expand("$VIMHOME/plugged/vim-elisp")
"source vimrc的时候会重新定义一下Sync_update，所以要想不触发错误，得在定义时加入判断
if !exists("*Sync_update")
function! Sync_update()
  :cd $VIMHOME
  "想尝试通过--git-dir 或者 -C的方式直接pull，似乎不行
  :!git pull
  "back to before dir
  :cd -
  "上面的回车是没用的，还是得进回车
  source $MYVIMRC
"  echom "已更新"
endfunction
else
"  echom "updated"
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
    let job2 = jobstart(["git -C " . $VIMHOME . " pull"], extend({'shell': 'shell 2'}, s:callbacks))
  else
    autocmd VimEnter * nested call Sync_update()
  endif
  "-------------------------------------------------------------------------
augroup END
"vimscript中用.而不是+链接字符串
if !exists("*Update")
  func Update()
    let dot_pull_job=job_start("git -C " . $VIMHOME . " pull",{"out_cb":"SourceHandler","err_cb":"ErrHandler"})
    let update_pull_job=job_start("git -C " . $UPDATE . " pull",{"out_cb":"LetItGoHandler","err_cb":"ErrHandler"})
    let elisp_pull_job=job_start("git -C " . $ELISP . " pull",{"out_cb":"LetItGoHandler","err_cb":"ErrHandler"})
    "需要注意的是任务名的变量不能相同，另外就是增加路径的时候如何自定义好任务变量名
  endfunc
else
  "  正常更新不再提示消息打断用户
"  echom "已经执行过更新"
endif

if !exists("*SourceHandler")
  func SourceHandler(channel,msg)
    let l:status=matchstr(a:msg,'\m\(Already\)*\(Fast\)*')
    if l:status=='Already'
      "有些是Already up to date 有些是 Already up-to-date
      "    正常更新不给提示
  "    echom "已经最新"
    elseif l:status=='Fast'
      "成功更新会出现Fast-forward
      echom "Succeed"
    else
      echom a:msg
    endif
    source $MYVIMRC
  endfunc
endif
"附属插件不需要重载vimrc
if !exists("*LetItGoHandler")
  func LetItGoHandler(channel,msg)
    let l:status=matchstr(a:msg,'\m\(Already\)|\(unable to access\)')
    if l:status=='Already'
      "有些是Already up to date 有些是 Already up-to-date
      "    正常更新不给提示
  "    echom "已经最新"
    elseif l:status=='unable to access'
      "实际上 错误不会走这里，会走下面
      echom "Fail to connect"
    else
      echom a:msg
    endif
  "  source $MYVIMRC
  endfunc
endif

if !exists("*ErrHandler")
  func ErrHandler(channel,msg)
    echom "Err" . a:msg
  endfunc
endif

