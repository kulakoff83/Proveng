//
//  FilterLessonWorkshopViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift

protocol FilterLessonWorkshopViewControllerDelegate {
    func filterObjects(filterParameters: [String: [String]])
}

class FilterLessonWorkshopViewController: BaseFormViewController {
    
    var delegate: FilterLessonWorkshopViewControllerDelegate?
    var currentLevels = [String]()
    var currentTypes = ServiceForBasicValue().getCalendarEventsType()
    var groupLevels : Results<GroupLevelPreview>?
    var filterParameters = ["type": [String](),"level": [String]()]
    var defaultFilterKey = "defaultFilterCalendar"
    var filterKey = "filterCalendar"
    
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .default
        super.viewDidLoad()
        configureElements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    deinit {
        print("DEINIT")
    }
    
    func configureElements() {
        self.configureNavigationBar()
        firstly {
            ServiceForData<GroupLevelPreview>().getDataResultsByIDFromStoragePromise(0)
        }.then { [weak self] levels -> Void in
            self?.groupLevels = levels
        }.always { [weak self] in
            self?.configureFilterForm()
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: - Configure Table Form
    
    func configureFilterForm() {
        self.setSortElements()
        if self.currentTypes.count > 0 {
            _ = self.addSection(title: "SORT BY TYPE")
            for type in self.currentTypes {
                if let typeIndex = self.currentTypes.index(of: type) {
                    let typeValue = self.isChekedValue(key: "type", value: type) ? true : false
                    _ = self.addPhotoLabelRow(type: type, useCheck: true, tag: "Type\(typeIndex)", value: typeValue)
                }
            }
        }
        
        _ = self.addSection(title: "SORT BY LEVEL")
        for level in self.currentLevels { 
            if let levelIndex = self.currentLevels.index(of: level) {
                let levelValue = self.isChekedValue(key: "level", value: level) ? true : false
                _ = self.addPhotoLabelRow(level: level.capitalized, useCheck: true, tag: "Level\(levelIndex)", value: levelValue)
            }
        }
    }
    
    // MARK: - Set Elements
    
    func setSortElements() {
        guard let levels = self.groupLevels else {
            return
        }
        let baseLevels = ServiceForBasicValue().getGroupLevels()
        if levels.count == 0 {
            currentLevels = baseLevels
        } else {
            for level in levels {
                if let levelName = level.name {
                    currentLevels.append(levelName)
                }
            }
        }
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: defaultFilterKey) {
            fillParameters()
            userDefaults.set(false, forKey: defaultFilterKey)
        }
        self.filterParameters = userDefaults.value(forKey: filterKey) as! [String : [String]]
    }
    
    func fillParameters() {
        
        for type in self.currentTypes {
            self.filterParameters["type"]?.append(type)
        }
        for level in self.currentLevels {
            self.filterParameters["level"]?.append(level)
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.filterParameters, forKey: filterKey)
    }
    
    func isChekedValue(key: String, value: String) -> Bool {
        if let filter = self.filterParameters[key] {
            if filter.contains(value) {
                return true
            }
        }
        return false
    }
    
    func  detectChoosedRows() {
        self.filterParameters = ["type": [String](),"level": [String]()]
        for type in self.currentTypes {
            if let typeIndex = self.currentTypes.index(of: type) {
                if let row = self.form.rowBy(tag: "Type\(typeIndex)") as? PhotoLabelRow {
                    if row.value == true {
                        self.filterParameters["type"]?.append(type)
                    }
                }
            }
        }
        for level in self.currentLevels {
            if let levelIndex = self.currentLevels.index(of: level) {
                if let row = self.form.rowBy(tag: "Level\(levelIndex)") as? PhotoLabelRow {
                    if row.value == true {
                        self.filterParameters["level"]?.append(level)
                    }
                }
            }
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.filterParameters, forKey: filterKey)
        self.delegate?.filterObjects(filterParameters: self.filterParameters)
    }
}

extension FilterLessonWorkshopViewController {
    
    func configureNavigationBar() {
        createBaseNavigationBar()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        self.baseNavigationBar?.baseNavigationItem.leftBarButtonItem = cancelButton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = doneButton
        self.setTranslucentBaseNavigationBar()
    }
    
    func closeVC() {
        let operation = RouterOperationBack.close
        self.router.performOperation(operation)
    }
    
    func cancelButtonPressed() {
        self.closeVC()
    }
    
    func doneButtonPressed() {
        self.closeVC()
        self.detectChoosedRows()
    }
}
