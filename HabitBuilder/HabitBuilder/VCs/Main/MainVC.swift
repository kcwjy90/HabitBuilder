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
    
    //realm Noti 에서 쓰는거
    deinit {
        print("deinit - NewHabitVC")
        notificationToken?.invalidate()
    }
    
    //realm Noti 에서 쓰는거
    var status: NewHabitVCStatus = .initialize
    var notificationToken: NotificationToken? = nil
    
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
            make.height.equalTo(52)
        }
        
        // dateLabel grid
        dateLabel.snp.makeConstraints{ (make) in
            make.centerY.equalTo(dateLabelBackView)
            make.right.equalTo(dateLabelBackView).offset(-10)
        }
        
        // todaysHabitTableView grid
        todaysHabitTableView.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabelBackView.snp.bottom)
            make.left.right.bottom.equalTo(backView)
        }
        todaysHabitTableView.separatorStyle = .none //removes lines btwn tableView cells
        
        updateOngoing()
        deletePrev()
        realmNoti()
    
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
        case 1 : cell.newHabitRepeat.text = "(D)"; cell.repeatBackground.backgroundColor = .pureRed
        case 2 : cell.newHabitRepeat.text = "(W)"; cell.repeatBackground.backgroundColor = .pureOrange
        case 3 : cell.newHabitRepeat.text = "(M)"; cell.repeatBackground.backgroundColor = .pureBlue
        case 4 : cell.newHabitRepeat.text = "(Y)"; cell.repeatBackground.backgroundColor = .purePurple
        default: cell.newHabitRepeat.text = ""; cell.repeatBackground.backgroundColor = .white
        }
        
        cell.backgroundColor = .white
        
        cell.newHabitTitle.text = title
        cell.newHabitDesc.text = desc
        cell.newHabitDate.text = newHabitDate
        
        return cell
    }
    
    
//FIXME: 만약에 오늘보다 오래된 habit이 repeat이고 지금 현재 보다 '과거'의 habit이라면 오늘 날짜로 업데이트 해서 여기에 display
    
    
    
// MARK: CheckTheDay bool에 따라서 RMO_Habit의 onGoing을 업데이트
    func updateOngoing() {
        
        if checkTheDay() == true {
            //onGoing 이 false인 애들을 true로 바꿔줌
            let realm = self.localRealm.objects(RMO_Habit.self).filter("onGoing == False")
            
            try! self.localRealm.write {
                realm.setValue(true, forKey: "onGoing")
            }

        } else {
            //아직 다음날이 아니라서 아무것도 안함
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
        try! self.localRealm.write {
            
            let deleteHabit = realm.where {
                $0.date < ystday && $0.privateRepeatType == 0
            }
            self.localRealm.delete(deleteHabit)
        }
    }
    
    
    
    
    //MARK: Realm Notification function
    func realmNoti() {
        
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
            if today > exeToday {
                // 다음날 실행
                UserDefaults.standard.set(today, forKey: "exeToday")
                print("today는 \(today)")
                print("exeToday는 \(exeToday)")

                return true
            }
                
                else {
                // 오늘 첫 실행
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

//-형하고 아마 해결해야 하는것-


//1.오늘 완료 하지 않고 지나가버린 habit들은
    // repeat 일경우 : 자동적으로 그 다음날에 해당하는 날짜를 달고 todaysTableview에 나타나야 한다!!!!! allHabitTalbeview에는 '완료되지 않은 과거의 habit' 는 빼고 그냥 '오늘 예정인' habit만 나타난다.
  
//2. AllHabit에서 habit을 지울경우 HabitDetailVC line 520이 allHabitSearchVC line 129번으로 가서 111번의 reloaddata로 가는데 왜 아직 tableView가 업데이트가 안되고 그대로일까?
 




/* 아니면 완전 다른 시나리오

전체적으로 갈아엎고 다시 해보자.
 1. RMO_Repeat 이라는 object를 만든다. 여기에는 habit이 repeat일 경우만 저장된다.
    a) haibtDetailVC에서 repeatType을 Daily에서 NONE으로 바꿀경우 RMO_repeat에서는 이 하빗을 지우고, RMO_Habit에 이하빗을 저장한다. Noti도 업데이트 한다.
 
 2. app을 처음 실행 시킬때
    a) daily의 경우: RMO_Habit에 똑같은 id가 있는 하빗이 있는가를 먼저 확인 후 RMO_Repeat에 있는 하빗의 날짜들을 오늘 날짜로 바꿔주고 이 하빗들을  해당하는 habit을 RMO_Habit에다가 넣어준다. 날짜를 바꿔주는 이유는 그래야지 todaysTableView에 띄워진다.
    b) weekly, monthly, yearly의 경우: 저장되어 있는 날짜가 오늘기준 1주/1달/1년 전인지를 확인 후, 맞다면 날짜를 오늘 날짜로 바꿔 주고 RMO_Habit에 넣어준다.
 
 3. app을 오늘 처음 실행 시킨것이 아닐떄: UserDefaults 때문에 아무일도 생기지 않는다.
 4. app을 그 다음날 실행시키면: UserDefaults에 아무것도 없기 떄문에 step 2가 실행된다.
 
 5. 하빗을 완료하는 경우
    a) success/fail 한 경우 RMO_Habit에서만 지워짐. 그렇기 떄문에 RMO_Repeat에는 repeat되어진 habit들이 계속 존재. 그리고 '그 다음 날'의 habit으로서 날짜가 바뀌고 AllHabitSearchVC에서 '내일'의 habit으로 띄워진다.
    b) delete 한 경우. RMO_Habit + RMO_repeat두개에서 다 지워짐. noti도 같이 업데이트 된다.
 
 6. 그날 하빗을 완료하지 않은경우
    a) repeat이 아닐경우: allHabitSearchVC에서 '어제'의 habit으로서 이 하빗들을 확인할수 있으며. 여기서도 success & fail & delete은 동일하게 적용 가능하다.
    b) repeat일 경우: '어제'의 habit은 사라지고 오늘 repeat되는 새로운 habit으로 생성된다.
    
 3. AllHabitsSearchVC에는 repeat되는 모든 하빗을 제일 위(밑)에 항상 display하고 있음.
 
 */




//-내가 혼자 해결할수 있지 않을까...하는것-

//2. HabitDetailVC 에서 edit 하면 noti도 업데이트 되어야함. 예) 시간을 바꾼다 -> 바꾼 시간으로 노티가 와야함
//3. past는 success/fail이 안되고, 오직 save나 delete밖에 못해야 된다.


// repeat이 아닐경우 : '완료되지 않은 과거의 habit'은 회색으로 display. 그리고 만약 더 지나면 과거의 habit들의 noti를 업데이트 해야함 (더 이상 오지 않도록)
