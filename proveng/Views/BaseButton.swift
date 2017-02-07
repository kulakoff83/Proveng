//
//  BaseButton.swift
//  proveng
//
//  Created by Dmitry Kulakov on 19.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

@IBDesignable

class BaseButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.backgroundColor = ColorForElements.main.color
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    }

}

