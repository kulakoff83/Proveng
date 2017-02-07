//
//  BaseLoadViewProtocol.swift
//  proveng
//
//  Created by Dmitry Kulakov on 11.11.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

protocol BaseLoadViewProtocol { }

extension BaseLoadViewProtocol where Self: UIViewController {
    
    func showLoadingView() {
        let loadView = LoadingView(frame: self.view.bounds)
        self.navigationController?.view.addSubview(loadView)
        self.navigationController?.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        loadView.startIndicator()
    }
    
    func hideLoadingView() {
        var loadView: LoadingView? = self.navigationController?.view.subviews.last as? LoadingView
        guard let subviews = self.navigationController?.view.subviews else {
            return
        }
        for view in subviews {
            if view is LoadingView {
                loadView = view as? LoadingView
            }
        }
        self.navigationController?.view.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        loadView?.removeFromSuperview()
        loadView?.stopIndicator()
    }
}
