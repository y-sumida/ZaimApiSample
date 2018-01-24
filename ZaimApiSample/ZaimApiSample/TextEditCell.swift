//
//  TextEditCell.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextEditCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!

    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    private var bag: DisposeBag!
    var bindValue: Variable<Int>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .distinctUntilChanged()
                .subscribe(onNext: {[weak self] value in
                    self?.textField.text = value.description
                })
                .disposed(by: bag)

            self.textField.rx.text
                .bind { string in
                    if let value: String = string, let amount: Int = Int(value) {
                        self.bindValue.value = amount
                    }
                }
                .disposed(by: bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        // Doneボタン
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeKeyboard))
        toolbar.items = [flexible, done]
        textField.inputAccessoryView = toolbar

        self.selectionStyle = .none
    }

    override func prepareForReuse() {
        placeholder = ""
        textField.text = ""
        keyboardType = .default
        textField.isUserInteractionEnabled = true
    }
}

extension TextEditCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    @objc func closeKeyboard() {
        textField.resignFirstResponder()
    }
}
