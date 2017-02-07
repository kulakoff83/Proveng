//
//  LessonViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 15.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//
import UIKit
import Eureka
import PromiseKit
import RealmSwift
protocol TeacherGroupsViewControllerDelegate {
    func groupRowDidSelected(_ group: GroupPreview)
}
class TeacherGroupsViewController: BaseFormViewController {
    
    let groupCellIdentifier = "GroupCell"
    let pendingStudentsCellIdentifier = "PendingStudentsCell"
    var showPickerScreen = false
    var delegate: TeacherGroupsViewControllerDelegate?
    var groups: Results<GroupPreview>!
    var levels = [GroupLevel]()
    fileprivate var notificationToken: NotificationToken? = nil
    var groupsActiveMethod: ApiMethod?
    var levelsActiveMethod: ApiMethod?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEvents()
        configureNavigationBar()
        configurePullToRefresh()
        request()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !showPickerScreen {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        self.tableView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !showPickerScreen {
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil && showPickerScreen {
            self.cancelActiveRequests()
        }
    }
    
    func setEvents() {
        firstly {
            ServiceForData<GroupPreview>().getDataArrayFromStoragePromise()
        }.then { [weak self] groups -> Promise<Results<GroupLevel>> in
            self?.groups = groups
            return ServiceForData<GroupLevel>().getDataArrayFromStoragePromise()
        }.then { [weak self] levels -> Void in
            for level in levels{
                self?.levels.append(level)
            }
            self?.configureGroupsForm()
            self?.configureRealmNotification()
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {
        // Observe Results Notifications
        self.notificationToken = groups.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial,.update:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView?.beginUpdates()
                self?.tableView?.endUpdates()
                self?.configureGroupsForm()//dont update
                break
            case .error(let error)://need add if group was deleting
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    override func requestObjects() {
        request()
    }
    
    deinit {
        notificationToken?.stop()
        print("Deinit Groups")
    }
    
    func cancelActiveRequests() {
        ApiLayer.SharedApiLayer.cancel(self.groupsActiveMethod)
        ApiLayer.SharedApiLayer.cancel(self.levelsActiveMethod)
    }
    
    func request() {
        self.cancelActiveRequests()
        let groupsMethod = ApiMethod.getGroups
        self.groupsActiveMethod = groupsMethod
        let levelsMethod = ApiMethod.getUsersCountForLevels
        self.levelsActiveMethod = levelsMethod
        let getGroupLevel = ServiceForRequest<GroupLevel>().getLevelObjects(levelsMethod)
        let getGroups = ServiceForRequest<GroupPreview>().getObjectsPromise(groupsMethod)
        when(resolved: [getGroupLevel.asVoid(), getGroups.asVoid()]).then{ [weak self] _ -> Void in
            if let levels = getGroupLevel.value {
                self?.levels = levels
                self?.configureGroupsForm()
                self?.tableView?.reloadData()
            }
            self?.refreshControl.endRefreshing()
        }.catch { [weak self] error in
            guard error.apiError.code != 404 else {
                return
            }
            self?.handleError(error: error)
        }
    }
    
    func configureGroupsForm() {
        var filteredGroups = [GroupPreview]()
        for i in 0..<self.levels.count {
            var levelName = ""
            if let level = levels[i].name {
                levelName = level
            }
            var studentsCount = self.levels[i].count != 0 ? self.levels[i].count : 0
            if showPickerScreen {
                filteredGroups = self.groups.filter{ $0.groupLevel == levelName }.filter{ $0.primaryGroupFlag == true}
            } else {
                filteredGroups = self.groups.filter{ $0.groupLevel == levelName }
            }
            if !showPickerScreen || filteredGroups.count > 0{
                if form.sectionBy(tag:levelName) == nil {
                    _ = self.addSection(title: levelName, tag: levelName)
                }
                if !showPickerScreen {
                    if (self.form.rowBy(tag: levelName) == nil) {
                        self.addCountUsersRow(title:Constants.PendingStudents, count: studentsCount, tag: levelName).cellUpdate{ [weak self] (cell, row) in
                            studentsCount = self?.levels[i].count != 0 ? (self?.levels[i].count)! : 0
                            cell.countPendingStudentsLabel.text = "\(studentsCount)"
                            if studentsCount == 0 {
                                cell.plusLabel.text = ""
                            } else {
                                cell.plusLabel.text = "+"
                            }
                            cell.configureCountUserCell(title: Constants.PendingStudents, count: studentsCount)
                            }.onCellSelection{ [weak self] (cell, row) in
                                if studentsCount != 0 {
                                    studentsCount = self?.levels[i].count != 0 ? (self?.levels[i].count)! : 0
                                    let operation = RouterOperationXib.openCreateGroup(level: levelName, studentsCount: studentsCount)
                                    _ = self?.router.performOperation(operation)
                                    cell.setSelected(false, animated: false)
                                    row.reload()
                                }
                        }
                    }
                }
                
                for group in filteredGroups {
                    let groupID = group.objectID
                    let groupIDString = "\(group.objectID)"
                    if (self.form.rowBy(tag: groupIDString) == nil) {
                        var accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                        if self.showPickerScreen {
                            accessoryType = UITableViewCellAccessoryType.none
                        }
                        if let groupName = group.groupName {
                            self.addButtonPushRow(title: groupName, tag: groupIDString, accessoryType: accessoryType, section: form.sectionBy(tag: levelName)).cellUpdate{ (cell, row) in
                                ServiceForData<GroupPreview>().getObjectByID(id: groupID, handler: { group in
                                    cell.textLabel?.text = group.groupName
                                })
                            }.onCellSelection { [weak self] (cell, row) in
                                ServiceForData<GroupPreview>().getObjectByID(id: groupID, handler: { group in
                                    if self!.showPickerScreen {
                                        self?.delegate?.groupRowDidSelected(group)
                                        self?.backToPrevVC()
                                    } else {
                                        let operation = RouterOperationXib.openGroupDetail(groupID: groupID, primaryGroupFlag: group.primaryGroupFlag)
                                        _ = self?.router.performOperation(operation)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        updateGroupSection()
    }
    
    func updateCountLabel() {
        for level in self.levels {
            if let levelName = level.name {
                self.form.rowBy(tag: levelName)?.updateCell()
            }
        }
    }
    
    func updateGroupSection() {
        for row in self.form.allRows {
            if let rowTag = row.tag, let intTag = Int(rowTag) {
                let filteredGroups = self.groups.filter{ $0.objectID == intTag }
                if filteredGroups.count == 0 && groups.count != 0 {
                    if let indexPath = row.indexPath {
                        if let tag = row.section?.tag,  var section = self.form.sectionBy(tag: tag) {
                            section.remove(at: indexPath.row)
                        }
                    }
                }
            }
        }
    }
}
extension TeacherGroupsViewController {
    func configureNavigationBar(){
        self.createBaseNavigationBar()
    }
}
