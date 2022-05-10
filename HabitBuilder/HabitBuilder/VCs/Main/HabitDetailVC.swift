//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

protocol habitDetailVCDelegate: AnyObject {
    func editComp()
    
}
class HabitDetailVC: UIViewController, UISearchBarDelegate, UITextViewDelegate {
    
    weak var delegate: habitDetailVCDelegate?   // Delegate property var 생성
    
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
        v.backgroundColor = .systemGray5
        v.placeholder = "Title of your New Habit"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.setLeftPaddingPoints(10)
        v.setRightPaddingPoints(10)
        return v
    }()
    
    //  habitDesc UITextView 생성
    lazy var habitDesc: UITextView = {
        let v = UITextView()
        v.backgroundColor = .systemGray5
        v.text = "Description of your New Habit"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.font = UIFont.systemFont(ofSize: 15.0)
        return v
    }()
    
    // habitDateBackview 생성
    lazy var habitDateBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
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
        v.backgroundColor = .systemGray5
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
        
    let localRealm = DBManager.SI.realm!
    
    var habits: [RMO_Habit] = []
    
    lazy var didPressEdit : Bool = false
    
    
    //CONSTRUCTOR. 이것을 MainVC에서 받지 않으면 아예 작동이 안됨.
    var habit: RMO_Habit //RMO_Habit object를 mainVC에서 여기로
    init (habit: RMO_Habit) {
        self.habit = habit //initializing habit
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { //위의 코드랑 꼭 같이 가야함
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        // tapGasture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(backButton)
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
        
        // habitDesc TextField size grid
        habitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(habitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(160)
        }
        habitDesc.delegate = self
        textViewDidBeginEditing(habitDesc)
        textViewDidEndEditing(habitDesc)
        habitDesc.addPadding()
        habitDesc.addPadding()
        
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
        
        
        habitTitle.text = habit.title
        habitDesc.text = habit.desc
        changeTextColor(habitDesc) // Description이 없을경우 placeholder처럼 꾸미기
        habitDate.date = habit.date
        habitTime.date = habit.time
        
        // Button Actions - backToMainButton & editHabitButton & saveHabitButton
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        saveHabitButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(sender: UIButton) {
        
        let realm = localRealm.objects(RMO_Habit.self)
        
            let habits = localRealm.objects(RMO_Habit.self).toArray()
        let indexNumb = habits.firstIndex(where: { $0.id == habit.id})
            let taskToUpdate = realm[indexNumb!]
            
//            let habits = localRealm.objects(RMO_Habit.self).filter { habit in
//                return habit.id == self.tempID
//            } 32:41 
            try! self.localRealm.write {
                taskToUpdate.title = habitTitle.text!
                taskToUpdate.desc = habitDesc.text!
                taskToUpdate.date = habitDate.date
                taskToUpdate.time = habitTime.date
            }
            
            NotificationManger.SI.addScheduleNoti(habit: taskToUpdate) //update된걸 scheduler에. 자동적으로 이 전에 저장된건 지워지나봐. 쏘 나이스

            delegate?.editComp()
            dismiss(animated: true, completion: nil)
        
    }
    
    //밑에 두 func으로 Habit Desc TextView에 placeholder 비슷한것을 넣는다.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description of your New Habit"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func changeTextColor(_ textView: UITextView) {
        if textView.text == "Description of your New Habit" {
            textView.textColor = UIColor.lightGray
            
            textViewDidBeginEditing(habitDesc)
            textViewDidEndEditing(habitDesc)
        }
    }

}
