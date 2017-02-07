//
//  RouteOperations.swift
//  proveng
//
//  Created by Dmitry Kulakov on 12.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

extension UIViewController {
    var router: Router {
        return (UIApplication.shared.delegate as! AppDelegate).router!
    }    
}

protocol BaseViewControllerProtocol {
    
}

protocol RouteOperation {
    func startOperation(_ router: Router) -> BaseViewControllerProtocol?
}













