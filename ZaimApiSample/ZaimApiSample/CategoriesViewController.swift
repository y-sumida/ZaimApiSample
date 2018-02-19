//
//  CategoriesViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class CategoriesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: CategoriesViewModel = CategoriesViewModel()
    private var originarlCategoryId: Category!
    private var originarlGenreId: Genre!
    var categoryId: Variable<Category?>! {
        didSet {
            originarlCategoryId = categoryId.value
        }
    }
    var genreId: Variable<Genre?>! {
        didSet {
            originarlGenreId = genreId.value
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "カテゴリー"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
        let categoryNib = UINib(nibName: "CategorySelectCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "CategorySelectCell")

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 11.0, *) {
            tableView.contentInset.bottom = view.safeAreaInsets.bottom
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        categoryId.value = originarlCategoryId
        genreId.value = originarlGenreId
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.categories.count > indexPath.row else { return }

        categoryId.value = viewModel.categories[indexPath.row]

        // ジャンル選択画面へ遷移
        let vc: GenresViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GenresViewController") as! GenresViewController
        vc.categoryId = categoryId
        vc.genreId = genreId

        // ナビゲーション
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.categories.count > indexPath.row else { return UITableViewCell() }

        let cell: CategorySelectCell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectCell") as! CategorySelectCell
        cell.categoryLabel.text = viewModel.categories[indexPath.row].name
        return cell
    }
}
