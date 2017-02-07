//
//  RouteOperationBack.swift
//  proveng
//
//  Created by Dmitry Kulakov on 25.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

enum RouterOperationBack {
    
    case backToLogin
    case backToTestPreview(testID: Int)
    case close
    case backToHome
    
    func baseViewController(_ router:Router) -> BaseViewControllerProtocol? {
        switch self {
        case .backToLogin:
            if let loginVC = router.viewControllerWithType(LoginViewController.self) as? BaseViewControllerProtocol {
                return loginVC
            } else {
                let operation = RouterOperationXib.openLogin
                router.performOperation(operation)
                if let loginVC = (router.navigationController?.viewControllers.last) as? LoginViewController {
                    return loginVC
                }
                return nil
            }
        case .backToTestPreview(let testID):
            if let testVC = router.viewControllerWithType(TestPreviewViewController.self) as? BaseViewControllerProtocol {
                return testVC
            } else {
                let operation = RouterOperationXib.openTestPreview(testID: testID)
                router.performOperation(operation)
                if let testVC = (router.navigationController?.viewControllers.last) as? TestPreviewViewController {
                    return testVC
                }
                return nil
            }
        case .close:
            if let presentedVC = router.navigationController?.presentedViewController {
                return presentedVC.dismiss(animated: true, completion: nil) as? BaseViewControllerProtocol
            } else {
                return router.navigationController?.popViewController(animated: true) as? BaseViewControllerProtocol
            }
        case .backToHome:
            let homeVC = router.viewControllerWithType(TeacherHomeTabBarController.self) as? BaseViewControllerProtocol
            return homeVC
        }
    }
    
    var ignoreStartOperation: Bool {
        switch self {
        case .close:
            return true
        default:
            return false
        }
    }
}

extension RouterOperationBack: RouteOperation {
    
    func startOperation(_ router: Router) -> BaseViewControllerProtocol? {
        if let loginVC = self.baseViewController(router) as? UIViewController {
            if !self.ignoreStartOperation {
                _ = router.navigationController?.popToViewController(loginVC, animated: true)
                router.navigationController?.setNavigationBarHidden(true, animated: false)
            }
        }
        return nil
    }
}
