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
        v.backgroundColor = .white
        v.searchTextField.backgroundColor = .customWhite
        return v
    }()
    
    // allHabitsTableView 생성
    lazy var allHabitsTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .white
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
            make.height.equalTo(52)
            make.centerY.equalTo(searchBar)
        }
        
        // allHabitsTableView grid
        allHabitsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(-5)
            make.left.right.bottom.equalTo(backView)
        }
        allHabitsTableView.separatorStyle = .none //removes lines btwn tableView cells

        
        reloadData()
        
        print("after app runs - after reloaddata()\(habits)")
        
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
    
    //MARK: time function that returns timeInterval
    func time(current: Date, habitDate: Date) -> TimeInterval {
        return current.timeIntervalSinceReferenceDate - habitDate.timeIntervalSinceReferenceDate
    }
    
    func reloadData() {
        // MARK: Get all habits with onGoing = true in the realm. Doesn't have to be ONGOING
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        print("reloaddata-\(habits)")
        //
        habits = habits.sorted(by: {
            $0.date.compare($1.date) == .orderedAscending
        })
        searchedHabits = habits
        allHabitsTableView.reloadData()
    }
    
}



//MARK: HabitDetail에서 Habit을 수정 할경우 다시 tableview가 reload 됨
extension AllHabitSearchVC: habitDetailVCDelegate, habitDetailNoReVCDelegate {
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
        
        let habit = searchedHabits[indexPath.row]
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다, based on RepeatType
        if habit.privateRepeatType == 0 {
            //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
            let habitDetailNoReVC = HabitDetailNoReVC(habit: habit)
            habitDetailNoReVC.delegate = self
            let habitDetailVCNavi = UINavigationController(rootViewController: habitDetailNoReVC)
            habitDetailVCNavi.modalPresentationStyle = .pageSheet
            present(habitDetailVCNavi, animated:true)
            
        } else {
           
            let habitDetailVC = HabitDetailVC(habit: habit)
            habitDetailVC.delegate = self
            let habitDetailVCNavi = UINavigationController(rootViewController: habitDetailVC)
            habitDetailVCNavi.modalPresentationStyle = .pageSheet
            present(habitDetailVCNavi, animated:true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        //If there's no habit, display noDataImage
        if habits.count == 0 {
            
            let image = UIImage(named: "HB logo")
            //FIXME: need to redraw the image
            let noDataImage = UIImageView(image: image)
            noDataImage.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
            noDataImage.layer.opacity = 0.5
            tableView.backgroundView = noDataImage
            tableView.separatorStyle = .none
            return 0
//            return habits.count

        } else {
            
            //Otherwise display SearchedHabits
            tableView.backgroundView = .none
            return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0 //Choose your custom row
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
        else {
            return UITableViewCell()
        }
        
        //Getting data for each cell
        let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
        let title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        let habitTime = newHabit.date
     
        //Dateformatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM d, yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US")
        timeFormatter.dateFormat = "h:mm a"

        //Changing date & time to string
        var newHabitDate = dateFormatter.string(from: date)
        var newHabitTime = timeFormatter.string(from: habitTime)
      
        //MARK: 오늘 날짜와 저장된 habit날짜를 비교
        let calendar = Calendar.current
        let todayStartOfDay = calendar.startOfDay(for: Date())
        let habitStartOfDay = calendar.startOfDay(for: date)
        let secondDifference = time(current: todayStartOfDay, habitDate: habitStartOfDay)
        let dayDifference = Int(round(secondDifference/(60*60*24)))
        
        //MARK: repeatType에 따라서 titleBackground color를 바꾼다.
        switch newHabit.privateRepeatType {
        case 1 : cell.titleBackground.backgroundColor = .pureGreen;
        case 2 : cell.titleBackground.backgroundColor = .pureOrange;
        case 3 : cell.titleBackground.backgroundColor = .pureBlue;
        case 4 : cell.titleBackground.backgroundColor = .purePurple
        default: cell.titleBackground.backgroundColor = .pureGray;
        }
        
        //MARK: 만약 habit날짜가 오늘일 경우
        if dayDifference == 0 {
            
            //MARK: 오늘 habit은 Today란 파란문구가 뜬다. complete 했으면 Completed가 뜬다.
            switch newHabit.onGoing {
            case true :
                cell.newHabitDate.textColor = UIColor.todayBlue;
                newHabitDate = "Today"
            default :
                cell.newHabitDate.textColor = UIColor.compBlue;
                newHabitDate = "Completed"
            }
           
        } else {
            cell.newHabitDate.textColor = UIColor.black;
        }
        
        
        //MARK: 하빗 날짜가 지났고 repeat되는 애들이 아니라면 habit의 색을 까맣게 바꾸고 date를 dispaly 되는 missed로 바꿈
        if dayDifference >= 1 && newHabit.privateRepeatType == 0 {
            cell.cellStackView.backgroundColor = .pastGray
            newHabitDate = "Missed"
            newHabitTime = ""
        } else {
        //MARK: habit날짜가 안 지났거나, 지났어도 repeat되는 애들인 경우는 색이 바뀌거나 miss 되지 않음.
            cell.cellStackView.backgroundColor = .cellGray
        }
        
        cell.newHabitTitle.text = title
        cell.newHabitDesc.text = desc
        cell.newHabitDate.text = newHabitDate
        cell.newHabitTime.text = newHabitTime
        
    
        
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
            print("after success - \(self.localRealm.objects(RMO_Count.self))")
            
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




