//
//  PromoViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 18.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

class PromoViewController: BaseViewController {
    
    var pageControl = UIPageControl()
    @IBOutlet var startButton: UIButton!
    private var pageViewController : UIPageViewController!
    var timer = Timer()
    let data = [["photo" : "promoGlobe", "text": "Discover how to learn English easier with PROVENG.\nCheck your level online."],
                ["photo" : "promoEvent", "text": "Keep in touch with the new English events in our company with PROVENG!"],
                ["photo" : "promoCalendar", "text": "Your timetable is always at hand with PROVENG Calendar."]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageControl()
        self.startButton.backgroundColor = ColorForElements.background.color
        self.startButton.setTitleColor(ColorForElements.text.color, for: UIControlState.normal)
        self.createPageViewController()
        self.startTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewPhotoCommentController(_ index: Int) -> PhotoCommentViewController? {
        if let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "PhotoCommentViewController") as? PhotoCommentViewController {
            if index < data.count {
                let pageData: [String: String] = data[index]
                page.photoName = pageData["photo"]
                page.photoIndex = 4
                page.text = pageData["text"]
                return page
            } else {
                return nil
            }
        }
        return nil
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.black
        appearance.backgroundColor = UIColor.clear
        appearance.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    }
    
    private func createPageViewController() {
        let screenSize: CGRect = UIScreen.main.bounds
        if let pageController = self.storyboard!.instantiateViewController(withIdentifier: "PromoPageViewController") as? UIPageViewController {
            pageController.dataSource = self
            if let viewController = viewPhotoCommentController(0) {
                let viewControllers = [viewController]
                pageController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            }
            pageController.view.frame = CGRect(x: 0, y: screenSize.height * 0.07, width: self.view.frame.size.width, height: self.view.frame.size.height - 45 - screenSize.height * 0.07)
            self.pageViewController = pageController
            addChildViewController(pageViewController!)
            self.view.insertSubview(pageViewController!.view, at: 0)
            self.pageViewController!.didMove(toParentViewController: self)
            let subviews: Array = self.pageViewController.view.subviews
            for i in 0 ..< subviews.count {
                if let controlSubview = subviews[i] as? UIPageControl {
                    self.pageControl = controlSubview
                    break
                }
            }
        }
    }
    
    @IBAction func startNowButtonPressed(_ sender: UIButton) {
        let operation = RouterOperationXib.openLogin
        self.router.performOperation(operation)
    }
    
    func moveToNextPage () {
        let index = pageControl.currentPage
        let nextIndex = (index + 1) % self.data.count
        if let nextViewController = self.viewPhotoCommentController(nextIndex) {
            pageViewController?.setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
            pageControl.currentPage = nextIndex
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    func resetTimer(){
        timer.invalidate()
        startTimer()
    }
}

//MARK: implementation of UIPageViewControllerDataSource
extension PromoViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.resetTimer()
        let i = pageControl.currentPage
        let prevIndex = (i - 1) < 0 ? self.data.count - 1 : (i - 1)
        return viewPhotoCommentController(prevIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.resetTimer()
        let i = pageControl.currentPage
        let nextIndex = (i + 1) % self.data.count
        return viewPhotoCommentController(nextIndex)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.data.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
