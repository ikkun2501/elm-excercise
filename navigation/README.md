# navigation
URLが切り替わったときに、画面を切り替える処理を実装したサンプルです。


## description
※基本的なことは[routing-intro](https://www.elm-tutorial.org/jp/07-routing/01-intro.html)に記載されています。  

## Navigationライブラリ
NavigationライブラリのNavigation.program関数を利用することで、画面の切り替えを実現します。  
Navigation.program関数はHtml.program関数のラッパーです。  
Navigation.programはURLの変更があった際にLocationを引数にしたMsgを引数にUpdate関数を呼び出してくれる仕組みになっています。  
Navigation.program関数を理解するときにHtmlとNavigationのprogram関数の定義の差を把握することで理解しやすくなると思います。  
  
Html.program関数の定義
```
program
  : { init : (model, Cmd msg)
    , update : msg -> model -> (model, Cmd msg)
    , view : model -> Html msg
    , subscriptions : model -> Sub msg
    }
  -> Program Never model msg
```

Navtigation.program関数の定義
```
program
  : (Location -> msg)
  ->
    { init : Location -> (model, Cmd msg)
    , update : msg -> model -> (model, Cmd msg)
    , view : model -> Html msg
    , subscriptions : model -> Sub msg
    }
  -> Program Never model msg
```

Html.programからNavigation.program関数へ以下のような変更があることがわかると思います。
1. Navigation関数にLocationからMsgに変換する関数を引数に追加  
   定義を見るとLocation -> Msgとなっています。  
   コンストラクタの引数としてLocationを設定したMsg型を渡してあげます。
   そのメッセージの処理では、画面を切り替えるようなモデルに変換するように実装してあげます。
2. initがタプルからLocationから（モデル、コマンド）を返す関数に変更  
   初期Locationから初期モデルに変換する関数です。
   
   
## url-parserライブラリ
Location（URL）をパースするのにurl-parserライブラリを利用します。
  
[url\-parser 2\.0\.1](http://package.elm-lang.org/packages/evancz/url-parser/latest/)
