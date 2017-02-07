//
//  PendingStudentsTableViewCell.swift
//  proveng
//
//  Created by Dmitry Kulakov on 03.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class CountUsersTableViewCell: Cell<String>, CellType {

    @IBOutlet weak var countPendingStudentsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setup() {
        super.setup()
        self.titleLabel.font = Constants.lightFont
        self.countPendingStudentsLabel.sizeToFit()
        self.titleLabel.sizeToFit()
    }
    
    func configureCountUserCell(title: String, count: Int, color: UIColor? = ColorForElements.additional.color, plusText: String? = "+", accessoryType: UITableViewCellAccessoryType? = UITableViewCellAccessoryType.none) {
        self.countPendingStudentsLabel.text = "\(count)"
        self.titleLabel.text = title
        self.selectionStyle = .none
        self.accessoryType = accessoryType!        
        if count != 0 {
            self.plusLabel.text = plusText
        }
        self.plusLabel.textColor = color
        self.colorView.backgroundColor = color        
        self.countPendingStudentsLabel.textColor = .white
        self.countPendingStudentsLabel.backgroundColor = color
        self.countPendingStudentsLabel.layer.cornerRadius = 5
        self.countPendingStudentsLabel.clipsToBounds = true
    }
}

final class CountUsersRow: Row<CountUsersTableViewCell>, RowType {
    
    required internal init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CountUsersTableViewCell>(nibName: "CountUsersTableViewCell")
    }
}
