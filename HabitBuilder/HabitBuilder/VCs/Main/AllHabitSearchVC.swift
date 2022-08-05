//
//  AllHabitSearchVC.swift
//  HabitBuilder
//
//  Created by CW on 1/25/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import UserNotifications


class AllHabitSearchVC: UIViewController, UISearchBarDelegate {
    
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
    
    // allHabitsTableView 생성
    lazy var allHabitsTableView: UITableView = {
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
        backView.addSubview(allHabitsTableView)
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // searchBar grid
        searchBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backView)
            make.height.equalTo(44)
        }
        
        // allHabitsTableView grid
        allHabitsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(backView)
        }
        
        reloadData()
        
        print(habits)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    //MARK: Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
      
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swip to dismiss tableView
        allHabitsTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    func reloadData() {
        // Get all habits in the realm
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        
        //
        habits = habits.sorted(by: {
            $0.date.compare($1.date) == .orderedAscending
        })
        searchedHabits = habits
        allHabitsTableView.reloadData()
    }
    
}



//MARK: HabitDetail에서 Habit을 수정 할경우 다시 tableview가 reload 됨
extension AllHabitSearchVC: habitDetailVCDelegate {
    func editComp() {
        
        self.reloadData() //this code prevents app from crashing when realm noti already deletes the habit. but AllHabitSearchVC doesn't have realm noti, so it has to RELOAD first. THEN show searched vs unsearched

        if habitSearched {
            searchedHabits = habits.filter { habit in
                //Search한 상태에서 title의 value를 바꾸고 난후 reload 되었을때 계속 search한 상태의 스크린이 뜬다. 원래는 tableView가 그냥 reload 되서, search 안 한 상태로 바뀌어 버렸다.
                return habit.title.lowercased().contains(searchedT.lowercased())
            }
            self.allHabitsTableView.reloadData()
            
        }  else {
            self.reloadData()
        }
    }
}

//Adding tableview and content
extension AllHabitSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        let habit = searchedHabits[indexPath.row]
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        habitDetailVC.delegate = self
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if habits.count != 0 {
            print("search 됨")
            return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
        } else {
            print("안돼")
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
        
        let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
        let title = newHabit.title
        let date = newHabit.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let newHabitDate = dateFormatter.string(from: date)
        let todayDate = dateFormatter.string(from: today)
        
        cell.newHabitTitle.text = title
        cell.newHabitDate.text = newHabitDate
        
        
        //repeatType에 따라서 혹은 오늘이냐에 따라서 바뀌는 text 색. 색은 좀 더 어떤게 좋은지 생각해보고 apply 하자
        if newHabitDate == todayDate {
            cell.newHabitDate.textColor = .red
        } else {
            cell.newHabitDate.textColor = .black
        }
        
        if newHabit.privateRepeatType == 0 {
            cell.newHabitTitle.textColor = .red
        } else {
            cell.newHabitTitle.textColor = .black
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
            self.searchedHabits = self.habits
            habitSearched = false
        }
        self.allHabitsTableView.reloadData()
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
        
        //        let configuration = UISwipeActionsConfiguration(actions: [remove, fail, success])
        //        configuration.performsFirstActionWithFullSwipe = false
        
        return UISwipeActionsConfiguration(actions: [remove, fail, success])
        
    }
    
}





//아직 해야 할것 - 1)앱 상에 빨간 숫자 사라지게 하는거. 지금은 noti뜨는걸 눌러야만 사라짐. TapGesture 가 있으니까 selectrowat이 안됨
//저번주에 못한거 - 1) 타임존 지정. 2) NSCalendar 써서 바꾸는 거
