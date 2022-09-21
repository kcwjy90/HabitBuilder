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
        v.backgroundColor = .dateGreen
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
    
    // todaysHabitTablewView 생성
    lazy var todaysHabitTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .dateGreen
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
            make.left.right.bottom.equalTo(backView)
        }
        todaysHabitTableView.separatorStyle = .none //removes lines btwn tableView cells
        
        updateOngoing()
        setRealmNoti()
        
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
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
}



//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let habit = habits?[indexPath.row] else { return }
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let theHabits = self.habits else { return 0 }
        return theHabits.count
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
        case 1 : cell.titleBackground.backgroundColor = .pureRed
        case 2 : cell.titleBackground.backgroundColor = .pureOrange
        case 3 : cell.titleBackground.backgroundColor = .pureBlue
        case 4 : cell.titleBackground.backgroundColor = .purePurple
        default: cell.titleBackground.backgroundColor = .dateGreen
        }
        
        cell.backgroundColor = .white
        
        cell.newHabitTitle.text = title
        cell.newHabitDesc.text = desc
        cell.newHabitDate.text = newHabitDate
        
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
            
            deletePrev()
            initHabits()
            
            print("===========================true=============")
            
        } else {
            //아직 다음날이 아니라서 아무것도 안함
            print("===========================false=============")
            
            return
        }
        
    }
    
    
    //MARK: Auto-deleting habits that are 2 days old
    func deletePrev() {
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        let today = Date()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: midnight)
        
        guard let ystday = yesterday else {return}
        
        // MARK: repeatType none이 애들은 이틀 이상 되면 delete
        // FIXME: perhaps all the repeated habits should just respawn
        try! self.localRealm.write {
            
            let deleteHabit = realm.where {
                $0.date < ystday && $0.privateRepeatType == 0
            }
            self.localRealm.delete(deleteHabit)
        }
    }
    
    
    //MARK: Intializing Habits. Updates day of the repeated habits to todays
    //FIXME: only targeting habits with repeattype 1. need to incorporate all other types
    
    func initHabits() {
        
        //daily repeat
        let dailyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 1")
        for dailyHabit in dailyHabits {
            
            //Grabbing today's date - day only
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: Date())
            let intDay = Int(day) ?? 0
            
            if let newHabitDate = Calendar.current.date(bySetting: .day, value: intDay, of: dailyHabit.date) {
                try! self.localRealm.write {
                    dailyHabit.date = newHabitDate
                }
            }
        }
        
        //weekly repeat
        let weeklyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 2")
        for dailyHabit in weeklyHabits {
            
            //If current Habit + 1 week == today's date...
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateComponent = DateComponents()
            dateComponent.day = 7
            let futureWeek = Calendar.current.date(byAdding: dateComponent, to: dailyHabit.date)
            
            guard let weeklyDate = futureWeek else { return }
            let habitWeekAwayString = dateFormatter.string(from: weeklyDate)
            let todayString = dateFormatter.string(from: Date())
            
            
            //Then execute
            if todayString == habitWeekAwayString {
                
                //Grabbing today's date - day only
                dateFormatter.dateFormat = "dd"
                let day = dateFormatter.string(from: Date())
                let intDay = Int(day) ?? 0
                
                if let newHabitDate = Calendar.current.date(bySetting: .day, value: intDay, of: dailyHabit.date) {
                    try! self.localRealm.write {
                        dailyHabit.date = newHabitDate
                    }
                }
                
            } else {
                print("FAlse")
                print(todayString)
                print(habitWeekAwayString)
                print(dailyHabit.date)
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
            
        }
        
        //monthly repeat
        let monthlyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 3")
        for dailyHabit in monthlyHabits {
            
            
            //If current Habit + 1 month == today's date...
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateComponent = DateComponents()
            dateComponent.month = 1
            let futureMonth = Calendar.current.date(byAdding: dateComponent, to: dailyHabit.date)
            
            guard let monthlyDate = futureMonth else { return }
            let habitMonthAwayString = dateFormatter.string(from: monthlyDate)
            let todayString = dateFormatter.string(from: Date())
            
            
            //Then execute
            if todayString == habitMonthAwayString {
                
                //Grabbing today's date - day only
                dateFormatter.dateFormat = "dd"
                let day = dateFormatter.string(from: Date())
                let intDay = Int(day) ?? 0
                
                if let newHabitDate = Calendar.current.date(bySetting: .day, value: intDay, of: dailyHabit.date) {
                    try! self.localRealm.write {
                        dailyHabit.date = newHabitDate
                    }
                }
                
            } else {
                print("FAlse")
                print(todayString)
                print(habitMonthAwayString)
                print(dailyHabit.date)
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
            
        }
        
        //yearly repeat
        let yearlyHabits = self.localRealm.objects(RMO_Habit.self).filter("privateRepeatType == 4")
        for dailyHabit in yearlyHabits {
            
            
            //If current Habit + 1 week == today's date...
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var dateComponent = DateComponents()
            dateComponent.year = 1
            let futureYear = Calendar.current.date(byAdding: dateComponent, to: dailyHabit.date)
            
            guard let yearlyDate = futureYear else { return }
            let habitYearAwayString = dateFormatter.string(from: yearlyDate)
            let todayString = dateFormatter.string(from: Date())
            
            
            //Then execute
            if todayString == habitYearAwayString {
                
                //Grabbing today's date - day only
                dateFormatter.dateFormat = "dd"
                let day = dateFormatter.string(from: Date())
                let intDay = Int(day) ?? 0
                
                if let newHabitDate = Calendar.current.date(bySetting: .day, value: intDay, of: dailyHabit.date) {
                    try! self.localRealm.write {
                        dailyHabit.date = newHabitDate
                    }
                }
                
            } else {
                print("FAlse")
                print(todayString)
                print(habitYearAwayString)
                print(dailyHabit.date)
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
                
            }
        }
    }
    
    
    
    
    //MARK: setting Realm Notification function
    func setRealmNoti() {
        
        
        let today = Date()
        
        guard let beginningOfToday = Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: today),
            month: Calendar.current.component(.month, from: today),
            day: Calendar.current.component(.day, from: today), hour: 0, minute: 0, second: 0)),
              
                let endOfToday = Calendar.current.date(from: DateComponents(
                    year: Calendar.current.component(.year, from: today),
                    month: Calendar.current.component(.month, from: today),
                    day: Calendar.current.component(.day, from: today), hour: 23, minute: 59, second: 59))
                
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





//아직 해야 할것 -
// HMM..maybe we need something to update the date of the renewed habits when the app gets deleted, b/c what if someone needs a notification at 6 am, but doesn't run the app til 8 am? 아! 노티는 상관없이 매일 fire되지 참. 그냥 tableview에 보여주는게 중요하지. 근데 역시 다 디스플레이하는게 필요할까? allHabits에서 미래것도 보고 싶을수도?


//-내가 혼자 해결할수 있지 않을까...하는것-

//2. HabitDetailVC 에서 edit 하면 noti도 업데이트 되어야함. 예) 시간을 바꾼다 -> 바꾼 시간으로 노티가 와야함
//3. past는 success/fail이 안되고, 오직 save나 delete밖에 못해야 된다.
