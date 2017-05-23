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

    fileprivate let viewModel: PaymentsViewModel = PaymentsViewModel()

    private var oauthswift: OAuthSwift?
    fileprivate var oauthClient: OAuthSwiftClient? {
        didSet {
            if let client: OAuthSwiftClient = oauthClient {
                // 明細取得
                self.viewModel.fetch(client: client)
            }
        }
    }

    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "出費一覧"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MoneyCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MoneyCell")

        // プルリフレッシュで更新
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // データ取得監視
        bind()

        // Client生成
        generateClient()

        // 認証チェック
        veryfyUser()

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
        viewModel.fetch(client: oauthClient!)
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
                self.viewModel.fetch(client: self.oauthClient!)
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
        guard let client: OAuthSwiftClient = oauthClient  else { return }

        // APIコールして成功だったら認証ボタンを閉じる
        // TODO loginの値を見る
        UserVerifyModel.call(client: client)
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

    @IBAction func tapDeauthButton(_ sender: Any) {
        // ローカルのトークンを削除して認証用のViewを表示
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "oauthToken")
        defaults.removeObject(forKey: "oauthTokenSecret")

        isAuthorized.value = false
    }

    @IBAction func tapAddButton(_ sender: Any) {
        showEditView(viewModel: nil)
    }

    private func bind() {
        viewModel.finishTrigger.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            })
            .disposed(by: bag)

        // 認証状態を購読
        isAuthorized.asObservable()
            .subscribe(onNext: {[unowned self] isAuthorized in
                self.oauthView.isHidden = isAuthorized
            })
            .disposed(by: bag)
    }

    fileprivate func showEditView(viewModel: MoneyEditViewModel?) {
        // 編集画面へ遷移
        let vc: EditViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        if let `viewModel`: MoneyEditViewModel = viewModel {
            vc.viewModel = viewModel
        }
        vc.client = oauthClient

        // ナビゲーション
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .custom
        nvc.modalTransitionStyle = .coverVertical

        self.present(nvc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard viewModel.payments.count > indexPath.row else { return nil }

        let payment: MoneyEditViewModel = viewModel.payments[indexPath.row]

        let deleteAction = UITableViewRowAction(style: .default, title: "delete"){ [unowned self] (action, indexPath) in
            self.viewModel.delete(client: self.oauthClient!, id: payment.id!, mode: payment.mode.value)
        }

        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.payments.count > indexPath.row else { return }

        // 編集画面へ遷移
        showEditView(viewModel: viewModel.payments[indexPath.row])
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.payments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MoneyCell = tableView.dequeueReusableCell(withIdentifier: "MoneyCell") as! MoneyCell
        if viewModel.payments.count > indexPath.row {
            cell.viewModel = viewModel.payments[indexPath.row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}
