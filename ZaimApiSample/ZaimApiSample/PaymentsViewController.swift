//
//  PaymentsViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/16.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import OAuthSwift
import RxSwift

class PaymentsViewController: UIViewController {
    @IBOutlet weak var oauthView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private let bag: DisposeBag = DisposeBag()
    private let isAuthorized: Variable<Bool> = Variable(true)
    private let registerFinishTrigger: PublishSubject<Void> = PublishSubject()

    private let viewModel: PaymentsViewModel = PaymentsViewModel()

    private var oauthswift: OAuthSwift?
    private var oauthClient: OAuthSwiftClient? {
        didSet {
            if let client: OAuthSwiftClient = oauthClient {
                // 明細取得
                self.viewModel.fetch(client: client, isRefresh: true)
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

        let nib = UINib(nibName: "MoneyCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MoneyCell")

        // プルリフレッシュで更新
        refreshControl.addTarget(self, action: #selector(PaymentsViewController.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // データ取得監視
        bind()

        // Client生成
        generateClient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 表示前に認証状態を確認
        guard let _ = UserDefaults.standard.string(forKey: "oauthToken"),
            let _ = UserDefaults.standard.string(forKey: "oauthTokenSecret")
            else {
                isAuthorized.value = false
                return
        }
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
        viewModel.fetch(client: oauthClient!, isRefresh: true)
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

    @IBAction func tapAddButton(_ sender: Any) {
        showEditView(viewModel: nil)
    }

    @IBAction func tapProfileButton(_ sender: Any) {
        let vc: ProfileViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        vc.oauthClient = oauthClient
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func bind() {
        // viewModelとTableViewをバインド
        viewModel.observablePayments.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "MoneyCell", cellType: MoneyCell.self)) { (row, element, cell) in

                cell.viewModel = element
            }
            .disposed(by: bag)

        // didSelectRowAt相当
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.didSelectRowAt(indexPath: indexPath)
            })
            .disposed(by: bag)

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

        // 新規登録後にAPIを呼び直す
        registerFinishTrigger.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.fetch(client: (self?.oauthClient)!, isRefresh: true)
            })
            .disposed(by: bag)

        // 最下端まで到達したか
        tableView.rx.reachedBottom.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.fetch(client: (self?.oauthClient)!, isRefresh: false)
            })
            .disposed(by: bag)

        // ローディングアイコン
        viewModel.isLoading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
    }

    private func showEditView(viewModel: MoneyEditViewModel?) {
        // 編集画面へ遷移
        let vc: EditViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        if let `viewModel`: MoneyEditViewModel = viewModel {
            vc.viewModel = viewModel
        }
        else {
            vc.registerFinishTrigger = self.registerFinishTrigger
        }
        vc.client = oauthClient

        // ナビゲーション
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .custom
        nvc.modalTransitionStyle = .coverVertical

        self.present(nvc, animated: true, completion: nil)
    }

    private func showDeleteConfirmDialog(payment: MoneyEditViewModel) {
        let defaultAction: (UIAlertAction) -> Void = { (action: UIAlertAction!) -> Void in
            self.viewModel.delete(client: self.oauthClient!, id: payment.id!, mode: payment.mode.value)
        }
        let cancelAction: (UIAlertAction) -> Void = { (action: UIAlertAction!) -> Void in
        }

        let alert: UIAlertController = UIAlertController(title: "本当に削除しますか", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: defaultAction))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: cancelAction))

        present(alert, animated: true, completion: nil)
    }

    private func didSelectRowAt(indexPath: IndexPath) {
        DispatchQueue.main.async { // こうしないともたつく
            let payment: MoneyEditViewModel = self.viewModel.observablePayments.value[indexPath.row]

            let alert: UIAlertController = UIAlertController(title: "メニュー", message: "選択してください", preferredStyle:  UIAlertControllerStyle.actionSheet)
            let editAction: UIAlertAction = UIAlertAction(title: "編集", style: .default, handler:{ [unowned self]
                (action: UIAlertAction!) -> Void in
                self.showEditView(viewModel: payment)
            })

            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("cancelAction")
            })

            let deleteAction: UIAlertAction = UIAlertAction(title: "削除", style: .destructive, handler:{ [unowned self]
                (action: UIAlertAction!) -> Void in
                self.showDeleteConfirmDialog(payment: payment)
            })

            alert.addAction(editAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
