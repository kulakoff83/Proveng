//
//  LoginViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 08.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class LoginViewController: BaseViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var loginButton: BaseButton!
    @IBOutlet weak var rulesLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rulesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: GIDSignInButton!
    lazy var serviceAuth = ServiceAuth()
    lazy var serviceRequest = ServiceForRequest<User>()
    let googleSignIn = GIDSignIn.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleSignIn?.uiDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.rulesLabel.font = nil
        UIApplication.shared.statusBarStyle = .default
        print("Contr: \(self.navigationController?.viewControllers)")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.rulesLabel.font = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.view.frame.height < 550 {
            self.rulesLabelTopConstraint.constant = 10
        } else {
            self.rulesLabelTopConstraint.constant = self.view.frame.height / 9.30
        }
        self.configureRulesLabel()
    }
    
    func requestUser(session: Session, completion: @escaping () -> Void) {
        let getLocationPromise = ServiceForRequest<Location>().getObjectsPromise(ApiMethod.getLocations).asVoid()
        let getDepartmentPromise = ServiceForRequest<Department>().getObjectsPromise(ApiMethod.getDepartments).asVoid()
        let getLevelsPromise = ServiceForRequest<GroupLevelPreview>().getObjectsPromise(ApiMethod.getLevels).asVoid()
        let apiMethod = ApiMethod.getUserProfile(userID: session.userID)
        when(resolved: [getLocationPromise, getDepartmentPromise, getLevelsPromise]).then { _ -> Promise<User> in
            return self.serviceRequest.getObjectPromise(apiMethod)
        }.then{ [weak self] user -> Void in
            let realm = try Realm()
            let currentSession = Session()
            currentSession.objectID = 1
            currentSession.token = session.token
            currentSession.userID = session.userID
            currentSession.currentUser = user
            try realm.write{
                realm.add(currentSession, update: true)
            }
            self?.checkUserType(type: user.userIsTeacher(), user: user)
        }.always { [weak self] in
            self?.hideLoadingView()
            completion()
        }.catch { [weak self] error in
            let operation = RouterOperationAlert.showError(title: error.apiError.domain, message: error.apiError.errorDescription, handler: nil)
            _ = self?.router.performOperation(operation)
        }
    }
    
    func configureRulesLabel() {
        self.rulesLabel.font = nil
        let text = "By signing in, you agree to Proveng Terms of Service and Privacy Policy"
        self.rulesLabel.text = text
        let underlineAttriString = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: ColorForElements.terms.color,NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightRegular)])
        let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSForegroundColorAttributeName: ColorForElements.text.color] as [String : Any]
        let range1 = (text as NSString).range(of: "Terms of Service")
        underlineAttriString.addAttributes(attributes, range: range1)
        let range2 = (text as NSString).range(of: "Privacy Policy")
        underlineAttriString.addAttributes(attributes, range: range2)
        self.rulesLabel.attributedText = underlineAttriString
        let tap = UITapGestureRecognizer(target: self, action: #selector(rulesLabelTapped(gesture:)))
        self.rulesLabel.addGestureRecognizer(tap)
        self.rulesLabel.isUserInteractionEnabled = true
    }
    
    //MARK: - Actions
    @IBAction func loginUserButtonPressed(_ sender: AnyObject) {
        if !chekInternetConnection() {
            return
        }
        self.loginButton.isEnabled = false
        //self.showLoadingView()
        self.showLoadingView()
        self.serviceAuth.signInWithGoogle({ [weak self] result in
            switch result {
            case .success(let value):
                if let session: Session = value as? Session, let token = session.token {
                    SessionData.token = token
                    SessionData.id = session.userID
                    self?.requestUser(session: session, completion: {
                        self?.loginButton.isEnabled = true
                    })
                } else {
                    self?.hideLoadingView()
                    print("ERROR - Value as not Session")
                }
            case .failure(let error):
                let apiError = error.apiError
                print("error \(error)")
                if apiError.code != -5 {
                    self?.handleError(error: error)
                }
                self?.loginButton.isEnabled = true
                self?.hideLoadingView()
            }
        })
    }
    
    func rulesLabelTapped(gesture: UITapGestureRecognizer) {
        if let text = rulesLabel.text {
            let termsRange = (text as NSString).range(of: "Terms of Service")
            let privacyRange = (text as NSString).range(of: "Privacy Policy")
            if gesture.didTapAttributedTextInLabel(label: rulesLabel, inRange: termsRange) {
                presentTextScreen(title: "Terms of Service", text: Constants.TermsText)
            } else if gesture.didTapAttributedTextInLabel(label: rulesLabel, inRange: privacyRange) {
                presentTextScreen(title: "Privacy Policy", text: Constants.PrivacyText)
            }
        }
    }
    
    func presentTextScreen(title: String, text: String) {
        self.setTranslucentNavigationBar()
        let operation = RouterOperationXib.openTextInfo(title: title, text: text)
        self.router.performOperation(operation)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let attributedText = label.attributedText!//must NOT Unwrapp
        let textStorage = NSTextStorage(attributedString: attributedText)
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
