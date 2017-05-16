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
    var oauthswift: OAuthSwift?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapButton(_ sender: Any) {
        // APIKey読み取り
        guard let path: URL = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist") else {
            return
        }

        var consumerKey: String = ""
        var consumerSecret: String = ""
        do {
            let data: Data = try Data(contentsOf: path)
            let keys = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
            consumerKey = keys?["consumerKey"] as! String
            consumerSecret = keys?["consumerSecret"] as! String
        }
        catch {
            return
        }

        let oauthswift = OAuth1Swift(
            consumerKey:    consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: "https://api.zaim.net/v2/auth/request",
            authorizeUrl:    "https://auth.zaim.net/users/auth",
            accessTokenUrl:  "https://api.zaim.net/v2/auth/access"
        )
        self.oauthswift = oauthswift
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "myzaimapp://oauth-callback")!,
            success: { credential, response, parameters in

                _ = oauthswift.client.get("https://api.zaim.net/v2/home/user/verify",
                                      success: { response in
                                        let dataString = response.string
                                        print(dataString ?? "")
                },
                                      failure: { error in
                                        print(error)
                }
                )
        },
            failure: { error in
                print(error.description)
        }
        )
    }

}

