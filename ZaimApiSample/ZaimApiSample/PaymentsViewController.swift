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
import RealmSwift

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

        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MoneyCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MoneyCell")

        // プルリフレッシュで更新
        tableView.addSubview(refreshControl)

        // データ取得監視
        bind()

        // Client生成
        generateClient()

        // TODO 認証チェック含めてAppDelegateに移す
        getCategories()
        getGenres()
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

    private func getCategories() {
        guard let client = oauthClient else { return }
        CategoriesModel.call(client: client)
            .subscribe(
                onNext: {model, response in
                    let realm = try! Realm()
                    try! realm.write {
                        for category in model.categories {
                            if category.mode == "payment" {
                                realm.add(category, update: true)
                            }
                        }
                    }
                    print(realm.objects(Category.self))
            },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
    }

    private func getGenres() {
        guard let client = oauthClient else { return }
        GenresModel.call(client: client)
            .subscribe(
                onNext: {model, response in
                    let realm = try! Realm()
                    try! realm.write {
                        for genre in model.genres {
                            realm.add(genre, update: true)
                        }
                    }
                    print(realm.objects(Genre.self))
            },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
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

        viewModel.isLoading.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                self?.footerView.isHidden = !isLoading
            })
            .disposed(by: bag)

        // プルリフレッシュ
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] in
                self.refresh(sender: self.refreshControl)
            })
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
        vc.dismissAction = {[unowned self] in
            if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
                self.tableView.flashScrollIndicators()
            }
        }

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
}

extension PaymentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.payments.count > indexPath.row else { return }
        let payment: MoneyEditViewModel = self.viewModel.payments[indexPath.row]
        self.showEditView(viewModel: payment)
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, viewModel.payments.count > indexPath.row {
            let payment = viewModel.payments[indexPath.row]
            self.showDeleteConfirmDialog(payment: payment)
        }
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "削除", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if self.viewModel.payments.count > indexPath.row {
                let payment = self.viewModel.payments[indexPath.row]
                self.showDeleteConfirmDialog(payment: payment)
            }
            success(true)
        })
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension PaymentsViewController: UITableViewDataSource {
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
}
