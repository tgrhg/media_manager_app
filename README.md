# media_manager_app

DVDやBDを管理するアプリ


## 環境変数

`.env` をプロジェクトルートに作成し、その中に定義してください。
- サンプルは `.env.sample` を参照してください
- 環境変数として定義する場合も、空の `.env` ファイルを作成してください

| # | 変数名| 説明 | デフォルト値 | 必須 |
| --- | --- | --- | --- | --- |
| 1 | RAKUTEN_API_KEY | [こちら](https://webservice.rakuten.co.jp) で発行した Application Key を設定してください |  | ◯ |

## iOSでの実行時の事前設定

`local.xcconfig.example` をコピーして、`./ios/local.xconfig` を作成し、`DEVELOPMENT_TEAM` に適切な値を設定してください。

https://developer.apple.com/jp/help/account/manage-your-team/locate-your-team-id/
