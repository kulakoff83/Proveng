//
//  AddStudentsViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 05.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class AddStudentsViewController: BaseFormViewController {
    
    var createGroup: Bool = true
    var group: Group!
    var minUserCount = 0
    var users: [UserPreview]!
    var studentsActiveMethod: ApiMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.request()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            ApiLayer.SharedApiLayer.cancel(self.studentsActiveMethod)
        }
    }
    
    func request() {
        let studentsMethod = ApiMethod.getUsersStartTest(level:group.groupLevel)
        self.studentsActiveMethod = studentsMethod
        firstly {
            ServiceForRequest<UserPreview>().getObjectsPromise(studentsMethod)
        }.then { [weak self] usersObject -> Void in
            self?.users = usersObject
            self?.configureStudentsForm()
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureStudentsForm() {
        self.configureNavigationBar()
        var label : UILabel!
        let section = Section() {
            var header = HeaderFooterView<AddStudentsSectionHeader>(HeaderFooterProvider.nibFile(name: "AddStudentsSectionHeader", bundle: nil))
            header.onSetupView = { [weak self] (view, section) -> () in
                if label == nil {
                    label = view.leftLabel
                    view.leftLabel.text = Constants.AddStudentsSectionHeaderTitle + String(describing: self?.minUserCount)
                    self?.setTextToStudentsCountLabel(label)
                }
            }
            $0.header = header
        }
       form +++ section
        for user in users {
            let userIndex = users.index(of: user)
            self.addPhotoLabelRow(user: user, useCheck: true, tag: Constants.Student + "\(userIndex)").onChange{ [weak self] row in
                if row.value == true {
                    self?.minUserCount += +1
                } else {
                    self?.minUserCount += -1
                }
                self?.setTextToStudentsCountLabel(label)
            }
        }
    }
}

extension AddStudentsViewController {
    
    func configureNavigationBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self,action: #selector(AddStudentsViewController.doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneItem
        doneItem.isEnabled = false
    }
    
    func doneButtonPressed() {
        let count = self.minUserCount
        if self.createGroup {
            group.members.removeAll()
            for user in self.users {
                let userIndex = self.users.index(of: user)
                if let row: PhotoLabelRow = self.form.rowBy(tag: Constants.Student + "\(userIndex)"), row.value == true {
                    group.members.append(user)
                }
            }
            self.backToPrevVC()
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            firstly {
                BaseModel.mappedCopy(self.group)
            }.then { [weak self] mapedGroup -> Promise<Group> in
                for user in self!.users {
                    let userIndex = self?.users.index(of: user)
                    if let row: PhotoLabelRow = self?.form.rowBy(tag: Constants.Student + "\(userIndex)"), row.value == true {
                        mapedGroup.members.append(user)
                    }
                }
                return ServiceForRequest<Group>().getObjectPromise(ApiMethod.updateGroup(group: mapedGroup))
            }.then { currentGroup -> Promise<GroupLevel> in
                if let level = currentGroup.groupLevel {
                    return ServiceForData<GroupLevel>().getDataByKeyFromStoragePromise("name", filterValue: level)
                } else {
                    return Promise(value: GroupLevel())
                }
            }.recover { error -> Promise<GroupLevel> in
                return Promise(value: GroupLevel())
            }.then { [weak self] level -> Void in
                if level.name != nil {
                    let realm = try Realm()
                    try realm.write {
                        level.count = (level.count - count) >= 0 ? level.count - count : 0
                        realm.add(level, update: true)
                    }
                }
                self!.backToPrevVC()
            }.always { [weak self] in
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }.catch { [weak self] error in
                self?.handleError(error: error)
            }
        }
    }
    
    func setTextToStudentsCountLabel(_ label: UILabel) {
        label.text = Constants.AddStudentsSectionHeaderTitle + String(self.minUserCount)
        switch self.minUserCount {
        case 0:
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        default:
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
