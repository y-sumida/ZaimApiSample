//
//  ViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/16.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import OAuthSwift
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var oauthView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let bag: DisposeBag = DisposeBag()

    fileprivate var money: MoneyModel!

    var oauthswift: OAuthSwift?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        oauthView.isHidden = true

        guard let apiKeys:  (consumerKey: String, consumerSecret: String) = readApiKeys(),
            let token: String = UserDefaults.standard.string(forKey: "oauthToken"),
            let secret: String = UserDefaults.standard.string(forKey: "oauthTokenSecret")
        else {
            oauthView.isHidden = false
            return
        }

        let client: OAuthSwiftClient = OAuthSwiftClient(consumerKey: apiKeys.consumerKey, consumerSecret: apiKeys.consumerSecret, oauthToken: token, oauthTokenSecret: secret, version: .oauth1)

        // APIコールして成功だったら認証ボタンを閉じる
        // TODO loginの値を見る
        UserVerifyModel.call(client: client)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {model, response in
                    self.oauthView.isHidden = true
                    self.userNameLabel.text = "ユーザ:\(model.name)"
                    print(model)
                },
                onError: {(error: Error) in
                    print("ng")
                }
            )
            .addDisposableTo(bag)

        // 明細取得
        MoneyModel.call(client: client)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    print(model)
                    self?.money = model
                    self?.tableView.reloadData()
            },
                onError: {(error: Error) in
                    print("ng")
            }
            )
            .addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapOauthButton(_ sender: Any) {
        // APIKey読み取り
        guard let apiKeys:  (consumerKey: String, consumerSecret: String) = readApiKeys() else { return }

        let oauthswift = OAuth1Swift(
            consumerKey:    apiKeys.consumerKey,
            consumerSecret: apiKeys.consumerSecret,
            requestTokenUrl: "https://api.zaim.net/v2/auth/request",
            authorizeUrl:    "https://auth.zaim.net/users/auth",
            accessTokenUrl:  "https://api.zaim.net/v2/auth/access"
        )
        self.oauthswift = oauthswift
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "myzaimapp://oauth-callback")!,
            success: { [unowned self] credential, response, parameters in
                self.oauthView.isHidden = true

                let defaults = UserDefaults.standard
                defaults.setValue(credential.oauthToken, forKey: "oauthToken")
                defaults.setValue(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
        },
            failure: { error in
                print(error.description)
        }
        )
    }

    private func readApiKeys() -> (consumerKey: String, consumerSecret: String)? {
        // APIKey読み取り
        guard let path: URL = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist") else {
            return nil
        }

        var consumerKey: String = ""
        var consumerSecret: String = ""
        do {
            let data: Data = try Data(contentsOf: path)
            let keys = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
            consumerKey = keys?["consumerKey"] as! String
            consumerSecret = keys?["consumerSecret"] as! String

            return (consumerKey, consumerSecret)
        }
        catch {
            return nil
        }
    }

    @IBAction func tapDeauthButton(_ sender: Any) {
        // ローカルのトークンを削除して認証用のViewを表示
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "oauthToken")
        defaults.removeObject(forKey: "oauthTokenSecret")

        oauthView.isHidden = false
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model: MoneyModel = money else { return 0 }
        return model.item.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        if let model: MoneyModel = money, money.item.count > indexPath.row {
            cell.textLabel?.text = "￥\(model.item[indexPath.row].ammount.description)"
        }

        return cell
    }
}
