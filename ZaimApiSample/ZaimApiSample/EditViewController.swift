//
//  EditViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/20.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift
import OAuthSwift

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registerButton: UIButton!

    private let bag: DisposeBag = DisposeBag()
    private var isEditMode: Bool = false

    var viewModel: MoneyEditViewModel! {
        didSet {
            bind()
        }
    }
    var client: OAuthSwiftClient!

    deinit {
        print("Edit deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            if let _ = viewModel {
                navigationItem.title = "編集"
                isEditMode = true
            }
            else {
                navigationItem.title = "登録"
                isEditMode = false
                viewModel = MoneyEditViewModel(money: nil)
            }
            navigationItem.hidesBackButton = false
        }

        //
        registerButton.layer.cornerRadius = 4.0

        tableView.delegate = self
        tableView.dataSource = self
        let textNib = UINib(nibName: "TextEditCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "TextEditCell")
        let categoryNib = UINib(nibName: "CategorySelectCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "CategorySelectCell")
        let dateNib = UINib(nibName: "DatePickerCell", bundle: nil)
        tableView.register(dateNib, forCellReuseIdentifier: "DatePickerCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapRegisterButton(_ sender: Any) {
        if isEditMode {
            viewModel.updateMoney(client: client)
        }
        else {
            viewModel.registerMoney(client: client)
        }
    }

    @IBAction func tapCacelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func bind() {
        viewModel.finishTrigger.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        )
        .disposed(by: bag)

        viewModel.isUpdate.asObservable()
            .skip(1)
            .subscribe(onNext: { [weak self] isUpdate in
                self?.registerButton.isEnabled = isUpdate
                }
            )
            .disposed(by: bag)
    }
}

extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            // カテゴリ選択へ遷移
            let vc: CategoriesViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoriesViewController") as! CategoriesViewController
            vc.categoryId = viewModel.categoryId
            vc.genreId = viewModel.genreId

            // ナビゲーション
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .custom
            nvc.modalTransitionStyle = .coverVertical

            self.present(nvc, animated: true, completion: nil)
        }
    }
}

extension EditViewController: UITableViewDataSource {
    // TODO セクション数、行数、セルを調整する
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // 金額
        }
        else {
            return 2 // カテゴリ、日付
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: TextEditCell = tableView.dequeueReusableCell(withIdentifier: "TextEditCell") as! TextEditCell
            cell.placeholder = "金額"
            cell.keyboardType = .numberPad
            cell.bindValue = viewModel.amount
            return cell
        }
        else if indexPath.row == 0 {
            let cell: CategorySelectCell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectCell") as! CategorySelectCell
            cell.bindValue = viewModel.genreId
            return cell
        }
        else {
            let cell: DatePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as! DatePickerCell
            cell.bindValue = viewModel.date
            return cell
        }
    }
}
