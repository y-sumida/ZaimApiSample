//
//  EditViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/20.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "編集"
            navigationItem.hidesBackButton = false
        }

        //
        registerButton.layer.cornerRadius = 4.0

        tableView.delegate = self
        tableView.dataSource = self
        let textNib = UINib(nibName: "TextEditCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "TextEditCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapRegisterButton(_ sender: Any) {
        // TODO 登録処理
    }

    @IBAction func tapCacelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditViewController: UITableViewDelegate {
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
            return 3 // カテゴリ、メモ、日付
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: TextEditCell = tableView.dequeueReusableCell(withIdentifier: "TextEditCell") as! TextEditCell
            cell.placeholder = "金額"
            cell.keyboardType = .numberPad
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
}
