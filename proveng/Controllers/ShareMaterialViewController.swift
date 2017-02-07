//
//  ShareMaterialViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 02.11.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class ShareMaterialViewController: BaseFormViewController {
    
    var level: String? = nil
    var groupID: Int = 0
    var materialID: Int = 0
    var materials: Results<MaterialPreview>!
    fileprivate var notificationToken: NotificationToken? = nil
    var materialsActiveMethod: ApiMethod?
    var levels: Results<GroupLevelPreview>!
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMaterials()
        self.configureNavigationBar()
        self.requestMaterials()
    }
    
    func setMaterials() {
        firstly {
            ServiceForData<GroupLevelPreview>().getDataResultsByIDFromStoragePromise(0)
        }.then { [weak self] levels -> Promise<Results<MaterialPreview>> in
            self?.levels = levels
            return ServiceForData<MaterialPreview>().getDataArrayFromStoragePromise()
        }.then { [weak self] materials -> Void in
            self?.materials = materials
            self?.addMaterialsSections()
            self?.configureRealmNotification()
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestMaterials() {
        ApiLayer.SharedApiLayer.cancel(self.materialsActiveMethod)
        let materialsMethod = ApiMethod.getMaterials
        self.materialsActiveMethod = materialsMethod
        firstly {
            ServiceForRequest<MaterialPreview>().getObjectsPromise(materialsMethod)
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {
        // Observe Results Notifications
        self.notificationToken = materials.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial,.update:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView?.reloadData()
                self?.addMaterialsSections()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func addMaterialsSections() {
        for level in self.levels {
            let levelName: String = level.name != nil ? level.name! : ""
            let materialsForLevel = self.materials.filter{ $0.minLevel == levelName }
            if materialsForLevel.count > 0{
                if form.sectionBy(tag:levelName) == nil {
                    _ = self.addSection(title: levelName, tag: levelName)
                }
                for material in materialsForLevel {
                    let materialID = material.objectID
                    let materialIDString = "\(material.objectID)"
                    if (self.form.rowBy(tag: materialIDString) == nil) {
                        self.addPhotoLabelRow(title: material.name, useCheck: true, tag: materialIDString, section: form.sectionBy(tag: levelName)).cellUpdate{ (cell, row) in
                            ServiceForData<MaterialPreview>().getObjectByID(id: materialID, handler: { materialData in
                                cell.nameLabel?.text = materialData.name
                            })
                        }.onCellSelection{ [weak self] (cell, row) in
                            self?.unchekRows()
                            row.value = true
                            row.updateCell()
                        }
                    }
                }
            }
        }
    }
    
    func updateSection<T: BaseModel>(objects: Results<T>) {
        for row in self.form.allRows {
            if let rowTag = row.tag, let intTag = Int(rowTag) {
                let filteredObjects = objects.filter{ $0.objectID == intTag }
                if filteredObjects.count == 0 && objects.count != 0 {
                    if let indexPath = row.indexPath {
                        if let tag = row.section?.tag,  var section = self.form.sectionBy(tag: tag) {
                            section.remove(at: indexPath.row)
                        }
                    }
                }
            }
        }
    }
    
    func unchekRows() {
        for row in self.form.rows as! [PhotoLabelRow] {
            row.value = false
            row.updateCell()
        }
    }
}

extension ShareMaterialViewController {
    
    func configureNavigationBar(){
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonPressed() {
        self.doneButton?.isEnabled = false
        for material in self.materials {
            if let row: PhotoLabelRow = self.form.rowBy(tag: "\(material.objectID)"), row.value == true {
                self.materialID = material.objectID
            }
        }
        guard self.materialID != 0 else {
            self.doneButton?.isEnabled = true
            let error = ApiError(errorDescription: "Please choose material for sharing")
            self.handleError(error: error)
            return
        }
        firstly {
            ApiLayer.SharedApiLayer.requestWithDictionaryPromise(ApiMethod.openMaterial(materialID: self.materialID, groupID: self.groupID))
        }.then { [weak self] _ -> Void in
            self?.backToPrevVC()
        }.always { [weak self] in
            self?.doneButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
}
