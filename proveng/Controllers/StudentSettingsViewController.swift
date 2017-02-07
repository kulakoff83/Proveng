//
//  StudentSettingsViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import MessageUI

class StudentSettingsViewController: BaseFormViewController, MFMailComposeViewControllerDelegate {
    
    let aboutTitle = NSLocalizedString("About", comment: "")
    let supportTitle = NSLocalizedString("Support", comment: "")
    let termsTitle = NSLocalizedString("Terms of Service", comment: "")
    let privacyTitle = NSLocalizedString("Privacy Policy", comment: "")
    let logOutTitle = NSLocalizedString("Log out", comment: "")
    let versionTitle = NSLocalizedString("VERSION: \(Constants.VersionValue())", comment: "")
    lazy var serviceAuth = ServiceAuth()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSettingsForm()
        configureNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !SessionData.teacher {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !SessionData.teacher {
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    deinit {
        print("Deinit Settings")
    }
    
    func configureSettingsForm() {
        _ = self.addSection(footerTitle: versionTitle)
        
        self.addButtonPushRow(title: aboutTitle, icon: IconForElements.about.icon).onCellSelection { [weak self] (cell, row) in
            self?.openTextViewController(row.title!, text: Constants.AboutAppText)
        }
        
        self.addButtonPushRow(title: supportTitle, icon: IconForElements.support.icon).onCellSelection { [weak self] (cell, row) in
            self?.sendMail()
        }
        
        self.addButtonPushRow(title: termsTitle, icon: IconForElements.terms.icon).onCellSelection { [weak self] (cell, row) in
            self?.openTextViewController(row.title!, text: Constants.TermsText)
        }
        
        self.addButtonPushRow(title: privacyTitle, icon: IconForElements.privacy.icon).onCellSelection { [weak self] (cell, row) in
            self?.openTextViewController(row.title!, text: Constants.PrivacyText)
        }
        
        _ = self.addSection()
        
        self.addButtonPushRow(title: logOutTitle, icon: IconForElements.logout.icon, accessoryType: UITableViewCellAccessoryType.none).cellUpdate { (cell, row) in
            cell.textLabel?.textColor = ColorForElements.additional.color
            cell.imageView?.tintColor = ColorForElements.additional.color
        }.onCellSelection { [weak self] (cell, row) in
            self?.showConfirmAlert()
        }
    }

    func openTextViewController(_ title: String, text: String) {
        let operation = RouterOperationXib.openTextInfo(title: title, text: text)
        self.router.performOperation(operation)
    }
    
    func showConfirmAlert() {
        let operation = RouterOperationAlert.showConfirmingLogOut { [weak self] alertAction in
            self?.logOutRowSelected()
        }
        self.router.performOperation(operation)
    }
    
    // MARK: - Mail
    
    func sendMail(){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: { () -> Void in
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            })
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Constants.SupportMail])
        mailComposerVC.setSubject("PROVENG IOS App")
        mailComposerVC.setMessageBody("Hi,\n\n\nProveng: \(Constants.VersionValue())\nDevice: \(self.platform())\niOS: \(UIDevice.current.systemVersion)\n", isHTML: false)
        
        return mailComposerVC
    }
    
    func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)! as String
    }
    
    func showSendMailErrorAlert() {
        let error = ApiError(errorDescription: "Make sure that the mail settings are correct and try again")
        self.handleError(error: error)
    }
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }

    // MARK: Actions
    
    func logOutRowSelected() {
        self.tableView?.isUserInteractionEnabled = false
        ApiLayer.SharedApiLayer.cancelAll()
        self.showLoadingView()
        self.serviceAuth.signOutWithGoogle({ [weak self] result in
            self?.hideLoadingView()
            switch result {
            case .success:
                print("google sign out succes")
            case .failure(let error):
                print("google sign out errpr \(error)")
            }
            self?.backToLogin()
            self?.tableView?.isUserInteractionEnabled = true
        })
    }
    
    func backToLogin() {
        SessionData.token = ""
        SessionData.id = 0
        SessionData.teacher = false
        let operation = RouterOperationBack.backToLogin
        _ = self.router.performOperation(operation)
    }
}

extension StudentSettingsViewController {
    
    func configureNavigationBar() {
        if !SessionData.teacher {
            self.createBaseNavigationBar()
        }
    }
}
