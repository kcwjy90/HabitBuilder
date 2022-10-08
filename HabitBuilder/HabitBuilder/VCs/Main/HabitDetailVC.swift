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
protocol habitDetailVCDelegate: AnyObject {
    func editComp()
}


class HabitDetailVC: UIViewController, UISearchBarDelegate, UITextViewDelegate, ChartViewDelegate{
    
    let localRealm = DBManager.SI.realm!
    
    // Delegate property var 생성
    weak var delegate: habitDetailVCDelegate?
    
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
    
    //==GRAPH RELATED===
    var habitLineChart = LineChartView()
    //==GRAPH RELATED===

    
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
        scrollContentView.addSubview(habitLineChart)
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
            make.left.equalTo(scrollContentView).offset(39)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // habitDateTime size grid
        habitDateTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(habitDateTimeBackView)
            make.right.equalTo(scrollContentView).offset(-34)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // repeatBackview size grid
        repeatBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateTimeBackView.snp.bottom).offset(10)
            make.left.equalTo(habitTitle)
            make.right.equalTo(habitTitle)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // repeatLabel size grid
        repeatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateTimeBackView.snp.bottom).offset(10)
            make.left.equalTo(scrollContentView).offset(39)
            make.height.equalTo(60)
        }
        
        // repeatButton size grid
        repeatButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.width.equalTo(repeatTypeLabel)
            make.height.equalTo(40)
            make.right.equalTo(scrollContentView).offset(-30)
        }
        
        // repeatTypeLabel size grid
        repeatTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.height.equalTo(40)
            make.right.equalTo(scrollContentView).offset(-30)
        }
        
        habitLineChart.snp.makeConstraints{ (make) in
            make.top.equalTo(repeatBackView.snp.bottom).offset(10)
            make.left.equalTo(scrollContentView).offset(50)
            make.right.equalTo(scrollContentView).offset(-50)
            make.height.equalTo(200)
        }
        habitLineChart.center = view.center
        habitLineChart.backgroundColor = .white
        habitLineChart.delegate = self
        
        // successButton size grid
        successButton.snp.makeConstraints { (make) in
            make.top.equalTo(habitLineChart.snp.bottom).offset(30)
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
        
        
        // Button Actions -  repeatButton, failButton, successButton, deleteButton
        repeatButton.addTarget(self, action: #selector(repeatButtonPressed), for: .touchUpInside)
        failButton.addTarget(self, action: #selector(failButtonPressed), for: .touchUpInside)
        successButton.addTarget(self, action: #selector(successButtonPressed), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
    }
    
    
    //Graph Related======================================
    
    //MARK: time function that returns timeInterval
    func time(current: Date, start: Date) -> TimeInterval {
        return current.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
   
        let startHabitDate = habit.startDate
        let currentHabitDate = habit.date
    
        //MARK: Calculating the Date difference. converting seconds to date.
        let secondDifference = time(current: currentHabitDate, start: startHabitDate)
        let dayDifference = Int(round(secondDifference/(60*60*24)))
     
        
        //일단 여기서 스톱
        //역시나 test용. 나중에 y axis에 갈것. success/fail 중 눌러지는것에 반응
        habits = self.localRealm.objects(RMO_Rate.self).filter("habitID == %@", habit.id)
                    
        print("habitdetailvc line 379---------habits--------------------------")
        print(habits)
 
        //FIXME: 만약 오늘 successButton이 눌러 졌으면..0...daydifference, 안눌러 졌으면 0..<dayDifference
        // 1. Set ChartDataEntry
        var entries = [ChartDataEntry]()
        
        guard let habitRates = habits else {return}
        
        for x in 0..<dayDifference{
            entries.append(ChartDataEntry(x: Double(x), y: habitRates[x].rate))
        }
        
        // 2. Set ChartDataSet
        let set = LineChartDataSet(entries: entries, label: "")
        set.colors = ChartColorTemplates.material()
        
        // 3. Set ChartData
        let data = LineChartData(dataSet: set)
        
        // 4. Assign it to the chart’s data
        habitLineChart.data = data
        
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //this Makes the screen scroallable
        scrollView.contentSize = CGSize(width: scrollContentView.frame.width,
                                        height: scrollContentView.frame.height)
    }
    
    
    
    
    //Graph Related======================================
    
    
    
    
    
    
    // MARK: functions for above buttons
    @objc func backButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func repeatButtonPressed(sender: UIButton){
        let v = RepeatVC()
        v.delegate = self
        v.modalPresentationStyle = .pageSheet
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    //FIXME: failButtonPressed, successButtonPressed, deleteButtonPressed all being worked on after fixing how to work realm noti.
    @objc func failButtonPressed(sender: UIButton){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return} //
        let taskToUpdate = countRealm[indexNumb]
        
        try! self.localRealm.write {
            taskToUpdate.fail += 1
        }
        
        
        
        // 만약 repeattype 이 none 이면 그냥 delete. 아닐경우 ongoing만 false로 만든다.
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
        
        if updateHabit.privateRepeatType == 0 {
            
            let thisId = habit.id
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
        } else {
            
            try! self.localRealm.write {
                updateHabit.onGoing = false
            }
        }
        
        delegate?.editComp()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func successButtonPressed(sender: UIButton){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
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
 
  
        // MARK: 만약 repeatType 이 none 이면 RMO_Habit에서 delete. repeatType이 none이 아니면 ongoing만 false로 만든다.
        
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
        
        let thisId = habit.id

        if updateHabit.privateRepeatType == 0 {
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
        } else {
           
//            let rateRealm = self.localRealm.objects(RMO_Rate.self) // not needed?

            let rate = RMO_Rate()

            rate.createdDate = updateHabit.date
            rate.habitID = updateHabit.id
            
            let success = Double(updateHabit.success) + Double(1)
            let total = Double(updateHabit.total)
            print("NewHabitDetailVC line 534, success , total, successrat")
            print(success)
            print(total)
            let successRate = Double(success/total)*100
            print(successRate)
            
            rate.rate = successRate
            
            
            //FIXME: rate append
            try! self.localRealm.write {
                updateHabit.onGoing = false
                updateHabit.success += 1
                localRealm.add(rate)
            }
            
            
            print(updateHabit)
            print(rate)
            print(self.localRealm.objects(RMO_Rate.self))
        }
                
        delegate?.editComp()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func deleteButtonPressed(sender: UIButton){
        
        //MARK: creating Alert with two buttons - Cancel: to cancel delete. Confirm: to Delete
        let alert = UIAlertController(
            title: "Delete this Habit",
            message: "",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
            
            
            let countRealm = self.localRealm.objects(RMO_Count.self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
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
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let countRealm = localRealm.objects(RMO_Count.self)
        let realm = localRealm.objects(RMO_Habit.self)
        
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
        
        
        
        //MARK: updating Habit
        try! self.localRealm.write {
            guard let titleText = habitTitle.text, let descText = habitDesc.text
            else { return }
            taskToUpdate.title = titleText
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
        delegate?.editComp()
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
            textView.text = "Description of your New Habit"
            textView.textColor = UIColor.lightGray
        }
    }
    
    //처음 Habit을 정할때 Desc을 안넣으면 그냥 "Desc of your New Habit"이 value 로서 저장 되는데, 이것을 다시 불러 왔을때 text color가 까만색이 아니라 여전히 placeholder로서 회색이 되게 함.
    func changeTextColor(_ textView: UITextView) {
        
        if textView.text == "Description of your New Habit" {
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
extension HabitDetailVC: RepeatVCDelegate {
    
    func didChangeRepeatType(repeatType: RepeatType) {
        repTyp = repeatType
        let repeatTypeString = String(describing: repeatType) //string으로 바꿔줌. repeatType이 원래 있는 type이 아니라서 그냥 String(repeatType) 하면 안되고 "describing:" 을 넣어줘야함
        repeatTypeLabel.text = repeatTypeString.capitalized + " >"
    }
}

