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
    var registerFinishTrigger: PublishSubject<Void>?

    fileprivate let sectionTitles:[String] = ["金額", "カテゴリー", "日付"]

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
                registerButton.setTitle("更新する", for: .normal)
                isEditMode = true
            }
            else {
                navigationItem.title = "登録"
                registerButton.setTitle("登録する", for: .normal)
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

        // キーボードイベント検知
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil)
            .bind { [unowned self] notification in
                self.keyboardWillShow(notification)
            }
            .addDisposableTo(bag)

        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil)
            .bind { [unowned self] notification in
                self.keyboardWillHide(notification)
            }
            .addDisposableTo(bag)
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
                if !(self?.isEditMode)! {
                    self?.registerFinishTrigger?.onNext(())
                }
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

    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let firstResponder: UIResponder = self.view.searchFirstResponder(),
            let textField: UITextField = firstResponder as? UITextField,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {

            tableView.contentInset = UIEdgeInsets.zero
            tableView.scrollIndicatorInsets = UIEdgeInsets.zero

            let convertedKeyboardFrame: CGRect = tableView.convert(keyboardFrame, from: nil)
            let convertedTextFieldFrame: CGRect = textField.convert(textField.frame, to: tableView)

            let offsetY: CGFloat = convertedTextFieldFrame.maxY - convertedKeyboardFrame.minY
            if offsetY > 0 {
                UIView.beginAnimations("ResizeForKeyboard", context: nil)
                UIView.setAnimationDuration(animationDuration)

                let contentInsets = UIEdgeInsetsMake(0, 0, offsetY, 0)
                tableView.contentInset = contentInsets
                tableView.scrollIndicatorInsets = contentInsets
                tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y + offsetY)

                UIView.commitAnimations()
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: TextEditCell = tableView.dequeueReusableCell(withIdentifier: "TextEditCell") as! TextEditCell
            cell.placeholder = "金額"
            cell.keyboardType = .numberPad
            cell.bindValue = viewModel.amount
            return cell
        case 1:
            let cell: CategorySelectCell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectCell") as! CategorySelectCell
            cell.bindValue = viewModel.genreId
            return cell
        case 2:
            let cell: DatePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as! DatePickerCell
            cell.bindValue = viewModel.date
            return cell
        default:
            return UITableViewCell()
        }
    }
}
