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
        
        //FIX: 일단은 app을 run 할때마다 지워지기는 하는데...문제는 app을 완전히 close하지 않은상태에서 noti가 왔고, 그걸 못 보고 app을 켰을경우 밑의 code가 run 되지는 않으니 noti가 지워지지 않는다.
        UIApplication.shared.applicationIconBadgeNumber = 0

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
    
    //MARK: auto-deleting habits that are 2 days old
    func deletePrev() {
        let realm = self.localRealm.objects(RMO_Habit.self)
        
        let today = Date()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: midnight)
        
        guard let ystday = yesterday else {return}
        
        try! self.localRealm.write {
            
            let deleteHabit = realm.where {
                $0.date < ystday
            }
            self.localRealm.delete(deleteHabit)
        }
    }
    
    
    //step 4 =====================
// MARK: Updating on going
    func updateOngoing() {
        
//        //MARK: RMO_Count에 오늘 날짜가 없을경우 오늘 날짜를 넣는다.
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        let habitDate = dateFormatter.string(from: Date())
//
//        let countRealm = localRealm.objects(RMO_Count.self)
//
//        if !countRealm.contains(where: { $0.date == habitDate} )
//        {
//            let newCount = RMO_Count()
//            newCount.date = habitDate
//
//            try! localRealm.write {
//                localRealm.add(newCount)
//            }
//        }
//
        let realm = self.localRealm.objects(RMO_Habit.self).filter("onGoing == False")
        
        print("===========")
        print(realm)
        print("===========")
        
        try! self.localRealm.write {
            realm.setValue(true, forKey: "onGoing")
        }
        
        print(localRealm.objects(RMO_Habit.self))
        
    }
    //step 4 =====================

    
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
//1)앱 상에 빨간 숫자 사라지게 하는거.지금은 noti뜨는걸 눌러야만 사라짐.
//      -> MainVC 117줄을 보시오
//2)repeat에 따라 cell이 자동 생성되게 하는거? 코드는 어디에 적어야 하나?
//3)repeat이 지정된 것을 영구 지우면 noti가 안오게 하는법
// 예> 책읽기는 daily habit인데, 오늘 성공했으면 'Success' button 을 누른다. 이러면 tableview에서 사라지지만 daily habit이기 때문에 내일이 되면 다시 떠야함. 현재 noti는 오고 있음. 근데 habit 생성은 안됨
// 그러다가 책읽기 habit을 영구적으로 지우면 다시 뜨지도 않아야 하고 noti 도 안와야 함.
//4) 다음날 자정에 onGoing == false로 바꿔 다시 뜨게 해주는 코드는 아직 개발중
//      -> 토요일날 형이랑 시나리오 점검 하고나면 아마 만들수 있지 않을까
//5. 해야할거 - habit을 habitDetailVC에서 지웠을 경우 allHabitsearchVC를 update해줘야함
//      -> 아 이거 꼭 물어봐야 함
//6. noti 는 또 왜 안되고 지랄이야 ㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜㅜ
//      -> 시뮬레이터에서 돌리면 되기는 됨 ㅜㅜ


 
/* 이렇게 하면 되나? 일단 지금 까지 한거
 1. RMO_Habit 에 var onGoing: Bool 을 생성
 2. tableview 에는 onGoing == True 인 애들만 불러옴
 3. habit 이 success나 fail을 하면 onGoing 을 false로 바꿔 tableView에 안 뜨게함. RMO_Habit자체에서 habit을 지우는 것은 아님.
 4. 그리고 다음날이 되면 모든 habit에 onGoing을 true 로 다시 바꿈. 이러면 매일마다 repeat되는 habit들이 다시 뜸
    a) 만약 repeate = .none 일경우는 영구 지워지고, repeat != .none이 아닌경우는 onGoing 이 false 가 됨
 5. 영구적으로 habit을 지우고 싶을때는 delete button을 눌러 아예 지워버림
 
 */


/*PLAN B
1. RMO_habit 말고 RMO_repeat object를 하나 더 만들경우
새로 add 할때
    a) non-repeat인 경우 -> adds habit to RMO_Habit
    b) repeat인 경우 -> adds habit to RMO_repeat
2. App을 실행시킬때 RMO_repeat에 있는 것들을 RMO_Habit으로 가지고 온다. (Q: 하지만 앱을 매번 실행시킬때마다 이걸 하는게 아니라 하루에 한번만 해야하는데..)
3. success/fail 을 할경우 RMO_Habit에서만 지우고, delete을 할 경우 만약 이게 repeated habit이면 RMO_Habit, RMO_Repeat이 둘다 에서 지운다.
 
edit 할때
scenario 1 : old RepeatType & new repeatType == .none
    -> RMO_Habit에서만 edit
scenario 2 : old RepeatType == .none & new repeatType = .repeat
    -> RMO_Habit에서 edit, RMO_repeat 에 새로추가
scenario 3 : old repeatType == .repeat & new repeatType = .none
    -> RMO_Habit에서 edit, RMO_repeat 에서 지우기
scenario 4 : old RepeatType & new repeatType == .repeat (different interval ex> daily -> monthly)
    -> RMO_Habit, RMO_Repeat 둘다 edit
    */

/*새로운 시나리오

 ==RMO_Habit에 있는 onGoing var을 업데이트 하는 방법==
 
 1. App을 실행 하면 func updateOnGoing 이 바로 실행된다.

    a) 만약 app이 오늘 처음 실행되는 거라면..
        1) RMO_Count에 오늘에 해당하는 날짜가 있는지 없는지 체크한다.
            a) 없으면 date var에 오늘 날짜가 저장된다.
            b) 있으면 그냥 2)로 넘어간다 (있는 경우는 NewHabitVC를 통해서 미래에 있을 habit을 이미 만들어 놓은경우)
        2) 오늘 날짜에 해당하는 object의 habitUpdated를 체크한다. false일 것이다.
        3) RMO_Count에 있는 habitUpdated (Bool) var이 false에서 true로 바뀐다.
        4) RMO_Habit에 있는 모든 onGoing이 true로 바뀐다.
 
 2. tableView에는 onGoing == true 인 모든 habit들이 찍힌다.
 3. 그러고 나서 오늘 repeat되는 애들중에 몇개를 success/fail 했다고 치자. 그러면 걔네들은 onGoing = false 가 되고 tableview에 더 이상 나타나지 않는다.
 
    b) 오늘중 app을 다시 실행 시키면
        1) RMO_Count의 오늘에 해당하는 object의 habitUpdated를 체크한다.
            a) true일 경우 이미 app을 오늘 실행했다는 의미이기 때문에 아무일도 일어나지 않는다.
            b) 오늘 하루중 이미 app을 실행 시켰다면 false일 경우는 없다.(왜냐하면 app이 실행되면 제일 먼저 hapitUpdated가 true로 바뀌기 때문에)
 
그리고 그 다음날 app을 실행하면
 
4.역시나 func updateOnGoing이 실행되고, RMO_Count는 그 다음날에 해당하는 날짜의 habitUpdate를 true로 바꿔주고 RMO_Habit에 있는 onGoing도 true로 만들어 준다. 이렇게 함으로 RMO_Habit에 남아있는 모든 habit들이 새로 tableView에 뜨게 된다.
 
 
 ==tableView에서 habit을 delete/success/fail하게 되면 생기는 변화==
 1. tableView에서 delete을 한 경우
    a) repeatType에 상관없이 무조건 RMO_Habit에서 지워진다.
 
 2. tableView에서 success/fail 한 경우
    a) habit이 repeatType == .none 이면 RMO_Habit에서 지워진다.
    b) habit이 repeatType != .none 이면 onGoing = false가 되고 tableView에서만 지워진다.

 
 
 

 
 
 */

//Q: AllHabit에서 habit을 지울경우 HabitDetailVC line 476이 allHabitSearchVC line 113을 call 하는데 왜 tableview가 reload될때 habit은 아직 그대로일까?
