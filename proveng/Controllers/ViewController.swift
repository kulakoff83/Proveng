//
//  ViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 07.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let apiLayer = ApiLayer(urlScheme: "http", urlHost: "api.openweathermap.org")
//        let weatherData = ApiMethod.GetUserData(q: "Odessa", APPID: "84021df1516d4be5c5e5a5827ea2c198", units: "metric")
//        apiLayer.sendRequest(weatherData){ result in
//            switch result {
//            case .Success:
//                let jsonData = result.value!
//                 print(jsonData["name"].stringValue)
//            case .Failure(let error):
//                print(error)
//            }
//        }
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }  
}

extension ViewController: GIDSignInUIDelegate {

}

extension ViewController: GIDSignInDelegate {
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if (error == nil) {           
            let name = user.profile.name
            let email = user.profile.email
            let idToken = user.authentication.idToken
            
            print(idToken)
            print(email)
            print(name)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("ToggleAuthUINotification",object: nil,userInfo: ["statusText": "User has disconnected."])
    }
    
    @IBAction func didTapSignOut(sender: AnyObject) {        
        GIDSignIn.sharedInstance().signOut()
    }
}

