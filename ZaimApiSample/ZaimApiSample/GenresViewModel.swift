//
//  GenresViewModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2018/02/15.
//  Copyright © 2018年 Yuki Sumida. All rights reserved.
//

import RealmSwift

class GenresViewModel {
    private let realm: Realm
    var genres: [Genre] = []

    init(categoryId: Int) {
        realm = try! Realm()
        genres = realm.objects(Genre.self).map { $0 }.filter { $0.categoryId == categoryId }
    }
}
