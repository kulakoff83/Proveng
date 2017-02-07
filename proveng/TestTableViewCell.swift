//
//  TestTableViewCell.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class TestTableViewCell:  Cell<String>, CellType {
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setup() {
        super.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timeLabel.isHidden = false
        self.timeIconImageView.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureTestCell(_ test: TestPreview) {
        self.pointLabel.text = "\(String(describing: test.weight))"
        self.nameLabel.text = test.name
        let minutes = test.duration.minutes()
        if minutes > 0 {
            self.timeLabel.text = "\(String(describing: minutes)) min."
        } else {
            //                self.timeLabel.isHidden = true
            //                self.timeIconImageView.isHidden = true
            self.timeLabel.text = "free time"
        }
    }
}

final class TestRow: Row<TestTableViewCell>, RowType {
    required internal init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<TestTableViewCell>(nibName: "TestTableViewCell")
    }
}
