//
//  TestRouteOperation.swift
//  proveng
//
//  Created by Dmitry Kulakov on 28.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import XCTest

@testable import proveng

class TestRouteOperation: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRouteOperationXibOpenLogin() {
        let operation = RouterOperationXib.OpenLogin
        let baseViewController = operation.baseViewController
        XCTAssert(operation.xibName == "LoginViewController")
        XCTAssert(type(of: baseViewController) == LoginViewController.self)
    }
    
    func testRouterOperationAlertShowAlert() {
        let title = "Success"
        let buttonTitles = ["OK","NEXT"]
        let needCancelButton = true
        let operation = RouterOperationAlert.ShowAlert(title: title, message: "", style: .Alert, cancelButton: needCancelButton, buttonTitles: buttonTitles, handler: nil)
        let alertViewController = operation.alertController
        XCTAssert(type(of: alertViewController) == UIAlertController.self)
        XCTAssert(alertViewController.title == title)
        XCTAssert(alertViewController.preferredStyle == .Alert)
        XCTAssert(alertViewController.actions.count == buttonTitles.count + (needCancelButton ? 1 : 0))
    }
    
    func testRouterOperationSwitchTabBar() {
        let operation = RouterOperationSwitchTabBar.OpenChalenge
        let index = operation.tag
        XCTAssert(index == 3)
    }
    
    func testRouteOperationXibOpenHomeScreen() {
        let operation = RouterOperationXib.OpenHomeScreen
        let baseViewController = operation.baseViewController
        XCTAssert(operation.xibName == "TeacherHomeTabBarController")
        XCTAssert(type(of: baseViewController) == TeacherHomeTabBarController.self)
        XCTAssert(((baseViewController as! TeacherHomeTabBarController).viewControllers?.count) == 4)
    }
    
    func testRouteOperationBackToLogin() {
        let operation = RouterOperationBack.BackToLogin
        let router = (UIApplication.sharedApplication().delegate as! AppDelegate).router!
        let baseViewController = operation.baseViewController(router)
        XCTAssertNil(baseViewController) //test that back operation won't work if login screen isn't presented
        
        let expect = self.expectation(description: "Back To Login")
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            let baseViewController = operation.baseViewController(router)!
            XCTAssert(type(of: baseViewController) == LoginViewController.self)
            expect.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}
