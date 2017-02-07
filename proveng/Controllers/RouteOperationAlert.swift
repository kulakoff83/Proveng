//
//  RouteOperationAlert.swift
//  proveng
//
//  Created by Dmitry Kulakov on 21.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import PromiseKit
/**
 
 Show AlertViewController
 
 */

enum RouterOperationAlert {
    
    case showError(title: String, message: String, handler: AlertHandler)
    case showSuccess(message: String, handler: AlertHandler)
    case showChoose(title: String, message: String, buttonTitles: [String], cancelButtonTitle: String, handler: AlertHandler)
    case showAlert(title: String, message: String, style: UIAlertControllerStyle,cancelButtonTitle: String?, buttonTitles: [String], handler: AlertHandler)
    case showConfirmingEditEvent(eventType: String, handler: AlertHandler)
    case showConfirmingLogOut(handler: AlertHandler)
    case showTryAgain(handler: AlertHandler)
    case showEndTest(handler: AlertHandler)
    case showCancelTest(handler: AlertHandler)

    
    var alertController: UIAlertController {
        switch self {
        case .showAlert(let title, let message,let style,let cancelButtonTitle, let buttonTitles, let handler):
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            for title in buttonTitles {
                let action = UIAlertAction(title: title, style: .default, handler: handler)
                action.buttonIndex = buttonTitles.index(of: title)! + 1
                alert.addAction(action)
            }
            alert.view.tintColor = ColorForElements.main.color
            if cancelButtonTitle != nil {
                let cancelAction = UIAlertAction(title: Constants.CancelActionTitle, style: .cancel, handler: nil)
                cancelAction.setValue(cancelButtonTitle, forKey: "title")
                cancelAction.buttonIndex = 0
                alert.addAction(cancelAction)
            }
            return alert
        case .showError(var title, var message, var handler):
            if title == "Alamofire.AFError" {
                title = Constants.ErrorAlertTitle
                message = "Server is temporarily unavailable"
            } else if title.isEmpty || title == "NSURLErrorDomain"{
                title = Constants.ErrorAlertTitle
            }
            if message.isEmpty {
                message = "Server error"
            }
            if title == "sessionError" {
                handler = { (alertAction: UIAlertAction) -> Void in
                    let promiseForLogout = ServiceForData<Session>().deleteAllDataFromStoragePromise()
                    let promiseForDeletingTables = ServiceForData<EventPreview>().deleteTablesAfterLogoutPromise()
                    when(resolved: [promiseForLogout, promiseForDeletingTables]
                    ).always {
                        let operation = RouterOperationBack.backToLogin
                        self.alertController.router.performOperation(operation)
                    }.catch{ error in
                        print(error)
                    }
                }
            } else if title == "authError" {
                handler = { (alertAction: UIAlertAction) -> Void in
                    ServiceAuth().signOutWithGoogle({ result in
                        switch result {
                        case .success:
                            print("google sign out succes")
                        case .failure(let error):
                            print("google sign out error \(error)")
                        }
                    })
                }
            }
            return RouterOperationAlert.showAlert(title: title.capitalizingFirstLetter(), message: message.capitalizingFirstLetter(), style: .alert, cancelButtonTitle: nil, buttonTitles: [Constants.DefaultActionTitle], handler: handler).alertController
        case .showSuccess(let message,let handler): return RouterOperationAlert.showAlert(title: Constants.SuccessAlertTitle, message: message,style: .alert, cancelButtonTitle: nil, buttonTitles: [Constants.DefaultActionTitle], handler: handler).alertController
        case .showConfirmingEditEvent(let eventType, let handler): return RouterOperationAlert.showAlert(title: Constants.ConfirmEditingEventAlertTitle(eventType), message: Constants.ConfirmEditingEventAlertMessage,style: .alert, cancelButtonTitle: Constants.NoActionTitle, buttonTitles: [Constants.YesActionTitle], handler: handler).alertController
        case .showConfirmingLogOut(let handler): return RouterOperationAlert.showAlert(title: Constants.ConfirmLogOutAlertMessage, message: "",style: .alert, cancelButtonTitle: Constants.NoActionTitle, buttonTitles: [Constants.YesActionTitle], handler: handler).alertController
        case .showChoose(let title, let message, let buttonTitles, let cancelButtonTitle, let handler): return RouterOperationAlert.showAlert(title: title, message: message, style: .actionSheet, cancelButtonTitle: cancelButtonTitle, buttonTitles: buttonTitles, handler: handler).alertController
        case .showTryAgain(let handler): return RouterOperationAlert.showAlert(title: Constants.ServerErrorAlertTitle, message: "Please try again",style: .alert, cancelButtonTitle: Constants.CancelActionTitle, buttonTitles: [Constants.TryActionTitle], handler: handler).alertController
        case .showEndTest(let handler): return RouterOperationAlert.showAlert(title: Constants.EndTestAlertTitle, message: Constants.EndTestAlertMessage,style: .alert, cancelButtonTitle: nil, buttonTitles: [Constants.DefaultActionTitle], handler: handler).alertController
        case .showCancelTest(let handler): return RouterOperationAlert.showAlert(title: Constants.CancelTestAlertTitle, message: Constants.CancelTestAlertMessage,style: .alert, cancelButtonTitle: nil, buttonTitles: [Constants.NoActionTitle,Constants.YesActionTitle], handler: handler).alertController
        }
    }
}

extension RouterOperationAlert: RouteOperation {
    func startOperation(_ router: Router) -> BaseViewControllerProtocol? {
        let alertController = self.alertController
        if let presentedVC = router.navigationController?.presentedViewController {
            presentedVC.present(alertController, animated: true, completion: nil)
        } else {
            router.navigationController?.present(alertController, animated: true, completion: nil)
        }
        return nil
    }
}

extension UIAlertController {
    func pressed() {
        
    }
}

typealias AlertHandler = ((UIAlertAction) -> Void)?

extension UIAlertAction {
    fileprivate struct AlertInfo {
        static var alertButtonIndex: Int = 0
    }
    
    var buttonIndex: Int! {
        get{
            return objc_getAssociatedObject(self, &AlertInfo.alertButtonIndex) as! Int
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &AlertInfo.alertButtonIndex, unwrappedValue as NSInteger, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}



