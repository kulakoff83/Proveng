//
//  TestResultViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 16.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class TestResultViewController: BaseViewController {

    @IBOutlet weak var levelTextLabel: UILabel!
    @IBOutlet weak var markTextLabel: UILabel!
    @IBOutlet weak var thanksButton: BaseButton!
    
    var currentTest: Test!
    var testWeight: Int!
    var isStartTest = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTextLabel()
        configureThanksButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func thanksButtonPressed(_ sender: AnyObject) {
        if self.isStartTest {
            let operation = RouterOperationXib.openHomeScreen(userType: .student)
            self.router.performOperation(operation)
        } else {
            let operation = RouterOperationBack.backToHome
            self.router.performOperation(operation)
        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension TestResultViewController {
    
    func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func configureTextLabel() {
        self.markTextLabel.textColor = ColorForElements.additional.color
        if let level = self.currentTest.resultLevel {
            self.levelTextLabel.text = Constants.ResultLevelTestText(level: level.capitalized)
        } else {
            self.levelTextLabel.text = Constants.ResultLevelTestText(level: "Unknown")
        }
        self.markTextLabel.text = Constants.ResultMarkTestText(self.currentTest.mark, weight: self.testWeight)
    }
    
    func configureThanksButton() {
        self.thanksButton.setTitle("Thanks", for: .normal)
    }
}
