//
//  NotificationManager.swift
//  HabitBuilder
//
//  Created by ppc90 on 4/28/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationManger: NSObject {
    
    static let SI = NotificationManger()
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    //notification 를 정해진 시간에 보내는 content. DATE 말고 시간에 일단 맞춰놨음
    let notificationContent = UNMutableNotificationContent()
    
    override init() {
        super.init()
        self.userNotificationCenter.delegate = self //
        
    }
    
    //처음에 notification 받을지 authorize 하는 것
    func requestNotiAuth() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    
    //MARK: Notification을 정해진 시간에 보내는 content.
    func addScheduleNoti(habit: RMO_Habit) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = NSNumber(value: 1)
        
        notificationContent.title = habit.title
        notificationContent.body = habit.desc
        
        
        guard let repeatType = habit.repeatType else { return }
        
        execTrigger(repeatType: repeatType, habit: habit, nc: notificationContent)
        
    }
    
    
    func execTrigger(repeatType: RepeatType, habit: RMO_Habit, nc: UNMutableNotificationContent) {
        
        let cal = Calendar.current
        
        let calM = cal.component(.month, from: habit.date)
        let calW = cal.component(.weekOfMonth, from: habit.date)
        let calWd = cal.component(.weekday, from: habit.date)
        let calD = cal.component(.day, from: habit.date)
        let calH = cal.component(.hour, from: habit.date)
        let calMi = cal.component(.minute, from: habit.date)
        
        var repeats: Bool = false
        
        let noRepeat = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: habit.date)
        var yesRepeat = DateComponents()
        
        var dateComponent = DateComponents()
        
        switch repeatType {
        case .none:
            repeats = false
            dateComponent = noRepeat
        case .daily:
            repeats = true
            yesRepeat.hour = calH
            yesRepeat.minute = calMi
            dateComponent = yesRepeat
        case .weekly:
            repeats = true
            yesRepeat.weekday = calWd
            yesRepeat.hour = calH
            yesRepeat.minute = calMi
            dateComponent = yesRepeat
        case .monthly:
            repeats = true
            yesRepeat.weekOfMonth = calW
            yesRepeat.day = calD
            yesRepeat.hour = calH
            yesRepeat.minute = calMi
            dateComponent = yesRepeat
        case .yearly:
            repeats = true
            yesRepeat.month = calM
            yesRepeat.day = calD
            yesRepeat.hour = calH
            yesRepeat.minute = calMi
            dateComponent = yesRepeat
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
        let request = UNNotificationRequest(identifier: habit.id, content: nc, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        self.userNotificationCenter.add(request) { (error) in
            if (error != nil)
            {
                print("Error" + error.debugDescription)
                return
            }
        }
    }
    
    
    // HabitBuilder 실행 중에도 notification 받을수 있게 하는 code
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
}



//Mark: UNUserNotificationCenterDelegate
extension NotificationManger: UNUserNotificationCenterDelegate {
    // 근데 이 안에는 아무 코드가 없어도 잘 돌아가네...뭐지? 근데 또 없으면 안돼? 왜지?
}
