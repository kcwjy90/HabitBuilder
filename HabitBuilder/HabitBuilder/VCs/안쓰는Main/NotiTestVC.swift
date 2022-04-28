//
//  NotificationManager.swift
//  HabitBuilder
//
//  Created by ppc90 on 4/25/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import UserNotifications //Import 하시고




class NotiTestVC: UIViewController {
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
    
    let notiCenter = UNUserNotificationCenter.current()

    
    override func loadView() {
        super.loadView()
        
        notiCenter.requestAuthorization(options: [.alert, .sound]) {
            (PermissionGranted, error) in
            if (!PermissionGranted)
            {
                print("Permission Denied")
            }
        }
        
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
        
        
        addButton.addTarget(self, action: #selector(scheduleAdded), for: .touchUpInside)

    }
    
    @objc func scheduleAdded (_sender : UIButton)
    {
        notiCenter.getNotificationSettings { (settings)  in
            
            DispatchQueue.main.async {
                let title = self.titleTF.text!
                let date = self.newDate.date

                if(settings.authorizationStatus == .authorized)
                {
                    let content = UNMutableNotificationContent()
                        content.title = title
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)

                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    self.notiCenter.add(request) { (error) in
                        if (error != nil)
                        {
                            print("Error" + error.debugDescription)
                            return
                        }
                    }
                    let ac = UIAlertController(title: title, message: "저장완료", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "성공", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
                else
                {
                    let ac = UIAlertController(title: "Enable Notification", message: "PleaseChange", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in}))
                    self.present(ac, animated: true)
                }
                
            }
           
        }

    }
    
    func formattedDate(date: Date) -> String
    {
        let formmater = DateFormatter()
        formmater.dateFormat = "d MMM y HH:mm"
        return formmater.string(from:date)
    }
    
}




