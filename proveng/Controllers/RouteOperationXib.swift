//
//  RouteOperationXib.swift
//  proveng
//
//  Created by Dmitry Kulakov on 21.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

/**
 
 Open ViewController from Xib or StoryBoard
 
 */

enum RouterOperationXib {
    
    case openHomeScreen(userType: UserType)
    case openTabBar(tapBarVC: BaseViewControllerProtocol, childs: [UIViewController])
    //MARK: Group
    case openGroupDetail(groupID: Int, primaryGroupFlag: Bool)
    case openEditGroup(group: Group)
    case openCreateGroup(level: String, studentsCount: Int)
    case openGroups(showPickerScreen: Bool)
    //MARK: Event
    case openCreateLessonWorkshop(date: Date)
    case openLessonWorkshop(eventID: Int, teacher: Bool)
    case openEditLessonWorkshop(event: Event)
    case openFilterLessonWorkshop
    case openCalendar
    //MARK: User
    case openLogin
    case openViewUserProfile(userID: Int, isChild: Bool)
    case openEditUserProfile(user: User?)
    case openAddStudents(createGroup: Bool, group: Group)
    case openTextInfo(title: String, text: String)
    case openSettingsScreen
    //MARK: Test
    case openTest(test: Test)
    case openTestPreview(testID: Int)
    case openTestResult(test: Test, weight: Int)
    //MARK: Material
    case openMaterialsScreen(materialID: Int)
    case openCreateMaterial
    case openEditMaterial(material: Material)
    case openShareMaterial(level: String, groupID: Int)
    
    var baseViewController: BaseViewControllerProtocol {
        switch self {
        case .openHomeScreen(let userType):
            let tabBar = TeacherHomeTabBarController(nibName: xibName, bundle: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            tabBar.navigationItem.hidesBackButton = true
            appDelegate.router?.tabBarViewController = tabBar
            var childViewControllers = [UIViewController]()
            switch userType {
            case .teacher:
                childViewControllers = createTeacherChildControllers()
            case .student:
                childViewControllers = createStudentChildControllers()
            }
            return RouterOperationXib.openTabBar(tapBarVC: tabBar, childs: childViewControllers).baseViewController
        case .openTabBar(let tapBarVC, let childs):
            (tapBarVC as! UITabBarController).viewControllers = childs
            return tapBarVC
        //MARK: Group
        case .openGroupDetail(let groupID, let primaryGroupFlag):
            let groupDetailVC = GroupDetailsViewController(nibName: xibName,bundle: nil)
            groupDetailVC.groupID = groupID
            groupDetailVC.primaryGroupFlag = primaryGroupFlag
            return groupDetailVC
        case .openEditGroup(let group):
            let editGroupVC = EditGroupViewController(nibName: xibName,bundle: nil)
            editGroupVC.title = Constants.EditGroupControllerTitle
            editGroupVC.group = group
            return editGroupVC
        case .openCreateGroup(let level, let studentsCount):
            let createGroupeVC = CreateGroupViewController(nibName: xibName,bundle: nil)
            createGroupeVC.groupLevel = level
            createGroupeVC.pendingStudentsCount = studentsCount
            createGroupeVC.title = Constants.CreateGroupControllerTitle
            return createGroupeVC
        case .openGroups(let showPickerScreen):
            let groupsVC = TeacherGroupsViewController(nibName: xibName,bundle: nil)
            groupsVC.title = Constants.GroupsControllerTitle
            groupsVC.showPickerScreen = showPickerScreen
            return groupsVC
        //MARK: Event
        case .openLessonWorkshop(let eventID, let teacher):
            let lessonWorkshopVC = LessonWorkshopDetailsViewController(nibName: xibName,bundle: nil)
            lessonWorkshopVC.eventID = eventID
            lessonWorkshopVC.teacher = teacher
            return lessonWorkshopVC
        case .openEditLessonWorkshop(let event):
            let editLessonWorkshopVC = EditLessonWorkshopViewController(nibName: xibName,bundle: nil)
            editLessonWorkshopVC.event = event
            editLessonWorkshopVC.hidesBottomBarWhenPushed = true
            return editLessonWorkshopVC
        case .openFilterLessonWorkshop:
            let filterLessonWorkshopVC = FilterLessonWorkshopViewController(nibName: xibName,bundle: nil)
            filterLessonWorkshopVC.title = Constants.FilterLessonWorkshopControllerTitle
            return filterLessonWorkshopVC
        case .openCreateLessonWorkshop(let date):
            let createLessonWorkshopVC = CreateLessonWorkshopViewController(nibName: xibName,bundle: nil)
            createLessonWorkshopVC.startDate = date
            createLessonWorkshopVC.title = Constants.CreateLessonWorkshopControllerTitle
            return createLessonWorkshopVC
        case .openCalendar:
            let calendarVC = TeacherCalendarViewController(nibName: xibName,bundle: nil)
            calendarVC.title = Constants.CalendarControllerTitle
            return calendarVC
        //MARK: User
        case .openLogin: return LoginViewController(nibName: xibName,bundle: nil)
        case .openAddStudents(let createGroup, let group):
            let addStudentsVC = AddStudentsViewController(nibName: xibName,bundle: nil)
            addStudentsVC.title = Constants.AddStudentsControllerTitle
            addStudentsVC.createGroup = createGroup
            addStudentsVC.group = group
            return addStudentsVC
        case .openViewUserProfile(let userID, let isChild):
            let profileVC = ViewProfileViewController(nibName: xibName,bundle: nil)
            profileVC.title = Constants.ProfileControllerTitle
            profileVC.userID = userID
            profileVC.isChild = isChild
            return profileVC
        case .openEditUserProfile(let user):
            let profileVC = EditProfileViewController(nibName: xibName,bundle: nil)
            profileVC.title = Constants.EditProfileControllerTitle
            profileVC.user = user
            return profileVC
        case .openTextInfo(let title, let text):
            let textVC = TextInfoViewController(nibName: xibName,bundle: nil)
            textVC.title = title
            textVC.text = text
            return textVC
        case .openSettingsScreen:
            let settingsVC = StudentSettingsViewController(nibName: xibName, bundle: nil)
            settingsVC.title = Constants.SettingsControllerTitle
            return settingsVC
        //MARK: Test
        case .openTest(let test):
            let testVC = TestViewController(nibName: xibName,bundle: nil)
            testVC.currentTest = test
            return testVC
        case .openTestPreview(let testID):
            let testPreviewVC = TestPreviewViewController(nibName: xibName,bundle: nil)
            testPreviewVC.testID = testID
            return testPreviewVC
        case .openTestResult(let test, let testWeight):
            let testResultVC = TestResultViewController(nibName: xibName,bundle: nil)
            testResultVC.currentTest = test
            testResultVC.testWeight = testWeight
            return testResultVC
        //MARK: Material
        case .openMaterialsScreen(let materialID):
            let materialsVC = MaterialsViewController(nibName: xibName,bundle: nil)
            materialsVC.materialID = materialID
            return materialsVC
        case .openCreateMaterial:
            let createMaterialVC = CreateMaterialViewController(nibName: xibName,bundle: nil)
            createMaterialVC.title = Constants.CreateMaterialControllerTitle
            return createMaterialVC
        case .openEditMaterial(let material):
            let editMaterialVC = EditMaterialViewController(nibName: xibName,bundle: nil)
            editMaterialVC.material = material
            editMaterialVC.title = Constants.EditMaterialControllerTitle
            return editMaterialVC
        case .openShareMaterial(let level, let groupID):
            let shareMaterialVC = ShareMaterialViewController(nibName: xibName,bundle: nil)
            shareMaterialVC.level = level
            shareMaterialVC.groupID = groupID
            shareMaterialVC.title = Constants.ShareMaterialControllerTitle
            return shareMaterialVC
        }
    }
    
    var xibName: String {
        switch self {
        case .openHomeScreen:
            return "TeacherHomeTabBarController"
        case .openTabBar:
            return ""
        //MARK: Group
        case .openGroupDetail:
            return "GroupDetailsViewController"
        case .openEditGroup:
            return "EditGroupViewController"
        case .openCreateGroup:
            return "CreateGroupViewController"
        case .openGroups:
            return "TeacherGroupsViewController"
        //MARK: Event
        case .openLessonWorkshop:
            return "LessonWorkshopDetailsViewController"
        case .openEditLessonWorkshop:
            return "EditLessonWorkshopViewController"
        case .openFilterLessonWorkshop:
            return "FilterLessonWorkshopViewController"
        case .openCreateLessonWorkshop:
            return "CreateLessonWorkshopViewController"
        case .openCalendar:
            return "TeacherCalendarViewController"
        //MARK: User
        case .openLogin:
            return "LoginViewController"
        case .openAddStudents:
            return "AddStudentsViewController"
        case .openViewUserProfile:
            return "ViewProfileViewController"
        case .openEditUserProfile:
            return "EditProfileViewController"
        case .openTextInfo:
            return "TextInfoViewController"
        case .openSettingsScreen:
            return "StudentSettingsViewController"
        case .openTest:
            return "TestViewController"
        case .openTestPreview:
            return "TestPreviewViewController"
        case .openTestResult:
            return "TestResultViewController"
        //MARK: Material
        case .openMaterialsScreen:
            return "MaterialsViewController"
        case .openCreateMaterial:
            return "CreateMaterialViewController"
        case .openEditMaterial:
            return "EditMaterialViewController"
        case .openShareMaterial:
            return "ShareMaterialViewController"
        }
    }
        
    var navigationBarHidden: Bool {
        switch self {
        case .openLogin:
            return true
        case .openHomeScreen:
            return true
        default:
            return false
        }
    }
    
    var transitionStyle: RouteTransitionStyle {
        switch self {
        case .openFilterLessonWorkshop:
            return RouteTransitionStyle.present
        default:
            return RouteTransitionStyle.push
        }
    }
}

enum RouteTransitionStyle {
    case push
    case present
}

enum UserType {
    case student
    case teacher
}

extension RouterOperationXib: RouteOperation {
    
    //MARK: Protocol operation
    
    func startOperation(_ router: Router) -> BaseViewControllerProtocol? {
        let baseViewController = self.baseViewController as! UIViewController
        baseViewController.router.navigationController?.setNavigationBarHidden(self.navigationBarHidden, animated: false)
        switch self.transitionStyle {
        case RouteTransitionStyle.push:
            router.navigationController?.pushViewController(baseViewController, animated: true)
        case RouteTransitionStyle.present:
            router.navigationController?.present(baseViewController, animated: true, completion: nil)
        }
        return baseViewController as? BaseViewControllerProtocol
    }
    
    //MARK: Create
    
    func createTeacherChildControllers() -> [UIViewController] {
        
        let calendarVC = TeacherCalendarViewController(nibName: "TeacherCalendarViewController", bundle: nil)
        calendarVC.title = Constants.CalendarControllerTitle
        calendarVC.tabBarItem = UITabBarItem(title: Constants.CalendarControllerTitle,image: IconForElements.tabBarCalendarItem.icon, tag: 1)
        
        let groupVC = TeacherGroupsViewController(nibName: "TeacherGroupsViewController", bundle: nil)
        groupVC.title = Constants.GroupsControllerTitle
        groupVC.tabBarItem = UITabBarItem(title: Constants.GroupsControllerTitle,image: IconForElements.tabBarGroupsItem.icon, tag: 2)
        
        let materialsVC = StudentMaterialsViewController(nibName: "StudentMaterialsViewController", bundle: nil)
        materialsVC.title = Constants.MaterialsControllerTitle
        materialsVC.tabBarItem = UITabBarItem(title: Constants.MaterialsControllerTitle,image: IconForElements.tabBarMaterialsItem.icon, tag: 3)
        
        let profileVC = ViewProfileViewController(nibName: "ViewProfileViewController", bundle: nil)
        profileVC.title = Constants.ProfileControllerTitle
        profileVC.tabBarItem = UITabBarItem(title: Constants.ProfileControllerTitle,image: IconForElements.tabBarProfileItem.icon, tag: 4)
        
        let childViewControllers = [calendarVC, groupVC, materialsVC, profileVC]
        return childViewControllers
    }
    
    func createStudentChildControllers() -> [UIViewController] {
        
        let feedVC = StudentFeedViewController(nibName: "StudentFeedViewController", bundle: nil)
        feedVC.title = Constants.FeedControllerTitle
        feedVC.tabBarItem = UITabBarItem(title: Constants.FeedControllerTitle,image: IconForElements.tabBarFeedItem.icon, tag: 1)
        
        let materialsVC = StudentMaterialsViewController(nibName: "StudentMaterialsViewController", bundle: nil)
        materialsVC.title = Constants.MaterialsControllerTitle
        materialsVC.tabBarItem = UITabBarItem(title: Constants.MaterialsControllerTitle,image: IconForElements.tabBarMaterialsItem.icon, tag: 2)
        
        let profileVC = ViewProfileViewController(nibName: "ViewProfileViewController", bundle: nil)
        profileVC.title = Constants.ProfileControllerTitle
        profileVC.tabBarItem = UITabBarItem(title: Constants.ProfileControllerTitle,image: IconForElements.tabBarProfileItem.icon, tag: 3)
        
        let settingsVC = StudentSettingsViewController(nibName: "StudentSettingsViewController", bundle: nil)
        settingsVC.title = Constants.SettingsControllerTitle
        settingsVC.tabBarItem = UITabBarItem(title: Constants.SettingsControllerTitle,image: IconForElements.tabBarSettingsItem.icon, tag: 4)
        
        let childViewControllers = [feedVC, materialsVC, profileVC, settingsVC]
        return childViewControllers
    }
}
