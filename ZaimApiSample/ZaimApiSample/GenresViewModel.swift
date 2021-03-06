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
    var category: Category!

    init(categoryId: Int) {
        realm = try! Realm()
        genres = realm.objects(Genre.self).filter("categoryId == %@ and active == 1", categoryId).map { $0 }
        category = realm.objects(Category.self).filter("id == %@", categoryId).map { $0 }.first
    }
}
