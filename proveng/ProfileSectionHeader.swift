//
//  ProfileSectionHeader.swift
//  proveng
//
//  Created by Виктория Мацкевич on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class ProfileSectionHeader: UIView {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLevelLabel: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var userName: UILabel!    
    @IBOutlet weak var userDeparment: UILabel!
    @IBOutlet weak var levelImage: UIImageView!    
    @IBOutlet weak var pointsImage: UIImageView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    override func draw(_ rect: CGRect) {
        self.userImageView.layer.cornerRadius = userImageView.frame.height / 2.0
    }
    
    func updateHeight() {
        if userLevelLabel.isHidden {
            self.viewHeightConstraint.constant = self.userName.frame.origin.y + self.userName.frame.size.height + 44
        } else {
            self.viewHeightConstraint.constant = self.userLevelLabel.frame.origin.y + self.userLevelLabel.frame.size.height + 44
        }
    }

}
