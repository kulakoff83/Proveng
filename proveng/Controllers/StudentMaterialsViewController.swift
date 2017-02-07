//
//  StudentMaterialsViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import ObjectMapper
import PromiseKit
import RealmSwift

class StudentMaterialsViewController: BaseFormViewController, FilterLessonWorkshopViewControllerDelegate, UITabBarControllerDelegate {
    
    var isChild = true
    var tests: Results<TestPreview>!
    var materials: Results<MaterialPreview>!
    fileprivate var notificationToken: NotificationToken? = nil
    var segmentControl = BaseSegmentedControl()
    fileprivate let apiLayer = ApiLayer.SharedApiLayer
    var levels: Results<GroupLevelPreview>!
    var testsActiveMethod: ApiMethod?
    var materialsActiveMethod: ApiMethod?
    var isFilterResetNeeded = true
    var filterKey = "filterMaterials"
    var defaultFilterKey = "defaultFilterMaterials"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLevels()
        self.setMaterials()
        self.configureNavigationBar()
        self.configurePullToRefresh()
        self.requestMaterials()
        self.requestTests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isChild {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFilterResetNeeded = true
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func cancelActiveRequests() {
        ApiLayer.SharedApiLayer.cancel(self.testsActiveMethod)
        ApiLayer.SharedApiLayer.cancel(self.materialsActiveMethod)
    }
    
    func setTests() {
        firstly {
            ServiceForData<TestPreview>().getDataArrayFromStoragePromise()
        }.then { [weak self] tests -> Void in
            self?.tests = tests
            self?.addTestSections()
            self?.configureRealmNotification(objects: self!.tests)
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func setLevels(){
        firstly {
            ServiceForData<GroupLevelPreview>().getDataResultsByIDFromStoragePromise(0)
        }.then { [weak self] levels -> Void in
            self?.levels = levels
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func setMaterials() {
        firstly {
            ServiceForData<MaterialPreview>().getDataArrayFromStoragePromise()
        }.then { [weak self] materials -> Void in
            self?.materials = materials
            self?.addMaterialsSections()
            self?.configureRealmNotification(objects: self!.materials)
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification<T>(objects: Results<T>) {
        // Observe Results Notifications
        self.notificationToken = objects.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial,.update:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView?.beginUpdates()
                self?.tableView?.endUpdates()
                let userDefaults = UserDefaults.standard
                if T() is TestPreview {
                    self?.tests = objects as Any as? Results<TestPreview>
                    if !userDefaults.bool(forKey: Constants.DefaultTestsFilterKey) {
                        self?.filterObjects(filterParameters: userDefaults.object(forKey: Constants.TestsFilterKey) as! [String : [String]])
                        break
                    }
                    self?.addTestSections()
                } else {
                    self?.materials = objects as Any as? Results<MaterialPreview>
                    if !userDefaults.bool(forKey: Constants.DefaultMaterialFilterKey) {
                        self?.filterObjects(filterParameters: userDefaults.object(forKey: Constants.MaterialFilterKey) as! [String : [String]])
                        break
                    }
                    self?.addMaterialsSections()
                }
                break
            case .error(let error)://need add if group was deleting
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    deinit {
        notificationToken?.stop()
        print("Deinit Materials")
    }
    
    override func requestObjects() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.requestMaterials()
        case 1:
            self.requestTests()
        default:
            break
        }
    }
    
    func requestTests() {
        ApiLayer.SharedApiLayer.cancel(self.testsActiveMethod)
        let testsMethod = ApiMethod.getTests
        self.testsActiveMethod = testsMethod
        firstly {
            ServiceForRequest<TestPreview>().getObjectsPromise(testsMethod)
        }.always { [weak self] in
            self?.stopRefreshControl()
        }.catch { [weak self] error in
            guard error.apiError.code != 404 else {
                return
            }
            self?.handleError(error: error)
        }
    }
    
    func requestMaterials() {
        ApiLayer.SharedApiLayer.cancel(self.materialsActiveMethod)
        let materialsMethod = ApiMethod.getMaterials
        self.materialsActiveMethod = materialsMethod
        firstly {
            ServiceForRequest<MaterialPreview>().getObjectsPromise(materialsMethod)
        }.always { [weak self] in
            self?.stopRefreshControl()
        }.catch { [weak self] error in
            guard error.apiError.code != 404 else {
                return
            }
            self?.handleError(error: error)
        }
    }
    
    func stopRefreshControl() {
        self.refreshControl.endRefreshing()
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView?.contentOffset = CGPoint.zero//FIXME: problem in ios 10 need this crutch
        })
    }
    
    func configureSegmentControl() {
        let zero: CGFloat = 0
        let height: CGFloat = 29
        let width: CGFloat = 226
        let frame = CGRect(x:zero,y:zero,width: width, height: height)
        segmentControl = BaseSegmentedControl(items: ["Materials","Tests"])
        segmentControl.frame = frame
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)
        self.baseNavigationBar?.baseNavigationItem.titleView = segmentControl
    }
    
    func addTestSections() {
        if form.sectionBy(tag:"Test") == nil {
            let section = self.addSection(tag: "Test")
            section.header?.height = {CGFloat.leastNormalMagnitude}
        }
        for level in self.levels {
            guard let levelName: String = level.name else {
                return
            }
            let testsForLevel = self.tests.filter{ $0.level == levelName }
            if testsForLevel.count > 0 {
                if form.sectionBy(tag:levelName) == nil {
                    _ = self.addSection(title: levelName, tag: levelName)
                }
                for test in testsForLevel {
                    let testID = test.objectID
                    let testIDString = "\(test.objectID)"
                    if (self.form.rowBy(tag: testIDString) == nil) {
                        if let section = form.sectionBy(tag: levelName) {
                            if (self.form.rowBy(tag: testIDString) == nil) {
                                self.addTestRow(value: test, tag: testIDString, section: section).cellUpdate{ (cell, row) in
                                    ServiceForData<TestPreview>().getObjectByID(id: testID, handler: { testData in
                                        cell.configureTestCell(testData)
                                    })
                                    }.onCellSelection{ [weak self] (cell, row) in
                                        self?.presentTestPreviewVC(testID: testID, isStartTest: false)
                                }
                            }
                        }
                    }
                }
            }
        }
        self.updateSection(objects: self.tests)
    }
    
    func addMaterialsSections() {
        if form.sectionBy(tag:"Materials") == nil {
            let section = self.addSection(tag: "Materials")
            section.header?.height = {CGFloat.leastNormalMagnitude}
        }
        for level in self.levels {
            guard let levelName: String = level.name else {
                return
            }
            let materialsForLevel = self.materials.filter{ $0.minLevel == levelName }
            if materialsForLevel.count > 0 {
                if form.sectionBy(tag:levelName) == nil {
                    _ = self.addSection(title: levelName, tag: levelName)
                }
                for material in materialsForLevel {
                    let materialID = material.objectID
                    let materialIDString = "\(material.objectID)"
                    if (self.form.rowBy(tag: materialIDString) == nil) {
                        if let section = form.sectionBy(tag: levelName) {
                            guard let materialName = material.name else {
                                return
                            }
                            self.addButtonPushRow(title: materialName , tag: materialIDString, section: section).cellUpdate{ (cell, row) in
                                ServiceForData<MaterialPreview>().getObjectByID(id: materialID, handler: { materialData in
                                    if let materialName = materialData.name {
                                        cell.textLabel?.text = materialName
                                    }
                                })
                            }.onCellSelection{ [weak self] (cell, row) in
                                let operation = RouterOperationXib.openMaterialsScreen(materialID: materialID)
                                _ = self?.router.performOperation(operation)
                            }
                        }
                    }
                }
            }
        }
        self.updateSection(objects: self.materials)
    }
    
    func updateSection<T: BaseModel>(objects: Results<T>) {
        for row in self.form.allRows {
            if let rowTag = row.tag {
                let intTag = Int(rowTag)
                let filteredObjects = objects.filter{ $0.objectID == intTag }
                if filteredObjects.count == 0 {//&& objects.count != 0 {
                    if let indexPath = row.indexPath {
                        guard let sectionTag = row.section?.tag else {
                            return
                        }
                        var section = self.form.sectionBy(tag: sectionTag)
                        section?.remove(at: indexPath.row)
                        if (self.form.allRows.filter{ $0.section == section }).count == 0 {
                            if let sectionIndex = section?.index {
                                self.form.remove(at: sectionIndex)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func segmentValueChanged(sender: AnyObject?){
        self.stopRefreshControl()
        self.form.removeSubrange(0...form.allSections.count)
        switch sender!.selectedSegmentIndex {
        case 0:
            self.defaultFilterKey = Constants.DefaultMaterialFilterKey
            self.filterKey = Constants.MaterialFilterKey
            self.setMaterials()
            addNavItem()
        case 1:
            self.filterKey = Constants.TestsFilterKey
            self.defaultFilterKey = Constants.DefaultTestsFilterKey
            self.setTests()
            self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = nil
        default:
            break
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController != self) && (isFilterResetNeeded) {
            resetFilter()
            isFilterResetNeeded = false
        } else if viewController == self {
            isFilterResetNeeded = true
            //self.cancelActiveRequests()
        }
    }
    
    func filterObjects(filterParameters: [String: [String]]) {
        
        guard let filterType = filterParameters["type"] else {
            return
        }
        guard let filterLevel = filterParameters["level"] else {
            return
        }
        
        if self.filterKey == Constants.MaterialFilterKey {
            firstly {
                ServiceForData<MaterialPreview>().getDataArrayFromStoragePromise()
            }.then { [weak self] materials -> Void in
                self?.materials = materials
                var types = [String]()
                for type in filterType {
                    types.append(type.uppercased())
                }
                let typePredicate = NSPredicate(format: "type IN %@",types as CVarArg)
                let levelPredicate = NSPredicate(format: "minLevel IN %@",filterLevel as CVarArg)
                self?.materials = materials.filter(typePredicate).filter(levelPredicate)
                self?.addMaterialsSections()
            }.catch { error in
                print(error)
            }
        } else {
            firstly {
                ServiceForData<TestPreview>().getDataArrayFromStoragePromise()
                }.then { [weak self] tests -> Void in
                    self?.tests = tests
                    let levelPredicate = NSPredicate(format: "level IN %@",filterLevel as CVarArg)
                    self?.tests = tests.filter(levelPredicate)
                    self?.addTestSections()
                }.catch { error in
                    print(error)
            }
        }
    }
    
    func resetFilter() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: Constants.DefaultMaterialFilterKey)
        userDefaults.set(true, forKey: Constants.DefaultTestsFilterKey)
        if self.filterKey == Constants.MaterialFilterKey {
            setMaterials()
        } else {
            setTests()
        }
    }
}

extension StudentMaterialsViewController {
    
    func addButtonPressed() {
        let operation = RouterOperationXib.openCreateMaterial
        self.router.performOperation(operation)
    }
    
    func filterButtonPressed() {
        let operation = RouterOperationXib.openFilterLessonWorkshop
        let filterVC = self.router.performOperation(operation) as! FilterLessonWorkshopViewController
        filterVC.delegate = self
        filterVC.currentTypes = self.filterKey == Constants.MaterialFilterKey ? ServiceForBasicValue().getMaterialType() : [String]()
        filterVC.filterKey = filterKey
        filterVC.defaultFilterKey = defaultFilterKey
    }
    
    func configureNavigationBar(){
        self.createBaseNavigationBar()
        self.configureSegmentControl()
        addNavItem()
    }
    
    func addNavItem(){
        if SessionData.teacher {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
            self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = addButton
        }
        let filterButton = UIBarButtonItem(image:  UIImage(named: "filter"),style: .plain,target: self, action: #selector(filterButtonPressed))
        self.baseNavigationBar?.baseNavigationItem.leftBarButtonItem = filterButton
    }
}
