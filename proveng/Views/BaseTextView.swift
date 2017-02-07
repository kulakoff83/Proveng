//
//  BaseTextView.swift
//  proveng
//
//  Created by Виктория Мацкевич on 08.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class BaseTextView: UITextView {
    
    override func draw(_ rect: CGRect) {
        self.textColor = ColorForElements.text.color
        self.font = Constants.lightFont
    }
    
}
