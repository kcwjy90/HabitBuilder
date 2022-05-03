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



class MainVC: UIViewController, UISearchBarDelegate, UNUserNotificationCenterDelegate {
    
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
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    let localRealm = DBManager.SI.realm!
    
    // Habits array. RMO_Habit에서 온 data가 여기 들어감. 지금은 empty.
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit]! //일단은 empty []로.
    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // tapGasture - Dismisses Keyboard
        //        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        //        view.addGestureRecognizer(UITapGesture)
        
        
        self.userNotificationCenter.delegate = self //
        self.requestNotificationAuthorization()
        self.sendNotification()
        
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
        
        filterTodaysHabit()
        
        todaysHabitTableView.reloadData()
        
    }
    
    //Navi Bar 만드는 func. loadview() 밖에!
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
    
    //filter to display Today's Habit
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
        let fromRMO_Habit = RMO_Habit()
        fromRMO_Habit.title = title
        fromRMO_Habit.desc = desc
        fromRMO_Habit.date = date
        fromRMO_Habit.time = time
        
        try! localRealm.write {
            localRealm.add(fromRMO_Habit)
        }
        // let habits = localRealm.objects(RMO_Habit.self)
        
        filterTodaysHabit() //새로추가된 habit을 오늘 날짜에 따라 filter, 그리고 다시 searchedHabits [] 안으로
        todaysHabitTableView.reloadData() //reload
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterTodaysHabit()
        todaysHabitTableView.reloadData()
    }
    
    //처음에 notification 받을지 authorize 하는 것
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    // Notification 를 정해진 시간에 보내는 content. DATE 말고 시간에 일단 맞춰놨음
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.badge = NSNumber(value: 1)
        
        for habit in localRealm.objects(RMO_Habit.self) {
            
            notificationContent.title = habit.title
            notificationContent.body = habit.desc
            
            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: habit.time)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            
            self.userNotificationCenter.add(request) { (error) in
                if (error != nil)
                {
                    print("Error" + error.debugDescription)
                    return
                }
            }
        }
    }
    
    // HabitBuilder 실행 중에도 notification 받을수 있게 하는 code
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
}

//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("Row: \(indexPath.row)")
        //        print(habits[indexPath.row].date)
        
        
        let habitDetailVC = HabitDetailVC() // Your destination
        habitDetailVC.habitTitle.text = habits[indexPath.row].title
        habitDetailVC.habitDesc.text = habits[indexPath.row].desc
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        habitDetailVC.habitDate.text = dateFormatter.string(from: habits[indexPath.row].date)
        habitDetailVC.habitTime.text = timeFormatter.string(from: habits[indexPath.row].date)
        
        navigationController?.pushViewController(habitDetailVC, animated: true)
        
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
            searchedHabits = habits.filter { habit in
                return habit.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            self.searchedHabits = self.habits
        }
        self.todaysHabitTableView.reloadData()
    }
    
    
    
    //swipe 해서 지우는 function
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let realm = localRealm.objects(RMO_Habit.self)
            let habit = searchedHabits[indexPath.row]
            let thisTitle = habit.title
            let thisTime = habit.time
            
            try! localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.title == thisTitle || $0.time == thisTime
                }
                localRealm.delete(deleteHabit)
                
            }
            
            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
            tableView.beginUpdates()
            searchedHabits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    
    
    
    
    //    private func doneHabit() {
    //        print("Finished Habit")
    //    }
    //
    //    private func editHabit() {
    //        print("Edit Habit")
    //    }
    //
    //    private func deleteHabit() {
    //        print("Delete Habit")
    //    }
    //
    //    func tableView(_ tableView: UITableView,
    //                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //
    //        let done = UIContextualAction(style: .normal,
    //                                       title: "Done") { [weak self] (action, view, completionHandler) in
    //                                        self?.doneHabit()
    //                                        completionHandler(true)
    //        }
    //        done.backgroundColor = .systemBlue
    //
    //        let edit = UIContextualAction(style: .normal,
    //                                       title: "Edit") { [weak self] (action, view, completionHandler) in
    //                                        self?.doneHabit()
    //                                        completionHandler(true)
    //        }
    //        edit.backgroundColor = .systemOrange
    //
    //        let delete = UIContextualAction(style: .destructive,
    //                                        title: "Delete") { [weak self] (action, view, completionHandler) in
    //                                            self?.deleteHabit()
    //                                            completionHandler(true)
    //        }
    //        delete.backgroundColor = .systemRed
    //
    //        return UISwipeActionsConfiguration(actions: [delete, edit, done])
    
    //    }
    
    
}

//아직 해야 할것 - 1)앱 상에 빨간 숫자 사라지게 하는거. 지금은 noti뜨는걸 눌러야만 사라짐. TapGesture 가 있으니까 selectrowat이 안됨
//저번주에 못한거 - 1) 타임존 지정. 2) NSCalendar 써서 바꾸는 거

