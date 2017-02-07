//
//  ViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 07.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit

class SplashViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkSession()
    }
    
    func checkSession() {
        firstly {
            ServiceForData<Session>().getDataArrayFromStoragePromise()
        }.then { sessions -> Void in
            if let firstSession = sessions.first, let token = firstSession.token, let user = firstSession.currentUser {
                SessionData.token = token
                SessionData.id = firstSession.userID
                let typeTeacher = user.userIsTeacher()
                self.checkUserType(type: typeTeacher, user: user)
            } else {
                self.presentPromoVC()
            }
        }.catch { error in
            self.presentPromoVC()
        }
    }
}
