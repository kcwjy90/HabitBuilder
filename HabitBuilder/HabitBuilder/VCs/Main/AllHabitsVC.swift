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
    
    let localRealm = DBManager.SI.realm!
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit]! //일단은 empty []로.
    
    
    override func loadView() {
        super.loadView()
        
        print("please")
        
        setNaviBar()
        
        searchBar.delegate = self
        
        view.backgroundColor = .red
        view.addSubview(backView)
        view.backgroundColor = .white
        backView.addSubview(searchBar)
        backView.addSubview(allHabitsTableView)
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.bottom.equalTo(view)
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
        
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        searchedHabits = habits //  이 3줄을 여기 적는 이유는 MainVC와는 다르게 today()로 filter하는게 없기 때문에 tableView 에서 NumbofRow를 지정하고 value를 가져오려면 searchedHabits[] 일단 data가 들어가야 해서 이다. 이전에는 바로 RMO_Habits에서 data를 가져왔기 때문에 상관없었다.
        allHabitsTableView.reloadData()
        
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

}

// extension 은 class 밖에
extension AllHabitsVC: NewHabitVCDelegate {
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
        
        // Get all habits in the realm
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        searchedHabits = habits
        allHabitsTableView.reloadData()
        
//        let mainvc = MainVC()  // 왜 reload가 안되는거지...암만 해봐도 모르겠네
//        mainvc.filterTodaysHabit()
//        mainvc.todaysHabitTableView.reloadData()
        
        print(habits)
        
    }
    
}


//Adding tableview and content

extension AllHabitsVC: UITableViewDelegate, UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.searchedHabits.count
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
//        return searchedHabits[section].desc.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0 //Choose your custom row
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let date = searchedHabits.first {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let header = dateFormatter.string(from: date.date)
//            return header
//        }
//        return "section: \(Date())"
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
        else {
            return UITableViewCell()
        }
        
        let newHabit = searchedHabits[indexPath.row]
        var title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        let time = newHabit.time
        
//        ======== 지금 당장 필요한 기능은 아니고, 나중에 혹시 필요할지도 몰라서..
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//
//        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
//            let today = "[Today] "
//            title = "[Today] " + title
//            cell.newHabitTitle.textColor = UIColor.red
//            print(date)
//        } else {
//            cell.newHabitTitle.textColor = UIColor.black
//        }
//        =======
        
        
        cell.newHabitTitle.text = title + " - "
        cell.newHabitDesc.text = desc
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = []
        
        if searchText == "" { //만약 searchText가 비었으면 habits전체를 나타냄.
            searchedHabits = habits
        }
        
        for habit in habits { //만약 habits 안에 있는 habit.title이 검색된 것에 해당하면 그것을 searchedHabits[] 안으로
            if habit.title.lowercased().contains(searchText.lowercased()) {
                searchedHabits.append(habit)
            }
        }
        self.allHabitsTableView.reloadData() //tableView를 reload
    }
    
}


