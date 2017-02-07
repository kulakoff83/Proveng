//
//  PhotoLabelCell.swift
//  proveng
//
//  Created by Виктория Мацкевич on 05.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class PhotoLabelCell: Cell<Bool>, CellType {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chekLabel: UILabel!
    @IBOutlet weak var cellSwitch: BaseSwitch!
    @IBOutlet weak var checkImageView: UIImageView!
    
    @IBOutlet weak var dateLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customImageViewWidthConstraint: NSLayoutConstraint!
    
    var useCheck = false
    var useSwitch = false
    var fromTest = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.tintColor = ColorForElements.additional.color
    }
    
    override func setup() {
        super.setup()
        self.nameLabel.font = Constants.lightFont
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(_ title: String?, imageURL: String? = nil) {
        self.nameLabel.text = title
        if let imageURL = imageURL, let URL = URL(string: imageURL) {
            userImageView.requestImage(URL)
        } else {
            userImageView.constraints[1].constant = 0
        }
    }
    
    func configureWithUser(_ user: UserPreview) {
//        var name = "slkdj sdjflk jsdklfj lksajd lkfj klsdjfkljskdlfj kjdjf sjf kjsdkfj k sjkdfjk sjdkfj ksjkfdj"
        var name = ""
        if let firstName = user.firstName {
            name = firstName + " "
        }
        if let lastName = user.lastName {
            name += lastName
        }
        if user.objectID == SessionData.id {
            name += " (You)"
            self.nameLabel.textColor = ColorForElements.additional.color
        }
        self.nameLabel.text = name
        self.userImageView.backgroundColor = ColorForElements.background.color
        self.userImageView.layer.cornerRadius = self.userImageView.constraints[0].constant / 2
        if let url = user.imageURL, let imageUrl = URL(string: url) {
            userImageView.requestImage(imageUrl)
        } else {
            self.userImageView.image = IconForElements.noPhoto.icon
        }
        if self.useCheck {
            for dayBook in user.dayBook {
                if dayBook.type == "StartTest", let markDate = dayBook.markDate {
                    self.dateLabel.text = markDate.formattedDateStringWithFormat("dd.MM.yy")
                }
            }
        }
        if self.useSwitch {
            self.cellSwitch.isHidden = false
            self.cellSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        }
    }
    
    func configureWithType(_ type: String) {
        self.nameLabel.text = type
        let iconWidth: CGFloat = 20
        self.configureCellElementsWithIconWidth(iconWidth)
        if type == "Lesson" {
            self.userImageView.image = IconForElements.lesson.icon
        } else if type == "Workshop" {
            self.userImageView.image = IconForElements.workshop.icon
        } else {
            let iconWidth: CGFloat = 10
            self.configureCellElementsWithIconWidth(iconWidth)
            self.userImageView?.layer.cornerRadius = iconWidth/2
            self.userImageView.image = UIImage.createImageFromTabIcon()
        }
    }
    
    func configureWithLevel(_ level: String) {
        self.nameLabel.text = level
        let iconWidth: CGFloat = 10
        self.configureCellElementsWithIconWidth(iconWidth)
        self.userImageView?.layer.cornerRadius = iconWidth/2
        if let colorTag = ServiceForBasicValue.sharedInstance.getlevelColorTags()[level] {
            self.userImageView.backgroundColor = colorTag
        } else {
            self.userImageView.backgroundColor = UIColor.gray
        }
    }
    
    func configureWithAnswer(_ answer: String, number: Int) {
        self.nameLabel.text = "\(number). \(answer)"
        self.selectionStyle = .none
        self.userImageView.isHidden = true
        self.dateLabel.isHidden = true
        self.customImageViewWidthConstraint.constant = 0
        self.fromTest = true
    }
    
    func configureCellElementsWithIconWidth(_ iconWidth: CGFloat) {
        self.selectionStyle = .none
        self.dateLabel.isHidden = true
        self.customImageViewWidthConstraint.constant = iconWidth
        self.customImageViewHeightConstraint.constant = iconWidth
        self.dateLabelHeightConstraint.constant = 0
    }
    
    func switchValueChanged(){
        row.value = self.cellSwitch.isOn
        self.row.updateCell()
    }
    
    override func update() {
        super.update()
        if useCheck {
            self.checkImageView.image = row.value == true ? IconForElements.checkmark.icon : UIImage()
            if self.fromTest {
                self.nameLabel.textColor = row.value == true ? ColorForElements.additional.color : ColorForElements.text.color
            }
        }
    }
    
    override func didSelect() {
        super.didSelect()
        if useCheck {
            row.value = row.value ?? false ? false : true
            row.deselect()
            row.updateCell()
        }
    }
}

final class PhotoLabelRow: Row<PhotoLabelCell>, RowType {
    required internal init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<PhotoLabelCell>(nibName: "PhotoLabelCell")
    }
}
