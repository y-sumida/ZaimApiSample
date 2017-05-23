# ZaimApiSample
ZaimのAPIを使ってみる

## Xcode
- Version 8.3.2 (8E2002)

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
