//
//  CreateGroupViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 10.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class CreateGroupViewController: BaseFormViewController {
    
    var groupLevel: String?
    var pendingStudentsCount: Int = 0
    var group = Group()
    var createdGroup = Group()
    let duration = ServiceForBasicValue().getGroupDuration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.group.groupLevel = groupLevel
        configureGroupForm()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNeededRows()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureGroupForm() {
        _ = self.addSection()
        self.addCountUsersRow(title:Constants.AddStudentsControllerTitle, count: self.pendingStudentsCount, tag: "").onCellSelection{ [weak self] (cell, row) in
            let operation = RouterOperationXib.openAddStudents(createGroup: true, group: self!.group)
            _ = self?.router.performOperation(operation)
            cell.setSelected(false, animated: false)
            self?.tableView?.reloadData()
        }
        _ = self.addSection()
        _ = self.addNameRow(title: Constants.GroupName, icon: IconForElements.groupName.icon)
        _ = self.addLabelRow(title: self.groupLevel?.capitalized, icon: IconForElements.groupLevel.icon)
        _ = self.addDateInlineRow(title: Constants.Started, icon: IconForElements.date.icon)
        _ = self.addPickerInlineRow(title: Constants.CourseDuration, icon: IconForElements.duration.icon, options: ServiceForBasicValue().getGroupDuration(), value: self.duration[2])
        
        self.createLessonSections()
        _ = self.addSection(title: Constants.Students, tag: Constants.Students)
        addStudentSection()
    }
    
    func addStudentSection(){
        for member in self.group.members {
            if let memberIndex = self.group.members.index(of: member) {
                self.addPhotoLabelRow(user: member, tag: Constants.Student + "\(memberIndex)").onCellSelection{ [weak self] (cell, row) in
                    let operation = RouterOperationXib.openViewUserProfile(userID: member.objectID, isChild: false)
                    _ = self?.router.performOperation(operation)
                    cell.setSelected(false, animated: false)
                }
            }
        }
    }
    func updateNeededRows() {
        if let studentsSection = self.form.sectionBy(tag: Constants.Students) {
            studentsSection.removeAll()
            self.addStudentSection()
        }
    }
    
    func createGroup() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var lessonEvents = [EventPreview]()
        self.group.groupName = self.form.rowBy(tag: Constants.GroupName)?.value
        self.group.modifyDate = Date()
        let leader = UserPreview()
        leader.objectID = SessionData.id
        self.group.leader = leader
        self.group.primaryGroupFlag = true
        let superEvent = EventPreview()
        if let dateStart = self.form.rowBy(tag: Constants.Started)?.baseValue as? Date, let duration = self.form.rowBy(tag: Constants.CourseDuration)?.baseValue as? String {
            let dateEnd = dateStart.setEndDateWithDuration(duration)
            let zeroDate = Date.convertStringToDate("01/01/1970 00:00:00 GMT", dateFormat: "dd/mm/yyy HH:mm:ss zzz")
            superEvent.dateStart = zeroDate.changeDayByOtherDate(dateStart)
            superEvent.dateEnd = zeroDate.changeDayByOtherDate(dateEnd)
        }
        superEvent.type = Constants.LifetimeType
        firstly {
            ServiceForData<Location>().getDataArrayFromStoragePromise()
        }.then { locations -> Promise<Group> in
            for eventIndex in 1 ..< 3 {
                let lessonEvent = EventPreview()
                if let place = self.form.rowBy(tag: Constants.Location + "\(eventIndex)")?.baseValue as? String {
                    let predicate = NSPredicate(format: "place = %@",place)
                    if let location = locations.filter(predicate).first {
                        let newLocation = Location()
                        newLocation.objectID = location.objectID
                        lessonEvent.location = newLocation
                    }
                }
                if let weekday = self.form.rowBy(tag: Constants.Repeat + "\(eventIndex)")?.baseValue as? String, let startTime: Date = self.form.rowBy(tag: Constants.StartTime + "\(eventIndex)")?.baseValue as? Date, let endTime: Date = self.form.rowBy(tag: Constants.EndTime + "\(eventIndex)")?.baseValue as? Date {
                    lessonEvent.dateStart = startTime.getDateByWeekday(weekday)
                    lessonEvent.dateEnd = endTime.getDateByWeekday(weekday)
                }
                lessonEvent.type = Constants.ScheduleType
                lessonEvents.append(lessonEvent)
            };
            lessonEvents.append(superEvent)
            if (self.createdGroup.groupName == self.group.groupName) {
                return Promise(value: self.createdGroup)
            } else {
                return ServiceForRequest<Group>().createGroupPromise(group: self.group)
            }
            
        }.then { [weak self] returnedGroup -> Promise<GroupLevel> in
            self?.createdGroup = returnedGroup
            if let level = returnedGroup.groupLevel {
                return ServiceForData<GroupLevel>().getDataByKeyFromStoragePromise("name", filterValue: level)
            } else {
                return Promise(value: GroupLevel())
            }
        }.recover { error -> Promise<GroupLevel> in
            return Promise(value: GroupLevel())
        }.then { [weak self] level -> Promise<Group> in
            if level.name != nil, let count = self?.createdGroup.members.count, count != 0 {
                let realm = try Realm()
                try realm.write {
                    level.count = (level.count - count) >= 0 ? level.count - count : 0
                    realm.add(level, update: true)
                }
            }
            return ServiceForRequest<EventPreview>().createSchedulePromise(group: self!.createdGroup, schedule: lessonEvents)
        }.then { object -> Void in
            self.backToPrevVC()
        }.always { [weak self] in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
}

extension CreateGroupViewController {
    
    func configureNavigationBar(){
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backToPrevVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneButtonPressed() {
        guard validateRow(Constants.GroupName) == true else {
            return
        }
        for i in 1..<3 {
            guard validateStartEndDateRow(Constants.StartTime + "\(i)", endTag: Constants.EndTime + "\(i)") == true else {
                return
            }
            guard validatePushRowString(Constants.Repeat + "\(i)", rowTitle: Constants.Repeat) == true else {
                return
            }
            guard validatePushRowString(Constants.Location + "\(i)", rowTitle: Constants.Location) == true else {
                return
            }            
        }
        self.createGroup()
    }
}
