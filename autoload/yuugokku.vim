let s:indent_count = 4

function! s:URLSafe(url) abort
    let urlsafe = ""
    for char in split(a:url, '\zs')
        if matchend(char, '[-_~a-zA-Z0-9]') >= 0
            let urlsafe .= char
        else
            for i in range(strlen(char))
                let byte = strpart(char, i, 1)
                let decimal = char2nr(byte, 1)
                let urlsafe = urlsafe . "%" . printf("%02x", decimal)
            endfor
        endif
    endfor
    return urlsafe
endfunction


function! s:GetHTTP(url) abort
    let result = system("curl -Ss \"" . a:url . "\"")
    return result
endfunction


function! s:ParseJSON(json_text) abort
    " JSON文字列をVimscriptのデータに変換する
    return json_decode(a:json_text)
endfunction


function! s:WrapLine(line, colnum=0) abort
    let colnum = a:colnum
    if colnum == 0
        let colnum = g:yuugokku_colnum
    endif

    let wrapped = ''
    let i = 0
    for char in split(a:line, '\zs')
        let wrapped .= char
        if i + s:indent_count >= colnum
            let wrapped .= "\n"
            let i = 0
        elseif char ==# "\n"
            let i = 0
        else
            if strlen(char) == 1
                let i += 1
            else
                let i += 2
            endif
        endif
    endfor
    return wrapped
endfunction

let s:options = {"is": "に一致する", "includes": "を含む", "ends": "で終わる", "starts": "で始まる", "regex": "の正規表現にハマる"}
let s:targets = {"wordtrans": "見出し語または訳語", "word": "見出し語", "trans": "訳語", "ex": "用例", "rhyme": "韻律"}

function! s:FormatResult(result_dict) abort
    " 結果のJSONを表示用テキストに整形する
    let result = "Yuugokku.vim 有日辞典 on Vim\n"
    
    let keyword = get(a:result_dict, "keyword", "")
    if empty(keyword)
        let i = 0
        for c in a:result_dict["conditions"]
            let result .= " 条件" . (i + 1) .  ": " . s:targets[c["target"]] . "が" . c["keyword"] . s:options[c["option"]]
            let result .= "\n"
            let i += 1
        endfor
        let result .= "\n\n"
    else
        let result .= " 検索する単語: " . keyword . "\n"
        let result .= "\n\n"
    endif

    let result .= " 検索結果: " . len(a:result_dict["words"]) . "件"
    let result .= "\n"

    let line_length = g:yuugokku_colnum

    for i in range(line_length)
        let result .= "="
    endfor
    let result .= "\n"

    for word in a:result_dict["words"]
        let result .=  word["word"] . "\n"
        for line in split(s:WrapLine(word["trans"]), "\n")
            let result .= "    " . line . "\n"
        endfor
        for line in split(s:WrapLine(word["ex"]), "\n")
            let result .= "    " . line . "\n"
        endfor

        for i in range(line_length)
            let result .= "-"
        endfor
        let result .= "\n"
    endfor
    return result
endfunction


function! s:ShowResult(text) abort
    " テキストに変換された結果を表示する
    let win_num = bufwinnr("yuugokku")
    if win_num == -1
        vsplit yuugokku
        normal! ggdG
        setlocal filetype=yuugokku
        setlocal buftype=nowrite
        call append(0, split(a:text, '\v\n'))
        normal! gg
    else
        execute win_num . "wincmd w"
        normal! ggdG
        call append(0, split(a:text, '\v\n'))
        normal! gg
    endif
endfunction


function! yuugokku#FindWord(keyword, target='') abort
    let url = g:yuugokku_url . 'word?keyword=' . s:URLSafe(a:keyword)
    if a:target !=# ''
        let url .= '&target=' . a:target
    endif
    let result = s:ParseJSON(s:GetHTTP(url))
    call s:ShowResult(s:FormatResult(result))
endfunction


function! yuugokku#Search(targets, keywords, options) abort
    let url = g:yuugokku_url . 'search?'
    for i in range(len(a:targets))
        let url .= 'target_' . i . '=' . s:URLSafe(a:targets[i]) . '&'
        let url .= 'keyword_' . i . '=' . s:URLSafe(a:keywords[i]) . '&'
        let url .= 'option_' . i . '=' . s:URLSafe(a:options[i]) . '&'
    endfor
    let result = s:ParseJSON(s:GetHTTP(url))
    echom g:fanache_url . "にリクエストを送信しました"
    call s:ShowResult(s:FormatResult(result))
endfunction

function! yuugokku#SearchCommand(...) abort
    let targets = []
    let keywords = []
    let options = []

    let defined = 0

    for arg in a:000
        " 直前のtargetsがrhymeなら、-で分割しない
        let last_target = get(targets, -1, "")
        if last_target ==# "rhyme"
            let arg_split = [arg]
        else
            let arg_split = split(arg, "-")
        endif

        if len(arg_split) == 1
            if defined
                call add(keywords, arg_split[0])
                let defined = 0
            else
                call add(keywords, arg_split[0])
                call add(targets, "wordtrans")
                call add(options, "includes")
            endif
        else
            call add(targets, arg_split[0])
            call add(options, arg_split[1])
            let defined = 1
        endif
    endfor

    call yuugokku#Search(targets, keywords, options)
endfunction
