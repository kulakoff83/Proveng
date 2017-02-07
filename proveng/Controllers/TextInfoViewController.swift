//
//  TextInfoViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class TextInfoViewController: BaseViewController {

    @IBOutlet weak var textView: BaseTextView!
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.text = self.text
        self.view.backgroundColor = .white
        self.textView.textAlignment = .left
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.setTranslucentNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setDefaultNavigationBar()
    }
    
    deinit {
        print("Text deinit")
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.setDefaultNavigationBar()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
}
