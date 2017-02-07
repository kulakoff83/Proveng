//
//  BaseSegmentedControl.swift
//  proveng
//
//  Created by Виктория Мацкевич on 19.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class BaseSegmentedControl: UISegmentedControl {
    
    override func draw(_ rect: CGRect) {
        self.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
        self.tintColor = .white
    }    
}
