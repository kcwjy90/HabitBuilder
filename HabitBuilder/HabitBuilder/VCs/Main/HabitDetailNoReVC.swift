//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import SwiftUI
import Charts


//MARK: update 된 Habit이 담긴 protocol. MainVC나 AllHabitsVC로 간다
protocol habitDetailNoReVCDelegate: AnyObject {
    func editComp()
}


class HabitDetailNoReVC: UIViewController, UISearchBarDelegate, UITextViewDelegate, ChartViewDelegate{
    
    let localRealm = DBManager.SI.realm!
    
    // Delegate property var 생성
    weak var delegate: habitDetailNoReVCDelegate?
    
    // backview 생성
    lazy var scrollContentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // habitTitle TextField 생성
    lazy var habitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
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
        v.backgroundColor = .white
        v.text = "Description of your New Habit"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.font = UIFont.systemFont(ofSize: 15.0)
        return v
    }()
    
    // habitDateTimeBackview 생성
    lazy var habitDateTimeBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .white
        return v
    }()
    
    // habitDateTimeLabel 생성
    lazy var habitDateTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Date and Time"
        v.textColor = .pureBlack
        return v
    }()
    
    // habitDateTime 생성
    lazy var habitDateTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .dateAndTime
        //MARK: two lines of code that doesn't allow user to pick PAST date. but if this is activated, then the time changes automatically when the user opens up existing habit.
//        let today = Date()
//        v.minimumDate = today
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
    var prevRep: RepeatType?
    var repTyp: RepeatType?
    
    // successButton 생성
    lazy var successButton: UIButton = {
        let v = UIButton()
        v.setTitle("Success", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.backgroundColor = .pureBlue
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    // failButton 생성
    lazy var failButton: UIButton = {
        let v = UIButton()
        v.setTitle("Fail", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.backgroundColor = .pureRed
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    // deleteButton 생성
    lazy var deleteButton: UIButton = {
        let v = UIButton()
        v.setTitle("Delete", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.backgroundColor = .pureBlack
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isUserInteractionEnabled = true
        v.isScrollEnabled = true
        v.backgroundColor = .white
        return v
    }()
    
    
    
    //MARK: CONSTRUCTOR. 이것을 MainVC나 AllHabitsVC에서 받지 않으면 아예 작동이 안됨. Needed to receive selected Habit information from TableView to display in the HabitDetail VC
    var habit: RMO_Habit //RMO_Habit object를 mainVC, AllHabitsVC 에서 여기로
    init (habit: RMO_Habit) {
        self.habit = habit //initializing habit
        super.init(nibName: nil, bundle: nil)
        
    }
    
    //위의 코드랑 꼭 같이 가야함
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var habits: Results<RMO_Rate>? = nil
    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        //MARK: tapGesture - Dismisses Keyboard
        //Used Gesture instead of Swipe to prevent from dismissing the HabitDetailVC modal when dismising the keyboard by Swipe.
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(habitTitle)
        scrollContentView.addSubview(habitDesc)
        scrollContentView.addSubview(habitDateTimeBackView)
        scrollContentView.addSubview(habitDateTimeLabel)
        scrollContentView.addSubview(habitDateTime)
        scrollContentView.addSubview(repeatBackView)
        scrollContentView.addSubview(repeatLabel)
        scrollContentView.addSubview(repeatButton)
        scrollContentView.addSubview(repeatTypeLabel)
        scrollContentView.addSubview(successButton)
        scrollContentView.addSubview(failButton)
        scrollContentView.addSubview(deleteButton)
        
        view.backgroundColor = .white
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // backView grid
        scrollContentView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.bottom.equalTo(deleteButton.snp.bottom)
        }
        
        // habitTitle TextField size grid
        habitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(scrollContentView).offset(10)
            make.left.equalTo(scrollContentView).offset(16)
            make.right.equalTo(scrollContentView).offset(-16)
            make.height.equalTo(50)
        }
        habitTitle.layer.borderWidth = 1.5
        habitTitle.layer.borderColor = UIColor.pastGray.cgColor
        
        
        // habitDesc TextView size grid
        habitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(habitTitle.snp.bottom).offset(5)
            make.left.equalTo(habitTitle)
            make.right.equalTo(habitTitle)
            make.height.equalTo(180)
        }
        //MARK: UITextView는 placeholder가 없어서 따로 placeholder처럼 보이게 만든것. Function is at the bottom
        habitDesc.delegate = self
        textViewDidBeginEditing(habitDesc)
        textViewDidEndEditing(habitDesc)
        habitDesc.addPadding()
        habitDesc.addPadding()
        habitDesc.layer.borderWidth = 1.5
        habitDesc.layer.borderColor = UIColor.pastGray.cgColor

        
        // habitDateTimeBackview size grid
        habitDateTimeBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDesc.snp.bottom).offset(10)
            make.left.equalTo(habitTitle)
            make.right.equalTo(habitTitle)
            make.height.equalTo(60)
        }
        
        // habitDateTimeLabel size grid
        habitDateTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateTimeBackView)
            make.left.equalTo(habitDateTimeBackView).offset(5)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // habitDateTime size grid
        habitDateTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(habitDateTimeBackView)
            make.right.equalTo(habitDateTimeBackView).offset(-5)
            make.height.equalTo(habitDateTimeBackView)
        }
        habitDateTime.tintColor = .compBlue

        // repeatBackview size grid
        repeatBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateTimeBackView.snp.bottom)
            make.left.equalTo(habitTitle)
            make.right.equalTo(habitTitle)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // repeatLabel size grid
        repeatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(repeatBackView)
            make.left.equalTo(habitDateTimeLabel)
            make.height.equalTo(60)
        }
        
        // repeatButton size grid
        repeatButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.left.equalTo(repeatTypeLabel).offset(-10)
            make.height.equalTo(32)
            make.right.equalTo(habitDateTime)
        }
        repeatButton.layer.borderWidth = 1.5
        repeatButton.layer.borderColor = UIColor.dateGray.cgColor
        repeatButton.layer.backgroundColor = UIColor.dateGray.cgColor
                
        // repeatTypeLabel size grid
        repeatTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.height.equalTo(40)
            make.right.equalTo(habitDateTime).offset(-10)
        }
        
        // successButton size grid
        successButton.snp.makeConstraints { (make) in
            make.top.equalTo(repeatTypeLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.left.equalTo(scrollContentView).offset(16)
            make.right.equalTo(scrollContentView).offset(-16)
            make.centerX.equalTo(scrollContentView)
        }
        
        // failButton size grid
        failButton.snp.makeConstraints { (make) in
            make.top.equalTo(successButton.snp.bottom).offset(10)
            make.height.equalTo(successButton)
            make.left.equalTo(successButton)
            make.right.equalTo(successButton)
            make.centerX.equalTo(successButton)
        }
        
        // deleteButton size grid
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(failButton.snp.bottom).offset(20)
            make.height.equalTo(successButton)
            make.left.equalTo(successButton)
            make.right.equalTo(successButton)
            make.centerX.equalTo(successButton)
        }
        
   
        // Displaying Title, Desc, DateTime, and Repeat Type from selected Habit cell from MainVC/AllHabitsVC
        habitTitle.text = habit.title
        habitDesc.text = habit.desc
        changeTextColor(habitDesc) // Description이 없을경우 placeholder처럼 꾸미기
        habitDateTime.date = habit.date
        prevRep = habit.repeatType
        
        guard let rt = habit.repeatType else { return }
        let repeatTypeString = String(describing: rt)
        repeatTypeLabel.text = repeatTypeString.capitalized + " >"
        
        let secondDifference = time(current: Date(), habitDate: habit.date)
        let dayDifference = Int(round(secondDifference/(60*60*24)))
        
        if dayDifference > 1 {
            successButton.isHidden = true
            failButton.isHidden = true
        } else {
            successButton.isHidden = false
            failButton.isHidden = false
        }
        
        // Button Actions -  repeatButton, failButton, successButton, deleteButton
        repeatButton.addTarget(self, action: #selector(repeatButtonPressed), for: .touchUpInside)
        failButton.addTarget(self, action: #selector(failButtonPressed), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(successButtonPressed), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //this Makes the screen scroallable
        scrollView.contentSize = CGSize(width: scrollContentView.frame.width,
                                        height: scrollContentView.frame.height)
    }
    
    
    
    //MARK: time function that returns timeInterval
    func time(current: Date, habitDate: Date) -> TimeInterval {
        return current.timeIntervalSinceReferenceDate - habitDate.timeIntervalSinceReferenceDate
    }
    
    
    // MARK: functions for above buttons
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
//        v.delegate = self
//        v.modalPresentationStyle = .pageSheet
//        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    //MARK: Fail Button Pressed
    @objc func failButtonPressed(sender: UIButton){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        //MARK: Fail함에 따라 오늘 Fail한 count를 count_realm에 +.
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return} //
        let taskToUpdate = countRealm[indexNumb]
        
        try! self.localRealm.write {
            taskToUpdate.fail += 1
        }
    
        
        // MARK: RMO_Habit을 지운다. Removes from both TodaysTableView + AllSearchTableView
        
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
                    
            let thisId = habit.id
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
        delegate?.editComp()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func successButtonPressed(sender: UIButton){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        
        //MARK: Success함에 따라 오늘 success한 count를 count_realm에 +. TodayProgressBar에 적용.
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return} //
        let taskToUpdate = countRealm[indexNumb]
        
        try! self.localRealm.write {
            taskToUpdate.success += 1
        }
 
  
        // MARK: RMO_Habit을 지운다. Removes from both TodaysTableView + AllSearchTableView

        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
        
        let thisId = habit.id
            
            try! self.localRealm.write {

                updateHabit.success += 1

                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)

            }
        delegate?.editComp()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @objc func deleteButtonPressed(sender: UIButton){
        
        //MARK: creating Alert with two buttons - Cancel: to cancel delete. Confirm: to Delete
        let alert = UIAlertController(
            title: "\(habit.title)",
            message: "will be Permanently Deleted",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
            
            
            let countRealm = self.localRealm.objects(RMO_Count.self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let today = Date()
            let todayDate = dateFormatter.string(from: today)
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.total -= 1
            }
            
            
            self.dismiss(animated: true) {
                let realm = self.localRealm.objects(RMO_Habit.self)
                let thisId = self.habit.id
                
                //MARK: to remove notification when habit is deleted.
                NotificationManger.SI.removeNoti(id: thisId)
                
                try! self.localRealm.write {
                    let deleteHabit = realm.where {
                        $0.id == thisId
                    }
                    self.localRealm.delete(deleteHabit)
                    self.delegate?.editComp()
                    
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: Making changes to the existing habit
    @objc func saveButtonPressed() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let countRealm = localRealm.objects(RMO_Count.self)
        let realm = localRealm.objects(RMO_Habit.self)
        let rateRealm = self.localRealm.objects(RMO_Rate.self)

        
        //Filtering the habit where ID matches
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let taskToUpdate = realm[indexNumb]
        
        // 원래있던 habit의 date가 변동이 있을경우에만 실행됨.
        if taskToUpdate.date != habitDateTime.date {
            
            //만약 새로운 date에 해당하는 object가 RMO_Count에 없으면 새로 생성
            let countDate = dateFormatter.string(from: habitDateTime.date)
            if !countRealm.contains(where: { $0.date == countDate} )
            {
                let newCount = RMO_Count()
                newCount.date = countDate
                
                try! localRealm.write {
                    localRealm.add(newCount)
                }
                
            }
            
            //예전 habit의 count 수를 -1
            let removeDate = dateFormatter.string(from: taskToUpdate.date)
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == removeDate}) else
            {return}
            let minusCount = countRealm[indexNumb]
            
            try! localRealm.write {
                minusCount.total -= 1
                
            }
            
            //새로운 habit의 count수를 +1
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == countDate}) else
            {return}
            let plusCount = countRealm[indexNumb]
            try! localRealm.write {
                plusCount.total += 1
            }
            
        }
        
        
        guard let rateIndex = rateRealm.firstIndex(where: { $0.habitID == self.habit.id}) else {return}
        let rateToUpdate = rateRealm[rateIndex]

        try! self.localRealm.write {
            
            if repTyp == nil {
                rateToUpdate.repeatType = prevRep
            } else {
                rateToUpdate.repeatType = repTyp
            }
        }
        
        //MARK: updating Habit
        try! self.localRealm.write {
            guard let titleText = habitTitle.text, let descText = habitDesc.text
            else { return }
            
            if habitTitle.text == "" {
                taskToUpdate.title = "No Title"
            } else {
                taskToUpdate.title = titleText
            }
            taskToUpdate.desc = descText

            if repTyp == nil {
                taskToUpdate.repeatType = prevRep
            } else {
                taskToUpdate.repeatType = repTyp
            }
            
            //MARK: If Habit Date was updated
            if taskToUpdate.date != habitDateTime.date {
                print("theyare different")

                taskToUpdate.date = habitDateTime.date
                taskToUpdate.startDate = habitDateTime.date
                taskToUpdate.total = 1
                taskToUpdate.success = 0
                                
            } else {
                print("no changes")
                return
            }
   
        }
        

        // MARK: Update된 Habit을 noti scheduler에. 자동적으로 이 전에 저장된건 지워짐.
        NotificationManger.SI.addScheduleNoti(habit: taskToUpdate)
        self.delegate?.editComp()
        dismiss(animated: true, completion: nil)
        
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
    
    //처음 Habit을 정할때 Desc을 안넣으면 그냥 "Desc of your New Habit"이 value 로서 저장 되는데, 이것을 다시 불러 왔을때 text color가 까만색이 아니라 여전히 placeholder로서 회색이 되게 함.
    func changeTextColor(_ textView: UITextView) {
        
        if textView.text == "Please Add Description" {
            textView.textColor = UIColor.lightGray
            
            textViewDidBeginEditing(habitDesc)
            textViewDidEndEditing(habitDesc)
        }
    }
    
    //MARK: Navi Bar
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        
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
            action: #selector(saveButtonPressed)
        )
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
}




//MARK: Receiving Updated Repeat Type from RepeatVC
extension HabitDetailNoReVC: RepeatVCDelegate {
    
    func didChangeRepeatType(repeatType: RepeatType) {
        repTyp = repeatType
        let repeatTypeString = String(describing: repeatType) //string으로 바꿔줌. repeatType이 원래 있는 type이 아니라서 그냥 String(repeatType) 하면 안되고 "describing:" 을 넣어줘야함
        repeatTypeLabel.text = repeatTypeString.capitalized + " >"
    }
}

