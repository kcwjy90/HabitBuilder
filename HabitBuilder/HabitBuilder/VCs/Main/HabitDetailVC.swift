//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

class HabitDetailVC: UIViewController, UISearchBarDelegate {
        
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // backButton 생성
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setTitle("Back", for: .normal)
        v.setTitleColor(.red, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // editHabitButton 생성
    lazy var editHabitButton: UIButton = {
        let v = UIButton()
        v.setTitle("Edit", for: .normal)
        v.setTitleColor(.black, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()

    // saveHabitButton 생성
    lazy var saveHabitButton: UIButton = {
        let v = UIButton()
        v.setTitle("Save", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // habitTitle TextField 생성
    lazy var habitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .yellow
        v.placeholder = "No Title"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.setLeftPaddingPoints(10)
        v.setRightPaddingPoints(10)
        return v
    }()
    
    //  habitDesc TextField 생성
    lazy var habitDesc: UITextField = {
        let v = UITextField()
        v.backgroundColor = .yellow
        v.placeholder = "No Description"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.setLeftPaddingPoints(10)
        v.setRightPaddingPoints(10)
        return v
    }()
    
    // habitDateBackview 생성
    lazy var habitDateBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .yellow
        return v
    }()
    
    // habitDateLabel 생성
    lazy var habitDateLabel: UILabel = {
        let v = UILabel()
        v.text = "Date"
        v.textColor = .black
        return v
    }()
    
    lazy var habitDate: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .date
        v.layer.cornerRadius = 15
        return v
    }()
    
    // habitTimeBackview 생성
    lazy var habitTimeBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .yellow
        return v
    }()
    
    // habitTimeLabel 생성
    lazy var habitTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Time"
        v.textColor = .black
        return v
    }()
    
    lazy var habitTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .time
        v.layer.cornerRadius = 15
        return v
    }()
        
    lazy var tempTitle: UITextField = {
        let v = UITextField()
        return v
    }()
    
    lazy var tempDesc: UITextField = {
        let v = UITextField()
        return v
    }()
    
    lazy var tempDate: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .date
        return v
    }()
    
    lazy var tempTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .time
        return v
    }()
    
    let localRealm = DBManager.SI.realm!

    var habits: [RMO_Habit] = []

    lazy var didPressEdit : Bool = false
        
    override func loadView() {
        super.loadView()
        
        // tapGasture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(backButton)
        backView.addSubview(editHabitButton)
        backView.addSubview(saveHabitButton)
        backView.addSubview(habitTitle)
        backView.addSubview(habitDesc)
        backView.addSubview(habitDateBackView)
        backView.addSubview(habitDateLabel)
        backView.addSubview(habitDate)
        backView.addSubview(habitTimeBackView)
        backView.addSubview(habitTimeLabel)
        backView.addSubview(habitTime)
        
        // backView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        // backToMainButton size grid
        backButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // editHabitButton size grid
        editHabitButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.centerX.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // addHabitButton size grid
        saveHabitButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.right.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        
        // habitTitle TextField size grid
        habitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(50)
        }
        habitTitle.isUserInteractionEnabled = false
        
        // habitDesc TextField size grid
        habitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(habitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(160)
        }
        habitDesc.isUserInteractionEnabled = false
        habitDesc.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top

        
        // habitDateBackview size grid
        habitDateBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // habitDateLabel size grid
        habitDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // habitDate size grid
        habitDate.snp.makeConstraints { (make) in
            make.centerY.equalTo(habitDateBackView)
            make.right.equalTo(backView).offset(-34)
            make.height.equalTo(60)
        }
        habitDate.isUserInteractionEnabled = false
        
        // habitTimeBackview size grid
        habitTimeBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateBackView.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // habitTimeLabel size grid
        habitTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateBackView.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // habitTime size grid
        habitTime.snp.makeConstraints { (make) in
            make.top.equalTo(habitDate.snp.bottom).offset(10)
            make.right.equalTo(backView).offset(-28)
            make.height.equalTo(60)
        }
        habitTime.isUserInteractionEnabled = false

        
        // Button Actions - backToMainButton & editHabitButton & saveHabitButton
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        editHabitButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        saveHabitButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)

    }

    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editButtonPressed(sender: UIButton) {

        // Edit을 누를경우 다시 title, desc, date, time 을 유저가 edit 할수 있게됨
        habitTitle.backgroundColor = .systemGray5
        habitDesc.backgroundColor = .systemGray5
        habitDateBackView.backgroundColor = .systemGray5
        habitTimeBackView.backgroundColor = .systemGray5

        habitTitle.isUserInteractionEnabled = true
        habitDesc.isUserInteractionEnabled = true
        habitDate.isUserInteractionEnabled = true
        habitTime.isUserInteractionEnabled = true
        
        didPressEdit = true

    }
    
    @objc func saveButtonPressed(sender: UIButton) {
        
        let realm = localRealm.objects(RMO_Habit.self)

        if didPressEdit == true { //만약 editHabitButton이 press 되었으면
            
            let habits = localRealm.objects(RMO_Habit.self).toArray()
            let indexNumb = habits.firstIndex(where: { $0.title == tempTitle.text! || $0.desc == tempDesc.text! || $0.date == tempDate.date || $0.time == tempTime.date })

            let taskToUpdate = realm[indexNumb!]

            try! self.localRealm.write {
                taskToUpdate.title = habitTitle.text!
                taskToUpdate.desc = habitDesc.text!
                taskToUpdate.date = habitDate.date
                taskToUpdate.time = habitTime.date
            }

        } else {
        }
        dismiss(animated: true, completion: nil)
    }
    
}

// for UITextField Padding

//extension UITextField {
//    func setLeftPaddingPoints(_ amount:CGFloat){
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//    func setRightPaddingPoints(_ amount:CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.rightView = paddingView
//        self.rightViewMode = .always
//    }
//
//}
