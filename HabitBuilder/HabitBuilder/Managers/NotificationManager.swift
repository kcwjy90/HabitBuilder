//
//  NotificationManager.swift
//  HabitBuilder
//
//  Created by ppc90 on 4/28/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

let localRealm = DBManager.SI.realm!

class NotificationManger: NSObject {
    
    static let SI = NotificationManger()
    
    func sendNotification() {
        
        //notification 를 정해진 시간에 보내는 content. DATE 말고 시간에 일단 맞춰놨음
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = NSNumber(value: 1)
        
        for habit in localRealm.objects(RMO_Habit.self) {
            
            notificationContent.title = habit.title
            notificationContent.body = habit.desc

            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: habit.time)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            
//            self.userNotificationCenter.add(request) { (error) in
//                if (error != nil)
//                {
//                    print("Error" + error.debugDescription)
//                    return
//                }
//            }
        }
    }
    
    // HabitBuilder 실행 중에도 notification 받을수 있게 하는 code
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
}
