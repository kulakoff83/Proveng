//
//  LessonWorkshopDetailsViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import ObjectMapper
import RealmSwift
import Realm

class LessonWorkshopDetailsViewController: BaseFormViewController, EditLessonWorkshopViewControllerDelegate {
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    var teacher = false
    var eventID: Int = 0
    var event: Event!
    var group: GroupPreview?
    fileprivate var notificationToken: NotificationToken? = nil
    var isFeed = false
    lazy var dataServiceEvent = ServiceForData<Event>()
    lazy var dataServiceFeedEvent = ServiceForData<FeedEvent>()
    var visitedEvents: Results<EventPreview>!
    var eventActiveMethod: ApiMethod?
    var groupActiveMethod: ApiMethod?
    var acceptActiveMethod: ApiMethod?
    var cancelActiveMethod: ApiMethod?
    var doneButton: UIBarButtonItem?
    var finishRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.sendSubview(toBack: self.tableView!)
        self.setEvent(handler: self.configureElements)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNeededRows()
        self.configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.cancelEventRequest()
        }
    }
    
    deinit {
        notificationToken?.stop()
        print("Deinit Lesson/Workshop")
    }
    
    func configureElements() {
        self.confifigureEventForm()
        self.configureButtons()
        self.configureNavigationBar()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.request()
    }
    
    //MARK: Data
    
    func setEvent(handler: @escaping ()->()) {
        if isFeed {
            self.dataServiceFeedEvent.getObjectByID(id: self.eventID, handler: { [weak self] feedEvent in
                self?.event = feedEvent
                handler()
                })
        } else {
            dataServiceEvent.getObjectByID(id: self.eventID, handler: { [weak self] event in
                self?.event = event
                handler()
                })
        }
    }
    
    func configureEventRealmNotification() {
        firstly { [weak self] in
            self!.dataServiceEvent.getDataResultsByIDFromStoragePromise(self!.eventID)
            }.then { [weak self] events -> Void in
                self?.configureRealmNotification(objects: events)
            }.catch { error in
                print(error)
        }
    }
    
    func configureFeedEventRealmNotification() {
        firstly { [weak self] in
            self!.dataServiceFeedEvent.getDataResultsByIDFromStoragePromise(self!.eventID)
            }.then { [weak self] events -> Void in
                self?.configureRealmNotification(objects: events)
            }.catch { error in
                print(error)
        }
    }
    
    func configureRealmNotification<T>(objects: Results<T>) {
        // Observe Results Notifications
        self.notificationToken = objects.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .update(_, let deletions, _, _):
                if deletions.count > 0 {
                    self?.setEvent(handler: self!.updateNeededRows)
                } else{
                    self?.updateNeededRows()
                }
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView?.reloadData()
                //self?.configureButtons()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func cancelEventRequest() {
        ApiLayer.SharedApiLayer.cancel(self.eventActiveMethod)
        ApiLayer.SharedApiLayer.cancel(self.groupActiveMethod)
    }
    
    func cancelChangeEventRequest() {
        ApiLayer.SharedApiLayer.cancel(self.acceptActiveMethod)
        ApiLayer.SharedApiLayer.cancel(self.cancelActiveMethod)
    }
    
    func request() {
        
        let eventMethod = ApiMethod.getEvent(eventID: eventID)
        self.eventActiveMethod = eventMethod
        var groupID = 0
        if let objectID = self.event.group?.objectID {
            groupID = objectID
        }
        let groupMethod = ApiMethod.getGroup(groupID: groupID)
        self.groupActiveMethod = groupMethod
        
        if isFeed {
            self.requestFeedEvent(eventMethod: eventMethod, groupMethod: groupMethod)
            self.configureFeedEventRealmNotification()
        } else {
            self.requestEvent(eventMethod: eventMethod, groupMethod: groupMethod)
            self.configureEventRealmNotification()
        }
        
    }
    
    func requestEvent(eventMethod: ApiMethod, groupMethod: ApiMethod) {
        firstly {
            ServiceForRequest<Event>().getEventWithMembersPromise(groupMethod: groupMethod, eventMethod: eventMethod)
        }.then { [weak self]_ -> Void in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
            self?.finishRequest = true
            self?.tableView?.reloadData()
            self?.showButtons()
        }.catch { [weak self] error  in
            self?.showErrorAlert(error: error.apiError)
        }
    }
    
    func requestFeedEvent(eventMethod: ApiMethod, groupMethod: ApiMethod) {
        firstly {
            ServiceForRequest<FeedEvent>().getEventWithMembersPromise(groupMethod: groupMethod, eventMethod: eventMethod)
        }.then { [weak self] _ -> Void in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
            self?.finishRequest = true
        }.catch { [weak self] error  in
            self?.showErrorAlert(error: error.apiError)
        }
    }
    
    func showErrorAlert(error: ApiError) {
        guard self.navigationController?.topViewController == self else {
            return
        }
        let operation = RouterOperationAlert.showError(title: error.apiError.domain, message: error.apiError.errorDescription, handler: nil)
        _ = self.router.performOperation(operation)
    }
    
    // MARK: - Configure Table Form
    
    func confifigureEventForm() {
        _ = self.addSection(tag: Constants.InfoSection)
        if event.typeEnum == .lesson {
            let groupName = event.group?.groupName != nil ? event.group?.groupName : Constants.GroupName
            self.addLabelRow(title: groupName!, icon: IconForElements.groupName.icon).cellUpdate { [weak self] (cell, row) in
                cell.textLabel?.text = self?.event.group?.groupName != nil ? self?.event.group?.groupName : Constants.GroupName
            }
        }
        let groupLevel = event.group?.groupLevel != nil ? event.group?.groupLevel?.capitalized : Constants.GroupLevel
        self.addLabelRow(title: groupLevel!, icon: IconForElements.groupLevel.icon).cellUpdate { [weak self] (cell, row) in
            cell.textLabel?.text = self?.event.group?.groupLevel != nil ? self?.event.group?.groupLevel?.capitalized : Constants.GroupLevel
        }
        if let location = event.location?.place{
            self.addLabelRow(title: location, icon: IconForElements.location.icon).cellUpdate { [weak self] (cell, row) in
                cell.textLabel?.text = self?.event.location?.place
            }
        }
        if let startTime = event.dateStart, let endTime = event.dateEnd {
            self.addLabelRow(title: startTime.getWeekdayByDate(), icon: IconForElements.time.icon, value: "\(endTime.formattedDateStringWithFormat("HH:mm")) - \(endTime.formattedDateStringWithFormat("HH:mm"))").cellUpdate { [weak self] (cell, row) in
                if let newStartTime = self?.event.dateStart, let newEndTime = self?.event.dateEnd {
                    cell.textLabel?.text = newStartTime.getWeekdayByDate()
                    cell.detailTextLabel?.text = newStartTime.formattedDateStringWithFormat("HH:mm") + " - " + newEndTime.formattedDateStringWithFormat("HH:mm")
                }
            }
        }
        
        _ = self.addSection()
        let note = event.note != nil ? event.note : Constants.NotesKey
        self.addLabelRow(title: note!, icon: IconForElements.notes.icon, tag: Constants.NotesKey).cellUpdate { [weak self] (cell, row) in
            cell.textLabel?.text = self?.event.note != nil ? self?.event.note : Constants.NotesKey
            cell.textLabel?.layoutIfNeeded()
        }
        
        let userSection = self.addSection(title: "Attending Students", tag: Constants.Students)
        if event.typeEnum == .workshop && !self.teacher && !event.isPast() {
            userSection.footer?.height = { [weak self] in
                if let weakSelf = self {
                    return CGFloat.leastNormalMagnitude + weakSelf.declineButton.constraints[0].constant
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            }
        }
        self.addStudentSection()
    }
    
    func addStudentSection() {
        var isSwitcher = teacher
        if let startTime = event.dateStart, startTime.timeIntervalSince(Date().makeLocalTime()) > 0 {
            isSwitcher = false
        }
        let visitedPredicate = NSPredicate(format: "type = %@","Visited")
        visitedEvents = event.eventsB.filter(visitedPredicate)
        for member in self.event.members {
            let predicateID = NSPredicate(format: "createrID = %i", member.objectID)
            var value = true
            if visitedEvents.count > 0 {
                if visitedEvents.filter(predicateID).count > 0  {
                    value = true
                } else {
                    value = false
                }
            } else {
                value = false
            }
            if let memberIndex = self.event.members.index(of: member) {
                let row = self.addPhotoLabelRow(user: member, useSwitch: isSwitcher, tag: Constants.Student + "\(memberIndex + 1)", value:value).onCellSelection{ [weak self] (cell, row) in
                    let operation = RouterOperationXib.openViewUserProfile(userID: member.objectID, isChild: false)
                    _ = self?.router.performOperation(operation)
                    cell.setSelected(false, animated: false)
                }
                row.cellUpdate({ [weak self] cell, row in
                    row.cell.cellSwitch.isEnabled = self!.finishRequest
                })
            }
        }
    }
    
    func updateNeededRows() {
        self.configureNavigationBar()
        if let section = self.form.sectionBy(tag: Constants.InfoSection){
            section.reload()
        }
        
        if let studentsSection = self.form.sectionBy(tag: Constants.Students){
            studentsSection.removeAll()
            self.addStudentSection()
        }
        
        self.form.rowBy(tag: Constants.NotesKey)?.updateCell()
    }
    
    func eventDidChanged(_ event: Event) {
        self.event = event
    }
    
    func changeEventState(apiMethod: ApiMethod) {
        firstly {
            ServiceForRequest<EventPreview>().getObjectPromise(apiMethod)
        }.then { [weak self] eventB -> Void in
            BaseModel.realmWrite({
                if self!.event.eventsB.count > 0 {
                    self!.event.eventsB[0] = eventB
                } else {
                    self!.event.eventsB.append(eventB)
                }
                self?.checkDeclineAcceptButtons()
            })
            self?.request()
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func sendVisitedMembers(){
        self.doneButton?.isEnabled = false
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        var members = [UserPreview]()
        for member in event.members {
            if let userIndex = self.event.members.index(of: member), let row: PhotoLabelRow = self.form.rowBy(tag: Constants.Student + "\(userIndex + 1)"), row.value == true {
                members.append(member)
            }
        }
        var groupID = 0
        if let ID = self.event.group?.objectID {
            groupID = ID
        }
        let apiMethod = ApiMethod.createVisitedEvent(eventID: self.eventID, groupID: groupID, visitedMembers: members)
        firstly {
            ApiLayer.SharedApiLayer.requestWithDictionaryOfAnyObjectsPromise(apiMethod)
        }.then { [weak self] results -> Void in
            self?.event.eventsB.removeAll()
            if let objects = Mapper<EventPreview>().mapArray(JSONObject: results) {
                for object in objects {
                    self?.event.eventsB.append(object)
                }
            }
            //print(results)
        }.always { [weak self] in
            self?.doneButton?.isEnabled = true
            do {
                try realm.commitWriteTransaction()
            } catch {
            }
        }.catch { error in
            print(error)
        }
        
    }
    
    //MARK: Actions
    
    @IBAction func declineButtonPressed(_ sender: AnyObject) {
        self.cancelChangeEventRequest()
        let cancelMethod = ApiMethod.cancelEvent(eventID: event.objectID)
        self.cancelActiveMethod = cancelMethod
        self.changeEventState(apiMethod: cancelMethod)
    }
    
    @IBAction func acceptButtonPressed(_ sender: AnyObject) {
        self.cancelChangeEventRequest()
        self.acceptActiveMethod = ApiMethod.acceptEvent(eventID: event.objectID)
        self.changeEventState(apiMethod: self.acceptActiveMethod!)
    }
    
    func editButtonPressed() {
        let operation = RouterOperationXib.openEditLessonWorkshop(event: self.event!)
        let destinationVC = self.router.performOperation(operation) as! EditLessonWorkshopViewController
        destinationVC.delegate = self
    }
    func checkDeclineAcceptButtons() {
        if event.containsEventBy(type: .accepted) {
            self.acceptButton.isEnabled = false
            self.declineButton.isEnabled = true
        } else if event.containsEventBy(type: .cancelled) {
            self.declineButton.isEnabled = false
            self.acceptButton.isEnabled = true
        }
    }
}
extension LessonWorkshopDetailsViewController {
    
    func configureNavigationBar() {
        self.title = self.event?.eventName
        if SessionData.teacher && self.event != nil {
            if let startTime = event.dateStart, startTime.timeIntervalSince(Date().makeLocalTime()) > 0{
                let editeButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
                self.navigationItem.rightBarButtonItem = editeButton
            } else {
                doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendVisitedMembers))
                self.navigationItem.rightBarButtonItem = doneButton
            }
        }
    }

    func showButtons() {
        if let event = self.event {
            if event.typeEnum == .workshop && !SessionData.teacher && !event.isPast() {
                self.acceptButton.isHidden = false
                self.declineButton.isHidden = false
            }
            self.checkDeclineAcceptButtons()
        }
    }

    func configureButtons() {
        let color = UIColor(hexString: "#8f9193").cgColor
        if self.isFeed {
            self.showButtons()
        }
        self.acceptButton.layer.borderWidth = 0.5
        self.acceptButton.layer.borderColor = color
        self.acceptButton.titleLabel?.textColor = Event.colorByType(eventType: .accepted)
        self.acceptButton.setTitle("Accept", for: .normal)
        self.acceptButton.setTitleColor(Event.colorByType(eventType: .accepted), for: .normal)
        self.acceptButton.backgroundColor = ColorForElements.background.color
        self.acceptButton.setTitleColor(.gray, for: .disabled)
        self.declineButton.layer.borderWidth = 0.5
        self.declineButton.layer.borderColor = color
        self.declineButton.titleLabel?.textColor = Event.colorByType(eventType: .cancelled)
        self.declineButton.backgroundColor = ColorForElements.background.color
        self.declineButton.setTitle("Decline", for: .normal)
        self.declineButton.setTitleColor(Event.colorByType(eventType: .cancelled), for: .normal)
        self.declineButton.setTitleColor(.gray, for: .disabled)
    }
}
