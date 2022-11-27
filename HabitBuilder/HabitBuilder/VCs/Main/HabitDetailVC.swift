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
    
    // habitDateTime 생성
    lazy var habitDateTime: UILabel = {
        let v = UILabel()
        v.text = ""
        v.font = UIFont.boldSystemFont(ofSize: 20.0)
        v.textColor = .black
        return v
    }()
    
    // repeatBackview 생성
    lazy var currentSuccessRateBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .white
        return v
    }()
    
    // currentSuccessRate 생성
    lazy var currentSuccessRateLabel: UILabel = {
        let v = UILabel()
        v.text = "Current Success Rate :"
        v.font = UIFont.systemFont(ofSize: 17.0)
        v.textColor = .black
        return v
    }()
    
    lazy var currentSuccessRate: UILabel = {
        let v = UILabel()
        v.text = ""
        v.font = UIFont.systemFont(ofSize: 40.0)
        v.textColor = .black
        return v
    }()
    
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
        scrollContentView.addSubview(habitDateTime)
        scrollContentView.addSubview(currentSuccessRateBackView)
        scrollContentView.addSubview(currentSuccessRateLabel)
        scrollContentView.addSubview(currentSuccessRate)
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
            make.height.equalTo(40)
        }
        
        // habitDateTime size grid
        habitDateTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(habitDateTimeBackView)
            make.centerX.equalTo(scrollContentView)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        
        habitLineChart.snp.makeConstraints{ (make) in
            make.top.equalTo(habitDateTime.snp.bottom)
            make.left.equalTo(scrollContentView).offset(15)
            make.right.equalTo(scrollContentView).offset(-15)
            make.height.equalTo(220)
        }
        habitLineChart.center = view.center
        habitLineChart.backgroundColor = .white
        habitLineChart.delegate = self
        habitLineChart.isUserInteractionEnabled = false
        //        habitLineChart.xAxis.granularity = 1
        habitLineChart.xAxis.labelPosition = .bottom
        habitLineChart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        habitLineChart.xAxis.setLabelCount(5, force: false)
        
        habitLineChart.rightAxis.enabled = false
        habitLineChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        habitLineChart.leftAxis.setLabelCount(6, force: false)
        habitLineChart.leftAxis.labelTextColor = .black
        habitLineChart.leftAxis.axisLineColor = .black
        habitLineChart.leftAxis.axisMinimum = 0
        habitLineChart.leftAxis.axisMaximum = 100
        //        habitLineChart.leftAxis.granularity = 1
        
        
        // currentSuccessRateBackView size grid
        currentSuccessRateBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitLineChart.snp.bottom)
            make.left.equalTo(habitTitle)
            make.right.equalTo(habitTitle)
            make.height.equalTo(habitDateTimeBackView)
        }
        
        // currentSuccessRateLabel size grid
        currentSuccessRateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(currentSuccessRate.snp.left).offset(-4)
            make.bottom.equalTo(currentSuccessRate)
            make.height.equalTo(20)
        }
        
        // currentSuccessRate size grid
        currentSuccessRate.snp.makeConstraints { (make) in
            make.top.equalTo(habitLineChart.snp.bottom)
            make.centerY.equalTo(currentSuccessRateBackView)
            make.height.equalTo(40)
            make.right.equalTo(currentSuccessRateBackView)
        }
        
        // successButton size grid
        successButton.snp.makeConstraints { (make) in
            make.top.equalTo(currentSuccessRateBackView.snp.bottom).offset(10)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let habitTime = dateFormatter.string(from: habit.date)
        
        
        guard let repeatType = habit.repeatType else { return }
        switch repeatType {
        case .none:
            habitDateTime.text = "Everyday at \(habitTime)"
            
        case .daily:
            habitDateTime.text = "Everyday at \(habitTime)"
            
        case .weekly:
            dateFormatter.dateFormat = "EEEE";
            let habitDay = dateFormatter.string(from: habit.date);
            habitDateTime.text = "Every \(habitDay) at \(habitTime)"
            
        case .monthly:
            dateFormatter.dateFormat = "d";
            let habitDay = dateFormatter.string(from: habit.date);
            
            var day = ""
            
            switch habitDay {
            case "1": day = "\(habitDay)st"
            case "2": day = "\(habitDay)nd"
            case "3": day = "\(habitDay)rd"
            case "21": day = "\(habitDay)st"
            case "22": day = "\(habitDay)nd"
            case "23": day = "\(habitDay)rd"
            case "31": day = "\(habitDay)st"
            default: day = "\(habitDay)th"
                
            }
            habitDateTime.text = "Every \(day) of the Month at \(habitTime)"
            
        case .yearly:
            dateFormatter.dateFormat = "MM/d";
            let habitDay = dateFormatter.string(from: habit.date);
            habitDateTime.text = "Every \(habitDay) at \(habitTime)"
        }
        
        
        //MARK: If Habit already completed, hide Success/Fail buttons
        if habit.onGoing == false {
            //            || habit.date > Date() {
            successButton.isHidden = true
            failButton.isHidden = true
        } else {
            successButton.isHidden = false
            failButton.isHidden = false
        }
        
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
        var dayDifference = Int(round(secondDifference/(60*60*24)))
        
        
        //MARK: For calculating difference in month. StartDate과 CurrentHabit을 비교
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let currentDate = calendar.startOfDay(for: currentHabitDate)
        let startDate = calendar.startOfDay(for: startHabitDate)
        
        let monthDiff = calendar.dateComponents([.month], from: startDate, to: currentDate)
        guard let months = monthDiff.month else {return}
        print(months)
        
        
        let todayDate = calendar.startOfDay(for: Date())
        let dayDiff = calendar.dateComponents([.day], from: todayDate, to: currentDate)
        guard let days = dayDiff.day else {return}
        print(days)
        
        var numbMonths: Int
        
        
        if months == 0 {
            //MARK: answer for Step1 = if StartHabitDate == currentHabitDate, then count is numbMonths = 0
            numbMonths = 0
            
        } else {
            //MARK: answer for Step2 = if currentHabitDate > today, then calculate the diff btwn today and currentHabitDate
            if 0 == 0 {
                
            } else {
                
            }
            
        }
        
        
        
        //일단 여기서 스톱
        //역시나 test용. 나중에 y axis에 갈것. success/fail 중 눌러지는것에 반응
        habits = self.localRealm.objects(RMO_Rate.self).filter("habitID == %@", habit.id)
        
        print("habitdetailvc line 379---------habits--------------------------")
        print(habits)
        
        
        if habits!.count == 0 {
            print("0")
        } else {
            //MARK: 만약 오늘 success/fail이 눌러 졌으면..0...daydifference, 안눌러 졌으면 0..<dayDifference
            // 1. Set ChartDataEntry
            var entries = [ChartDataEntry]()
            var xAxis: [String] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YY"
            
            
            //MARK: changing dayDifference depending on what type of repeat type habit is
            guard let habitRates = habits else {return}
            
            guard let repeatType = habitRates[0].repeatType else { return }
            switch repeatType {
            case .none:
                print("none")
            case .daily:
                print("daily")
            case .weekly:
                dayDifference = Int(floor(Double(dayDifference/7)))
            case .monthly:
                dayDifference = months
            case .yearly:
                print("yearly")
            }
            
            
            switch habit.onGoing {
                
                //오늘의 하빗을 컴플리트 했으니(onGoing == false) 오늘 날짜의 rate이 뜬다.
            case false :
                for x in 0...dayDifference{
                    entries.append(ChartDataEntry(x: Double(x), y: habitRates[x].rate))
                    xAxis.append(dateFormatter.string(from: habitRates[x].createdDate))
                }
                
                let last = entries.last
                
                //Updating last rate as % in currentSuccessRate
                if last == nil {
                    currentSuccessRate.text = "0.0%"
                } else {
                    let lastRate = habitRates[dayDifference].rate
                    currentSuccessRate.text = "\(String(format: "%.1f", Double(lastRate)))%"
                }
                
                //아직 오늘의 하빗을 컴플리트 하지 않았으니 (onGoing == true) 오늘 날짜의 rate은 뜨지 않는다.
            default :
                for x in 0..<dayDifference{
                    entries.append(ChartDataEntry(x: Double(x), y: habitRates[x].rate))
                    xAxis.append(dateFormatter.string(from: habitRates[x].createdDate))
                }
                let last = entries.last
                
                //Updating last rate as % in currentSuccessRate.
                if last == nil {
                    currentSuccessRate.text = "0.0%"
                } else {
                    let lastRate = habitRates[dayDifference-1].rate
                    currentSuccessRate.text = "\(String(format: "%.1f", Double(lastRate)))%"
                }
            }
            
            //Formatting xAxis from Numb to String
            habitLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxis)
            
            
            // 2. Set ChartDataSet
            let set = LineChartDataSet(entries: entries, label: "% Succeeded")
            // Makes the line smooth, changes radius of circle = 3 + line thickness = 2
            set.mode = .cubicBezier
            set.circleRadius = 3
            set.lineWidth = 2
            //            set.drawCirclesEnabled = false //Removes points on the graph
            
            // 3. Set ChartData
            let data = LineChartData(dataSet: set)
            data.setDrawValues(false) //Removes label
            print(xAxis)
            
            // 4. Assign it to the chart’s data
            habitLineChart.data = data
            
            if xAxis.count <= 10 {
                habitLineChart.xAxis.axisMaximum = 10
                habitLineChart.xAxis.axisMinimum = 0
            } else {
                habitLineChart.xAxis.axisMaximum = Double(xAxis.count + 1)
                habitLineChart.xAxis.axisMinimum = 0
            }
            
        }
        
        
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
    
    //MARK: fail button pressed
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
        
        // MARK: RepeatType isn't 0, therefore, won't  be deleted from the AllHabitSearchView.
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
        
        try! self.localRealm.write {
            updateHabit.onGoing = false
            updateHabit.todaysResult = 2
        }
        
        
        print(self.localRealm.objects(RMO_Habit.self))
        print(self.localRealm.objects(RMO_Rate.self))
        
        
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
        let rateRealm = self.localRealm.objects(RMO_Rate.self)
        
        
        
        //MARK: Success함에 따라 오늘 success한 count를 count_realm에 +. TodayProgressBar에 적용.
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return} //
        let taskToUpdate = countRealm[indexNumb]
        
        print("TASK TO UPDATE +==========================\(taskToUpdate)")
        try! self.localRealm.write {
            taskToUpdate.success += 1
            
        }
        
        
        
        // MARK: RepeatType isn't 0, therefore, won't  be deleted from the AllHabitSearchView.
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let updateHabit = realm[indexNumb]
        
        print("updateHabit +==========================\(updateHabit)")
        
        guard let indexNumb = rateRealm.firstIndex(where: { $0.habitID == self.habit.id && $0.createdDate == self.habit.date}) else
        {return}
        let updateRate = rateRealm[indexNumb]
        
        print("updateRate ===========================================\(updateRate)")
        
        
        let success = Double(updateHabit.success) + Double(1)
        let total = Double(updateHabit.total)
        let successRate = Double(success/total)*100
        
        
        
        try! self.localRealm.write {
            updateHabit.onGoing = false
            updateHabit.success += 1
            updateHabit.todaysResult = 1
            updateRate.rate = successRate
        }
        
        print(self.localRealm.objects(RMO_Habit.self))
        print(self.localRealm.objects(RMO_Rate.self))
        
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
            let habitRealm = self.localRealm.objects(RMO_Habit.self)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let today = Date()
            let todayDate = dateFormatter.string(from: today)
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            guard let habitIndex = habitRealm.firstIndex(where: { $0.id == self.habit.id}) else
            {return} //
            let habitToUpdate = habitRealm[habitIndex]
            
            //updating Final Total and Final Percent recorded in the habit about to be deleted
            let updatedTotal = taskToUpdate.total - 1
            var updatedSuccess: Int
            
            //remove 할때 만약에 success 된 habit일 경우 지우면 success도 지워진다.
            switch habitToUpdate.todaysResult {
            case 1 :
                updatedSuccess = taskToUpdate.success - 1
            default:
                updatedSuccess = taskToUpdate.success
            }
            
            let updatedFinalPercent = Float(updatedSuccess)/Float(updatedTotal)
            
            //Removing total from CountRealm
            try! self.localRealm.write {
                taskToUpdate.total = updatedTotal
                taskToUpdate.success = updatedSuccess
                taskToUpdate.finalPercent = updatedFinalPercent
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
        
        //Filtering the habit where ID matches
        guard let indexNumb = realm.firstIndex(where: { $0.id == self.habit.id}) else
        {return}
        let taskToUpdate = realm[indexNumb]
        
        
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







