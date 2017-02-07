//
//  GroupDetailsViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 04.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class GroupDetailsViewController: BaseFormViewController{
    
    var group: Group!
    var groupID: Int = 0
    fileprivate var notificationToken: NotificationToken? = nil
    var scheduleActiveMethod: ApiMethod?
    var groupActiveMethod: ApiMethod?
    var primaryGroupFlag: Bool = false
    var alpha: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRealmNotification()
        self.configureNavigationBar()
        request()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.cancelGroupRequest()
        }
    }
    
    func cancelGroupRequest() {
        ApiLayer.SharedApiLayer.cancel(self.groupActiveMethod)
        ApiLayer.SharedApiLayer.cancel(self.scheduleActiveMethod)
    }
    
    func request() {
        let groupMethod = ApiMethod.getGroup(groupID: self.groupID)
        self.groupActiveMethod = groupMethod
        let scheduleMethod = ApiMethod.getSchedule(groupID: self.groupID)
        self.scheduleActiveMethod = scheduleMethod
        firstly {
            ServiceForRequest<Group>().getGroupWithShedulePromise(groupMethod: groupMethod, scheduleMethod: scheduleMethod)
        }.then { [weak self] groupObject -> Void in
            self?.group = groupObject
            self?.alpha = 1
            if self?.notificationToken == nil {
                self?.configureRealmNotification()
            }
            self?.navigationItem.rightBarButtonItem?.isEnabled  = true
            if let row: ButtonPushRow = self?.form.rowBy(tag: Constants.AddStudentsControllerTitle) {
                row.cell.contentView.alpha = 1
            }
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {
        firstly { [weak self] in
            ServiceForData<Group>().getDataResultsByIDFromStoragePromise(self!.groupID)
            }.then { group -> Void in
                self.notificationToken = group.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    switch changes {
                    case .initial:
                        self?.group = group.first
                        self?.updateGroupForm()
                        break
                    case .update(_, let deletions, _, _):
                        if deletions.count > 0 {
                            ServiceForData<Group>().getObjectByID(id: self!.groupID, handler: { group in
                                self?.group = group
                                self?.updateGroupForm()
                            })
                        } else {
                            self?.group = group.first
                            ServiceForData<GroupPreview>().getObjectByID(id: self!.groupID, handler: { group in
                                BaseModel.realmWrite {
                                    group.groupName = self?.group.groupName
                                }
                            })
                            self?.updateGroupForm()
                        }
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                        break
                    }
                }
            }.catch { error in
                print(error)//What we do with error
        }
    }
    
    func updateGroupForm() {
        if self.group != nil {
            self.title = self.group.groupName
        }
        // Results are now populated and can be accessed without blocking the UI
        if self.form.sectionBy(tag: Constants.InfoSection) != nil{
            self.updateNeededRows()
        }else{
            self.configureGroupDetailsForm()
        }
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    func configureGroupDetailsForm(){
        _ = self.addSection(tag: Constants.InfoSection)
        self.addLabelRow(title: self.group.groupLevel?.capitalized, icon: IconForElements.groupLevel.icon).cellUpdate{ [weak self] (cell, row) in
            cell.textLabel?.text = self?.group.groupLevel?.capitalized
        }
        self.addLabelRow(title: Constants.Started, icon: IconForElements.date.icon, value: self.group.lifetimeEvent?.dateStart?.formattedDateStringWithFormat("MMMM dd, yyyy", dateStyle: .medium)).cellUpdate{ [weak self] (cell, row) in
            cell.detailTextLabel?.text = self?.group.lifetimeEvent?.dateStart?.formattedDateStringWithFormat("MMMM dd, yyyy", dateStyle: .medium)
        }
        self.addLabelRow(title: Constants.CourseDuration, icon: IconForElements.duration.icon, value: self.group.lifetimeEvent?.dateEnd?.offsetFrom(self.group.lifetimeEvent?.dateStart)).cellUpdate{ [weak self] (cell, row) in
            cell.detailTextLabel?.text = self?.group.lifetimeEvent?.dateEnd?.offsetFrom(self?.group.lifetimeEvent?.dateStart)
        }
        
        addSheduleSections()
    }
    
    func addSheduleSections() {
        addLessionSection()
        
        _ = self.addSection()
        if self.group.primaryGroupFlag {
            let addStudentsRow = self.addButtonPushRow(title: Constants.AddStudentsControllerTitle, icon: IconForElements.addStudent.icon).onCellSelection{ [weak self] (cell, row) in
                if self?.alpha == 1 {
                    let operation = RouterOperationXib.openAddStudents(createGroup: false, group: self!.group)
                    _ = self?.router.performOperation(operation)
                }
                cell.setSelected(false, animated: false)
                self?.adHocReloadWithoutResetContentOffset {
                    row.reload()
                }
            }
            addStudentsRow.cell.contentView.alpha = self.alpha
        }
        
        self.addButtonPushRow(title: "Share materials", icon: IconForElements.shareMaterials.icon).onCellSelection{ [weak self] (cell, row) in
            if let groupLevel = self?.group.groupLevel, let groupID = self?.group.objectID {
                let operation = RouterOperationXib.openShareMaterial(level: groupLevel, groupID: groupID)
                _ = self?.router.performOperation(operation)
            }
            cell.setSelected(false, animated: false)
        }
        _ = self.addSection(title: Constants.Students, tag: Constants.Students)
        addStudentSection()
    }
    
    func removeLastSections() {
        let sectionCount = self.form.allSections.count
        self.form.remove(at: sectionCount - 2)
        self.form.remove(at: sectionCount - 2)
    }
    
    func addLessionSection(){
        for event in self.group.scheduleEvents {
            guard let index = self.group.scheduleEvents.index(of: event) else {
                return
            }
            let eventIndex = index + 1
            if let endDate = event.dateEnd, let startDate = event.dateStart {
                let format = "HH:mm"
                _ = self.addSection(title: "Lesson \(eventIndex)", tag: "Lesson \(eventIndex)")
                self.addLabelRow(title: endDate.getWeekdayByDate(), icon: IconForElements.time.icon, value: "\(startDate.formattedDateStringWithFormat(format)) - \(endDate.formattedDateStringWithFormat(format))").cellUpdate { (cell, row) in
                    cell.textLabel?.text = startDate.getWeekdayByDate()
                    cell.detailTextLabel?.text = "\(startDate.formattedDateStringWithFormat(format)) - \(endDate.formattedDateStringWithFormat(format))"
                }
            }
            if let location = event.location?.place{
                self.addLabelRow(title: location, icon: IconForElements.location.icon).cellUpdate { (cell, row) in
                    cell.textLabel?.text = event.location?.place
                }
            }
        }
    }
    
    func addStudentSection(){
        for member in self.group.members {
            guard let index = self.group.members.index(of: member) else {
                return
            }
            let memberIndex = index + 1
            self.addPhotoLabelRow(user: member, tag: Constants.Student + "\(memberIndex)").onCellSelection{ [weak self] (cell, row) in
                let operation = RouterOperationXib.openViewUserProfile(userID: member.objectID, isChild: false)
                _ = self?.router.performOperation(operation)
                cell.setSelected(false, animated: false)
            }
        }
    }
    
    func updateNeededRows() {
        if let section = self.form.sectionBy(tag: Constants.InfoSection){
            section.reload()
        }
        for event in self.group.scheduleEvents {
            guard let index = self.group.scheduleEvents.index(of: event) else {
                return
            }
            let eventIndex = index + 1
            if let section = self.form.sectionBy(tag: "Lesson \(eventIndex)") {
                section.reload()
            } else {
                self.removeLastSections()
                self.addSheduleSections()
            }
        }
        if let studentsSection = self.form.sectionBy(tag: Constants.Students){
            studentsSection.removeAll()
            self.addStudentSection()
        }
    }
}

extension GroupDetailsViewController {
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        if !self.primaryGroupFlag {
            return false
        }
        if self.alpha == 1 {
            return indexPath.section == self.form.sectionBy(tag: Constants.Students)?.index ? true : false
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            let title = "Your reason for removing this student"
            let buttonTitles: [String] = ServiceForBasicValue().getReasonsForDeletion()
            let message = "This student will be notified"
            let operation = RouterOperationAlert.showChoose(title: title, message: message, buttonTitles: buttonTitles, cancelButtonTitle: "Cancel", handler: { [weak self] alertAction in
                let userID = self!.group.members[indexPath.row].objectID
                var note = "Unknown"
                if let alertTitle = alertAction.title {
                    note = alertTitle
                }
                let apiOperation = ApiMethod.deleteGroupUser(groupID: self!.groupID, userID: userID, note: note)
                firstly{
                    ServiceForRequest<UserPreview>().deleteObjectPromise(userID as AnyObject, operation: apiOperation)
                }.then { [weak self] answer -> Promise<GroupLevel> in
                    var section = self!.form.sectionBy(tag: Constants.Students)
                    section?.remove(at: indexPath.row)
                    if let level = self?.group.groupLevel {
                        return ServiceForData<GroupLevel>().getDataByKeyFromStoragePromise("name", filterValue: level)
                    } else {
                        return Promise(value: GroupLevel())
                    }
                }.recover { error -> Promise<GroupLevel> in
                    return Promise(value: GroupLevel())
                }.then { [weak self] level -> Void in
                    if level.name != nil && self!.group.primaryGroupFlag {
                        let realm = try Realm()
                            try realm.write {
                            level.count = level.count + 1
                            realm.add(level, update: true)
                        }
                    }
                }.catch { [weak self] error in
                    self?.handleError(error: error)
                }
            })
            self.router.performOperation(operation)
        }
    }
    
    func configureNavigationBar(){
        if self.primaryGroupFlag {
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            self.navigationItem.rightBarButtonItem = editButton
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func editButtonPressed(){
        let operation = RouterOperationXib.openEditGroup(group: self.group)
        self.router.performOperation(operation)
    }
}
