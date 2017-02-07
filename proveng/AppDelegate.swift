//
//  AppDelegate.swift
//  proveng
//
//  Created by Виктория Мацкевич on 07.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AlamofireNetworkActivityIndicator
import PromiseKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var kClientID:String = "1037523928422-9lvqhirscssiif3erd56p0psdgv1pkjo.apps.googleusercontent.com"
    var router : Router?
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Configure Fabric
        Fabric.with([Crashlytics.self])
        // Configure Google Auth
        GIDSignIn.sharedInstance().clientID = kClientID
        UIApplication.shared.statusBarStyle = .default
        // Configure NavigationController and Set Router
        let rootNavigationController = self.window?.rootViewController as! UINavigationController
        router = Router(navigationController:rootNavigationController)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for: .default)
        self.setupBaseAppearance()
        // Configure User Defaults
        
        let filterParameters = ["type": [String](),"level": [String]()]
        defaults.register(defaults: ["filterCalendar" : filterParameters, "filterMaterials" : filterParameters,"filterTests" : filterParameters, "defaultFilterCalendar": true, "defaultFilterMaterials": true, "defaultFilterTests": true])
        // Configure Network Activity Indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        getBaseData()
        return true
    }
    
    func setDefaultFiltersState() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "defaultFilterCalendar")
        userDefaults.set(true, forKey: "defaultFilterMaterials")
        userDefaults.set(true, forKey: "defaultFilterTests")
    }
    
    func getBaseData(){
        if defaults.value(forKey: "setBaseData") == nil{
            let locationsPath = Bundle.main.path(forResource: "locations", ofType: "json")
            let departmentsPath = Bundle.main.path(forResource: "departments", ofType: "json")
            let levelsPath = Bundle.main.path(forResource: "levels", ofType: "json")
        
            let locationPromise = ServiceForData<Location>().writeBaseDataToStoragePromise(path: locationsPath)
            let departmentPromise = ServiceForData<Department>().writeBaseDataToStoragePromise(path: departmentsPath)
            let levelsPromise = ServiceForData<GroupLevelPreview>().writeBaseDataToStoragePromise(path: levelsPath)
        
            when(resolved: [locationPromise.asVoid(), departmentPromise.asVoid(), levelsPromise.asVoid()]).then { _ -> Void in
                self.defaults.setValue(true, forKey: "setBaseData")
            }.catch { error in
                  print(error)
            }
        }
    }
    
    func setupBaseAppearance() {
        let locale = NSTimeZone.init(abbreviation: "UTC")
        NSTimeZone.default = locale as! TimeZone
        self.window?.tintColor = ColorForElements.main.color
        UIApplication.shared.statusBarStyle = .lightContent
        UILabel.appearance().textColor = ColorForElements.text.color
        UINavigationBar.appearance().barTintColor = ColorForElements.main.color
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: Constants.regularFont]
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.setDefaultFiltersState()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

