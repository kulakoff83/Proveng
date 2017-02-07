//
//  EditProfileViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 27.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit

class EditProfileViewController: BaseFormViewController {
    
    var user: User!
    let teacher = SessionData.teacher
    var backgroundImage = UIImage()
    lazy var groupName = ""
    var saveButton: UIBarButtonItem?
    let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage = IconForElements.profileBackground.image
        let frame = CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.54)
        let imageView = UIImageView(frame: frame)
        imageView.image = backgroundImage
        self.tableView?.addSubview(imageView)
        self.tableView?.bounces = false
        configureUserForm()
        configureNavigationBar()
    }
    
    override func fixFrameTableView() {
        self.fixInsetTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        statusBar?.backgroundColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = ColorForElements.main.color
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func configureUserForm(){
        _ = addProfileHeader(user: user, teacher: teacher, userID: self.user.objectID, isEdit: true)
        addProfileSection()
    }
    
    func addProfileSection(){
        _ = self.addLabelRow(title: Constants.Email, icon: IconForElements.email.icon, value: self.user.email)
        
        _ = self.addAccountRow(title: Constants.Skype, icon: IconForElements.skype.icon, value: self.user.skype)
        
        _ = self.addPhoneRow(title: Constants.PhoneNumber, icon: IconForElements.phone.icon, value: self.user.phone)
        if !self.teacher {
            let predicate = NSPredicate(format: "primaryGroupFlag = %i", 1)
            if let group = user.groups.filter(predicate).first, let name = group.groupName {
                groupName = name
            }            
            _ = self.addLabelRow(title: Constants.GroupName, icon: IconForElements.groupName.icon, value: groupName)
            
            if let department: Department = self.user.department {
                self.createDepartmentRow(departmentValue: department.name, titleSection: Constants.ProfileInfoSectionName)
            } else {
                self.createDepartmentRow(titleSection: Constants.ProfileInfoSectionName)
            }
        }
    }
}

extension EditProfileViewController  {   
    func configureNavigationBar(){
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func saveButtonPressed(){
        var currentUser = User()
        self.saveButton?.isEnabled = false
        firstly {
            return BaseModel.mappedCopy(self.user)
        }.then { mapedUser -> Promise<Department> in
            currentUser = mapedUser
            currentUser.skype = self.form.rowBy(tag: Constants.Skype)?.value
            currentUser.phone = self.form.rowBy(tag:Constants.PhoneNumber)?.value
            guard let departmentRow = self.form.rowBy(tag: Constants.DepartmentName) else {
                if currentUser.department == nil {
                    return Promise(value: Department())
                } else {
                    return Promise(value: currentUser.department)
                }
            }
            if let departmentValue = departmentRow.baseValue as? String {
                return ServiceForData<Department>().getDataByKeyFromStoragePromise("name", filterValue: departmentValue)
            } else {
                return Promise(value: Department())
            }
        }.then { department -> Promise<Department> in
            return BaseModel.mappedCopy(department)
        }.then { department -> Promise<User> in
            currentUser.department = department
            return ServiceForRequest<User>().getObjectPromise(ApiMethod.updateUserProfile(user: currentUser))
        }.then { user -> Void in
            self.backToPrevVC()
        }.always { [weak self] in
            self?.saveButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -25){
            self.navigationController?.navigationBar.backgroundColor = .clear
            statusBar?.backgroundColor = .clear
        } else{
            self.navigationController?.navigationBar.backgroundColor = ColorForElements.main.color.withAlphaComponent(0.5)
            statusBar?.backgroundColor = ColorForElements.main.color.withAlphaComponent(0.5)
        }
    }
}
