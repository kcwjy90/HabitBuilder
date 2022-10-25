//
//  MainVC.swift
//  HabitBuilder
//
//  Created by CW on 1/25/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import UserNotifications

//realm Noti 에서 쓰는거
enum NewHabitVCStatus {
    case initialize
    case loading
    case loadingSucceed
    case error
}


class MainVC: UIViewController {
    
    let localRealm = DBManager.SI.realm!
    
    //MARK: ====realm Noti 에서 쓰는거===
    deinit {
        print("deinit - NewHabitVC")
        notificationToken?.invalidate()
    }
    
    var status: NewHabitVCStatus = .initialize
    var notificationToken: NotificationToken? = nil
    //===components needed for realm Noti===
    
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // dateLabelBackView 생성
    lazy var dateLabelBackView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // dateLabel 생성
    lazy var dateLabel: UILabel = {
        let autoDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDate = dateFormatter.string(from: autoDate)
        let v = UILabel()
        v.text = currentDate
        v.font = UIFont.boldSystemFont(ofSize: 18.0)
        return v
    }()
    
    // progressLabel 생성
    lazy var progressLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        return v
    }()
    
    // perecentLabel 생성
    lazy var percentLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        return v
    }()
    
    // progressImage 생성
    lazy var progressImage: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    // progressBar 생성
    lazy var todayProgressBar: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .bar)
        //        v.setProgress(0.5, animated: true)
        v.trackTintColor = .cellGray
        v.tintColor = .todayBlue
        return v
    }()
    
    // progressBar에 필요한 count
    var counts = [0,0,0]
    
    // todaysHabitTablewView 생성
    lazy var todaysHabitTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .white
        v.separatorStyle = .none //removes lines btwn tableView cells
        v.separatorColor = .clear
        return v
    }()
    
    
    
    // RMO_Habit에서 온 data를 result로 가져온다?
    var habits: Results<RMO_Habit>? = nil
    
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        view.addSubview(backView)
        view.backgroundColor = .white
        backView.addSubview(dateLabelBackView)
        dateLabelBackView.addSubview(dateLabel)
        backView.addSubview(todaysHabitTableView)
        backView.addSubview(progressImage)
        backView.addSubview(progressLabel)
        backView.addSubview(percentLabel)
        backView.addSubview(todayProgressBar)
        
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // dateLabelBackView backveiw grid
        dateLabelBackView.snp.makeConstraints{ (make) in
            make.top.left.right.equalTo(backView)
            make.height.equalTo(47)
        }
        
        // dateLabel grid
        dateLabel.snp.makeConstraints{ (make) in
            make.centerY.equalTo(dateLabelBackView).offset(3)
            make.right.equalTo(dateLabelBackView).offset(-10)
        }
        
        // todaysHabitTableView grid
        todaysHabitTableView.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabelBackView.snp.bottom)
            make.left.right.equalTo(backView)
            make.bottom.equalTo(progressImage.snp.top)
        }
        
        
        progressImage.snp.makeConstraints{ (make) in
            make.top.equalTo(todaysHabitTableView.snp.bottom)
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.left.equalTo(backView).offset(10)
            make.bottom.equalTo(backView)
        }
        progressImage.image = UIImage(named: "PF")
        
        percentLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(todaysHabitTableView.snp.bottom)
            make.height.equalTo(20)
            make.left.equalTo(todayProgressBar)
            make.right.equalTo(todayProgressBar)
            make.bottom.equalTo(todayProgressBar.snp.top)
        }
        
//        progressLabel.snp.makeConstraints{ (make) in
//            make.top.equalTo(todayProgressBar)
//            make.height.equalTo(20)
//            make.left.equalTo(todayProgressBar).offset(5)
//            make.right.equalTo(todayProgressBar)
//            make.bottom.equalTo(todayProgressBar)
//        }
        
        todayProgressBar.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
            make.left.equalTo(progressImage.snp.right).offset(10)
            make.right.equalTo(backView).offset(-10)
            make.bottom.equalTo(backView)
        }
        
       
        
        
        updateOngoing()
        setRealmNoti()
        updateProgressBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    //MARK: when the app was in the background but day has passed, app needs to be refreshed
    @objc func applicationWillEnterForeground(_ notification: NSNotification) {
        
        if checkTheDay() == true {
            let realm = self.localRealm.objects(RMO_Habit.self).filter("onGoing == False")
            
            try! self.localRealm.write {
                realm.setValue(true, forKey: "onGoing")
            }
            
            initHabits()
            setRealmNoti()
            updateProgressBar()
            refreshTodaysDate()

        } else {
            print("")
        }
        
    }
    
    //MARK: when app enters foreground, refreshes today's date
    func refreshTodaysDate () {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDate = dateFormatter.string(from: Date())
        dateLabel.text = currentDate
        dateLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
    }
    
    //MARK: Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addItem)
        )
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swip to dismiss tableView
        todaysHabitTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    
    //MARK: Navi Bar에 있는 'Add' Button을 누르면 작동함.
    @objc func addItem(){
        let v = NewHabitVC()
        let newHabitVCNavi = UINavigationController(rootViewController: v)
        newHabitVCNavi.modalPresentationStyle = .pageSheet
        v.modalPresentationStyle = .pageSheet
        present(newHabitVCNavi, animated:true)   // modal view 가능케 하는 코드
    }
    
}



//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let habit = habits?[indexPath.row] else { return }
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다, based on RepeatType
        if habit.privateRepeatType == 0 {
            //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
            let habitDetailNoReVC = HabitDetailNoReVC(habit: habit)
            let habitDetailVCNavi = UINavigationController(rootViewController: habitDetailNoReVC)
            habitDetailVCNavi.modalPresentationStyle = .pageSheet
            present(habitDetailVCNavi, animated:true)
            
        } else {
           
            let habitDetailVC = HabitDetailVC(habit: habit)
            let habitDetailVCNavi = UINavigationController(rootViewController: habitDetailVC)
            habitDetailVCNavi.modalPresentationStyle = .pageSheet
            present(habitDetailVCNavi, animated:true)
        }
  
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let theHabits = self.habits else { return 0 }
      
        //MARK: image display when tableView is empty
        if theHabits.count == 0 {
            let image = UIImage(named: "Add")
            let noDataImage = UIImageView(image: image)
            //FIXME: How do I resize? CGRect doesn't seem to do anything?
            noDataImage.layer.opacity = 0.5
            tableView.backgroundView = noDataImage
            tableView.separatorStyle = .none

            return 0
            
        } else {
            tableView.backgroundView = .none
            return theHabits.count
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0 //Choose your custom row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell,
              let theHabits = self.habits
        else {
            return UITableViewCell()
        }
        
        
        let newHabit = theHabits[indexPath.row]
        let title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "h:mm a"
        let newHabitDate = dateFormatter.string(from: date)
        
        switch newHabit.privateRepeatType {
        case 1 : cell.titleBackground.backgroundColor = .pureGreen
        case 2 : cell.titleBackground.backgroundColor = .pureOrange
        case 3 : cell.titleBackground.backgroundColor = .pureBlue
        case 4 : cell.titleBackground.backgroundColor = .purePurple
        default: cell.titleBackground.backgroundColor = .pureGray
        }
        
        cell.backgroundColor = .white
        
        cell.newHabitTitle.text = title
        cell.newHabitDesc.text = desc
        cell.newHabitTime.text = newHabitDate
        
        return cell
    }
    
    
    
    
    
    // MARK: CheckTheDay bool에 따라서 RMO_Habit의 onGoing을 업데이트
    func updateOngoing() {
        
        if checkTheDay() == true {
            //만약 이게 그 다음날이 처음 실행 하는거면 오늘 처음 run 하는 거면
            //onGoing 이 false인 애들을 true로 바꿔줌
            let realm = self.localRealm.objects(RMO_Habit.self).filter("onGoing == False")
            
            try! self.localRealm.write {
                realm.setValue(true, forKey: "onGoing")
            }
            
            initHabits()
            
            print("===========================true=============")
            print(self.localRealm.objects(RMO_Habit.self))

            
        } else {
            //아직 다음날이 아니라서 아무것도 안함
            print("===========================false=============")
            print(self.localRealm.objects(RMO_Habit.self))
            print(self.localRealm.objects(RMO_Count.self))
            return
        }
        
    }
    
    
    //MARK: time function that returns timeInterval
    func time(current: Date, habitDate: Date) -> TimeInterval {
        return current.timeIntervalSinceReferenceDate - habitDate.timeIntervalSinceReferenceDate
    }
    
    //MARK: Intializing Habits. Updates day of the repeated habits to todays
    func initHabits() {
        
        //To add today's habit's count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        let rateRealm = self.localRealm.objects(RMO_Rate.self)
        
        
        //all counts of repeated habits that have dates changed to today will come here and be added to countrealm at the bottom
        var counts = 0
        
        
        //TEST 용
        //        let calendar = Calendar.current
        //        let tmr = calendar.date(byAdding: .day, value: 1, to: Date())
        
        //daily repeat
        let dailyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 1")
        for dailyHabit in dailyHabits {
            
            let currentHabitDate = dailyHabit.date
            
            //MARK: Calculating the Date difference between today's date & habit.date so we can add that many days to exisitng habit.date
            //MARK: Converting seconds to date.
            let secondDifference = time(current: today, habitDate: currentHabitDate)
            let dayDifference = Int(round(secondDifference/(60*60*24)))
            
            //MARK: Calculating Total number of days of Habit being live. today - startdate + 1
            let totalSecondDifference = time(current: today, habitDate: dailyHabit.startDate)
            let totalDayDifference = Int(round(totalSecondDifference/(60*60*24)))
            let newTotal = totalDayDifference + 1
            
            //MARK: 접속하지 않았던 비어있던 날짜에 rate 집어넣어 주기 (예> 10/1 마지막 접속 sucess (100%).그 다음 접속은 10/4. 그러면 접속하지 않은 10/2 = 50%, 10/3 = 33%. 접속한 날짜인 10/4는 일단 무조건 fail 로 간주한다. 그래서 user가 rate을 하지 않거나 app을 열기만 하고 아무것도 하지 않은경우 자동적으로 fail이 됨 (25%). cell을 touch해서 success를 할 경우만 rate이 올라감.
                
                for day in 1...dayDifference{
                    
                    print(dayDifference)
                    print(day)
                    print(dailyHabit.success)
                    print(dailyHabit.total)
                    let success = Double(dailyHabit.success)
                    let total = Double(dailyHabit.total) + Double(day)
                    print(total)
                    
                    let successRate = Double(success/total)*100
                    print(successRate)
                    
                    let oneMoreDay = Calendar.current.date(byAdding: .day,  value: day, to: currentHabitDate)
                    guard let omd = oneMoreDay else {return}
                    
                    let habitRate = RMO_Rate()
                    
                    habitRate.habitID = dailyHabit.id
                    habitRate.createdDate = omd
                    habitRate.rate = successRate
                    
                    try! self.localRealm.write {
                        localRealm.add(habitRate)
                    }
                    
                    print("habitrate-----MainVC line 400--------------------------for each missing days")
                    print(habitRate)
                    print(self.localRealm.objects(RMO_Habit.self))
                    print(self.localRealm.objects(RMO_Rate.self))
                    
                }
                
          
            
            if let newHabitDate = Calendar.current.date(byAdding: .day,  value: dayDifference, to: currentHabitDate) {
                try! self.localRealm.write {
                    dailyHabit.date = newHabitDate
                    dailyHabit.total = newTotal
                    
                }
            }
            
            print("================MainVC=========================total rateREALM")
            print(rateRealm)
            
            print("THIS HABIT BEING PRINTED HERE=-------------------------------")
            
            
            
            counts += 1
            print("daily repeat 357-----------------------------------------------------------")
            print(counts)
        }
        
        //weekly repeat
        let weeklyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 2")
        for weeklyHabit in weeklyHabits {
            
            
            let currentHabitDate = weeklyHabit.date

            //MARK: Calculating the Date difference between today's date & habit.date so we can add that many days to exisitng habit.date
            //MARK: Converting seconds to date.
            let secondDifference = time(current: today, habitDate: currentHabitDate)
            let dayDifference = Int(round(secondDifference/(60*60*24)))
            print("today ==========================\(today)")
            print("current habitDay ==========================\(currentHabitDate)")
            print("secondDIfference  ==========================\(secondDifference)")


            print("Daydifference NOT div by 7==========================\(dayDifference)")
            if dayDifference%7 == 0 && dayDifference != 0 {
                print("Daydifference divisble by 7 ==========================\(dayDifference)")
                let multiplesOfSeven = dayDifference/7
                print("multiplesOfSEven ==========================\(multiplesOfSeven)")


                var dateComponent = DateComponents()
                dateComponent.day = dayDifference
                
                              
                if let newHabitDate = Calendar.current.date(byAdding: dateComponent, to: weeklyHabit.date) {
                    try! self.localRealm.write {
                        weeklyHabit.total += multiplesOfSeven
                        weeklyHabit.date = newHabitDate
                    }
                    print("newHabitDate ==========================\(newHabitDate)")
                    print("weeklyHabit.total ==========================\(weeklyHabit.total)")

                }
                
                counts += 1
                print("counts ==========================\(counts)")

            } else {
                print("False")
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
            
        }
        
        //monthly repeat
        let monthlyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 3")
        for monthlyHabit in monthlyHabits {
            
            
            //If current Habit + 1 month == today's date...
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateComponent = DateComponents()
            dateComponent.month = 1
            let futureMonth = Calendar.current.date(byAdding: dateComponent, to: monthlyHabit.date)
            
            guard let monthlyDate = futureMonth else { return }
            let habitMonthAwayString = dateFormatter.string(from: monthlyDate)
            let todayString = dateFormatter.string(from: Date())
            
            
            //Then execute
            if todayString == habitMonthAwayString {
                
                
                if let newHabitDate = Calendar.current.date(byAdding: dateComponent, to: monthlyHabit.date) {
                    
                    print("NEWHABITDATE+=======================================")
                    print(newHabitDate)
                    try! self.localRealm.write {
                        monthlyHabit.date = newHabitDate
                    }
                }
                
                counts += 1
                print("habitmonth --- \(habitMonthAwayString)")
                print("monthAway --- \(habitMonthAwayString)")
                print("mon repeat 438-----------------------------------------------------------")
                print(counts)
                
            } else {
                print("FAlse")
                print(todayString)
                print(habitMonthAwayString)
                print(monthlyHabit.date)
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
            
        }
        
        //yearly repeat
        let yearlyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 4")
        for yearlyHabit in yearlyHabits {
            
            
            //If current Habit + 1 week == today's date...
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateComponent = DateComponents()
            dateComponent.year = 1
            let futureYear = Calendar.current.date(byAdding: dateComponent, to: yearlyHabit.date)
            
            guard let yearlyDate = futureYear else { return }
            let habitYearAwayString = dateFormatter.string(from: yearlyDate)
            let todayString = dateFormatter.string(from: Date())
            
            
            //Then execute
            if todayString == habitYearAwayString {
                
                if let newHabitDate = Calendar.current.date(byAdding: dateComponent, to: yearlyHabit.date) {
                    try! self.localRealm.write {
                        yearlyHabit.date = newHabitDate
                    }
                }
                
                counts += 1
                print("yearly repeat 484-----------------------------------------------------------")
                print(counts)
                
            } else {
                print("FAlse")
                print(todayString)
                print(habitYearAwayString)
                print(yearlyHabit.date)
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
        }
        
        print("final counts-----------------------------------------------------------")
        print(counts)
        
        if !countRealm.contains(where: { $0.date == todayDate} )
        {
            let newCount = RMO_Count()
            newCount.date = todayDate
            
            try! localRealm.write {
                localRealm.add(newCount)
                
            }
        }
        
        guard let inNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return}
        let existCount = countRealm[inNumb]
        
        try! localRealm.write {
            existCount.total += counts
            
        }
        
    }
    
    
    
    
    //MARK: setting Realm Notification function
    func setRealmNoti() {
        
        
        let today = Date()

        guard let beginningOfToday = Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: today),
            month: Calendar.current.component(.month, from: today),
            day: Calendar.current.component(.day, from: today),
            hour: 0,
            minute: 0,
            second: 0)),
              
                let endOfToday = Calendar.current.date(from: DateComponents(
                    year: Calendar.current.component(.year, from: today),
                    month: Calendar.current.component(.month, from: today),
                    day: Calendar.current.component(.day, from: today),
                    hour: 23,
                    minute: 59,
                    second: 59))
                
        else { return }
        
        habits = self.localRealm.objects(RMO_Habit.self).filter("date >= %@ AND date <= %@", beginningOfToday, endOfToday).filter("onGoing == True").sorted(byKeyPath: "date", ascending: true)
        //.sorted뒤에 나오는게 시간에 맞춰서 순서를 바꿔주는 핵심
        
        //notificationToken 은 ViewController 가 닫히기 전에 꼭 release 해줘야 함. 에러 나니까 코멘트
        guard let theHabits = self.habits else {return}
        notificationToken = theHabits.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.todaysHabitTableView else { return }
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                
                
                // Query results have changed, so apply them to the UITableView
                tableView.performBatchUpdates({
                    
                    // Always apply updates in the following order: deletions, insertions, then modifications.
                    // Handling insertions before deletions may result in unexpected behavior.
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    
                    
                }, completion: { finished in
                })
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            
            //updating ProgressBar after making changes in RMO_Habit
            self?.updateProgressBar()
        }
        
    }
    
    
    
    // MARK: userDefault에 오늘 날짜 저장/체크하기
    func checkTheDay() -> Bool {
        
        let executedToday = UserDefaults.standard.object(forKey: "exeToday")
        if let exeToday: Date = executedToday as? Date {
            
            let today = Date()
            
            //FIXME: Need to somehow compare the dates (only days), not strings
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let todayString = dateFormatter.string(from: today)
            let exeString = dateFormatter.string(from: exeToday)
            
            if todayString != exeString {
                //          if today > exeToday {
                
                // 다음날 실행
                UserDefaults.standard.set(today, forKey: "exeToday")
                print("today는 \(today)")
                print("exeToday는 \(exeToday)")
                
                return true
            }
            
            else {
                // 오늘 첫 실행이 아님
                return false
            }
            
        } else {
            //앱 처음 실행
            let today = Date()
            UserDefaults.standard.set(today, forKey: "exeToday")
            return false
        }
    }
    
    
    
    
    //MARK: updating todayProgressBar
    
    func updateProgressBar() {
        

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        
        //MARK: today's piechart에 들어가는 count들을 넣어주는 코드
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return}
        let todayCount = countRealm[indexNumb] //todayCount = 오늘 날짜에 해당하는 RMO_Count obj
        counts[0] = todayCount.success
        counts[1] = todayCount.fail
        counts[2] = todayCount.total
        
        let progress = Float(counts[0])/Float(counts[2])
        
//        try! self.localRealm.write {
  //            todayCount.finalPercent = progress
  //        }

            
//        progressLabel.text = "\(String(counts[0])) / \(String(counts[2]))"
        
        if counts[2] == 0 {
            percentLabel.text = "Please Add Your Habits"
        } else {
            percentLabel.text = "\(String(format: "%.1f", progress*100))% Succeeded!"
        }
        todayProgressBar.progress = progress
        
    }
    
    
    
    
    
    
    //MARK: SWIPE action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //FIXME: 나중에 dateformatter 얘들 scope을 바꿔야지
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        //MARK: Habit을 Success 했으면..
        let success = UIContextualAction(style: .normal, title: "Success") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Success")
            
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 success를 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.success += 1
            }
            print("Success 한 count - \(self.localRealm.objects(RMO_Count.self))")
            
            var habit: RMO_Habit
            
            guard let h = self.habits else {return}
            habit = h[indexPath.row]
            
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
            
        }
        success.backgroundColor = .systemBlue
        
        //MARK: Habit을 Remove 했으면
        let remove = UIContextualAction(style: .normal, title: "Remove") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Remove")
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 remove를 +1 한다
            
            let alert = UIAlertController(
                title: "Delete this Habit",
                message: "",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
                
                guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
                {return} //
                let taskToUpdate = countRealm[indexNumb]
                
                try! self.localRealm.write {
                    taskToUpdate.remove += 1
                }
                print(self.localRealm.objects(RMO_Count.self))
                
                
                var habit: RMO_Habit
                
                guard let h = self.habits else {return}
                habit = h[indexPath.row]
                
                
                
                let thisId = habit.id
                
                try! self.localRealm.write {
                    
                    let deleteHabit = realm.where {
                        $0.id == thisId
                    }
                    self.localRealm.delete(deleteHabit)
                }
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
        remove.backgroundColor = .systemOrange
        
        //MARK: Habit을 Fail 했으면..
        let fail = UIContextualAction(style: .destructive, title: "Fail") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Fail")
            
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 fail을 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.fail += 1
            }
            print(self.localRealm.objects(RMO_Count.self))
            
            
            var habit: RMO_Habit
            
            guard let h = self.habits else {return}
            habit = h[indexPath.row]
            
            
            
            let thisId = habit.id
            
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
            
        }
        fail.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [remove, fail, success])
        
    }
    
}



