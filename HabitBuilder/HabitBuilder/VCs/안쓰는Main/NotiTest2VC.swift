
import Foundation
import SnapKit
import UIKit
import UserNotifications //Import 하시고


class NotiTest2VC: UIViewController, UNUserNotificationCenterDelegate {
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .purple
        return v
    }()
    
    lazy var addButton: UIButton = {
        let v = UIButton()
        //        v.backgroundColor = .blue
        v.setTitle("Add", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.layer.masksToBounds = true
        return v
    }()
    
    lazy var titleTF: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        return v
    }()
    
    lazy var newDate: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .dateAndTime
        v.layer.cornerRadius = 15
        return v
    }()
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func loadView() {
        super.loadView()
        
        self.userNotificationCenter.delegate = self

        self.requestNotificationAuthorization()
        self.sendNotification()
        
        view.addSubview(backView)
        backView.addSubview(addButton)
        backView.addSubview(titleTF)
        backView.addSubview(newDate)
        
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.right.bottom.equalTo(view)
        }
        
        titleTF.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(200)
            make.right.equalTo(backView).offset(-20)
            make.left.equalTo(backView).offset(20)
            make.height.equalTo(40)
        }
        
        newDate.snp.makeConstraints{ (make) in
            make.top.equalTo(titleTF.snp.bottom).offset(10)
            make.right.left.equalTo(titleTF)
            
        }
        
        addButton.snp.makeConstraints{ (make) in
            make.top.equalTo(newDate.snp.bottom).offset(10)
            make.right.equalTo(backView).offset(-40)
            make.left.equalTo(backView).offset(40)
            make.height.equalTo(30)
        }
        //        addButton.addTarget(self, action: #selector(scheduleAdded), for: .touchUpInside)
    }
    
    func formattedDate(date: Date) -> String
    {
        let formmater = DateFormatter()
        formmater.dateFormat = "d MMM y HH:mm"
        return formmater.string(from:date)
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Test"
        notificationContent.body = "Test body"
        notificationContent.badge = NSNumber(value: 2)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    } //

    // 앱 안에 있을때도 noti 받을수 있게 하는 code
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
}




