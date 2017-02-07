//
//  EditeLessonWorkshopViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

protocol EditLessonWorkshopViewControllerDelegate: class {
    func eventDidChanged(_ event: Event)
}

class EditLessonWorkshopViewController: BaseFormViewController {
    
    @IBOutlet weak var cancelEventButton: UIButton!
    weak var event: Event!
    weak var delegate: EditLessonWorkshopViewControllerDelegate?
    var eventType = ""
    var members = [UserPreview]()

    override func viewDidLoad() {
        super.viewDidLoad()
        for member in event.members{
            members.append(member)
        }
        if let type = event?.type {
            eventType = type
        }
        confifigureEventForm()
        configureNavigationBar()
        cancelEventButton.setTitleColor(ColorForElements.additional.color, for: UIControlState.normal)
        self.cancelEventButton.setTitle("\(Constants.CancelActionTitle) \(self.eventType)", for: UIControlState())
        cancelEventButton.layer.borderWidth = 1
        cancelEventButton.layer.borderColor = ColorForElements.background.color.cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configure Table Form
    
    func confifigureEventForm() {
        configureTableView()
        _ = self.addSection()
        _ = self.addNameRow(title: self.eventType + " title", icon: IconForElements.eventName.icon, value: event?.eventName)
        if event.typeEnum == .lesson {
            let groupName = event.group?.groupName != nil ? event.group?.groupName : Constants.GroupName
            _ = self.addLabelRow(title: groupName, icon: IconForElements.groupName.icon)
        }
        let groupLevel = event.group?.groupLevel != nil ? event.group?.groupLevel?.capitalized : Constants.GroupLevel
        _ = self.addLabelRow(title: groupLevel, icon: IconForElements.groupLevel.icon)
        
        self.createEventSection(event: self.event, startDate: event?.dateStart)

        let noteSection = self.addSection()
        noteSection.footer?.height = {44}
        _ = self.addTextAreaRow(title: Constants.NotesKey, icon: IconForElements.notes.icon, value: self.event.note)
    }
    
    func configureTableView() {
        self.view.insertSubview(self.tableView!, belowSubview: self.cancelEventButton)
    }
    
    // MARK: - Actions
    
    func editLesson() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var currentEvent = Event()
        firstly {
            BaseModel.mappedCopy(self.event)
        }.then { mapedEvent -> Promise<Location> in
            currentEvent = mapedEvent
            if let locationRow = self.form.rowBy(tag: Constants.Location) as? PushRow<String>, let place = locationRow.value {
                return ServiceForData<Location>().getDataByKeyFromStoragePromise("place", filterValue: place)
            } else {
                return Promise(value: Location())
            }
        }.then { location -> Promise<Location> in
            return BaseModel.mappedCopy(location)
        }.then { mapedLocation -> Promise<Event> in
            if let row: NameRow = self.form.rowBy(tag: self.eventType + " title"), let name = row.value {
                currentEvent.eventName = name
            }
            currentEvent.location = mapedLocation
            if let date = (self.form.rowBy(tag: Constants.Started) as? DateInlineRow)?.value, let timeBeginDate = (self.form.rowBy(tag: Constants.StartTime) as? TimeInlineRow)?.value, let timeEndDate = (self.form.rowBy(tag: Constants.EndTime) as? TimeInlineRow)?.value {
                currentEvent.dateStart = timeBeginDate.changeDayByOtherDate(date)
                currentEvent.dateEnd = timeEndDate.changeDayByOtherDate(date)
            }
            currentEvent.note = self.form.rowBy(tag: Constants.NotesKey)?.value
            currentEvent.regular = "Once"
            let leader = UserPreview()
            leader.objectID = SessionData.id
            currentEvent.leader = leader
            return Promise(value: currentEvent)
        }.then { event -> Promise<Event> in
            return ServiceForRequest<Event>().getObjectPromise(ApiMethod.updateEvent(event: event))
        }.then { event -> Promise<String> in
            let realm = try Realm()
            try realm.write {
                for member in self.members {
                    event.members.append(member)
                }
                realm.add(event, update: true)
            }
            if event.objectID != self.event.objectID {
                let currentEventID = self.event.objectID
                currentEvent = event
               return ServiceForData<Event>().deleteDataFromStoragePromise(currentEventID as AnyObject)
            } else {
               return Promise(value: "")
            }
        }.then { status -> Void in
            if status == "Success" {
                self.delegate?.eventDidChanged(currentEvent)
            }
            self.backToPrevVC()
        }.always { [weak self] in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
   
    @IBAction func cancelEventButtonPressed(_ sender: AnyObject) {
        let operation = RouterOperationAlert.showConfirmingEditEvent(eventType: self.eventType.lowercased()) { alertAction in
            self.cancelEventButton.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let groupID = self.event?.group?.objectID
            firstly{
                ServiceForRequest<Event>().deleteObjectPromise(self.event.objectID as AnyObject, operation: ApiMethod.deleteEvent(eventID: self.event.objectID))
            }.then { [weak self] data -> Void in
                if self!.eventType == "Workshop" {
                    _ = ServiceForData<GroupPreview>().deleteDataFromStoragePromise(groupID as AnyObject)
                }
                let operation = RouterOperationBack.backToHome
                self!.router.performOperation(operation)
            }.always { [weak self] in
                self?.cancelEventButton.isEnabled = true
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }.catch { [weak self] error in
                self?.handleError(error: error)
            }
        }
        self.router.performOperation(operation)
    }
}

extension EditLessonWorkshopViewController {
    
    func configureNavigationBar() {
        self.title = "\(Constants.EditLessonWorkshopControllerTitle) \(self.eventType.lowercased())"
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backToPrevVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneButtonPressed() {
        if event.typeEnum == .workshop {
            guard validateRow(self.eventType + " title") == true else {
                return
            }
        }
        guard validateStartEndDateRow(Constants.StartTime, endTag: Constants.EndTime) == true else {
            return
        }
        guard validatePushRowString(Constants.Location, rowTitle: Constants.Location) == true else {
            return
        }
        editLesson()
    }
}
