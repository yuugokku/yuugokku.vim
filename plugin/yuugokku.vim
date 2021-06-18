if exists("g:yuugokku_loaded")
    finish
endif

let g:yuugokku_loaded = 1

if !exists("g:curl_command")
    let g:curl_command = 'curl -Ss'
endif

if !exists("g:yuugokku_colnum")
    let g:yuugokku_colnum = 80
endif

if !exists("g:yuugokku_buffertype")
    let g:yuugokku_buffertype = "vsplit"
endif

let g:fanache_url = 'test-fanache.herokuapp.com/api/'
let g:yuugokku_id = 1
let g:yuugokku_url = g:fanache_url . g:yuugokku_id . '/'


command! -nargs=1 Yuugokku call yuugokku#FindWord(<f-args>)
command! -nargs=1 Ygk Yuugokku <args>

command! -nargs=* YuugokkuSearch call yuugokku#SearchCommand(<f-args>)
command! -nargs=* Ygks YuugokkuSearch <args>
