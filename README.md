# ZaimApiSample
ZaimのAPIを使ってみる

## バージョン
- Swift 4.0
- Xcode Version 9.0.1 (9A1004)

## ライブラリ
Carthageを使います

```
cd ./ZaimApiSample
carthage bootstrap
```

## ApiKeys.plist サンプル
consumerKeyとconsumerSecretを定義します

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>consumerKey</key>
	<string>hogehogehoge</string>
	<key>consumerSecret</key>
	<string>fugafugafufa</string>
</dict>
</plist>
```
