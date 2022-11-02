//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import RealmSwift

class NewHabitVC: UIViewController, UISearchBarDelegate, UITextViewDelegate {
    
    //realm Noti 에서 쓰는거
    let localRealm = DBManager.SI.realm!
    
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
  
    // newHabitTitle TextField 생성
    lazy var newHabitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.placeholder = "Title of your New Habit"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    // newHabitDesc UITextView (Multi line) 생성
    lazy var newHabitDesc: UITextView = {
        let v = UITextView()
        v.backgroundColor = .white
        v.text = "Description of your New Habit"
        v.textColor = UIColor.lightGray
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.font = UIFont.systemFont(ofSize: 15.0)
        return v
    }()
    
    // newHabitDateTimeBackview 생성
    lazy var newHabitDateTimeBackview: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .white
        return v
    }()
    
    // newHabitDateTimeLabel 생성
    lazy var newHabitDateTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Date and Time"
        v.textColor = .systemGray
        return v
    }()
    
    // newHabitDateTime 생성
    lazy var newHabitDateTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .dateAndTime
        let today = Date()
        v.minimumDate = today
        v.layer.cornerRadius = 15
        return v
    }()
    
    // repeatBackview 생성
    lazy var repeatBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .white
        return v
    }()
    
    // repeatLabel 생성
    lazy var repeatLabel: UILabel = {
        let v = UILabel()
        v.text = "Repeat"
        v.textColor = .systemGray
        return v
    }()
    
    // repeatButton 생성
    lazy var repeatButton: UIButton = {
        let v = UIButton()
        v.layer.cornerRadius = 8
        return v
    }()
    
    // repeatTypeLabel 생성
    lazy var repeatTypeLabel: UILabel = {
        let v = UILabel()
        v.text = "None >"
        v.textColor = .black
        return v
    }()
    
    //default Repeat Type when user creates Habit
    var repTyp: RepeatType = .none
    
    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        // tapGesture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(newHabitTitle)
        backView.addSubview(newHabitDesc)
        backView.addSubview(newHabitDateTimeBackview)
        backView.addSubview(newHabitDateTimeLabel)
        backView.addSubview(newHabitDateTime)
        backView.addSubview(repeatBackView)
        backView.addSubview(repeatLabel)
        backView.addSubview(repeatButton)
        backView.addSubview(repeatTypeLabel)
        
        
        // backView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        // newHabitTitle TextField size grid
        newHabitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backView).offset(60)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(50)
        }
        //giving Padding to TextField
        newHabitTitle.setLeftPaddingPoints(10)
        newHabitTitle.setRightPaddingPoints(10)
        newHabitTitle.layer.borderWidth = 1.5
        newHabitTitle.layer.borderColor = UIColor.pastGray.cgColor

        
        // newHabitDesc UITextVIew size grid
        newHabitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(210)
        }
        newHabitDesc.delegate = self //placeholder가 UITextView에는 없어서 비슷한것을 생성하기위한 function.
        textViewDidBeginEditing(newHabitDesc) //을 넣기 위해서 delegate을 해야함.
        textViewDidEndEditing(newHabitDesc)
        newHabitDesc.addPadding()
        newHabitDesc.addPadding()
        newHabitDesc.layer.borderWidth = 1.5
        newHabitDesc.layer.borderColor = UIColor.pastGray.cgColor
        
        // newHabitDateTimeBackview size grid
        newHabitDateTimeBackview.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitDateTimeLabel size grid
        newHabitDateTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitDateTime size grid
        newHabitDateTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(newHabitDateTimeBackview)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(60)
        }
        newHabitDateTime.tintColor = .compBlue
        
        
        // repeatBackview size grid
        repeatBackView.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDateTimeBackview.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        
        // repeatLabel size grid
        repeatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(repeatBackView)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // repeatButton size grid
        repeatButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.left.equalTo(repeatTypeLabel).offset(-10)
            make.height.equalTo(32)
            make.right.equalTo(newHabitDateTime)
        }
        repeatButton.layer.borderWidth = 1.5
        //FIXME: needs to change gray color to match Date and TIme
        repeatButton.layer.borderColor = UIColor.dateGray.cgColor
        repeatButton.layer.backgroundColor = UIColor.dateGray.cgColor
        
        
        
        // repeatTypeLabel size grid
        repeatTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.height.equalTo(40)
            make.right.equalTo(newHabitDateTime).offset(-10)
        }
        
        
        //MARK: Button Actions - repeatButton
        repeatButton.addTarget(self, action: #selector(repeatButtonPressed), for: .touchUpInside)
        
    }
    
    //MARK: Button Funcs - Add, Back, Repeat Buttons
    @objc func addButtonPressed() {
        
        guard let titleText = newHabitTitle.text, let descText = newHabitDesc.text else { return }
        let habit = RMO_Habit()
        
        if newHabitTitle.text == "" {
            habit.title = "No Title"
        } else {
            habit.title = titleText
        }
        habit.desc = descText
        habit.date = newHabitDateTime.date
        habit.startDate = newHabitDateTime.date
        habit.repeatType = self.repTyp
        habit.total += 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let habitDate = dateFormatter.string(from: newHabitDateTime.date)
        
        let countRealm = localRealm.objects(RMO_Count.self)
        
        
        //MARK:RMO_Count 확인 -> either 새로운 날짜 추가 or existing 날짜에 total +1
        //새로 생성된 habit의 날짜가 RMO_Count에 있는지 확인하고, 없을 경우 RMO_Count에 추가한다.
        if !countRealm.contains(where: { $0.date == habitDate} )
        {
            let newCount = RMO_Count()
            newCount.date = habitDate
            
            try! localRealm.write {
                localRealm.add(newCount)
//                print("생성")
//                print(newCount)
            }
        }
        
        //만약 RMO_Count에 지금 add하는 날짜의 object가 있을경우 그 total 을 +1 한다
        guard let inNumb = countRealm.firstIndex(where: { $0.date == habitDate}) else
        {return}
        let existCount = countRealm[inNumb]
        
        try! localRealm.write {
            existCount.total += 1
//            print("+1")
//            print(existCount)
        }
        
        
        
        //habit 을 추가
        try! localRealm.write {
            localRealm.add(habit)
        }
        
        //Creating default RMO_Rate with 0% completion, so if the user doesn't do anything for the first day, it automatically saves 0%
        let rate = RMO_Rate()

        rate.createdDate = habit.date
        rate.habitID = habit.id
        rate.privateRepeatType = habit.privateRepeatType
        
        let success = Double(0)
        let total = Double(1)
        let successRate = Double(success/total)*100
       
        rate.rate = successRate
        
        
        try! self.localRealm.write {
            localRealm.add(rate)
        }
        
        
        print("=========printing RMO_Habit in NewHabitVC line 271===============")
        print(self.localRealm.objects(RMO_Habit.self))
        print(self.localRealm.objects(RMO_Rate.self))
        print("=========printing RMO_Habit in NewHabitVC line 271===============")

        //MARK: adding notification to Scheduler
        NotificationManger.SI.addScheduleNoti(habit: habit)
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func backButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func repeatButtonPressed(sender: UIButton){
        
        var repeatLabel: String?
        
        let alert = UIAlertController(
            title: "Select Repeat Frequency",
            message: "",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Daily", style: .default, handler: {_ in
            repeatLabel = "Daily"
            guard let label = repeatLabel else {return}
            self.repeatTypeLabel.text = label.capitalized + " >"
            guard let repeatType = RepeatType(rawValue: 1) else { return }
            self.repTyp = repeatType
        }))
        alert.addAction(UIAlertAction(title: "Weekly", style: .default, handler: {_ in
            repeatLabel = "Weekly"
            guard let label = repeatLabel else {return}
            self.repeatTypeLabel.text = label.capitalized + " >"
            guard let repeatType = RepeatType(rawValue: 2) else { return }
            self.repTyp = repeatType
        }))
        alert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: {_ in
            repeatLabel = "Monthly"
            guard let label = repeatLabel else {return}
            self.repeatTypeLabel.text = label.capitalized + " >"
            guard let repeatType = RepeatType(rawValue: 3) else { return }
            self.repTyp = repeatType
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            repeatLabel = "None"
            guard let label = repeatLabel else {return}
            self.repeatTypeLabel.text = label.capitalized + " >"
            guard let repeatType = RepeatType(rawValue: 0) else { return }
            self.repTyp = repeatType
        }))

        self.present(alert, animated: true)
        
        
//        let v = RepeatVC()
//            v.delegate = self
//            v.modalPresentationStyle = .pageSheet
//            present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    
    //MARK: UITextView "Placeholder" - 만약 edit 을 하려고 하는데 textColor가 gray 이다 (즉 가짜 placeholder이다) 그러면 text를 지우고 (마치 placeholder가 사라지듯이) textColor를 새롭게 black 으로 한다.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    //만약 Desc가 없으면 마치 placeholder인것처럼 "Description of your New Habit" 이라는 문구를 회색으로 넣음.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please Add Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: Navi Bar
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        
        title = "New Habit"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .done,
            target: self,
            action: #selector(backButtonPressed)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .black

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(addButtonPressed)
        )
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
}


//MARK: Receiving updated repeatType from ReapetVC
extension NewHabitVC: RepeatVCDelegate {
    func didChangeRepeatType(repeatType: RepeatType) {
        repTyp = repeatType
        let repeatTypeString = String(describing: repeatType) //string으로 바꿔줌. repeatType이 원래 있는 type이 아니라서 그냥 String(repeatType) 하면 안되고 "describing:" 을 넣어줘야함
        repeatTypeLabel.text = repeatTypeString.capitalized + " >"
    }
}


//MARK: Adding padding to UITextField
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}

//MARK: Adding padding to UITextView
extension UITextView {
    func addPadding() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
}


