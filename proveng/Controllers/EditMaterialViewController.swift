//
//  EditMaterialViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 01.11.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

class EditMaterialViewController: BaseFormViewController {
    
    var doneButton: UIBarButtonItem?
    var material = Material()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.configureCreateMaterialForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureCreateMaterialForm() {
        let type = self.material.type?.lowercased()
        _ = self.addSection(tag: "Main")
        _ = self.addNameRow(title: Constants.MaterialTitle, icon: IconForElements.materialTitle.icon, value: self.material.name)
        _ = self.addPushRow(title: Constants.MaterialType, icon: IconForElements.materialType.icon, options: ServiceForBasicValue().getMaterialType(), value: type?.capitalizingFirstLetter(), section: self.form.sectionBy(tag: "Main"))
        _ = self.addSection()
        _ = self.addTextAreaRow(title: Constants.MaterialDescription, icon: IconForElements.materialDescript.icon, value: self.material.materialDescript)
        
        _ = self.addSection()
        _ = self.addTextAreaRow(title: Constants.MaterialLink, icon: IconForElements.link.icon, value: self.material.link)
    }
    
    func editMaterial() {
        self.doneButton?.isEnabled = false
        let levelName = material.minLevel != nil ? material.minLevel : ""
        var currentMaterial = Material()
        firstly {
            BaseModel.mappedCopy(self.material)
        }.then { mapedMaterial -> Promise<GroupLevelPreview> in
            currentMaterial = mapedMaterial
            return ServiceForData<GroupLevelPreview>().getDataByKeyFromStoragePromise("name", filterValue: levelName!)
        }.then { level -> Promise<Material> in
            if let titleRow = self.form.rowBy(tag: Constants.MaterialTitle) as? NameRow, let title = titleRow.value {
                currentMaterial.name = title
            }
            if let typeRow = self.form.rowBy(tag: Constants.MaterialType) as? PushRow<String>, let type = typeRow.value {
                currentMaterial.type = type.uppercased()
            }
            currentMaterial.minLevel = "\(level.value)"
            if let noteRow = self.form.rowBy(tag: Constants.MaterialDescription) as? TextAreaRow, let noteValue = noteRow.value {
                currentMaterial.materialDescript = noteValue
            }
            if let linkRow = self.form.rowBy(tag: Constants.MaterialLink) as? TextAreaRow, let linkValue = linkRow.value {
                currentMaterial.link = linkValue
            }
            return ServiceForRequest<Material>().getObjectPromise(ApiMethod.editMaterial(material: currentMaterial))
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

extension EditMaterialViewController {
    
    func configureNavigationBar(){
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonPressed() {
        guard validateRow(Constants.MaterialTitle) == true else {
            return
        }
        guard validatePushRowString(Constants.MaterialType, rowTitle: Constants.MaterialType) == true else {
            return
        }
        guard validateTextRow(Constants.MaterialDescription) == true else {
            return
        }
        guard validateTextRow(Constants.MaterialLink) == true else {
            return
        }
        self.editMaterial()
    }
}
