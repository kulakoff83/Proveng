//
//  BaseViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 08.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit

class BaseViewController: UIViewController, BaseViewControllerProtocol, UINavigationBarDelegate, BaseLoadViewProtocol {
    
    var baseNavigationBar: BaseNavigationBar?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createBaseNavigationBar() {
        self.baseNavigationBar = BaseNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        self.baseNavigationBar!.isTranslucent = false
        self.baseNavigationBar!.delegate = self
        self.baseNavigationBar?.baseNavigationItem.title = self.title
        self.view.addSubview(baseNavigationBar!)
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
    
    func checkUserType(type: Bool, user: User) {
        SessionData.teacher = type
        let role = user.role.filter("name == %@",UserRoleType.student.rawValue)
        if type {
            self.presentHomeScreenVC(teacher: type)
        } else if role.count > 0 {
            self.presentHomeScreenVC(teacher: false)
        } else {
            self.requestTests()
        }
        self.appDelegate.setupBaseAppearance()
        self.navigationController?.navigationBar.barTintColor = ColorForElements.main.color//Important
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
    
    func setTranslucentNavigationBar(backgroundColor: UIColor? = .white) {
        let translucentImage = UIImage.createImageFromNavBar()
        self.navigationController?.navigationBar.shadowImage = translucentImage
        self.navigationController?.navigationBar.setBackgroundImage(translucentImage, for: .default)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        self.navigationController?.navigationBar.tintColor = ColorForElements.text.color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ColorForElements.text.color, NSFontAttributeName: Constants.regularFont]
        self.navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
        self.navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Constants.lightFont], for: .normal)
    }
    
    func setDefaultNavigationBar() {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.barTintColor = ColorForElements.main.color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: Constants.regularFont]
        self.navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIColor.white], for: .normal)
        self.navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIColor.white], for: .normal)
    }
    
    // MARK: - Requests
    
    func requestTests() {
        firstly{
            ServiceForRequest<Test>().getObjectsPromise(ApiMethod.getTests)
        }.then { tests -> Void in
                var testID: Int?
                for test in tests {
                    if test.type == "START" {
                        testID = test.objectID
                    }
                }
                if let startTestID = testID {
                    self.presentTestPreviewVC(testID: startTestID, isStartTest: true)
                } else {
                    self.presentHomeScreenVC(teacher: false)
                }
            }.catch { error in
                self.handleError(error: error)
        }
    }

    // MARK: - Present Controllers
    func presentPromoVC() {
        let operation = RouterOperationStoryBoard.openPromo
        self.router.performOperation(operation)
    }
    
    func presentHomeScreenVC(teacher: Bool) {
        let operation = RouterOperationXib.openHomeScreen(userType: teacher ? .teacher : .student)
        self.router.performOperation(operation)
    }
    
    func presentTestPreviewVC(testID: Int, isStartTest: Bool = false) {
        let operation = RouterOperationXib.openTestPreview(testID: testID)
        let testPreviewVC = self.router.performOperation(operation) as? TestPreviewViewController
        testPreviewVC?.isStartTest = isStartTest
    }
    
    func backToTestPreviewVC(testID: Int, isStartTest: Bool = false) {
        let operation = RouterOperationBack.backToTestPreview(testID: testID)
        let testPreviewVC = self.router.performOperation(operation) as? TestPreviewViewController
        testPreviewVC?.isStartTest = isStartTest
    }
    
    func backToLogin() {
        let operation = RouterOperationBack.backToLogin
        self.router.performOperation(operation)
    }
}
