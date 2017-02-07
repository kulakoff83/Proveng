//
//  TestPreviewViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 15.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class TestPreviewViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startTestButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    var currentTest : Test?
    var testID: Int!
    var isStartTest = true
    var isFirstLounch = true
    var testActiveMethod: ApiMethod?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTest()
        configureNavigationBar()
        configureNextButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            let navigationBarHeight: CGFloat = 64
            let buttonViewHeight: CGFloat = 73
            self.imageViewHeight.constant = self.view.frame.size.height - navigationBarHeight - self.textView.frame.height - buttonViewHeight
            isFirstLounch = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(isStartTest, animated: false)
        if !isStartTest {
            self.setTranslucentNavBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ApiLayer.SharedApiLayer.cancel(self.testActiveMethod)
        if !isStartTest {
            self.setDefaultNavigationBar()
        }
    }
    
    deinit {
        
    }
    
    func requestTest() {
        self.imageView.image = isStartTest ? UIImage(named:"start_test") : UIImage(named:"other_test")
        self.imageView.isHidden = true
        self.startTestButton.isHidden = true
        let testMethod = ApiMethod.getTest(id: testID)
        self.testActiveMethod = testMethod
        firstly{
            ServiceForRequest<Test>().getObjectPromise(testMethod)
        }.then { [weak self] test -> Void in
            self?.currentTest = test
            self?.configureTextLabel()
            self?.imageView.isHidden = false
            self?.startTestButton.isHidden = false
        }.catch { [weak self] error in
            let operation = RouterOperationAlert.showError(title: error.apiError.domain, message: error.apiError.errorDescription, handler: { alertAction in
                self?.backToNeeded()
            })
            _ = self?.router.performOperation(operation)
        }
    }
    
    func backToNeeded() {
        if self.isStartTest {
            self.backToLogin()
        } else {
            let operation = RouterOperationBack.backToHome
            _ = self.router.performOperation(operation)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startTestButtonPressed(_ sender: AnyObject) {
        guard let test = self.currentTest else {
            return
        }
        TestCard.realmWrite {
            for card in test.cards {
                card.answer = nil
            }
            let operation = RouterOperationXib.openTest(test: test)
            let startTestVC = self.router.performOperation(operation) as? TestViewController
            startTestVC?.isStartTest = self.isStartTest
        }

    }
}

extension TestPreviewViewController {
    
    func configureNavigationBar() {
        if isStartTest {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.setTranslucentNavBar()
        }
    }
    
    func setTranslucentNavBar() {
        self.setTranslucentNavigationBar()
        self.navigationController?.navigationBar.tintColor = ColorForElements.main.color
    }
    
    func configureNextButton() {
        self.startTestButton.setTitle("Start Test", for: .normal)
    }
    
    func configureTextLabel() {
        guard let test = self.currentTest else {
            self.backToNeeded()
            return
        }
        let duration = test.duration.minutes()
        let count = test.cards.count
        var title = ""
        if let name = test.name {
            title = name
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let testPreviewDescription = NSMutableAttributedString(string: isStartTest ? Constants.PreviewTestDescription : "\(title)\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle])
        let testPreviewTitle = NSMutableAttributedString(string: Constants.PreviewTestTitle, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),NSParagraphStyleAttributeName: NSParagraphStyle.default])
        
        let testPreviewText1 = Constants.PreviewTestText1(count).testPreviewAtrString()
        let testPreviewText2 = Constants.PreviewTestText2(duration).testPreviewAtrString()
        let testPreviewText3 = isStartTest ? Constants.PreviewTestText3.testPreviewAtrString() : Constants.PreviewRegularTestText3.testPreviewAtrString()
        
        testPreviewDescription.append(testPreviewTitle)
        testPreviewDescription.append(testPreviewText1)
        testPreviewDescription.append(testPreviewText2)
        testPreviewDescription.append(testPreviewText3)

        self.textView.attributedText = testPreviewDescription
        self.textView.sizeToFit()
    }
}

extension NSMutableAttributedString {
    func setColorForStr(textToFind: String, color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options:NSString.CompareOptions.caseInsensitive);
        if range.location != NSNotFound {
            self.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight), NSForegroundColorAttributeName: color], range: range)
        }
    }
}

extension String {
    func testPreviewAtrString() -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        let offset: CGFloat = 20
        paragraphStyle.tabStops = [NSTextTab(textAlignment:.left, location: offset,options:[:])]
        paragraphStyle.defaultTabInterval = offset
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = offset
        let testPreviewText = NSMutableAttributedString(string: self, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle])
        testPreviewText.setColorForStr(textToFind: "●", color: ColorForElements.additional.color)
        return testPreviewText
    }
}
