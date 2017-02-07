//
//  ViewProfileViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 27.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class ViewProfileViewController: BaseFormViewController {
    
    var userID: Int = SessionData.id
    var user: User!
    var isChild = true
    var teacher = SessionData.teacher
    fileprivate var notificationToken: NotificationToken? = nil
    var backgroundImage = UIImage()
    lazy var groupName = ""
    var navColor = UIColor()
    var activeUserMethod: ApiMethod?
    let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    var editButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionData.id == userID {
            backgroundImage = IconForElements.profileBackground.image
            navColor = ColorForElements.main.color
        } else {
            backgroundImage = IconForElements.profileAddBackground.image
            self.view.tintColor = ColorForElements.additional.color
            navColor = ColorForElements.additional.color
        }
        let frame = CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.54)
        let imageView = UIImageView(frame: frame)
        imageView.image = backgroundImage
        self.tableView?.addSubview(imageView)
        self.tableView?.bounces = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        configureRealmNotification()
    }
    
    override func fixFrameTableView() {
        self.fixInsetTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        if isChild {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.barTintColor = .clear
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        self.configureNavigationBar()
        self.requestUser()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            if !isChild {
                statusBar?.backgroundColor = .clear
                self.navigationController?.navigationBar.backgroundColor = .clear
                self.navigationController?.navigationBar.barTintColor = ColorForElements.main.color
                self.navigationController?.navigationBar.isTranslucent = false
            }
        }
    }
    
    func requestUser() {
        let userMethod = ApiMethod.getUserProfile(userID: userID)
        self.activeUserMethod = userMethod
        firstly {
            ServiceForRequest<User>().getObjectPromise(userMethod)
        }.then { [weak self] user -> Void in
            if self?.notificationToken == nil {
                self?.configureRealmNotification()
            }
            self?.editButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }

    func configureRealmNotification() {
        firstly { [weak self] in
            ServiceForData<User>().getDataResultsByIDFromStoragePromise(self!.userID)
        }.then { [weak self] user -> Void in
            self?.user = user.first
            self?.notificationToken = user.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    UIView.performWithoutAnimation {
                        //self?.tableView?.beginUpdates()
                        self?.configureUserForm()
                        //self?.tableView?.endUpdates()
                    }
                case .update:
                    self?.updateProfileSection()
                    // Results are now populated and can be accessed without blocking the UI
                    break
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
    
    deinit {
        notificationToken?.stop()
        print("Deinit Profile")
    }
    
    func configureUserForm(){
        _ = addProfileHeader(user: user, teacher: teacher, userID: self.userID)
        addProfileSection()
    }
    
    func addProfileSection(){
        self.addLabelRow(title: Constants.Email, icon: IconForElements.email.icon, value: self.user.email).cellUpdate { [weak self]  cell, row in
            cell.detailTextLabel?.text = self?.user.email
        }
        
        self.addLabelRow(title: Constants.Skype, icon: IconForElements.skype.icon, value: self.user.skype).cellUpdate { [weak self]  cell, row in
            cell.detailTextLabel?.text = self?.user.skype
        }
        
        self.addLabelRow(title: Constants.PhoneNumber, icon: IconForElements.phone.icon, value: self.user.phone).cellUpdate { [weak self]  cell, row in
            cell.detailTextLabel?.text = self?.user.phone
        }
         
        if teacher && SessionData.id == userID {
        } else{
            let predicate = NSPredicate(format: "primaryGroupFlag = %i", 1)
            if let group = user.groups.filter(predicate).first, let name = group.groupName{
                groupName = name
            }
            self.addLabelRow(title: Constants.GroupName, icon: IconForElements.groupName.icon, value: groupName).cellUpdate { [weak self] cell, row in
                if let group = self?.user.groups.filter(predicate).first, let name = group.groupName{
                    self?.groupName = name
                    cell.detailTextLabel?.text = self?.groupName
                }                
            }
        }
    }
    
    func updateProfileSection(){
        if let section = self.form.sectionBy(tag: Constants.ProfileInfoSectionName){
            section.reload()
        }
    }
}

extension ViewProfileViewController  {
    func configureNavigationBar(){
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        editButton?.isEnabled = false
        let settingsButton = UIBarButtonItem(title: Constants.SettingsControllerTitle, style: .plain, target: self, action: #selector(settingsButtonPressed))
        if isChild {
            self.createBaseNavigationBar()
            self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = editButton
            if self.teacher {
                self.baseNavigationBar?.baseNavigationItem.leftBarButtonItem = settingsButton
            }
            self.baseNavigationBar?.setBackgroundImage(UIImage(), for: .default)
            self.baseNavigationBar?.shadowImage = UIImage()
            self.baseNavigationBar?.isTranslucent = true
        } else if SessionData.id == userID && user != nil {
            self.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    func editButtonPressed(){
        let operation = RouterOperationXib.openEditUserProfile(user: user)
        self.router.performOperation(operation)
    }
    func settingsButtonPressed(){
        let operation = RouterOperationXib.openSettingsScreen
        self.router.performOperation(operation)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -25){
            if !isChild {
                self.navigationController?.navigationBar.backgroundColor = .clear
                statusBar?.backgroundColor = .clear
            } else{
                self.baseNavigationBar?.backgroundColor = .clear
            }
        } else{
            if !isChild {
                self.navigationController?.navigationBar.backgroundColor = navColor.withAlphaComponent(0.5)
                statusBar?.backgroundColor = navColor.withAlphaComponent(0.5)
            } else {
                self.baseNavigationBar?.backgroundColor = navColor.withAlphaComponent(0.5)
            }
        }
    }
}
