//
//  BaseFormExtension.swift
//  proveng
//
//  Created by Виктория Мацкевич on 09.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import Eureka
import PromiseKit

extension BaseFormViewController {
    
    //Section
    func addSection(title: String? = "", footerTitle: String? = "", tag: String? = "") -> Section {
        let section = Section(header:title!, footer: footerTitle!){
            $0.tag = tag
            if title!.isEmpty {
                $0.header?.height = { CGFloat.leastNormalMagnitude + 25 }
            } else {
                $0.header?.height = { 45 }
            }
            if footerTitle!.isEmpty {
                $0.footer?.height = { CGFloat.leastNormalMagnitude}
            }
        }
        form +++ section
        return section
    }
    
    func addProfileHeader(user: User, teacher: Bool, userID: Int, isEdit: Bool = false) -> Section {
        let section = Section(footer:"") {
            $0.tag = Constants.ProfileInfoSectionName
            var header = HeaderFooterView<ProfileSectionHeader>(HeaderFooterProvider.nibFile(name: "ProfileSectionHeader", bundle: nil))
            let section = $0
            header.onSetupView = { (view, section) -> () in
                var name = ""
                if let firstName = user.firstName {
                    name = firstName + " "
                }
                if let lastName = user.lastName {
                    name += lastName
                }
                view.userName.text = name
                view.userImageView.backgroundColor = ColorForElements.background.color
                view.userImageView.layer.borderWidth = 4
                view.userImageView.layer.borderColor = UIColor.white.cgColor
                view.userImageView.clipsToBounds = true
                if let url = user.imageURL, let imageUrl = URL(string: url) {
                    view.userImageView.requestImage(imageUrl)
                } else {
                    view.userImageView.image = IconForElements.noPhoto.icon
                }
                view.pointsImage.image = IconForElements.points.icon
                view.levelImage.image = IconForElements.userLevel.icon
                if teacher && SessionData.id == userID {
                    view.userPoints.isHidden = true
                    view.userLevelLabel.isHidden = true
                    view.userDeparment.isHidden = true
                    view.levelImage.isHidden = true
                    view.pointsImage.isHidden = true
                } else {
                    var points = 0
                    let predicate = NSPredicate(format: "type =[c] %@","totalPoints")
                    if let totalPoints = user.dayBook.filter(predicate).first {
                        points = totalPoints.mark
                    }
                    view.userPoints.text = String(points) + " points"
                    if !isEdit {
                        view.userDeparment.text = user.department?.name
                    } else {
                        view.userDeparment.text = ""
                    }
                    if let level = user.level {
                        view.userLevelLabel.text = level.capitalized
                        view.userLevelLabel.sizeToFit()
                    } else {
                        view.userLevelLabel.text = "No level"
                    }
                }
                view.updateHeight()
                view.bounds = CGRect(x: 0, y: 0, width: 320, height: view.viewHeightConstraint.constant)
                view.layoutIfNeeded()
                view.setNeedsDisplay()
            }
            section.header = header
            section.footer?.height = { CGFloat.leastNormalMagnitude}
        }
        form +++ section
        return section
    }
    
    // Base Row
    func addButtonPushRow(title: String, icon: UIImage? = nil, tag: String? = "", accessoryType: UITableViewCellAccessoryType? = .disclosureIndicator, section: Section? = nil) -> ButtonPushRow {
        let row = ButtonPushRow() {
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.cellSetup { (cell, row) in
                if icon != nil {
                    cell.imageView?.image = icon
                }
            }
            $0.cell.accessoryType = accessoryType!
        }
        if let sectionAfter = section {
            sectionAfter <<< row
        } else {
            form.last! <<< row
        }
        return row
    }
    
    func addLabelRow(title: String? = "", icon: UIImage, value: String? = "", tag: String? = "") -> LabelRow {
        let row = LabelRow() {
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.value = value
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
            cell.detailTextLabel?.textColor = .black
        }
        form.last! <<< row
        return row
    }
    
    func addAccountRow(title: String, icon: UIImage, value: String? = "", tag: String? = "") -> AccountRow {
        let row = AccountRow() {
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.value = value
            }.cellSetup { cell, row in
                cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addNameRow(title: String, icon: UIImage, value: String? = "", tag: String? = "") -> NameRow {
        let row = NameRow() {
            $0.tag = (tag != "") ? tag : title
            $0.placeholder = title
            $0.value = value
        } .onCellHighlightChanged { cell, row in
            cell.backgroundColor = UIColor.white
        } .cellSetup { cell, row in
            cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addPhoneRow(title: String, icon: UIImage, value: String? = "", tag: String? = "") -> PhoneRow {
        let row = PhoneRow() {
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.value = value
            }.cellSetup { cell, row in
                cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addPushRow(title: String, icon: UIImage, options: [String],  value: String? = "", tag: String? = "", section: Section? = nil) -> PushRow<String> {
        let row = PushRow<String>() {
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.options = options
            if let valueString = value {
                $0.value = valueString
            }
            $0.selectorTitle = title
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
        }.onCellSelection { cell, row in
            cell.backgroundColor = UIColor.white
        }
        if let sectionAfter = section {
            sectionAfter <<< row
        } else {
            form.last! <<< row
        }
        return row
    }
    
    func addDateInlineRow(title: String, icon: UIImage, value: Date? = Date(), tag: String? = "") -> DateInlineRow {
        let row = DateInlineRow(){
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.value = value
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            formatter.locale = Locale(identifier: "en-US")
            $0.dateFormatter = formatter
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addPickerInlineRow(title: String, icon: UIImage, options: [String], value: String? = "", tag: String? = "") -> PickerInlineRow<String> {
        let row = PickerInlineRow<String>() { (row : PickerInlineRow<String>) -> Void in
            row.tag = (tag != "") ? tag : title
            row.title = title
            row.options = options
            row.value = value
        }.onCellSelection { cell, row in
            cell.backgroundColor = UIColor.white
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addCountUsersRow(title: String, count: Int? = 0, tag: String, color: UIColor? = ColorForElements.additional.color, plusText: String? = "+",  accessoryType: UITableViewCellAccessoryType? = UITableViewCellAccessoryType.none) -> CountUsersRow {
        let row = CountUsersRow() {
            $0.tag = tag
            $0.cell.configureCountUserCell(title: title, count: count!, color: color, plusText: plusText, accessoryType: accessoryType)
        }
        form.last! <<< row
        return row
    }
    
    func addPhotoLabelRow(user: UserPreview? = nil, level: String? = "", type: String? = "", title: String? = "", useCheck: Bool? = false, useSwitch: Bool? = false, tag: String, value: Bool? = false, section: Section? = nil) -> PhotoLabelRow {
        let row = PhotoLabelRow() {
            $0.tag = tag
            $0.cell.useCheck = useCheck!
            $0.cell.useSwitch = useSwitch!
            $0.value = value!
            if useSwitch! {
                $0.cell.cellSwitch.isOn = value!
                $0.cell.selectionStyle = .none
            }
            $0.cell.height = { 44 }
            if user != nil {
                $0.cell.configureWithUser(user!)
            } else if level != "" {
                $0.cell.configureWithLevel(level!)
            } else if type != "" {
                $0.cell.configureWithType(type!)
            } else {
                $0.cell.configureCell(title)
            }
        }
        if let sectionAfter = section {
            sectionAfter <<< row
        } else {
            form.last! <<< row
        }
        return row
    }
    
    func addTextAreaRow(title: String, icon: UIImage, value: String? = "", tag: String? = "") -> TextAreaRow {
        let row = TextAreaRow() {
            $0.tag = (tag != "") ? tag : title
            $0.placeholder = title
            if value != "" {
                $0.value = value
            }
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 20)
        }.onCellHighlightChanged { cell, row in
            cell.backgroundColor = UIColor.white
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    func addTestRow(value: TestPreview, icon: UIImage? = nil, tag: String, section: Section? = nil) -> TestRow {
        let row = TestRow() {
            $0.tag = tag
            $0.cell.configureTestCell(value)
            $0.cellSetup { (cell, row) in
                if icon != nil {
                    cell.imageView?.image = icon
                }
            }
        }
        if let sectionAfter = section {
            sectionAfter <<< row
        } else {
            form.last! <<< row
        }
        return row
    }
    
    func addCalendarRow(value: Event, icon: UIImage? = nil, tag: String) -> CalendarRow {
        let row = CalendarRow() {
            $0.tag = tag
            $0.cell.configureCell(value)
            $0.cellSetup { (cell, row) in
                if icon != nil {
                    cell.imageView?.image = icon
                }
            }
        }
        form.last! <<< row
        return row
    }
    
    func addSegmentedRow(options: [String], value: String, tag: String) -> SegmentedRow<String> {
        let row = SegmentedRow<String>() {
            $0.tag = tag
            $0.options = options
            $0.value = value
        }
        form.last! <<< row
        return row
    }
    func addTimeInlineRow(title: String, icon: UIImage, value: Date? = Date(), tag: String? = "") -> TimeInlineRow {
        let row = TimeInlineRow(){
            $0.tag = (tag != "") ? tag : title
            $0.title = title
            $0.value = value
        }.cellSetup { cell, row in
            cell.imageView?.image = icon
        }
        form.last! <<< row
        return row
    }
    
    // Not Base row
    
    func createDepartmentRow(departmentValue: String? = "", titleSection: String) {
        var department = ServiceForBasicValue().getDepartment()
        firstly {
            ServiceForData<Department>().getDataArrayFromStoragePromise("name", ascending: true)
        }.then { departments -> Void in
            department.removeAll()
            for oneDepartment in departments {
                if let name = oneDepartment.name {
                    department.append(name)
                }
            }
        }.always{
            _ = self.addPushRow(title: Constants.DepartmentName, icon: IconForElements.department.icon, options: department, value: departmentValue, section: self.form.sectionBy(tag: titleSection))
            }.catch { error in
                print(error)
        }
    }
    
    func createLevelsRow(levelValue: String? = "", titleSection: String) {
        var baseLevels = ServiceForBasicValue().getGroupLevels()
        firstly {
            ServiceForData<GroupLevelPreview>().getDataResultsByIDFromStoragePromise(0)// need changed
        }.then { levels -> Void in
            baseLevels.removeAll()
            for level in levels {
                if let name = level.name {
                    baseLevels.append(name.capitalized)
                }
            }
        }.always{
            _ = self.addPushRow(title: Constants.GroupLevel, icon: IconForElements.groupLevel.icon, options: baseLevels, value: levelValue?.capitalized, section: self.form.sectionBy(tag: titleSection))
        }.catch { error in
            print(error)
        }
    }
    
    func createLocationRow(locationValue: String?, titleSection: String, tag: String? = "") {
        var location = ServiceForBasicValue().getGroupLocation()
        firstly {
            ServiceForData<Location>().getDataArrayFromStoragePromise("place", ascending: true)
        }.then { locations -> Void in
            location.removeAll()
            for oneLocation in locations {
                if let locationPlace = oneLocation.place {
                    location.append(locationPlace)
                }
            }
        }.always{
            _ = self.addPushRow(title: Constants.Location, icon: IconForElements.location.icon, options: location, value: locationValue, tag: tag, section: self.form.sectionBy(tag: titleSection))
        }.catch { error in
            print(error)
        }
    }
    
    func createStartEndTimeRows(startTime: Date, endTime: Date, startTag: String, endTag: String) {
        self.addTimeInlineRow(title: Constants.StartTime, icon: IconForElements.time.icon, value: startTime, tag: startTag).onChange { [weak self] row in
            if let endRow: TimeInlineRow = self?.form.rowBy(tag: endTag), let value = row.value {
                endRow.value = NSDate(timeInterval: self!.lessonTimeInterval, since: value) as Date
                endRow.cell?.backgroundColor = .white
                endRow.updateCell()
            }
        }.onExpandInlineRow { cell, row, inlineRow in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
        self.addTimeInlineRow(title: Constants.EndTime, icon: IconForElements.time.icon, value: endTime, tag: endTag).onChange { [weak self] row in
            if let startRow: TimeInlineRow = self?.form.rowBy(tag: startTag), let value = startRow.value {
                if row.value?.compare(value) == .orderedDescending {
                    row.cell!.backgroundColor = .white
                } else {
                    row.cell!.backgroundColor = Constants.errorColor
                }
                row.updateCell()
            }
        }.onExpandInlineRow { cell, row, inlineRow in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    func addAnswerRow(_ answer: TestAnswer, testIndex: Int, answered: Bool) -> PhotoLabelRow {
        let row = PhotoLabelRow()
        row.tag = "answer\(index)"
        row.cell.height = { 50 }
        row.cell.useCheck = true
        row.value = answered
        row.cell.checkImageView.tintColor = ColorForElements.additional.color
        row.cell.configureWithAnswer(answer.text!, number: testIndex + 1)
        form.last! <<< row
        return row
    }
    
    //Base Block
    
    func createLessonSections(group: Group? = Group()) {
        for i in 1 ..< 3 {
            var startTime = self.formStartTime
            var endTime = self.formEndTime
            var repeatInterval = self.interval
            var locationValue = ""
            let titleSection = "Lesson \(i)"
            if group!.scheduleEvents.count > 0, let lessonEvent = group?.scheduleEvents[i-1] {
                if let dateEnd = lessonEvent.dateEnd {
                    endTime = dateEnd
                }
                if let dateStart = lessonEvent.dateStart {
                    startTime = dateStart
                    repeatInterval = dateStart.getWeekdayByDate()
                }
                if let place = lessonEvent.location?.place {
                    locationValue = place
                }
            }
            _ = addSection(title: titleSection, tag: titleSection)
            self.createStartEndTimeRows(startTime: startTime, endTime: endTime, startTag: Constants.StartTime + "\(i)", endTag: Constants.EndTime + "\(i)")
            _ = self.addPushRow(title: Constants.Repeat, icon: IconForElements.regular.icon, options: ServiceForBasicValue().getRepeatInterval(), value: repeatInterval, tag: Constants.Repeat + "\(i)")
            self.createLocationRow(locationValue: locationValue, titleSection: titleSection, tag: Constants.Location + "\(i)")
        }    
    }
    
    func createEventSection(event: Event? = Event(), startDate: Date? = Date()) {
        _ = addSection(tag: Constants.InfoSection)
        let startTime = event?.dateStart != nil ? event?.dateStart : self.formStartTime
        let endTime = event?.dateEnd != nil ? event?.dateEnd : self.formEndTime
        _ = self.addDateInlineRow(title: Constants.Started, icon: IconForElements.date.icon, value: startDate)
        self.createStartEndTimeRows(startTime: startTime!, endTime: endTime!, startTag: Constants.StartTime, endTag: Constants.EndTime)
        self.createLocationRow(locationValue: event?.location?.place, titleSection: Constants.InfoSection, tag: Constants.Location)
    }
}
