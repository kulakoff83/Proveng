//
//  TestViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class TestViewController: BaseViewController, UIPageViewControllerDataSource, TestQuestionsViewControllerDelegate {
    
    @IBOutlet weak var nextButton: BaseButton!
    @IBOutlet weak var numberOfQuestionsLabel: UILabel!
    @IBOutlet weak var numberOfQuestionView: UIView!
    
    @IBOutlet weak var nextButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    var pageController = UIPageViewController(transitionStyle: .scroll,navigationOrientation: .horizontal, options: nil)
    var currentIndex = 0
    var countOfPages = 0
    weak var timer : Timer?
    var testTime : NSNumber?
    var testStartDate: Date?
    var currentTest : Test!
    var isStartTest = true
    var isFirstLounch = true
    var testActiveMethod: ApiMethod?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.countOfPages = self.currentTest.cards.count
        configureNavigationBar()
        testStartDate = Date()
        if self.currentTest.duration.minutes() > 0 {
            configureTimer()
            startTimer()
        }
        self.setFontAndColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLounch {
            configurePageViewController()
            isFirstLounch = false
        }
    }
    
    deinit {
        
    }
    
    // MARK: - PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.getTestIndex(viewController: viewController)
        if index == 0 {
            return nil
        }
        index = index - 1
        return self.testQuestionsViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.getTestIndex(viewController: viewController)
        index = index + 1
        if index == self.countOfPages {
            return nil
        }
        return self.testQuestionsViewControllerAtIndex(index)
    }
    
    func getTestIndex(viewController: UIViewController) -> Int {
        let testQuestionVC = viewController as? TestQuestionsViewController
        if let index = testQuestionVC?.index {
            return index
        }
        return 0
    }
    
    // MARK: - TestQuestionsViewControllerDelegate
    
    func viewControllerDidPresented(_ index: Int) {
        self.currentIndex = index
        updateNumberOfQuestiosLabel()
        if index == self.countOfPages - 1 {
            self.nextButton.setTitle("Submit", for: .normal)
            self.nextButton.removeTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
            self.nextButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        } else {
            self.nextButton.setTitle("Next", for: .normal)
            self.nextButton.removeTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
            self.nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        }
    }
    
    func layoutIsLoaded(offset: CGFloat) {
        self.nextButtonTopConstraint.constant = offset
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TestViewController.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    func updateTimerLabel() {
        guard let time = testTime else {
            return
        }
        if time.int32Value != 0 {
            testTime = Int(time) - 1 as NSNumber
            if testTime?.int32Value == 0 {
                showEndTestAlert { _ in
                    self.submitButtonPressed()
                }
                timer?.invalidate()
                timer = nil
            }
        }
        configureTimeLabel()
    }
    
    func configureTimeLabel() {
        guard let time = testTime else {
            return
        }
        let (m,s) = Date.secondsToHoursMinutesSeconds(Int(time))
        self.title = "\(m):\(String(format:"%02d", s))"
    }
    
    // MARK: - Actions
    
    func nextButtonPressed() {
        self.currentIndex += 1
        if self.currentIndex < self.countOfPages {
            let testQuestionViewControllers = [self.testQuestionsViewControllerAtIndex(self.currentIndex)]
            pageController.setViewControllers(testQuestionViewControllers, direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    func submitButtonPressed() {
        var duration: Double = 0
        if let startDate = self.testStartDate {
            duration = Date().msecondsFrom(startDate)
        }
        self.nextButton.isEnabled = false
        let testMethod = ApiMethod.resultTest(test: self.currentTest, duration: duration)
        self.testActiveMethod = testMethod
        //self.showLoadingView()
        firstly {
            ServiceForRequest<Test>().getObjectPromise(testMethod)
        }.then { [weak self] testResult -> Void in
            self?.presentTestResultScreenVC(test: testResult,weight: self!.currentTest.weight)
        }.always { [weak self] in
            //self?.hideLoadingView()
            self?.timer?.invalidate()
            self?.nextButton.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }

    func cancelButtonPressed() {
        ApiLayer.SharedApiLayer.cancel(self.testActiveMethod)
        let operation = RouterOperationAlert.showCancelTest { [weak self] action in
            switch action.buttonIndex {
            case 1:
                self?.startTimer()
            case 2:
                self?.timer?.invalidate()
                self?.timer = nil
                self!.backToTestPreviewVC(testID: self!.currentTest.objectID, isStartTest: self!.isStartTest)
            default:
                break
            }
        }
        self.router.performOperation(operation)
        self.timer?.invalidate()
    }
    
    func presentHomeScreenVC(_ teacher: Bool) {
        let operation = RouterOperationXib.openHomeScreen(userType: teacher ? .teacher : .student)
        self.router.performOperation(operation)
    }
    
    func presentTestResultScreenVC(test: Test, weight: Int) {
        let operation = RouterOperationXib.openTestResult(test: test, weight: weight)
        let testResultVC = self.router.performOperation(operation) as? TestResultViewController
        testResultVC?.isStartTest = self.isStartTest
    }
    
    func showEndTestAlert(_ handler: @escaping (UIAlertAction) -> ()) {
        let operation = RouterOperationAlert.showEndTest(handler: handler)
        self.router.performOperation(operation)
    }

}
extension TestViewController {
    
    func configureNavigationBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func configureTimer() {
        let time = self.currentTest.duration.minutes() * 60
        self.testTime = time as NSNumber
        configureTimeLabel()
    }
    
    func configurePageViewController() {
        pageController.dataSource = self
        let topOffset: CGFloat = 45
        let botomOffset = self.nextButtonBottomConstraint.constant + self.nextButtonHeightConstraint.constant
        pageController.view.frame = CGRect(x: 0, y: topOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height - botomOffset)
        let testQuestionViewControllers = [self.testQuestionsViewControllerAtIndex(self.currentIndex)]
        self.pageController.setViewControllers(testQuestionViewControllers, direction: .forward, animated: false, completion: nil)
        updateNumberOfQuestiosLabel()
        addChildViewController(self.pageController)
        self.view.insertSubview(self.pageController.view, at: 0)
        self.pageController.didMove(toParentViewController: self)
    }
    
    func testQuestionsViewControllerAtIndex(_ index: Int) -> TestQuestionsViewController {
        let testQuestionVC = TestQuestionsViewController(nibName: "TestQuestionsViewController", bundle: nil)
        testQuestionVC.index = index
        testQuestionVC.testCard = self.currentTest.cards[index]
        testQuestionVC.delegate = self
        return testQuestionVC
    }
    
    func updateNumberOfQuestiosLabel() {
        self.numberOfQuestionsLabel.text = "\(self.currentIndex+1) of \(self.countOfPages)"
    }
    
    func setFontAndColor() {
        self.numberOfQuestionsLabel.font = UIFont(name:".SFUIDisplay-Regular", size: 16.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)]
        self.numberOfQuestionView.layer.shadowColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 0.75).cgColor
        self.numberOfQuestionView.layer.masksToBounds = false
        self.numberOfQuestionView.layer.shadowOpacity = 0.75
        self.numberOfQuestionView.layer.shadowRadius = 2
        self.numberOfQuestionView.layer.shadowOffset = CGSize(width: 0.25, height: 0.45)
    }
}
