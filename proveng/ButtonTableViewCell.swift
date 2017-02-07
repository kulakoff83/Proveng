//
//  GroupNameTableViewCell.swift
//  proveng
//
//  Created by Dmitry Kulakov on 03.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class ButtonTableViewCell: Cell<String>, CellType {
   
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
    }
    
    override func setup() {
        super.setup()
        self.titleLabel.font = Constants.lightFont
        self.textLabel?.font = Constants.lightFont
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

final class ButtonPushRow: Row<ButtonTableViewCell>, RowType {
    
    required internal init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<ButtonTableViewCell>(nibName: "ButtonTableViewCell")
    }
    
}
