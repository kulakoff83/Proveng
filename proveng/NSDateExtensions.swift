//
//  NSDateExtensions.swift
//  proveng
//
//  Created by Dmitry Kulakov on 10.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit

extension Date {
    
    func makeLocalTime() -> Date {
        let timeZone  = NSTimeZone.init(name: "Europe/Kiev") as! TimeZone
        let UTCString = DateFormatter.dayFormatter(format: "yyyy-MM-dd HH:mm:ss", timeZone: timeZone).string(from: self)
        return DateFormatter.dayFormatter(format: "yyyy-MM-dd HH:mm:ss").date(from: UTCString)!
    }
    
    public func dateByDefaultTime(_ hour: Int, minute: Int, seconds: Int) -> Date {
        let calendar : Calendar = Calendar.current
        return (calendar as NSCalendar).date(bySettingHour: hour, minute: minute, second: seconds, of: self, options: [])!
    }
    
    public func formattedDateStringWithFormat(_ dateFormat: String, dateStyle: DateFormatter.Style? = .none) -> String {
        return DateFormatter.dayFormatter(format: dateFormat, dateStyle: dateStyle).string(from: self)
    }
    
    func getWeekdayByDate() -> String {
        let weekdayString = DateFormatter.weekDayFormatter.string(from: self)
        return weekdayString
    }
    
    func getDateByWeekday(_ dayName: String, considerToday consider: Bool = false, dayAfter: Date = Date()) -> Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en_EN")
        (calendar as NSCalendar).maximumRange(of: NSCalendar.Unit.weekday)
        let weekdaysName = calendar.weekdaySymbols
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1
        
        if consider && (calendar as NSCalendar).component(.weekday, from: dayAfter) == nextWeekDayIndex {
            return dayAfter
        }
        
        var nextDateComponent = DateComponents()
        (nextDateComponent as NSDateComponents).calendar = calendar
        nextDateComponent.weekday = nextWeekDayIndex
        nextDateComponent.hour = (calendar as NSCalendar).component(.hour, from: self)
        nextDateComponent.minute = (calendar as NSCalendar).component(.minute, from: self)
        let date = (calendar as NSCalendar).nextDate(after: dayAfter, matching: nextDateComponent, options: .matchPreviousTimePreservingSmallerUnits)
        return date!
    }
    
    func minutes() -> Int {
        return self.getMinutesFrom(Date(timeIntervalSince1970: 0))
    }
    
    func timeMoreThan(time: Date) -> (Int, Int) {
        let calendar = Calendar.current
        let componentsTime = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour,NSCalendar.Unit.minute], from: self)
        let componentsCompareWith = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour,NSCalendar.Unit.minute], from: time)
        let time = componentsTime.hour! * 60 + componentsTime.minute!
        let compareWithTime = componentsCompareWith.hour! * 60 + componentsCompareWith.minute!
        return (time, compareWithTime)
    }
    
    static func convertStringToDate(_ dateString: String, dateFormat:String) -> Date {
        return DateFormatter.dayFormatter(format: dateFormat).date(from: dateString)!
    }
    
    static func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int) {
        return ((seconds / 60), (seconds % 3600) % 60)
    }
    
    public func msecondsFrom(_ date: Date) -> Double {
        return (self.timeIntervalSince(date) * 1000).truncate(places: 0)
    }
    
    func changeDayByOtherDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour,NSCalendar.Unit.minute], from: date)
        var newComponents = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour,NSCalendar.Unit.minute], from: self)
        newComponents.day = components.day
        newComponents.month = components.month
        newComponents.year = components.year
        
        let newDate = calendar.date(from: newComponents)
        return newDate!
    }
    
    func setEndDateWithDuration(_ duration: String) -> Date {
        let allowedCharactersSet = NSMutableCharacterSet.decimalDigit()
        let num = duration.components(separatedBy: allowedCharactersSet.inverted)
        var components: DateComponents = DateComponents()
        if let firstNum = num.first, let intNum = Int(firstNum){
            components.setValue(intNum, for: Calendar.Component.month)
        }
        return (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func getHoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    
    func getMinutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func getDaysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).day!
    }
    
    func monthsFrom(from date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    /// Returns the a custom time interval description from another date
    func offsetFrom(_ date: Date? = nil) -> String {
        guard date != nil else {
            return ""
        }
        if monthsFrom(from: date!)  > 0 { return "\(monthsFrom(from: date!)) months"  }            
        return ""
    }
}

extension DateFormatter {
    @nonobjc static var weekDayFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en-US")
        return dateFormatter
    }()
    
    @nonobjc static var localFormatter: DateFormatter =  {
        let timeZone  = NSTimeZone.init(name: "Europe/Kiev") as! TimeZone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = timeZone
        dateFormatter.dateStyle = .none
        dateFormatter.locale = Locale(identifier: "en-US")
        return dateFormatter
    }()
    
    static func dayFormatter(format: String, timeZone: TimeZone? = TimeZone.autoupdatingCurrent, dateStyle: Style? = .none) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        if dateStyle != .none {
            dateFormatter.dateStyle = dateStyle!
        }
        dateFormatter.locale = Locale(identifier: "en-US")
        return dateFormatter
    }
}

extension NSDate {
    
    public func makeLocalTime() -> NSDate {
        let UTCString = DateFormatter.localFormatter.string(from: self as Date)
        return DateFormatter.localFormatter.date(from: UTCString)! as NSDate
    }
    
    func minutes() -> Int {
        return self.getMinutesFrom(NSDate(timeIntervalSince1970: 0))
    }
    
    func getMinutesFrom(_ date: NSDate) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date as Date, to: self as Date, options: []).minute!
    }
    
    public func formattedDateStringWithFormat(_ dateFormat: String) -> String {
        return DateFormatter.dayFormatter(format: dateFormat).string(from: self as Date)
    }
    
    func NSDateTimeAgoLocalizedStrings(_ key: String) -> String {
        let resourcePath: String?
        
        if let frameworkBundle = Bundle(identifier: "com.provectus.proveng-ios") {
            // Load from Framework
            resourcePath = frameworkBundle.resourcePath
        } else {
            // Load from Main Bundle
            resourcePath = Bundle.main.resourcePath
        }
        
        if resourcePath == nil {
            return ""
        }
        
        let path = URL(fileURLWithPath: resourcePath!).appendingPathComponent("NSDateTimeAgo.bundle")
        guard let bundle = Bundle(url: path) else {
            return ""
        }
        
        return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle, comment: "")
    }
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            if components.year! < 2 {
                return NSDateTimeAgoLocalizedStrings("Last year")
            } else {
                return stringFromFormat("%%d %@years ago", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                return NSDateTimeAgoLocalizedStrings("Last month")
            } else {
                return stringFromFormat("%%d %@months ago", withValue: components.month!)
            }
        }
        
        // localize for other calanders
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                return NSDateTimeAgoLocalizedStrings("Last week")
            } else {
                return stringFromFormat("%%d %@weeks ago", withValue: week)
            }
        }
        
        if components.day! > 0 {
            if components.day! < 2 {
                return NSDateTimeAgoLocalizedStrings("Yesterday")
            } else  {
                return stringFromFormat("%%d %@days ago", withValue: components.day!)
            }
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return NSDateTimeAgoLocalizedStrings("An hour ago")
            } else  {
                return stringFromFormat("%%d %@hours ago", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            if components.minute! < 2 {
                return NSDateTimeAgoLocalizedStrings("A minute ago")
            } else {
                return stringFromFormat("%%d %@minutes ago", withValue: components.minute!)
            }
        }
        
        if components.second! >= 0 {
            if components.second! < 5 {
                return NSDateTimeAgoLocalizedStrings("Just now")
            } else {
                return stringFromFormat("%%d %@seconds ago", withValue: components.second!)
            }
        }
        
        return ""
    }
    
    public var timeAgoSimple: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            return stringFromFormat("%%d%@yr", withValue: components.year!)
        }
        
        if components.month! > 0 {
            return stringFromFormat("%%d%@mo", withValue: components.month!)
        }
        
        // localize for other calanders
        if components.day! >= 7 {
            let value = components.day!/7
            return stringFromFormat("%%d%@w", withValue: value)
        }
        
        if components.day! > 0 {
            return stringFromFormat("%%d%@d", withValue: components.day!)
        }
        
        if components.hour! > 0 {
            return stringFromFormat("%%d%@h", withValue: components.hour!)
        }
        
        if components.minute! > 0 {
            return stringFromFormat("%%d%@m", withValue: components.minute!)
        }
        
        if components.second! > 0 {
            return stringFromFormat("%%d%@s", withValue: components.second! )
        }
        
        return ""
    }
    
    public var timeAgoShort: String {
        let components = self.dateComponents()
        
        if components.year! > 0 {
            if components.year! < 2 {
                return NSDateTimeAgoLocalizedStrings("1yr ago")
            } else {
                return stringFromFormat("%%d %@yrs ago", withValue: components.year!)
            }
        }
        
        if components.month! > 0 {
            if components.month! < 2 {
                return NSDateTimeAgoLocalizedStrings("1mo ago")
            } else {
                return stringFromFormat("%%d %@mo ago", withValue: components.month!)
            }
        }
        
        // localize for other calanders
        if components.day! >= 7 {
            let week = components.day!/7
            if week < 2 {
                return NSDateTimeAgoLocalizedStrings("last wk")
            } else {
                return stringFromFormat("%%d %@wks ago", withValue: week)
            }
        }
        
        if components.day! > 0 {
            return stringFromFormat("%%d %@d ago", withValue: components.day!)
        }
        
        if components.hour! > 0 {
            if components.hour! < 2 {
                return NSDateTimeAgoLocalizedStrings("1hr ago")
            } else  {
                return stringFromFormat("%%d %@hrs ago", withValue: components.hour!)
            }
        }
        
        if components.minute! > 0 {
            return stringFromFormat("%%d %@min ago", withValue: components.minute!)
        }
        
        if components.second! >= 0 {
            return stringFromFormat("%%d %@sec ago", withValue: components.second!)
        }
        
        return ""
    }
    
    fileprivate func dateComponents() -> DateComponents {
        let calander = Calendar.current
        return (calander as NSCalendar).components([.second, .minute, .hour, .day, .month, .year], from: self as Date, to: Date(), options: [])
    }
    
    fileprivate func stringFromFormat(_ format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
    }
    
    fileprivate func getLocaleFormatUnderscoresWithValue(_ value: Double) -> String {
        
        let localeCode = Bundle.main.preferredLocalizations.first
        
        // Russian (ru) and Ukrainian (uk)
        if localeCode == "ru" || localeCode == "uk" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
}

