//
//  FeedViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 15.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka
import FSCalendar
import PromiseKit
import RealmSwift

class TeacherCalendarViewController: BaseFormViewController, FilterLessonWorkshopViewControllerDelegate, UITabBarControllerDelegate {
    
    var calendar = FSCalendar()
    var date = Date()
    var events: Results<Event>!
    var eventsForCalendar: Results<Event>!
    fileprivate var notificationToken: NotificationToken? = nil
    var isFilterResetNeeded = true
    let dataPromise = ServiceForData<Event>().getDataArrayFromStoragePromise()
    var eventActiveMethod: ApiMethod?
    var monthDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TOKEN - \(SessionData.token)")
        setEvents()
        configureNavigationBar()
        tableView?.clipsToBounds = false
        configurePullToRefresh()
        requestEventsBy(date: monthDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SessionData.teacher {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func requestObjects() {
         requestEventsBy(date: monthDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFilterResetNeeded = true
        self.tabBarController?.delegate = self
        if SessionData.teacher {
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.cancelActiveMethod()
    }
    
    deinit {
        notificationToken?.stop()
        print("Deinit Calendar")

    }
    
    func cancelActiveMethod() {
        ApiLayer.SharedApiLayer.cancel(self.eventActiveMethod)
    }
    
    func requestEventsBy(date: Date) {
        self.cancelActiveMethod()
        let eventMethod = ApiMethod.getCalendar(userID: SessionData.id, date: date.msecondsFrom(Date(timeIntervalSince1970: 0)))
        self.eventActiveMethod = eventMethod
        firstly {
            ServiceForRequest<Event>().getObjectsPromise(eventMethod)
        }.always{ [weak self] in
            self?.refreshControl.endRefreshing()
        }.catch { [weak self] error in
            guard error.apiError.code != 404 else {
                return
            }
            self?.handleError(error: error)
        }
    }
    
    func filterObjects(filterParameters: [String: [String]]) {
        firstly {
            ServiceForData<Event>().getDataArrayFromStoragePromise()
            }.then { [weak self] events -> Void in
                self?.events = events
                if let typeParameters = filterParameters["type"], let levelParameters = filterParameters["level"] {
                    let typePredicate = NSPredicate(format: "type IN %@", typeParameters as CVarArg)
                    let levelPredicate = NSPredicate(format: "group.groupLevel IN %@", levelParameters as CVarArg)
                    self?.events = events.filter(typePredicate).filter(levelPredicate)
                    self?.updateCalendarForm()
                }
            }.catch { error in
                print(error)
        }
    }
    
    func resetFilterEvents() {
        firstly { [weak self] in
            self!.dataPromise
            }.then { [weak self] events -> Void in
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "defaultFilterCalendar")
                self?.events = events
                self?.updateCalendarForm()
            }.catch { error in
                print(error)
        }
    }
    
    func setEvents() {
        firstly { [weak self] in
            self!.dataPromise
            }.then { [weak self] events -> Void in
                self?.events = events
                if let mdate = self?.date.dateByDefaultTime(0, minute: 0, seconds: 0) {
                    let predicate = NSPredicate(format: "dayStart = %@", mdate as CVarArg)
                    self?.eventsForCalendar = events.filter(predicate).sorted(byProperty: "dateStart")
                    self?.configureCalendarForm()
                    self?.configureRealmNotification()
                }
            }.catch { [weak self] error in
                self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {
        // Observe Results Notifications
        self.notificationToken = events.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial,.update:
                // Results are now populated and can be accessed without blocking the UI
                self?.updateCalendarForm()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func configureCalendarForm(){
        tableView?.estimatedRowHeight = 125
        self.tableView?.backgroundColor = UIColor.white
        form +++ Section(){ [weak self] section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback {
                    self!.configureCalendarView()
                    })
                header.height = { 250 }
                return header
            }()
        }
        _ = self.addSection(tag: "Events")
        addEventSection()
    }
    
    func addEventSection(){
        print("addEventSection\(self.eventsForCalendar.count)")
        for event in self.eventsForCalendar {
            guard let eventIndex = self.eventsForCalendar.index(of: event) else {
                return
            }
            let eventID = self.eventsForCalendar[eventIndex].objectID
            if self.form.rowBy(tag: "Event\(eventID)") == nil {
                self.addCalendarRow(value: event, tag: "Event\(eventID)").cellUpdate{ (cell, row) in
                    if !event.isInvalidated {
                        cell.configureCell(event)
                    } else {
                        ServiceForData<Event>().getObjectByID(id: eventID, handler: { dataEvent in
                            cell.configureCell(dataEvent)
                        })
                    }
                    }.onCellSelection{ [weak self] (cell, row) in
                        ServiceForData<Event>().getObjectByID(id: eventID, handler: { event in
                            let operation = RouterOperationXib.openLessonWorkshop(eventID: event.objectID, teacher: SessionData.teacher)
                            _ = self?.router.performOperation(operation)
                            cell.setSelected(false, animated: false)
                            self?.tableView?.reloadData()
                        })
                }
            }
        }
    }
    
    func configureCalendarView() -> UIView {
        let screen = UIScreen.main.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 250))
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width:screen.width, height: 250))
        calendar.locale = Locale(identifier: "en_US")
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.firstWeekday = 2
        calendar.backgroundColor = UIColor.white
        calendar.clipsToBounds = true
        calendar.appearance.headerMinimumDissolvedAlpha = 0        
        let previosButton = UIButton(type: .system)
        previosButton.frame = CGRect(x:0,y: 0,width:30,height:40)
        previosButton.backgroundColor = UIColor.white
        previosButton.contentEdgeInsets = UIEdgeInsetsMake(12, 7, 12, 7)
        previosButton.setImage(UIImage(named: "previos"), for: .normal)
        previosButton.tintColor = ColorForElements.text.color
        previosButton.addTarget(self, action: #selector(self.previosMonthButtonPressed), for: .touchUpInside)
        let nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x:screen.width - 30,y: 0,width:30,height:40)
        nextButton.backgroundColor = UIColor.white
        nextButton.contentEdgeInsets = UIEdgeInsetsMake(12, 7, 12, 7)
        nextButton.setImage(UIImage(named: "next"), for: .normal)
        nextButton.tintColor = ColorForElements.text.color
        nextButton.addTarget(self, action: #selector(self.nextMonthButtonPressed), for: .touchUpInside)
        calendar.appearance.eventDefaultColor = ColorForElements.main.color
        calendar.appearance.eventSelectionColor = ColorForElements.additional.color
        calendar.appearance.weekdayTextColor = ColorForElements.text.color
        calendar.appearance.headerTitleColor = ColorForElements.text.color
        calendar.appearance.titleDefaultColor = ColorForElements.text.color
        calendar.appearance.selectionColor = ColorForElements.additional.color
        calendar.appearance.todayColor = ColorForElements.main.color
        self.calendar = calendar
        view.addSubview(calendar)
        self.calendar.addSubview(previosButton)
        self.calendar.addSubview(nextButton)
        return view
    }
    
    func updateEventSection() {
        guard var section = self.form.sectionBy(tag: "Events") else {
            return
        }
        for row in self.form.allRows {
            if let rowTag = row.tag, let eventID = Int(rowTag.replacingOccurrences(of: "Event", with: "")){
                let events = self.eventsForCalendar.filter{ $0.objectID == eventID }
                if events.count == 0 && self.eventsForCalendar.count != 0 && section.count > 0 {
                    if let indexPath = row.indexPath {
                        section.remove(at: indexPath.row)
                    }
                }
            }
        }
        if self.eventsForCalendar.count == 0 {
            section.removeAll()
        }
        section.reload()
        self.addEventSection()
    }
    
    func updateCalendarForm() {
        self.calendar.reloadData()
        self.getEventByDate(self.date)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController != self) && (isFilterResetNeeded) {
            print("RESET Events\(viewController)")
            resetFilterEvents()
            isFilterResetNeeded = false
        } else if viewController == self {
            isFilterResetNeeded = true
        }
    }
}

extension TeacherCalendarViewController {
    
    func configureNavigationBar(){
        if SessionData.teacher {
            self.createBaseNavigationBar()
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
            self.baseNavigationBar?.baseNavigationItem.rightBarButtonItem = addButton
            let filterButton = UIBarButtonItem(image:  UIImage(named: "filter"),style: .plain,target: self, action: #selector(filterButtonPressed))
            self.baseNavigationBar?.baseNavigationItem.leftBarButtonItem = filterButton
        }
    }
    
    func addButtonPressed() {
        let operation = RouterOperationXib.openCreateLessonWorkshop(date: self.date)
        self.router.performOperation(operation)
    }
    
    func filterButtonPressed() {
        let operation = RouterOperationXib.openFilterLessonWorkshop
        let filterVC = self.router.performOperation(operation) as! FilterLessonWorkshopViewController
        filterVC.delegate = self
    }
    
    func previosMonthButtonPressed() {
        let currentMonth = self.calendar.currentPage
        if  let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            self.calendar.setCurrentPage(previousMonth, animated: true)
        }
    }
    
    func nextMonthButtonPressed() {
        let currentMonth = self.calendar.currentPage
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            self.calendar.setCurrentPage(nextMonth, animated: true)
        }
    }
}

extension TeacherCalendarViewController: FSCalendarDataSource, FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count = 0
        let dateString = DateFormatter.dayFormatter(format: "yyyy-MM-dd").string(from: date)
        let mdate = date.dateByDefaultTime(0, minute: 0, seconds: 0)
        let predicate = NSPredicate(format: "dayStart = %@",mdate as CVarArg)
        eventsForCalendar = self.events.filter(predicate).sorted(byProperty: "dateStart")
        for event in self.eventsForCalendar {
            if let eventStartDate = event.dateStart {
                let oneDateString = DateFormatter.dayFormatter(format: "yyyy-MM-dd").string(from: eventStartDate as Date)
                if oneDateString == dateString{
                    count += 1
                }
            }
        }
        return count
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.monthDate = calendar.currentPage.addingTimeInterval(86400)
        self.requestEventsBy(date: self.monthDate)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        self.date = date
        self.getEventByDate(date)
    }
    
    func getEventByDate(_ date:Date) {
        let mdate = date.dateByDefaultTime(0, minute: 0, seconds: 0)
        let predicate = NSPredicate(format: "dayStart = %@",mdate as CVarArg)
        self.eventsForCalendar = events.filter(predicate).sorted(byProperty: "dateStart")
        self.updateEventSection()
    }
}
