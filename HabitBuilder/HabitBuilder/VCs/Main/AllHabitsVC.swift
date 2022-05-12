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
import SwiftUI

class AllHabitsVC: UIViewController, UISearchBarDelegate {
    
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
    
    // allHabitTablewView 생성
    lazy var allHabitsTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    var habitSearched: Bool = false
    
    let localRealm = DBManager.SI.realm!
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit]! //일단은 empty []로.
    
    var sectionedHabit = [Date:Results<RMO_Habit>]() // section하기 위해서
    var itemDates = [Date]() //이것도 section하기 위해서
    
    
    override func loadView() {
        super.loadView()
        
        print(localRealm.objects(RMO_Habit.self))
        
        createSection() //날짜대로 section만드는 func
        
        setNaviBar()
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swip to dismiss tableView
        allHabitsTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        searchBar.delegate = self
        
        view.backgroundColor = .red
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
        
        // todaysHabitTableView grid
        allHabitsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(backView)
        }
        
        reloadData()
        
    }
    
    //Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        title = "All Habits"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addItem)
        )
    }
    
    @objc func addItem(){
        let v = NewHabitVC()
        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    func reloadData() {
        // Get all habits in the realm
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        searchedHabits = habits
        createSection() // Section을 다시 reload해서 만약 날짜가 edit 되었으면 section도 update시킴
        allHabitsTableView.reloadData()
    }
    
    func createSection() {
        //Find each unique day for which an Item exists in your Realm
        itemDates = localRealm.objects(RMO_Habit.self).reduce(into: [Date](), { results, currentItem in
            let date = currentItem.date
            let beginningOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            //Only add the date if it doesn't exist in the array yet
            if !results.contains(where: { addedDate->Bool in
                return addedDate >= beginningOfDay && addedDate <= endOfDay
            }) {
                results.append(beginningOfDay)
            }
        })
        
        
        //Filter each Item in realm based on their date property and assign the results to the dictionary
        sectionedHabit = itemDates.reduce(into: [Date:Results<RMO_Habit>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = localRealm.objects(RMO_Habit.self).filter("date >= %@ AND date <= %@", beginningOfDay, endOfDay)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    
}

// extension 은 class 밖에
extension AllHabitsVC: NewHabitVCDelegate {
    func didCreateNewHabit (title: String, desc: String, date: Date, time: Date) {
        //        print("HabitVC - title : \(title), detail: \(desc)")
        
        // Get new habit from RMO_Habit
        let fromRMO_Habit = RMO_Habit()
        fromRMO_Habit.title = title
        fromRMO_Habit.desc = desc
        fromRMO_Habit.date = date
        fromRMO_Habit.time = time
        
        try! localRealm.write {
            localRealm.add(fromRMO_Habit)
        }
        
        createSection()
        reloadData()
    }
}

extension AllHabitsVC: habitDetailVCDelegate {
    func editComp() {
        reloadData()
    }
}


//Adding tableview and content

extension AllHabitsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if habitSearched == true || habits.count == 0 { //search 하고 있을때는 section 이 하나로
            return 1
        } else {
            return itemDates.count //search 안할때는 itemDates 수에 따라서
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if habitSearched == true || habits.count == 0 { //search 하고 있을때는 Heading 이 Search Result로
            return ""
        } else {
            if let first = sectionedHabit[itemDates[section]]!.first { // search 날짜를 heading으로
                let dateFormmater = DateFormatter()
                dateFormmater.dateFormat = "MM/dd/YYYY"
                return dateFormmater.string(from: first.date)
            }
        }
        return nil //얘는 그냥 넣어야 되더라고
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if habitSearched == true || habits.count == 0 {
            return searchedHabits.count //serach 를 하면 searchedHabits row number 를
        } else {
            return sectionedHabit[itemDates[section]]!.count // 안하면 sectionedHabit row number 를
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        var habit: RMO_Habit
        
        if habitSearched == true || habits.count == 0 {
            habit = habits[indexPath.row]
        } else {
            habit = sectionedHabit[itemDates[indexPath.section]]![indexPath.row]
        }
        
        let habitDetailVC = HabitDetailVC(habit: habit) // NewHabitVC의 constructor에 꼭 줘야함
        habitDetailVC.delegate = self
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
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
        
        if habitSearched == true || habits.count == 0 { //search 가 되었을경우는 searchedHabit 에서만 object를..
            let newHabit = searchedHabits[indexPath.row]
            var title = newHabit.title
            let desc = newHabit.desc
            let date = newHabit.date
            let time = newHabit.time
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else { //아닌경우는 groupedHabits에서 뽑아온다
            let itemsForDate = sectionedHabit[itemDates[indexPath.section]]!
            var habit = itemsForDate[indexPath.row]
            cell.newHabitTitle.text = habit.title + " - "
            cell.newHabitDesc.text = habit.desc
            
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = [] //비어있는 searchedHabits
        let habits = localRealm.objects(RMO_Habit.self).toArray() // RMO_Habit 을 array로
        
        if searchText != "" { //만약 searchText가 비어있지 않으면
            habitSearched = true
            searchedHabits = habits.filter { habit in //searchedHabits은 Habit 을 filter한것과 =
                return habit.title.lowercased().contains(searchText.lowercased()) //filter내용은 title = searchText
            }
        } else {
            self.searchedHabits = self.habits // searchText가 비어 있으면 searchedHabits = habits.
            habitSearched = false
            
        }
        self.allHabitsTableView.reloadData() //tableView를 reload
    }
    
    //swipe 해서 지우는 function
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //            if habitSearched == true || habits.count == 0 {
            
            let realm = localRealm.objects(RMO_Habit.self)
            let habit = searchedHabits[indexPath.row]
            let ip = indexPath.row
            let thisId = habit.id
            
            try! localRealm.write {
                
                let deleteHabit = realm.where {
                    $0.id == thisId
                }
                localRealm.delete(deleteHabit)
                
                //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
                tableView.beginUpdates()
                searchedHabits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            }
            
            //            }
            //                else {
            //
            //                let realm = localRealm.objects(RMO_Habit.self)
            //                let habit = sectionedHabit[itemDates[indexPath.section]]![indexPath.row]
            //                let inpS = indexPath.section
            //                let inpR = indexPath.row
            //                let thisId = habit.id
            //
            //                try! localRealm.write {
            //
            //                    let deleteHabit = realm.where {
            //                        $0.id == thisId
            //                    }
            //                    localRealm.delete(deleteHabit)
            //
            //                }
            //                tableView.beginUpdates()
            //                sectionedHabit.remove(at: itemDates[indexPath.section]]![indexPath.row])
            //                tableView.deleteRows(at: [indexPath], with: .fade)
            //                tableView.endUpdates()
            //
            //            }
        }
    }
}
