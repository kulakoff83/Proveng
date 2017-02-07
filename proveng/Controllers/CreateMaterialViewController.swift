//
//  CreateMaterialViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 30.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//
import UIKit
import Eureka
import PromiseKit
import RealmSwift

class CreateMaterialViewController: BaseFormViewController {
    
    var doneButton: UIBarButtonItem?
    var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.checkPasteBoard()
        self.configureCreateMaterialForm()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkPasteBoard),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(endEditing),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
    }
    
    func configureCreateMaterialForm() {
        _ = self.addSection(tag: "Main")
        _ = self.addNameRow(title: Constants.MaterialTitle, icon: IconForElements.materialTitle.icon)
        _ = self.addPushRow(title: Constants.MaterialType, icon: IconForElements.materialType.icon, options: ServiceForBasicValue().getMaterialType(), value: "", section: self.form.sectionBy(tag: "Main"))
        _ = self.createLevelsRow(levelValue: "", titleSection: "Main")
        _ = self.addSection()
        _ = self.addTextAreaRow(title: Constants.MaterialDescription, icon: IconForElements.materialDescript.icon)
        
        _ = self.addSection()
        self.addTextAreaRow(title: Constants.MaterialLink, icon: IconForElements.link.icon, value: link).cellUpdate { [weak self] (cell, row) in
            row.value = self?.link
            row.textAreaHeight = .dynamic(initialTextViewHeight: 20)
        }
    }
    
    func checkPasteBoard(){
        let pasteboardString = UIPasteboard.general.string
        if let theString = pasteboardString, let url = URL(string: theString) {
            if UIApplication.shared.canOpenURL(url) {
                link = theString
                self.tableView?.reloadData()
            }
        }
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    func createMaterial() {
        self.doneButton?.isEnabled = false
        var levelName = ""
        if let name = (self.form.rowBy(tag: Constants.GroupLevel) as? PushRow<String>)?.value {
            levelName = name
        }
        firstly {
            ServiceForData<GroupLevelPreview>().getDataByKeyFromStoragePromise("name", filterValue: levelName)
        }.then { level -> Promise<Material> in
            let material = Material()
            if let titleRow = self.form.rowBy(tag: Constants.MaterialTitle) as? NameRow, let title = titleRow.value {
                material.name = title
            }
            if let typeRow = self.form.rowBy(tag: Constants.MaterialType) as? PushRow<String>, let type = typeRow.value {
                material.type = type.uppercased()
            }
            material.minLevel = "\(level.value)"
            if let noteRow = self.form.rowBy(tag: Constants.MaterialDescription) as? TextAreaRow, let noteValue = noteRow.value {
                material.materialDescript = noteValue
            }
            if let linkRow = self.form.rowBy(tag: Constants.MaterialLink) as? TextAreaRow, let linkValue = linkRow.value {
                material.link = linkValue
            }
            return ServiceForRequest<Material>().getObjectPromise(ApiMethod.createMaterial(material: material))
        }.then { material -> Void in
            let materialPreview = MaterialPreview()
            materialPreview.objectID = material.objectID
            materialPreview.name = material.name
            materialPreview.type = material.type
            materialPreview.minLevel = material.minLevel
            let realm = try Realm()
            try realm.write {
                realm.add(materialPreview, update: true)
            }
            self.backToPrevVC()
        }.always { [weak self] in
            self?.doneButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
}

extension CreateMaterialViewController {
    
    func configureNavigationBar(){
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.backToPrevVC))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneButtonPressed() {
        guard validateRow(Constants.MaterialTitle) == true else {
            return
        }
        guard validatePushRowString(Constants.MaterialType, rowTitle: Constants.MaterialType) == true else {
            return
        }
        guard validatePushRowString(Constants.GroupLevel, rowTitle: Constants.GroupLevel) == true else {
            return
        }
        guard validateTextRow(Constants.MaterialDescription) == true else {
            return
        }
        guard validateTextRow(Constants.MaterialLink) == true else {
            return
        }
        self.createMaterial()
    }
}
