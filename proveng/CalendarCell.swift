//
//  CalendarCell.swift
//  proveng
//
//  Created by Виктория Мацкевич on 15.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class CalendarCell:  Cell<String>, CellType {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var startLabelConstraint: NSLayoutConstraint!    
    @IBOutlet weak var startLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setup() {
        super.setup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(_ event: Event) {
        self.typeLabel.text = event.type
        self.nameLabel.text = event.eventName
        self.nameLabel.textColor = ColorForElements.main.color
        self.typeImage.image = UIImage.checkImage(named: event.type.lowercased())
        self.locationImage.image = UIImage.checkImage(named: "location")
        if event.type == "Lesson" {
            self.colorView.backgroundColor = Event.colorByType(eventType: EventType.lesson)
            if let groupName = event.group?.groupName, let groupLevel = event.group?.groupLevel {
                self.groupLabel.text = groupName + " (\(groupLevel.capitalized))"
            }
            self.typeImage.image = Event.iconByType(eventType: EventType.lesson)
        } else {
            self.typeImage.image = Event.iconByType(eventType: EventType.workshop)
            self.colorView.backgroundColor = Event.colorByType(eventType: EventType.workshop)
            self.groupLabel.text = event.group?.groupLevel?.capitalized
        }
        self.locationLabel.text = event.location?.place
        if let dateStart = event.dateStart, let dateEnd = event.dateEnd {
            if dateStart.timeIntervalSince(Date().makeLocalTime()) <= 3600 && dateStart.timeIntervalSince(Date().makeLocalTime()) >= 0{
                self.startLabelConstraint.constant = 12
                self.startLabel.textColor = ColorForElements.additional.color
            }
            self.timeLabel.text = dateStart.formattedDateStringWithFormat("HH:mm") + " - " + dateEnd.formattedDateStringWithFormat("HH:mm")
        }
    }
}

final class CalendarRow: Row<CalendarCell>, RowType {
    required internal init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CalendarCell>(nibName: "CalendarCell")
    }
}
