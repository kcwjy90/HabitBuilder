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



class MainVC: UIViewController, UISearchBarDelegate {
    
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
    var searchedT: String = ""
    
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
        
        filterTodaysHabit()
        
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
        
        let realm = self.localRealm.objects(RMO_Habit.self).filter("date >= %@ AND date <= %@", beginningOfToday, endOfToday)
        
        //notificationToken 은 ViewController 가 닫히기 전에 꼭 release 해줘야 함. 에러 나니까 코멘트
        notificationToken = realm.observe { [weak self] (changes: RealmCollectionChange) in
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
                    // ...
                })
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let todaysDate = dateFormatter.string(from: Date())
        
        habits = localRealm.objects(RMO_Habit.self).filter {
            habit in
            return dateFormatter.string(from:habit.date) == todaysDate
        }
        
        if habitSearched {
            
            if searchedHabits.count != 0 {
                searchedHabits = habits.filter { habit in
                    //Search한 상태에서 title의 value를 바꾸고 난후 reload 되었을때 계속 search한 상태의 스크린이 뜬다. 원래는 tableView가 그냥 reload 되서, search 안 한 상태로 바뀌어 버렸다.
                    return habit.title.lowercased().contains(searchedT.lowercased())
                }
            } else {
                return
            }
        }
    }
}


//Extension 은 항상 class 밖에
//MARK: NewHabitVC에서 새로 생성된 habit들. RMO_Habit에 넣을 예정
extension MainVC: NewHabitVCDelegate {
    func didCreateNewHabit () {
        
        //이거넣으니까 된다! 미쳤다
        filterTodaysHabit()

    }
}

//MARK: HabitDetail에서 Habit을 수정 할경우 다시 tableview가 reload 됨
extension MainVC: habitDetailVCDelegate {
    func editComp() {
        if habitSearched {
            searchedHabits = habits.filter { habit in
                //Search한 상태에서 title의 value를 바꾸고 난후 reload 되었을때 계속 search한 상태의 스크린이 뜬다. 원래는 tableView가 그냥 reload 되서, search 안 한 상태로 바뀌어 버렸다.
                return habit.title.lowercased().contains(searchedT.lowercased())
            }
            self.todaysHabitTableView.reloadData()
        }
        //        }  else {
        //            self.reloadData()
        //        }
    }
}

//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("Row: \(indexPath.row)")  print(habits[indexPath.row].date)
        
        var habit: RMO_Habit
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        if habitSearched {
            habit = searchedHabits[indexPath.row]
        } else {
            habit = habits[indexPath.row]
        }
        
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        habitDetailVC.delegate = self
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if habitSearched {
            print("search 됨")
            return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
        } else {
            print("search 안됨")
            return habits.count
        }
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
        
        if habitSearched {
            
            let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
            let title = newHabit.title
            let desc = newHabit.desc
            let date = newHabit.date
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else {
            
            let newHabit = habits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
            let title = newHabit.title
            let desc = newHabit.desc
            let date = newHabit.date
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        }
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = []
        
        if searchText != "" {
            habitSearched = true
            searchedT = searchText //search한 text를 저장.
            
            searchedHabits = habits.filter { habit in
                return habit.title.lowercased().contains(searchText.lowercased())
            }
        } else {
            habitSearched = false
        }
        self.todaysHabitTableView.reloadData()
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
            print(self.localRealm.objects(RMO_Count.self))
            
            var habit: RMO_Habit
            
            if self.habitSearched {
                habit = self.searchedHabits[indexPath.row]
            } else {
                habit = self.habits[indexPath.row]
            }
            
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
            
            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드+++Realm noti 가 있음으로 밑에게 필요가 없어짐.
            //            tableView.beginUpdates()
            //            self.searchedHabits.remove(at: indexPath.row)
            //            tableView.deleteRows(at: [indexPath], with: .fade)
            //            tableView.endUpdates()
            //            actionPerformed(true)
            self.filterTodaysHabit() //이거를 넣으니까 search 한상태에서 habit을 없애도 에러가 안남
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
                
                if self.habitSearched {
                    habit = self.searchedHabits[indexPath.row]
                    
                } else {
                    habit = self.habits[indexPath.row]
                    
                }
                
                let thisId = habit.id
                
                try! self.localRealm.write {
                    
                    let deleteHabit = realm.where {
                        $0.id == thisId
                    }
                    self.localRealm.delete(deleteHabit)
                }
                
                self.filterTodaysHabit()

                
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
            
            if self.habitSearched {
                habit = self.searchedHabits[indexPath.row]
                
            } else {
                habit = self.habits[indexPath.row]
                
            }
            
            let thisId = habit.id
            
            try! self.localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                self.localRealm.delete(deleteHabit)
            }
            
            self.filterTodaysHabit()
        }
        fail.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [remove, fail, success])
        
    }
    
}





//아직 해야 할것 - 1)앱 상에 빨간 숫자 사라지게 하는거. 지금은 noti뜨는걸 눌러야만 사라짐. TapGesture 가 있으니까 selectrowat이 안됨
//저번주에 못한거 - 1) 타임존 지정. 2) NSCalendar 써서 바꾸는 거


//7/5 - 1) delete 하면 noti도 사라지는거 2) delete하는 방식을 바꿈 - habitDetailVC 에 button들을 만들어서 success or fail
