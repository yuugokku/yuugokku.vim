if exists("b:yuugokku_syntax")
    finish
endif


syntax match Word "\v^[^=\- ]+\n"
highlight link Word Keyword

syntax match Horizontal "\v^-+"
highlight link Horizontal Comment

syntax match Class "\v\[.+\]"
syntax match Class "\v【.+】"
highlight link Class Type

let b:yuugokku_syntax = 1

