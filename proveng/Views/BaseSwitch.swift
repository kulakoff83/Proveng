//
//  BaseSwitch.swift
//  proveng
//
//  Created by Виктория Мацкевич on 08.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class BaseSwitch: UISwitch {
    
    override func draw(_ rect: CGRect) {
        self.tintColor = ColorForElements.additional.color
        self.onTintColor = ColorForElements.additional.color
    }
    
}
