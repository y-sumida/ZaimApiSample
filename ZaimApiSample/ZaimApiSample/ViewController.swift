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
    private let isAuthorized: Variable<Bool> = Variable(true)

    fileprivate var money: MoneyModel!

    private var oauthswift: OAuthSwift?
    private var oauthClient: OAuthSwiftClient?

    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "明細"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MoneyCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MoneyCell")

        // プルリフレッシュで更新
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // 認証状態を購読
        isAuthorized.asObservable()
            .subscribe(onNext: {[unowned self] isAuthorized in
                self.oauthView.isHidden = isAuthorized
            })
            .disposed(by: bag)

        // Client生成
        generateClient()

        // 認証チェック
        veryfyUser()

        // 明細取得
        fetchMoney()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapOauthButton(_ sender: Any) {
        authorize()
    }

    func refresh(sender: UIRefreshControl) {
        // 再読込
        fetchMoney()
        tableView.reloadData()
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

    private func authorize() {
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
                self.isAuthorized.value = true

                let defaults = UserDefaults.standard
                defaults.setValue(credential.oauthToken, forKey: "oauthToken")
                defaults.setValue(credential.oauthTokenSecret, forKey: "oauthTokenSecret")

                self.generateClient()
                self.veryfyUser()
                self.fetchMoney()
            },
            failure: { error in
                print(error.description)
        }
        )
    }

    private func generateClient() {
        guard let apiKeys:  (consumerKey: String, consumerSecret: String) = readApiKeys(),
            let token: String = UserDefaults.standard.string(forKey: "oauthToken"),
            let secret: String = UserDefaults.standard.string(forKey: "oauthTokenSecret")
            else {
                isAuthorized.value = false
                return
        }

        oauthClient = OAuthSwiftClient(consumerKey: apiKeys.consumerKey, consumerSecret: apiKeys.consumerSecret, oauthToken: token, oauthTokenSecret: secret, version: .oauth1)
    }

    private func veryfyUser() {
        guard isAuthorized.value else { return }

        // APIコールして成功だったら認証ボタンを閉じる
        // TODO loginの値を見る
        UserVerifyModel.call(client: oauthClient!)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {model, response in
                    self.isAuthorized.value = true
                    self.userNameLabel.text = "ユーザ:\(model.name)"
                    print(model)
            },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            }
            )
            .addDisposableTo(bag)
    }

    private func fetchMoney() {
        guard isAuthorized.value else { return }

        MoneyModel.call(client: oauthClient!)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    print(model)
                    self?.money = model
                    self?.refreshControl.endRefreshing()
                    self?.tableView.reloadData()
                },
                onError: {[weak self] (error: Error) in
                    self?.refreshControl.endRefreshing()
                    print(error.localizedDescription)
            }
            )
            .addDisposableTo(bag)
    }

    fileprivate func deleteMoney(id: Int, mode: MoneyMode) {
        guard isAuthorized.value else { return }

        MoneyDeleteModel.call(client: oauthClient!, id: id, mode: mode)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.money.item = (self?.money.item.filter { item in item.id != model.id })!
                    self?.tableView.reloadData()
                },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            }
            )
            .addDisposableTo(bag)
    }

    @IBAction func tapDeauthButton(_ sender: Any) {
        // ローカルのトークンを削除して認証用のViewを表示
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "oauthToken")
        defaults.removeObject(forKey: "oauthTokenSecret")

        isAuthorized.value = false
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let model: MoneyModel = money, money.item.count > indexPath.row else { return nil }

        let item: MoneyModel.Item = model.item[indexPath.row]

        let deleteAction = UITableViewRowAction(style: .default, title: "delete"){ [unowned self] (action, indexPath) in
                self.deleteMoney(id: item.id, mode: item.mode)
        }

        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集画面へ遷移
        // TODO データを渡す
        let vc: EditViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController

        // ナビゲーション
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .custom
        nvc.modalTransitionStyle = .coverVertical

        self.present(nvc, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model: MoneyModel = money else { return 0 }
        return model.item.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MoneyCell = tableView.dequeueReusableCell(withIdentifier: "MoneyCell") as! MoneyCell
        if let model: MoneyModel = money, money.item.count > indexPath.row {
            cell.dateLabel?.text = model.item[indexPath.row].date
            cell.modeLabel?.text = model.item[indexPath.row].mode.rawValue
            cell.amountLabel?.text = "￥\(model.item[indexPath.row].ammount.description)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}
