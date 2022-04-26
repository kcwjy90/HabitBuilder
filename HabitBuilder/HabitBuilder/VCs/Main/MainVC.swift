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



class MainVC: UIViewController, UISearchBarDelegate {
    
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
    
    let localRealm = DBManager.SI.realm!
    
    // Habits array. RMO_Habit에서 온 data가 여기 들어감. 지금은 empty.
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit]! //일단은 empty []로.
    
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
            make.top.equalTo(view).offset(64)
            make.left.right.bottom.equalTo(view)
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
    

    
}

//Adding tableview and content
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
        print(habits[indexPath.row].date)
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
        
        //        let autoDate = Date() //왜 얘는 또 4/15/22 이찍히는거야...
        
        let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
        let title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        let time = newHabit.time
        
        cell.newHabitTitle.text = title + " - "
        cell.newHabitDesc.text = desc
        
        return cell
    }
    
    // SearchBar.
    
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
        self.todaysHabitTableView.reloadData() //tableView를 reload
    }
    
}

// 해야 할것 - 1) 타임존 지정. 2) NSCalendar 써서 바꾸는 거

