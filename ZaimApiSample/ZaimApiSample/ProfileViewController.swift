//
//  ProfileViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/27.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import OAuthSwift
import RxSwift

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deauthButton: UIButton!

    fileprivate let sectionTitles:[String] = ["ユーザー名", "入力回数", "連続入力日数"]

    var oauthClient: OAuthSwiftClient!

    private let bag: DisposeBag = DisposeBag()
    fileprivate let viewModel: ProfileViewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        deauthButton.layer.cornerRadius = 4.0

        bind()

        if let client: OAuthSwiftClient = oauthClient {
            viewModel.fetch(client: client)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func bind() {
        viewModel.finishTrigger.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: bag)

    }

    @IBAction func tapDeauthButton(_ sender: Any) {
        // ローカルのトークンを削除して初期画面に戻す
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "oauthToken")
        defaults.removeObject(forKey: "oauthTokenSecret")

        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileViewController: UITableViewDelegate {
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = viewModel.name
        case 1:
            cell.textLabel?.text = "\(viewModel.inputCount) 回"
        case 2:
            cell.textLabel?.text = "\(viewModel.dayCount) 日"
        default:
            break
        }

        return cell
    }
}

