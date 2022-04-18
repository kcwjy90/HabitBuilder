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

class MainVC: UIViewController {
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
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
    
    var habits: [RMO_Habit] = []
    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        view.addSubview(backView)
        view.backgroundColor = .white
        backView.addSubview(dateLabelBackView)
        dateLabelBackView.addSubview(dateLabel)
        backView.addSubview(todaysHabitTableView)
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.bottom.equalTo(view)
        }
        
        // dateLabelBackView backveiw grid
        dateLabelBackView.snp.makeConstraints{ (make) in
            make.top.left.right.equalTo(backView)
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
        
        reloadHabits()
    }
    
    func removeTimeFrom(date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let date = Calendar.current.date(from: components)
        return date!
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
        
        //SearchController 더하는 코드
        let searchController = UISearchController(searchResultsController: MainVC())
        navigationItem.searchController = searchController
        
    }
    
    @objc func addItem(){
        let v = NewHabitVC()
        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    func reloadHabits() {
        let today = removeTimeFrom(date: Date())
        let predicate = NSPredicate(format: "date >= %@", today as NSDate)
        habits = localRealm.objects(RMO_Habit.self).filter(predicate).toArray(type: RMO_Habit.self)
        todaysHabitTableView.reloadData()
    }
}

// extension 은 class 밖에
extension MainVC: NewHabitVCDelegate {
    func newHabit (title: String, desc: String, date: Date, time: Date) {
        print("HabitVC - title : \(title), detail: \(desc)")
        
        // Get new habit from RMO_Habit
        let habit = RMO_Habit()
        habit.title = title
        habit.desc = desc
        habit.date = date
        habit.time = time
        
        try! localRealm.write {
            localRealm.add(habit)
        }
        
        // Get all habits in the realm
        let habits = localRealm.objects(RMO_Habit.self)
        print(habits)
        
        reloadHabits()
    }
    
}

//Adding tableview and content

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return habits.count
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
        
        let habit = habits[indexPath.row]
        cell.newHabitTitle.text = habit.title
        cell.newHabitDesc.text = habit.desc
        
        
        return cell
    }
    
    
}

//Q. UISearchController가 날짜를 가리는데..이것을 어찌 해야하나...게다가 search를 누르면 다른애들을 몽땅 같이 끌어 올리는거는 안돼는가 ㅜㅜㅜㅜ
//Q. line 104 v.delegate = self가 하는 일을 다시 한번만 설명을...

//아직 해야 하는거
//2. delegate 다시 연습
//3. 오늘 날짜에 맞는게 표시되도록 적용 .....흠....이대로 하면은 오늘에 해당하는 것만 보이기는 하는데 중간에 cell들은 비어있단 말이지. 해당 안되는 row 는 건너뛰고 비어있는 다음cell 에 해당 되는 row 를 어찌 찍어야 하는고...
//5. 나머지

