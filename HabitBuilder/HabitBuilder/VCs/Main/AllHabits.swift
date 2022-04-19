////
////  MainVC.swift
////  HabitBuilder
////
////  Created by CW on 1/25/22.
////  Copyright © 2022 CW. All rights reserved.
////
//
//import UIKit
//import SnapKit
//import RealmSwift
//
//
//
//class AllHabitsVC: UIViewController {
//    
//    // backView 생성
//    lazy var backView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .white
//        return v
//    }()
//    
//    // searchBar 생성
//    lazy var searchBar : UISearchBar = {
//        let v = UISearchBar()
//        v.searchBarStyle = .minimal
//        return v
//    }()
//    
//    // dateLabelBackView 생성
//    lazy var dateLabelBackView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .starWhite
//        return v
//    }()
//    
//    // dateLabel 생성
//    lazy var dateLabel: UILabel = {
//        let autoDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        let currentDate = dateFormatter.string(from: autoDate)
//        let v = UILabel()
//        v.text = currentDate
//        v.font = UIFont.boldSystemFont(ofSize: 18.0)
//        //        v.backgroundColor = .blue
//        return v
//    }()
//    
//    // todaysHabitTablewView 생성
//    lazy var todaysHabitTableView: UITableView = {
//        let v = UITableView()
//        v.register(HabitTableCell.self,
//                   forCellReuseIdentifier:"MyCell")
//        v.delegate = self
//        v.dataSource = self
//        return v
//    }()
//    
//    let localRealm = DBManager.SI.realm!
//    
//    // Habits array. RMO_Habit에서 온 data가 여기 들어감. 지금은 empty.
//    var habits: [RMO_Habit] = []
//    
//    
//    override func loadView() {
//        super.loadView()
//        
//        setNaviBar()
//        
//        view.addSubview(backView)
//        view.backgroundColor = .white
//        backView.addSubview(searchBar)
//        backView.addSubview(dateLabelBackView)
//        dateLabelBackView.addSubview(dateLabel)
//        backView.addSubview(todaysHabitTableView)
//        
//        // BackView grid
//        backView.snp.makeConstraints { (make) in
//            make.top.equalTo(view).offset(64)
//            make.left.right.bottom.equalTo(view)
//        }
//        
//        // searchBar grid
//        searchBar.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(backView)
//            make.height.equalTo(44)
//        }
//        
//        // dateLabelBackView backveiw grid
//        dateLabelBackView.snp.makeConstraints{ (make) in
//            make.top.equalTo(searchBar.snp.bottom)
//            make.left.right.equalTo(backView)
//            make.height.equalTo(52)
//        }
//        
//        // dateLabel grid
//        dateLabel.snp.makeConstraints{ (make) in
//            make.centerY.equalTo(dateLabelBackView)
//            make.right.equalTo(dateLabelBackView).offset(-10)
//        }
//        
//        // todaysHabitTableView grid
//        todaysHabitTableView.snp.makeConstraints { (make) in
//            make.top.equalTo(dateLabelBackView.snp.bottom)
//            make.left.right.bottom.equalTo(backView)
//        }
//        
////       filter하는거
//        habits = localRealm.objects(RMO_Habit.self).filter {
//            habit in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let habitDate = dateFormatter.string(from: habit.date)
//            let today = Date()
//            let todaysDate = dateFormatter.string(from: today)
//            return habitDate == todaysDate
//        }
//
//        
//    }
//    
//    //Navi Bar 만드는 func. loadview() 밖에!
//    func setNaviBar() {
//        title = "Habit Builder"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
//        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationController?.navigationBar.backgroundColor = .white
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Add",
//            style: .done,
//            target: self,
//            action: #selector(addItem)
//        )
//        
//        //SearchController 더하는 코드
////        let searchController = UISearchController(searchResultsController: MainVC())
////        navigationItem.searchController = searchController
//        
//    }
//    
//    @objc func addItem(){
//        let v = NewHabitVC()
//        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
//        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
//        present(v, animated:true)   // modal view 가능케 하는 코드
//    }
//}
//
//// extension 은 class 밖에
//extension AllHabitsVC: NewHabitVCDelegate {
//    func didCreateNewHabit (title: String, desc: String, date: Date, time: Date) {
//        print("HabitVC - title : \(title), detail: \(desc)")
//        
//        // Get new habit from RMO_Habit
//        let fromRMO_Habit = RMO_Habit()
//        fromRMO_Habit.title = title
//        fromRMO_Habit.desc = desc
//        fromRMO_Habit.date = date
//        fromRMO_Habit.time = time
//        
//        try! localRealm.write {
//            localRealm.add(fromRMO_Habit)
//        }
//        
//        // Get all habits in the realm
//        let habits = localRealm.objects(RMO_Habit.self)
//        
//        print(habits)
//        
//        todaysHabitTableView.reloadData()
//    }
//    
//}
//
////Adding tableview and content
//
//extension AllHabitsVC: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Row: \(indexPath.row)")
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        let habits = localRealm.objects(RMO_Habit.self)
//        return habits.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 44.0 //Choose your custom row
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
//        else {
//            return UITableViewCell()
//        }
//        
//        //        let autoDate = Date() //왜 얘는 또 4/15/22 이찍히는거야...
//                
//        let habits = localRealm.objects(RMO_Habit.self)
//        let newHabit = habits[indexPath.row]
//        let title = newHabit.title
//        let desc = newHabit.desc
//        let date = newHabit.date
//        let time = newHabit.time
//        
//        cell.newHabitTitle.text = title + " - "
//        cell.newHabitDesc.text = desc
//        
//        
//        return cell
//    }
//    
//    
//}
