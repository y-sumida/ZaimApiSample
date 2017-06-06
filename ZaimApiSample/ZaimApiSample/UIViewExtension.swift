//
//  UIViewExtension.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/06/06.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//
import UIKit

extension UIView {
    func searchFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }

        for subview in self.subviews {
            if let responder:UIResponder = subview.searchFirstResponder() {
                return responder
            }
        }

        return nil
    }
}
