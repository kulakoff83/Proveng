//
//  RouteOperationSwitchTabBar.swift
//  proveng
//
//  Created by Dmitry Kulakov on 21.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

/**
 
 Switch Child in UITabBarViewController
 
 */

enum RouterOperationSwitchTabBar {
    case openFeed
    case openLesson
    case openWorkShops
    case openChalenge
    
    var tag: Int {
        switch self {
        case .openFeed: return 0
        case .openLesson: return 1
        case .openWorkShops: return 2
        case .openChalenge: return 3
        }
    }
}

extension RouterOperationSwitchTabBar: RouteOperation {
    func startOperation(_ router: Router) -> BaseViewControllerProtocol? {
        let tabBarViewController = router.tabBarViewController
        tabBarViewController?.selectedIndex = self.tag
        return nil
    }
}
