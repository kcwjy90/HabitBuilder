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

protocol MainVCDelegate: AnyObject {
    func statusChange(countFromMain: Int)
}


class MainVC: UIViewController, UISearchBarDelegate {
    
    weak var delegate: MainVCDelegate?   // Delegate property var 생성
    
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
        //        v.backgroundColor = .blue
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
    
    var habitSearched: Bool = false
    
    let localRealm = DBManager.SI.realm!
    
    // Habits array. RMO_Habit에서 온 data가 여기 들어감. 지금은 empty.
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit]! //일단은 empty []로.
    
    //왜 안돼는거야왜왜왜왜왜오애왜
//    var compCount = 1
    //왜 안돼는거야왜왜왜왜왜오애왜

    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swip to dismiss tableView
        todaysHabitTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        // tapGasture - Dismisses Keyboard
        
        //        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        //        view.addGestureRecognizer(UITapGesture)
        
        
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
    }
    
    //MARK: filter to display Today's Habit
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
        
        searchedHabits = habits //search 된 habit을 다시 habits[] 안으로
    }
    
    
    @objc func addItem(){
        let v = NewHabitVC()
        v.delegate = self
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
}

// extension 은 class 밖에
extension MainVC: NewHabitVCDelegate {
    func didCreateNewHabit (title: String, desc: String, date: Date, time: Date) {
        print("HabitVC - title : \(title), detail: \(desc)")
        // Get new habit from RMO_Habit
        let newHabit = RMO_Habit()
        newHabit.title = title
        newHabit.desc = desc
        newHabit.date = date
        newHabit.time = time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let countDate = dateFormatter.string(from: date)
        let countRealm = localRealm.objects(RMO_Count.self)
        
        // newHabit을 생성할때 마다 생성된 habit의 날짜가 RMO_Count에 있는지 확인하고, 오직 없을 경우만 새로운 object에 날짜를 추가해서 그 object 를 RMO_Count에 추가한다.
        if !countRealm.contains(where: { $0.date == countDate} )
        {
            let newCount = RMO_Count()
            newCount.date = countDate
            
            try! localRealm.write {
                localRealm.add(newCount)
            }
        }
        
        try! localRealm.write {
            localRealm.add(newHabit)
        }
        // let habits = localRealm.objects(RMO_Habit.self)
        
        // 새로운 habit을 만들때만 noti를 생성한다.
        NotificationManger.SI.addScheduleNoti(habit: newHabit)
        
        reloadData()
    }
    
    func reloadData() {
        // Get all habits in the realm
        filterTodaysHabit() //새로추가된 habit을 오늘 날짜에 따라 filter, 그리고 다시 searchedHabits [] 안으로
        todaysHabitTableView.reloadData() //reload
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
}

extension MainVC: habitDetailVCDelegate {
    func editComp() {
        reloadData()
    }
}

//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("Row: \(indexPath.row)")  print(habits[indexPath.row].date)
        
        // cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        let habit = searchedHabits[indexPath.row]
        let habitDetailVC = HabitDetailVC(habit: habit) // NewHabitVC의 constructor에 꼭 줘야함
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
    
    // SearchBar
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
        
        //Complete Option
        let complete = UIContextualAction(style: .normal, title: "Complete") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("done")
            actionPerformed(true)
        }
        complete.backgroundColor = .systemBlue
        
        //remind option.
        //FIXME: need modal to display time
        let remind = UIContextualAction(style: .normal, title: "Remind") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("remind")
            actionPerformed(true)
        }
        remind.backgroundColor = .systemOrange
        
        //FIXME: 나중에 scope을 바꿔야지
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)

        
        //delete option
        //FIXME: swipe을 해서 delete말고 꼭 눌러서 delete하게끔
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("delete")
            
            //오늘 날짜를 가진 object를 찾아서 delete 될때마다 completed를 +1 한다
            guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
            {return} //
            let taskToUpdate = countRealm[indexNumb]
            
            try! self.localRealm.write {
                taskToUpdate.completed += 1
            }
            print(self.localRealm.objects(RMO_Count.self))
            
            
            //왜 안돼는거야왜왜왜왜왜오애왜
//            self.compCount += 1
//            print(self.compCount)
            //왜 안돼는거야왜왜왜왜왜오애왜

            let realm = self.localRealm.objects(RMO_Habit.self)
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
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete, remind, complete])
    }
    
    
    //왜 안돼는거야왜왜왜왜왜오애왜
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.delegate?.statusChange(countFromMain: self.compCount)
//
//    }
    //왜 안돼는거야왜왜왜왜왜오애왜

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
