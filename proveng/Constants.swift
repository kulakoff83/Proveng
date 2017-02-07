//
//  Constants.swift
//  proveng
//
//  Created by Dmitry Kulakov on 15.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

public struct Constants {
    
    static let StoryBoardName = "Main"
    static func VersionValue() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return ""
    }    
    // MARK: Actions Titles and Messages
    static let DefaultActionTitle = NSLocalizedString("OK", comment: "")
    static let CancelActionTitle = NSLocalizedString("Cancel", comment: "")
    static let ErrorAlertTitle = NSLocalizedString("Error", comment: "")
    static let ServerErrorAlertTitle = NSLocalizedString("Server Error", comment: "")
    static let SuccessAlertTitle = NSLocalizedString("Success", comment: "")
    static let ConfirmEditingEventAlertMessage = NSLocalizedString("All members of the group will be notified", comment: "")
    static func ConfirmEditingEventAlertTitle(_ eventType: String) -> String {
        return String(format: NSLocalizedString("Are you sure you want to cancel this %@?", comment: ""),eventType)
    }
    static let ConfirmLogOutAlertMessage = NSLocalizedString("Are you sure you want to log out?", comment: "")
    static let UnknownErrorDescription = NSLocalizedString("Unknown Error", comment: "")
    static let LostInternetConectionAlertMessage = NSLocalizedString("Please check your internet connection and try again", comment: "")
    static let IncorrectDateAlertMessage = NSLocalizedString("End time can't precede the start time", comment: "")
    static let SameDateAlertMessage = NSLocalizedString("The end time can't be the same as the start time", comment: "")
    static let NoActionTitle = NSLocalizedString("No", comment: "")
    static let YesActionTitle = NSLocalizedString("Yes", comment: "")
    static let TryActionTitle = NSLocalizedString("Try", comment: "")
    static let EndTestAlertTitle = NSLocalizedString("Time is up", comment: "")
    static let EndTestAlertMessage = NSLocalizedString("Test will be finished", comment: "")
    static let CancelTestAlertTitle = NSLocalizedString("Are you sure you want to cancel this test?", comment: "")
    static let CancelTestAlertMessage = NSLocalizedString("All results will be lost and you'll have to take the test again", comment: "")
    
    // MARK: Controllers Titles
    static let CalendarControllerTitle = NSLocalizedString("Calendar", comment: "")
    static let GroupsControllerTitle = NSLocalizedString("Groups", comment: "")
    static let MaterialsControllerTitle = NSLocalizedString("Materials", comment: "")
    static let ProfileControllerTitle = NSLocalizedString("Profile", comment: "")
    static let EditProfileControllerTitle = NSLocalizedString("Edit Profile", comment: "")
    static let FeedControllerTitle = NSLocalizedString("Feed", comment: "")
    static let SettingsControllerTitle = NSLocalizedString("Settings", comment: "")
    static let TestPreviewControllerTitle = NSLocalizedString("English Placement Test", comment: "")
    static let TestControllerTitle = NSLocalizedString("NO TIMER", comment: "")
    static let TestResultControllerTitle = NSLocalizedString("Test result", comment: "")
    
    static let AddStudentsControllerTitle = NSLocalizedString("Add Students", comment: "")
    static let AddStudentsSectionHeaderTitle = NSLocalizedString("NUMBER OF STUDENTS: ", comment: "")
    static let EditGroupControllerTitle = NSLocalizedString("Edit group", comment: "")
    static let CreateGroupControllerTitle = NSLocalizedString("Create Group", comment: "")
    static let AttendStudentsControllerTitle = NSLocalizedString("Students", comment: "")
    static let FilterLessonWorkshopControllerTitle = NSLocalizedString("Filter", comment: "")
    static let EditLessonWorkshopControllerTitle = NSLocalizedString("Edit", comment: "")
    static let CreateLessonWorkshopControllerTitle = NSLocalizedString("Create event", comment: "")
    static let GroupLevelControllerTitle = NSLocalizedString("Group Level", comment: "")
    static let CreateMaterialControllerTitle = NSLocalizedString("Create Material", comment: "")
    static let EditMaterialControllerTitle = NSLocalizedString("Edit Material", comment: "")
    static let ShareMaterialControllerTitle = NSLocalizedString("Share Material", comment: "")
    
    // MARK: Other
    static let GroupLevel = NSLocalizedString("Group level", comment: "")
    static let Started = NSLocalizedString("Start date", comment: "")
    static let CourseDuration = NSLocalizedString("Course duration", comment: "")
    static let StartTime = NSLocalizedString("Start time", comment: "")
    static let EndTime = NSLocalizedString("End time", comment: "")
    static let Repeat = NSLocalizedString("Repeat", comment: "")
    static let Location = NSLocalizedString("Location", comment: "")
    static let Rating = NSLocalizedString("Rating", comment: "")
    static let Achivement = NSLocalizedString("Achievement", comment: "")
    static let Statistics = NSLocalizedString("Statistics", comment: "")
    static let NotesKey = NSLocalizedString("Notes", comment: "")    
    static let Name = NSLocalizedString("Name", comment: "")
    static let Email = NSLocalizedString("Email", comment: "")
    static let Skype = NSLocalizedString("Skype", comment: "")
    static let PhoneNumber = NSLocalizedString("Phone Number", comment: "")
    static let GroupName = NSLocalizedString("Group name", comment: "")
    static let DepartmentName = NSLocalizedString("Department", comment: "")
    static let ProfileInfoSectionName = NSLocalizedString("User Info", comment: "")
    static let WorkshopLevel = NSLocalizedString("Upper-intermediate", comment: "")
    static let WorkshopType = NSLocalizedString("Workshop", comment: "")
    static let ScheduleType = NSLocalizedString("Schedule", comment: "")
    static let LifetimeType = NSLocalizedString("Lifetime", comment: "")
    static let Student = NSLocalizedString("Student", comment: "")
    static let Students = NSLocalizedString("Students", comment: "")
    static let PendingStudents = NSLocalizedString("Pending Students", comment: "")
    static let InfoSection = NSLocalizedString("Info", comment: "")
    
    static let MaterialTitle = NSLocalizedString("Material title", comment: "")
    static let MaterialType = NSLocalizedString("Type", comment: "")
    static let MaterialDescription = NSLocalizedString("Description", comment: "")
    static let MaterialLink = NSLocalizedString("Link", comment: "")
    // MARK: Info
    static let SupportMail = NSLocalizedString("proveng@gmail.com", comment: "")
    static let AboutAppText = NSLocalizedString("PROVENG helps each user to learn English more effective. It offers users a placement test to determine their language skill level.\n\nYou always know where and when will be next lesson or workshop. With PROVENG Calendar your timetable is always at hand.\n\nPROVENG is reliable assistant for English teacher. Discover how to learn English easier with PROVENG.\n\nP.S. Gene Galanter & Nick Antonov already use PROVENG for studying English.\n\nDeveloped by a team of interns:\nDaria Servatko    UI/UX Designer\nEugene Afanasiev    UI/UX Designer\nDmitriy Kulakov    iOS Developer\nViktoriya Matskevich    iOS Developer\nAlexander Usov     Java Developer\nVictor Levchenko     Java Developer\nAlexander Smityuk    Android Developer\nIlona Demkovskaya    QA Engineer\nKirill Karnyshov     QA Engineer\nAnna Kirichenko     QA Engineer\n\nUnder the guidance of curators PROVENG Formula 1:\nAlex Osadchyy \nAlina Remeslennikova \nGeorge Frigo \nAndrey Boyko \nAndrey Kulbatskiy \nPasha Shmigol \nAlex Zagulaev \nAnna Ermolaeva \nAlla Golosenko \n", comment: "")
    static let PrivacyText = NSLocalizedString("This app is aimed at people over 13\n\nThis app collects next information:\n•  User Details (Email address);\n•  Device identifier (Device information (UDID), OS version);\n•  User files (Photos/videos).\nThis app collects information from you so we can:\n•  Give you the service you wanted.\n•  Improve the app over time.\n\nPROVENG includes measuring tools. We want to learn how you use the app so we can improve it in future updates. The data is seen only us. We measure how you use this app.\n\nFrom time to time, we might contact you via Message Within app.\n\nThe security of your personal information is extremely important. We take the following precautions to make sure it cannot be accessed or altered:\n•  Data encrypted in storage\n•  Industry standard Internal security protocols", comment: "")
    static let TermsText = NSLocalizedString("GENERAL\nPlease read these Terms of Service carefully before using the PROVENG Application (next Application). Your access to and use of the Application is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users and others who access or use the Application. By accessing or using the Application you agree to be bound by these Terms.\n\nDEFINITIONS\nThe \"Application\" shall mean the software provided by Provectus to offer services related to PROVENG to be used on iOS, Android devices and any upgrades from time to time and any other software or documentation which enables the use of the Application.\n\nDATA PROTECTION\nAny personal information you supply to PROVENG when using the Application will be used in accordance with Privacy Policy.\n\nRPOPRIETARY RIGHTS AND LICENCE\nAll trademarks, copyrighting, database rights and other intellectual property rights of any nature in the Application together with the underlying software code are owned directly by PROVENG. PROVENG hereby grants you a worldwide, non-exclusive, royalty-free revocable licence to use the Application for personal use in accordance with these appterms.\n\nLINKS TO OTHER WEB SITES\nOur Application may contain links to third-party web sites or services that are not owned or controlled by PROVENG. PROVENG has no control over, and doesn't take responsibility for the content, privacy policies, or practices of any third party web sites or services.  We strongly advise you to read the terms and conditions and privacy policies of any third-party web sites or services that you visit.\n\nTERMINATION\nWe may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\nCHANGES\nWe reserve the right, at our sole discretion, to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.\n\nCONTACT US\nIf you have any questions about these Terms, please contact us.", comment: "")
    static let EmptyFeedTitle = NSLocalizedString("No feed, yet!", comment: "")
    static let EmptyFeedText = NSLocalizedString("You'll be added to the group soon", comment: "")
    // MARK: Tests
    static let PreviewTestDescription = NSLocalizedString("Find out what your level of English ability is by completing the following placement test.\n\n",comment: "")
    static let PreviewTestTitle = NSLocalizedString("Instructions:",comment: "")
    static func PreviewTestText1(_ questionsCount: Int) -> String {
        let text = String(format: NSLocalizedString("\n\n●  The test contains %i single-answer questions", comment: ""), questionsCount)
        return text
    }
    static func PreviewTestText2(_ minutes: Int) -> String {
        let text = String(format: NSLocalizedString("\n\n●  You will have %i minute(s) to complete the test", comment: ""),minutes)
        return text
    }
    static let PreviewTestText3 = NSLocalizedString("\n\n●  You’ll receive your score and have to wait before the teacher adds you to the group that would best fit your level",comment: "")
    
    static let PreviewRegularTestText3 = NSLocalizedString("\n\n●  If you cancel in the middle of the test you will lose your results and will have to start over.",comment: "")
    
    static func ResultLevelTestText(level: String) -> String {
        let text = String(format: NSLocalizedString("Congratulations,\nYour level is %@",comment: ""), level)
        return text
    }
    
    static func ResultMarkTestText(_ mark: Int, weight: Int) -> String {
        let text = String(format: NSLocalizedString("Correct answers: %i/%i",comment: ""),mark, weight)
        return text
    }
    // MARK: Design
    static let errorColor = UIColor.red
    static let regularFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
    static let lightFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
    // MARK: Keys
    static let DefaultMaterialFilterKey = "defaultFilterMaterials"
    static let DefaultTestsFilterKey = "defaultFilterTests"
    static let MaterialFilterKey = "filterMaterials"
    static let TestsFilterKey = "filterTests"
}
