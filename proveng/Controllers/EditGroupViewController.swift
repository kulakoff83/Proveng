//
//  EditGroupViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 05.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class EditGroupViewController: BaseFormViewController {
    
    var group: Group!
    let superEvent = EventPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.configureEditGroupsForm()
    }
    
    func configureEditGroupsForm(){
        _ = self.addSection(title: self.group?.groupLevel)
        _ = self.addNameRow(title: Constants.GroupName, icon: IconForElements.groupName.icon, value: self.group.groupName)
        var startValue = ""
        var durationValue = ""
        if let lifetimeEvent = self.group.lifetimeEvent, let startDate = lifetimeEvent.dateStart, let endDate = lifetimeEvent.dateEnd{
            startValue = startDate.formattedDateStringWithFormat("MMM dd, yyyy")
            durationValue = endDate.offsetFrom(startDate)
        }
        
        _ = self.addLabelRow(title: Constants.Started, icon: IconForElements.date.icon, value: startValue)
        _ = self.addLabelRow(title: Constants.CourseDuration, icon: IconForElements.duration.icon, value: durationValue)
        self.createLessonSections(group: self.group)        
    }
    
    func editGroup(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var currentGroup = Group()
        var lessonEvents = [EventPreview]()
        var lifetimeEvent = EventPreview()
        firstly {
            BaseModel.mappedCopy(self.group)
        }.then { mapedGroup -> Promise<EventPreview> in
            currentGroup = mapedGroup
            if let groupLife: EventPreview = self.group.lifetimeEvent{
                return BaseModel.mappedCopy(groupLife)
            } else {
                return Promise(value: EventPreview())
            }
        }.then { mapedLifetime -> Promise<Results<Location>> in
            lifetimeEvent = mapedLifetime
            return ServiceForData<Location>().getDataArrayFromStoragePromise()
        }.then { locations -> Promise<Group> in
            currentGroup.groupName = self.form.rowBy(tag: Constants.GroupName)?.value
            var i = 1
            for event in self.group.scheduleEvents {
                let lessonEvent = EventPreview()
                if let place = self.form.rowBy(tag: Constants.Location + "\(i)")?.baseValue as? String {
                    let predicate = NSPredicate(format: "place = %@",place)
                    if let location = locations.filter(predicate).first {
                        let newLocation = Location()
                        newLocation.objectID = location.objectID
                        lessonEvent.location = newLocation
                    }
                }
                lessonEvent.objectID = event.objectID
                if let weekday = self.form.rowBy(tag: Constants.Repeat + "\(i)")?.baseValue as? String, let startTime: Date = self.form.rowBy(tag: Constants.StartTime + "\(i)")?.baseValue as? Date, let endTime: Date = self.form.rowBy(tag: Constants.EndTime + "\(i)")?.baseValue as? Date {
                    lessonEvent.dateStart = startTime.getDateByWeekday(weekday)
                    lessonEvent.dateEnd = endTime.getDateByWeekday(weekday)
                }
                
                lessonEvent.regular = event.regular
                lessonEvent.type = event.type
                lessonEvents.append(lessonEvent)
                i += 1
            }
            lessonEvents.append(lifetimeEvent)
            return ServiceForRequest<Group>().editGroupWithShedulePromise(group: currentGroup, schedule: lessonEvents)
        }.then{ group -> Void in
            self.backToPrevVC()
        }.always { [weak self] in
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
}

extension EditGroupViewController {
    func configureNavigationBar(){
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.backToPrevVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneButtonPressed(){
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
        editGroup()        
    }
}
