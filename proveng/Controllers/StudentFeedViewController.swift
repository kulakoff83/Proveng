//
//  StudentFeedViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import RealmSwift
import ObjectMapper

class StudentFeedViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let feedCellIdentifier = "FeedCell"
    @IBOutlet weak var infoLabel: UILabel!    
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    private var notificationToken: NotificationToken? = nil
    var events: Results<FeedEvent>!
    var refreshControl: UIRefreshControl!
    weak var timer : Timer?
    let timeRequestMinInterval = 10.0 * 60.0 // 10 min
    var feedActiveMethod: ApiMethod?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("User ID: \(SessionData.id)")
        setEvents()
        configureNavigationBar()
        configureElements()
        configurePullToRefresh()
        requestEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        startTimer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: timeRequestMinInterval, target: self, selector: #selector(requestEvents), userInfo: nil, repeats: true)
    }
    
    func chekEvents() {
        if let events = self.events {
            if events.count < 1 {
                self.tableView.backgroundColor = UIColor.clear
            } else {
                self.tableView.backgroundColor = ColorForElements.background.color
            }
        }
    }
    
    func requestEvents() {
        ApiLayer.SharedApiLayer.cancel(self.feedActiveMethod)
        let feedMethod = ApiMethod.getFeed(userID: SessionData.id)
        self.feedActiveMethod = feedMethod
        firstly { 
            ServiceForRequest<FeedEvent>().getObjectsPromise(feedMethod)
        }.then { feedEvents -> Promise<[FeedEvent]> in
            return ServiceForData<UserPreview>().getPreparedFeedEvents(feedEvents: feedEvents)
        }.always { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
            UIView.animate(withDuration: 0.3, animations: {
                self?.tableView.contentOffset = CGPoint.zero//FIXME: problem in ios 10 need this crutch
            })
            self?.chekEvents()
        }.catch { [weak self] error in
            guard error.apiError.code != 404 else {
                return
            }
            self?.handleError(error: error)
        }
    }
    
    func setEvents() {
        firstly {
            ServiceForData<FeedEvent>().getDataArrayFromStoragePromise()
        }.then { [weak self] events -> Void in
            self?.events = events
            self?.configureTableView()
            self?.configureRealmNotification()
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {        
        // Observe Results Notifications
        self.notificationToken = events.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial, .update:
                // Results are now populated and can be accessed without blocking the UI
                print("0000000000000000000")
                tableView.reloadData()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    // MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.feedCellIdentifier) as! FeedTableViewCell
        cell.configureCell(with: self.events[indexPath.row])
        
        let buttonHandler = { [weak self] (event: Event, accepted: Bool) -> Void in
            let apiMethod = accepted ? ApiMethod.acceptEvent(eventID: event.objectID) : ApiMethod.cancelEvent(eventID: event.objectID)
            ServiceForRequest<EventPreview>().getObjectPromise(apiMethod).then { eventB -> Void in
                accepted ? cell.setAcceptState() : cell.setDeniedState()
                cell.hideButtons()
                BaseModel.realmWrite({
                    if event.eventsB.count > 0 {
                        event.eventsB[0] = eventB
                    } else {
                        event.eventsB.append(eventB)
                    }
                })
                tableView.beginUpdates()
                tableView.endUpdates()
            }.catch { [weak self] error in
                self?.handleError(error: error)
            }
        }
        cell.buttonPressedHandler = buttonHandler
        
        return cell
    }
    
    // MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! FeedTableViewCell
        if cell.isSelectable {
            let event = self.events[indexPath.row]
            if event.typeEnum == .test {
                if let title = event.eventName, let testID = event.testItem?.objectID {
                    self.presentTestPreviewVC(testID: testID, title: title)
                }
            } else if event.typeEnum == .material {
                if let materialID = event.materialItem?.objectID {
                    self.presentMaterialVC(materialID: materialID)
                }
            } else {
                let operation = RouterOperationXib.openLessonWorkshop(eventID: event.objectID, teacher: false)
                let eventVC = self.router.performOperation(operation) as? LessonWorkshopDetailsViewController
                eventVC?.isFeed = true
            }
        }
    }
    
    func presentTestPreviewVC(testID: Int, title: String) {
        let operation = RouterOperationXib.openTestPreview(testID: testID)
        let testPreviewVC = self.router.performOperation(operation)as? TestPreviewViewController
        testPreviewVC?.isStartTest = false
    }
    
    func presentMaterialVC(materialID: Int) {
        let operation = RouterOperationXib.openMaterialsScreen(materialID: materialID)
        _ = self.router.performOperation(operation)
    }
    
    // MARK: Actions
    
    func calendarButtonPressed() {
        let operation = RouterOperationXib.openCalendar
        self.router.performOperation(operation)
    }

}
extension StudentFeedViewController {
    
    func configureElements() {
        self.infoLabel.text = Constants.EmptyFeedTitle
        self.infoTextLabel.text = Constants.EmptyFeedText
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = UIView(frame : CGRect(x: 0, y: 0, width: 0,height: 20))
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView?.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: self.feedCellIdentifier)
        self.tableView.backgroundColor = ColorForElements.background.color
    }
    
    func configurePullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestEvents), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = self.refreshControl
            self.refreshControl.layoutIfNeeded()
        } else {
            tableView.insertSubview(refreshControl, at: 0)
        }
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.barStyle = .black
        self.createBaseNavigationBar()
        let calendarButton = UIBarButtonItem(image: IconForElements.calendar.icon,style: .plain,target: self, action: #selector(calendarButtonPressed))
        self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = calendarButton
    }
}
