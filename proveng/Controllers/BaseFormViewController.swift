
//  BaseFormViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

class BaseFormViewController: FormViewController, BaseViewControllerProtocol, UINavigationBarDelegate, BaseLoadViewProtocol {
    
    let interval = Date().getWeekdayByDate()
    let lessonTimeInterval: TimeInterval = 60*60
    let formStartTime = Date().dateByDefaultTime(16,minute: 30, seconds: 0)
    var baseNavigationBar: BaseNavigationBar?
    var refreshControl: UIRefreshControl!
    
    var formEndTime: Date {
        return formStartTime.addingTimeInterval(self.lessonTimeInterval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        self.navigationController?.navigationBar.barStyle = .black
        configureDefaultCells()
        self.tableView?.backgroundColor = ColorForElements.background.color
        self.tableView?.estimatedRowHeight = 45
        fixFrameTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func deleteAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func insertAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func reloadAnimation(oldRows: [BaseRow], newRows: [BaseRow]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func reloadAnimation(oldSections: [Section], newSections: [Section]) -> UITableViewRowAnimation {
        return .fade
    }
    
    func configurePullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestObjects), for: UIControlEvents.valueChanged)
        tableView?.insertSubview(refreshControl, at: 0)
    }
    
    func requestObjects() { }
    
    func presentTestPreviewVC(testID: Int, isStartTest: Bool = true) {
        let operation = RouterOperationXib.openTestPreview(testID: testID)
        let testPreviewVC = self.router.performOperation(operation) as? TestPreviewViewController
        testPreviewVC?.isStartTest = isStartTest
    }
    
    func createBaseNavigationBar() {
        self.baseNavigationBar = BaseNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        self.baseNavigationBar!.isTranslucent = false
        self.baseNavigationBar!.delegate = self
        self.baseNavigationBar?.baseNavigationItem.title = self.title
        self.view.addSubview(baseNavigationBar!)
    }
    
    func configureDefaultCells(){
        DatePickerRow.defaultCellUpdate = { cell, row in
            cell.datePicker.locale = Locale(identifier: "en-US")
        }        
        LabelRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
            cell.textLabel?.numberOfLines = 0
        }
        ButtonPushRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
        }
        AccountRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
            cell.textField.font = Constants.lightFont
            cell.textField.textColor = ColorForElements.text.color
        }
        NameRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
            cell.textField.font = Constants.lightFont
            cell.textField.textColor = ColorForElements.text.color
        }
        PhoneRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
            cell.textField.font = Constants.lightFont
            cell.textField.textColor = ColorForElements.text.color
        }
        PushRow<String>.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
        }
        DateInlineRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
        }
        TimeInlineRow.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
        }
        PickerInlineRow<String>.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
        }
        TextAreaRow.defaultCellUpdate = { cell, row in
            cell.textView.font = Constants.lightFont
            cell.placeholderLabel.font = Constants.lightFont
            cell.textView.textColor = ColorForElements.text.color
            cell.textView.backgroundColor = UIColor.clear
        }
        ListCheckRow<String>.defaultCellUpdate = { [weak self] cell, row in
            _ = self?.cellConfiguration(cell: cell)
            cell.tintColor = ColorForElements.additional.color
            
        }
        TestRow.defaultCellUpdate = { cell, row in
            cell.nameLabel.font = Constants.regularFont
            cell.nameLabel.textColor = ColorForElements.additional.color
            cell.pointLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
            cell.timeLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight)
        }
    }
    
    func cellConfiguration(cell: UITableViewCell) -> UITableViewCell {
        cell.textLabel?.font = Constants.lightFont
        cell.detailTextLabel?.font = Constants.lightFont
        cell.textLabel?.textColor = ColorForElements.text.color
        cell.detailTextLabel?.textColor = ColorForElements.text.color
        return cell
    }
    
    func setTranslucentBaseNavigationBar() {
        self.baseNavigationBar!.barTintColor = ColorForElements.background.color
        self.baseNavigationBar!.tintColor = ColorForElements.text.color
        self.baseNavigationBar!.titleTextAttributes = [NSForegroundColorAttributeName: ColorForElements.text.color, NSFontAttributeName: Constants.regularFont]
        self.baseNavigationBar!.baseNavigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
        self.baseNavigationBar!.baseNavigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
    }
    
    func setTranslucentNavigationBar(backgroundColor: UIColor? = .white) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        self.navigationController?.navigationBar.tintColor = ColorForElements.text.color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorForElements.text.color, NSFontAttributeName: Constants.regularFont]
        self.navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
        self.navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
    }
    
    func setDefaultNavigationBar() {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        UINavigationBar.appearance().tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = ColorForElements.main.color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: Constants.regularFont]
        self.navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIColor.white], for: .normal)
        self.navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIColor.white], for: .normal)
    }
    
    func backToPrevVC(){
        if self.navigationController?.topViewController == self {
            let operation = RouterOperationBack.close
            self.router.performOperation(operation)
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func handleError(error: Error) {
        guard error.apiError.code != 403 else {
            return
        }
        var errorTitle = error.apiError.domain
        if error.apiError.code == 404 {
            errorTitle = "Error"
        }
        let operation = RouterOperationAlert.showError(title: errorTitle, message: error.apiError.errorDescription, handler: nil)
        _ = self.router.performOperation(operation)
    }
}

extension BaseFormViewController {
    
    func fixInsetTableView() {
        let statusBarHeight: CGFloat = 20
        let navigationBarHeight: CGFloat = self.navigationController == nil ? 44 : (self.navigationController!.navigationBar.frame).height
        let adjustForBarsInsets = UIEdgeInsetsMake(navigationBarHeight + statusBarHeight, 0, 0, 0)
        tableView!.contentInset = adjustForBarsInsets
    }
    
    func fixFrameTableView() {
        let statusBarHeight: CGFloat = 20
        let navigationBarHeight: CGFloat = self.navigationController == nil ? 44 : (self.navigationController!.navigationBar.frame).height
        if let tableView = self.tableView {
            let offset = navigationBarHeight + statusBarHeight
            self.tableView?.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y + offset, width: tableView.frame.size.width, height: tableView.frame.size.width - offset)
        }
    }
    
    func adHocReloadWithoutResetContentOffset(_ actionsWithoutAnimation: () -> Void) {
        let contentOffset = self.tableView?.contentOffset
        UIView.performWithoutAnimation(actionsWithoutAnimation)
        self.tableView?.contentOffset = contentOffset!
    }
    
    //Validation
    func validateRow(_ rowTag: String) -> Bool {
        guard let row = self.form.rowBy(tag: rowTag) as? NameRow else {
            print("No such row")
            return false
        }
        if row.baseValue == nil || row.baseValue as? String == ""{
            row.cell?.backgroundColor = Constants.errorColor
            row.updateCell()
            let error = ApiError(errorDescription: "\(rowTag) is empty")
            self.handleError(error: error)
            return false
        }
        return true
    }
    
    func validateTextRow(_ rowTag: String) -> Bool {
        guard let row = self.form.rowBy(tag: rowTag) as? TextAreaRow else {
            print("No such row")
            return false
        }
        if row.baseValue == nil || row.baseValue as? String == ""{
            row.cell?.backgroundColor = Constants.errorColor
            row.updateCell()
            let error = ApiError(errorDescription: "\(rowTag) is empty")
            self.handleError(error: error)
            return false
        }
        return true
    }
    
    func validatePickertRow(_ rowTag: String) -> Bool {
        guard let row = self.form.rowBy(tag: rowTag) as? PickerInlineRow<String> else {
            print("No such row")
            return false
        }
        if row.baseValue == nil || row.baseValue as? String == ""{
            row.cell?.backgroundColor = Constants.errorColor
            row.updateCell()
            let error = ApiError(errorDescription: "\(rowTag) is empty")
            self.handleError(error: error)
            return false
        }
        return true
    }
    
    func validateButtonPushRow(_ rowTag: String) -> Bool {
        guard let row = self.form.rowBy(tag: rowTag) as? ButtonPushRow else {
            print("No such row")
            return false
        }
        if (row.title == row.tag){
//            row.cell?.backgroundColor = Constants.errorColor
//            row.updateCell()
            let error = ApiError(errorDescription: "Please choose \(rowTag)")
            self.handleError(error: error)
            return false
        }
        return true
    }
    
    func validatePushRowString(_ rowTag: String, rowTitle: String) -> Bool {
        guard let row = self.form.rowBy(tag: rowTag) as? PushRow<String> else {
            print("No such row")
            return false
        }
        if row.baseValue == nil || row.baseValue as? String == ""{
            row.cell?.backgroundColor = Constants.errorColor
            row.updateCell()
            let error = ApiError(errorDescription: "Please choose \(rowTitle)")
            self.handleError(error: error)
            return false
        }
        return true
    }
    
    func validateStartEndDateRow(_ startTag: String, endTag: String) -> Bool {
        if let startDateRow: TimeInlineRow = self.form.rowBy(tag: startTag), let endDateRow: TimeInlineRow = self.form.rowBy(tag: endTag), let startDate = startDateRow.value as Date?, let endDate = endDateRow.value as Date? {
            let (time, compareWithTime) = endDate.timeMoreThan(time: startDate)
            if time < compareWithTime {
                let error = ApiError(errorDescription: Constants.IncorrectDateAlertMessage)
                self.handleError(error: error)
                return false
            } else if time == compareWithTime{
                endDateRow.cell.backgroundColor = Constants.errorColor
                let error = ApiError(errorDescription: Constants.SameDateAlertMessage)
                self.handleError(error: error)
                return false
            }
            return true
        } else {
            print("No such rows")
            return false
        }
    }
}
