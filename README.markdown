# yuugokku.vim
有日辞典を検索できるVimプラグイン

## インストール
Vim-plugなら次のように.vimrcに書き込んで、`:PlugInstall`する。

```
Plug 'yuugokku/yuugokku.vim'
```

## 使い方
### コマンド
|`:Yuugokku {word}`, `:Ygk {word}`|{word}で見出し語、または訳語検索する。|
|`:YuugokkuSearch [{target-option}] {keyword} [...]`, `:Ygks [{target-option}] {keyword} [...]`|{keyword}と{target-option}で詳細検索する。|

`:Yuugokku`コマンドは手軽な検索に向いている。  
一方で`:YuugokkuSearch`コマンドはより詳細な条件を指定したいときに向いている。

### 詳細検索について
構文は次の通り。

```
:YuugokkuSearch [{target1-option1}] {keyword1} [[{target2-option2}] {keyword2} [[{target3-option3}] {keyword3} [...]]]
```

`{target-option} {keyword}`で検索条件1つを意味する。  
`{keyword}`は検索語句を意味する。例: fistir, 幸せ, である  
`{target-option}`は検索語句についての設定を追加する。targetはどの項目を対象にするかを表し、次の中からどれか一つを指定する。

- `word`見出し語
- `trans`訳語
- `ex`用例
- `wordtrans`見出し語と訳語
- `rhyme`韻律のいずれかから選ぶ。

optionは検索のマッチ方法を次の中から一つ指定する。

- `is`完全一致
- `includes`含む
- `starts`始まる
- `ends`終わる

これらを組み合わせて検索条件を指定する。複数の検索条件を指定することができ、その場合、すべてAND検索である。  
例えば、訳語に"名詞"を含み、かつ見出し語が"oo"で終わる、という条件は次のように指定する。

```
:YuugokkuSearch trans-includes 名詞 word-ends oo
```

{target-option}は省略することができる。省略された場合、targetには`wordtrans`が、optionには`includes`がそれぞれ選ばれる。

### 韻律検索について
ユーゴック語の音節規則、韻律により、`-`を長音節を表す記号、`^`を短音節を表す記号として検索条件に指定することができる。  
例えば、音節が「長-短」の構成になっており、見出し語が"anba"で終わる、という条件は次のように指定する。

```
:YuugokkuSearch rhyme-is -^ word-ends anba
```

