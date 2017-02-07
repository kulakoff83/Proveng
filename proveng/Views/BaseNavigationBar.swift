//
//  BaseNavigationBar.swift
//  proveng
//
//  Created by Dmitry Kulakov on 19.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class BaseNavigationBar: UINavigationBar {
    
    var baseNavigationItem = UINavigationItem()


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.items = [baseNavigationItem]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
