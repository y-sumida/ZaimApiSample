//
//  GenresViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/22.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class GenresViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let bag: DisposeBag = DisposeBag()
    private var viewModel: GenresViewModel?

    var categoryId: Variable<PaymentCategory?>!
    var genreId: Variable<Genre?>!

    deinit {
        print("Genres deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = categoryId.value {
            viewModel = GenresViewModel(categoryId: id.rawValue)
        }

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "ジャンル"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
        let categoryNib = UINib(nibName: "GenreSelectCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "GenreSelectCell")

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
}

extension GenresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = viewModel, vm.genres.count > indexPath.row else { return }

        genreId.value = vm.genres[indexPath.row]
        categoryId.value = PaymentCategory(rawValue: (genreId.value?.categoryId)!)
        self.dismiss(animated: true, completion: nil)
    }
}

extension GenresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.genres.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel, vm.genres.count > indexPath.row else { return UITableViewCell() }

        let cell: GenreSelectCell = tableView.dequeueReusableCell(withIdentifier: "GenreSelectCell") as! GenreSelectCell
        cell.genreLabel.text = vm.genres[indexPath.row].name
        return cell
    }
}
