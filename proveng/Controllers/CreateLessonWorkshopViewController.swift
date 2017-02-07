//
//  CreateLessonWorkshopViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 15.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit

class CreateLessonWorkshopViewController: BaseFormViewController, TeacherGroupsViewControllerDelegate {
    
    var group: EventGroup = EventGroup()
    var workshopGroup: GroupPreview!
    var startDate : Date?
    var type = "Lesson"
    var fieldTitle = ""
    @IBOutlet weak var eventSegment: BaseSegmentedControl!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentImageView: UIImageView!
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workshopGroup = GroupPreview()
        self.configureNavigationBar()
        self.configureCreateLessonWorkshopForm()
        self.segmentView.backgroundColor = ColorForElements.main.color        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
    }
    
    func configureCreateLessonWorkshopForm() {
        self.view.insertSubview(self.tableView!, belowSubview: self.segmentView)
        self.addEventSection(type: self.type)
    }
    
    @IBAction func updateCell(_ sender: UISegmentedControl) {
        self.form.removeAll()
        switch sender.selectedSegmentIndex {
        case 0:
            self.type = "Lesson"
        case 1:
            self.type = "Workshop"
        default:
            break
        }
        self.addEventSection(type: self.type)
        tableView?.reloadData()
    }
    
    func addEventSection(type: String) {
        let mainSection = self.addSection(tag: "Main")
        mainSection.header?.height = {CGFloat.leastNormalMagnitude + 65}
        if type == Constants.WorkshopType {
            self.fieldTitle = "Workshop title"
            _ = self.addNameRow(title: self.fieldTitle, icon: IconForElements.eventName.icon)
        } else {
            self.addButtonPushRow(title: Constants.GroupName, icon: IconForElements.groupName.icon).onCellSelection{ (cell, row) in
                cell.backgroundColor = .white
                let operation = RouterOperationXib.openGroups(showPickerScreen: true)
                let destinationVC = self.router.performOperation(operation) as! TeacherGroupsViewController
                destinationVC.delegate = self
            }.cellUpdate{ (cell, row) in
                if let levelRow: LabelRow = self.form.rowBy(tag: Constants.GroupLevel) as? LabelRow {
                    levelRow.updateCell()
                }
                row.title = self.group.groupName == nil ? row.tag: self.group.groupName
            }
            self.addLabelRow(title: Constants.GroupLevel, icon: IconForElements.groupLevel.icon).cellUpdate{ (cell, row) in
                row.title = self.group.groupLevel == nil ? Constants.GroupLevel: self.group.groupLevel?.capitalized
            }
        }
        
        self.createEventSection(startDate: startDate)
        _ = self.addSection()
        _ = self.addTextAreaRow(title: Constants.NotesKey, icon: IconForElements.notes.icon)
    }
    
    func createEvent() {
        self.doneButton?.isEnabled = false
        firstly {
            if let locationRow = self.form.rowBy(tag: Constants.Location) as? PushRow<String>, let place = locationRow.value {
                return ServiceForData<Location>().getDataByKeyFromStoragePromise("place", filterValue: place)
            } else {
                return Promise(value: Location())
            }
        }.then { location -> Promise<Location> in
            return BaseModel.mappedCopy(location)
        }.then { mapedLocation -> Promise<Event> in
            let event = Event()
            event.type = self.type
            if let row: NameRow = self.form.rowBy(tag: "Workshop title"), let name = row.value {
                event.eventName = name
            } else {
                event.eventName = self.type
            }
            event.location = mapedLocation
            if let date = (self.form.rowBy(tag: Constants.Started) as? DateInlineRow)?.value, let timeBeginDate = (self.form.rowBy(tag: Constants.StartTime) as? TimeInlineRow)?.value, let timeEndDate = (self.form.rowBy(tag: Constants.EndTime) as? TimeInlineRow)?.value {
                event.dateStart = timeBeginDate.changeDayByOtherDate(date)
                event.dateEnd = timeEndDate.changeDayByOtherDate(date)
            }
            event.regular = "Once"
            if let noteRow = self.form.rowBy(tag: Constants.NotesKey) as? TextAreaRow, let noteValue = noteRow.value {
                event.note = noteValue
            }
            if event.typeEnum == .lesson {
                event.group = self.group
            }
            let leader = UserPreview()
            leader.objectID = SessionData.id
            event.leader = leader
            return Promise(value: event)
        }.then { event -> Promise<Event> in
            return ServiceForRequest<Event>().getObjectPromise(ApiMethod.createEvent(event: event))
        }.then { eventObject -> Void in
            self.backToPrevVC()
        }.always { [weak self] in
            self?.doneButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    // MARK: - TeacherGroupsViewControllerDelegate
    
    func groupRowDidSelected(_ group: GroupPreview) {
        self.group.objectID = group.objectID
        self.group.groupName = group.groupName
        self.group.groupLevel = group.groupLevel
    }
}
    
extension CreateLessonWorkshopViewController {
    
    func configureNavigationBar(){
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.backToPrevVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneButtonPressed() {
        if self.type == Constants.WorkshopType {
            guard validateRow(fieldTitle) == true else {
                return
            }
        } else {
            guard validateButtonPushRow(Constants.GroupName) == true else {
                return
            }
        }
        guard validateStartEndDateRow(Constants.StartTime, endTag: Constants.EndTime) == true else {
            return
        }
        
        guard validatePushRowString(Constants.Location, rowTitle: Constants.Location) == true else {
            return
        }
        self.createEvent()
    }
}
