//
//  RouterOperationStoryBoard.swift
//  proveng
//
//  Created by Dmitry Kulakov on 21.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

/**
 
 Open ViewController from StoryBoard
 
 */

enum RouterOperationStoryBoard {
    
    case openLogin
    case openPromo
    
    var baseViewController: BaseViewControllerProtocol {
        switch self {
        case .openLogin: return UIStoryboard(name: Constants.StoryBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier) as! LoginViewController
        case .openPromo: return UIStoryboard(name: Constants.StoryBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier) as! PromoViewController
        }
    }
    var identifier: String {
        switch self {
        case .openLogin:
            return "LoginVCIdentifier"
        case .openPromo:
            return "PromoVCIdentifier"
        }
    }
    
    var navigationBarHidden: Bool {
        switch self {
        case .openPromo:
            return true
        default:
            return false
        }
    }
}

extension RouterOperationStoryBoard: RouteOperation {
    func startOperation(_ router: Router) -> BaseViewControllerProtocol? {
        let baseViewController = self.baseViewController as! UIViewController
        baseViewController.router.navigationController?.setNavigationBarHidden(self.navigationBarHidden, animated: false)
        router.navigationController?.pushViewController(baseViewController, animated: true)
        return self.baseViewController
    }
}
