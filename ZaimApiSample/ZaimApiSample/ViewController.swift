//
//  ViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/16.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // APIKey読み取り
        guard let path: URL = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist") else {
            return
        }
        do {
            let data: Data = try Data(contentsOf: path)
            let keys = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
            dump(keys)
        }
        catch {
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

