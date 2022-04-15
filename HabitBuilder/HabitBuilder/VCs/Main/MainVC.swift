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
        v.backgroundColor = .exoticLiras
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
        v.font = UIFont.systemFont(ofSize: 18.0)
        v.backgroundColor = .blue
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

    override func loadView() {
        super.loadView()
        
        setNaviBar()
            
        view.addSubview(backView)
        view.backgroundColor = .yellow
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
    }
    
    //Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        title = "Habit Builder"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .green
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
}

// extension 은 class 밖에
extension MainVC: NewHabitVCDelegate {
    func newHabit (title: String, desc: String, date: String, time: String, dateTime: Date) {
        print("HabitVC - title : \(title), detail: \(desc)")
        
        // Get new habit from RMO_Habit
        let fromRMO_Habit = RMO_Habit()
        fromRMO_Habit.title = title
        fromRMO_Habit.desc = desc
        fromRMO_Habit.date = date
        fromRMO_Habit.time = time
        fromRMO_Habit.dateTime = dateTime
        
        try! localRealm.write {
            localRealm.add(fromRMO_Habit)
        }
        
        // Get all habits in the realm
        let habits = localRealm.objects(RMO_Habit.self)
        
        print(habits)
        
        todaysHabitTableView.reloadData()
    }
    
}

//Adding tableview and content

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let habits = localRealm.objects(RMO_Habit.self)
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
        
//        let autoDate = Date() //왜 얘는 또 4/15/22 이찍히는거야...
        
        let todaysDate = dateLabel.text
        
        let habits = localRealm.objects(RMO_Habit.self)
        let newHabit = habits[indexPath.row]
        
        if todaysDate == newHabit.date {
            
        let title = newHabit.title
        let desc = newHabit.desc
        let date = newHabit.date
        let time = newHabit.time
        let dateTime = newHabit.dateTime
        
        cell.newHabitTitle.text = title + " - "
        cell.newHabitDesc.text = desc
        }
        
        return cell
    }
    
    
}

//Q. UISearchController가 날짜를 가리는데..이것을 어찌 해야하나...게다가 search를 누르면 다른애들을 몽땅 같이 끌어 올리는거는 안돼는가 ㅜㅜㅜㅜ
//Q. line 104 v.delegate = self가 하는 일을 다시 한번만 설명을...

//아직 해야 하는거
//2. delegate 다시 연습
//3. 오늘 날짜에 맞는게 표시되도록 적용 .....흠....이대로 하면은 오늘에 해당하는 것만 보이기는 하는데 중간에 cell들은 비어있단 말이지. 이것은 왜냐, count가 RMO_Habit obj에서 오기 때문인데..그럼 count의 number를 바꿔야 하는데 어찌하지?
//4. color 맞추기
//5. 나머지
