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

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "編集"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
