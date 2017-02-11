# cookpad scraping

## Purpose
- つくれぽの件数が多いレシピを抜き出します。

## How to use
 ```sh
 ruby  cookpad-scraping.rb -d --menu "カレー" --limit 10 --cond 10
 ```
### option
 - `-d` debug mode
 - `--menu` 検索したいメニュー
 - `--limit` 何ページ検索するか
 - `--cond` つくれぽ何件以上を抽出するか
 
## Result
下記形式で、`--menu で指定した文字列`-yummy.txtという名前で出力されます
```
料理名,url
```
## 実行環境
```
ubuntu:~$ ruby -v
ruby 2.4.0p0 (2016-12-24 revision 57164) [x86_64-darwin16]
```
