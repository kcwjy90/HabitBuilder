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


class MainVC: UIViewController, UISearchBarDelegate {
    
    let localRealm = DBManager.SI.realm!
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // searchBar 생성
    lazy var searchBar : UISearchBar = {
        let v = UISearchBar()
        v.searchBarStyle = .minimal
        return v
    }()
    
    // dateLabelBackView 생성
    lazy var dateLabelBackView: UIView = {
        let v = UIView()
        v.backgroundColor = .starWhite
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
        return v
    }()
    
    // habit이 검색됨에 따라 tableView에 보여지는걸 다르게 하기 위해서
    var habitSearched: Bool = false
    
    // RMO_Habit에서 온 data를 넣을 empty한 array들
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit] = []
    
    
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        searchBar.delegate = self
        
        view.addSubview(backView)
        view.backgroundColor = .white
        backView.addSubview(searchBar)
        backView.addSubview(dateLabelBackView)
        dateLabelBackView.addSubview(dateLabel)
        backView.addSubview(todaysHabitTableView)
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // searchBar grid
        searchBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backView)
            make.height.equalTo(44)
        }
        
        // dateLabelBackView backveiw grid
        dateLabelBackView.snp.makeConstraints{ (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(backView)
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
        
        reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    func dateFormatting() {
        
    }
    
    //MARK: Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        title = "Habit Builder"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
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
        v.delegate = self
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    //MARK: Filter to only display Habits with Today's Habit
    func filterTodaysHabit() {
        habits = localRealm.objects(RMO_Habit.self).filter {
            habit in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let habitDate = dateFormatter.string(from: habit.date)
            let today = Date()
            let todaysDate = dateFormatter.string(from: today)
            return habitDate == todaysDate
        }
        
        searchedHabits = habits //search 된 habits을 searchedHabits[] 안으로
    }
    
}

//Extension 은 항상 class 밖에
//MARK: NewHabitVC에서 새로 생성된 habit들. RMO_Habit에 넣을 예정
extension MainVC: NewHabitVCDelegate {
    func didCreateNewHabit (title: String, desc: String, date: Date, time: Date) {
        
        // Get new habit from RMO_Habit
        let newHabit = RMO_Habit()
        newHabit.title = title
        newHabit.desc = desc
        newHabit.date = date
        newHabit.time = time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let habitDate = dateFormatter.string(from: date) // habitDate = 방금받은 habit의 date
        let countRealm = localRealm.objects(RMO_Count.self)
        
        //MARK:RMO_Count 확인 -> either 새로운 날짜 추가 or existing 날짜에 total +1
        //새로 생성된 habit의 날짜가 RMO_Count에 있는지 확인하고, 없을 경우 RMO_Count에 추가한다.
        if !countRealm.contains(where: { $0.date == habitDate} )
        {
            let newCount = RMO_Count()
            newCount.date = habitDate
            
            try! localRealm.write {
                localRealm.add(newCount)
                print("생성")
                print(newCount)
            }
        }
        
        try! localRealm.write {
            localRealm.add(newHabit)
            print("무사들어감")
        }
        
        //만약 RMO_Count에 지금 add하는 날짜의 object가 있을경우 그 total 을 +1 한다
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == habitDate}) else
        {return}
        let existCount = countRealm[indexNumb]
        
        try! localRealm.write {
            existCount.total += 1
            print("+1")
            print(existCount)
        }
        
        
        // 새로운 habit을 만들때'만' noti를 생성한다.
        NotificationManger.SI.addScheduleNoti(habit: newHabit)
        
        reloadData()
    }
    
    //MARK:Get all habits in the realm and reload.
    func reloadData() {
        filterTodaysHabit() //새로추가된 habit을 오늘 날짜에 따라 filter, 그리고 다시 searchedHabits [] 안으로
        todaysHabitTableView.reloadData() //reload
    }
    
}

//MARK: HabitDetail에서 Habit을 수정 할경우 다시 tableview가 reload 됨
extension MainVC: habitDetailVCDelegate {
    func editComp() {
        reloadData()
    }
}

//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("Row: \(indexPath.row)")  print(habits[indexPath.row].date)
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        let habit = searchedHabits[indexPath.row]
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit) 
        habitDetailVC.delegate = self
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0 //Choose your custom row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
        else {
            return UITableViewCell()
        }
        
        let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
        let title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        let time = newHabit.time
        
        cell.newHabitTitle.text = title + " - "
        cell.newHabitDesc.text = desc
        
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = []
        
        if searchText != "" {
            habitSearched = true
            
            searchedHabits = habits.filter { habit in
                return habit.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            self.searchedHabits = self.habits
            habitSearched = false
        }
        self.todaysHabitTableView.reloadData()
    }
    
    
    
    //FIXME: still need to fix app dying when habit deleted during search
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
            print("done")
            
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 success를 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.success += 1
            }
            print(self.localRealm.objects(RMO_Count.self))
            
            let habit = self.searchedHabits[indexPath.row]
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
                
            }
            
            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
            tableView.beginUpdates()
            self.searchedHabits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            actionPerformed(true)
        }
        success.backgroundColor = .systemBlue
        
        //MARK: Habit을 Remove 했으면
        let remove = UIContextualAction(style: .normal, title: "Remove") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Remove")
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 remove를 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.remove += 1
            }
            print(self.localRealm.objects(RMO_Count.self))
            
            let habit = self.searchedHabits[indexPath.row]
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
                
            }
            
            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
            tableView.beginUpdates()
            self.searchedHabits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            actionPerformed(true)
            actionPerformed(true)
        }
        remove.backgroundColor = .systemOrange
        
        //MARK: Habit을 Fail 했으면..
        let fail = UIContextualAction(style: .destructive, title: "Fail") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("delete")
            
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 fail을 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.fail += 1
            }
            print(self.localRealm.objects(RMO_Count.self))
            
            let habit = self.searchedHabits[indexPath.row]
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
                
            }
            
            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
            tableView.beginUpdates()
            self.searchedHabits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            actionPerformed(true)
        }
        fail.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [success, remove, fail])
    }
    
}




//swipe 해서 지우는 function
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            let realm = localRealm.objects(RMO_Habit.self)
//            let habit = searchedHabits[indexPath.row]
//            let thisId = habit.id
//
//            try! localRealm.write {
//
//                let deleteHabit = realm.where {
//                    $0.id == thisId
//                }
//                localRealm.delete(deleteHabit)
//
//            }
//
//            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
//            tableView.beginUpdates()
//            searchedHabits.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
//        }
//
//    }
//


//아직 해야 할것 - 1)앱 상에 빨간 숫자 사라지게 하는거. 지금은 noti뜨는걸 눌러야만 사라짐. TapGesture 가 있으니까 selectrowat이 안됨
//저번주에 못한거 - 1) 타임존 지정. 2) NSCalendar 써서 바꾸는 거

//let today = Date()
//let todaysDate = dateFormatter.string(from: today)
