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
    
    // todaysHabitTablewView 생성
    lazy var todaysHabitTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
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
    
    override func loadView() {
        super.loadView()
        
        // migration
        let configuration = Realm.Configuration(schemaVersion:5)
        let localRealm = try! Realm(configuration: configuration)
        
        setNaviBar()
        
        view.addSubview(backView)
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
    }
    
    @objc func addItem(){
        let v = NewHabitVC()
        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
        v.modalPresentationStyle = .fullScreen
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
}

// extension 은 class 밖에
extension MainVC: NewHabitVCDelegate {
    func newHabit (title: String, desc: String) {
        print("HabitVC - title : \(title), detail: \(desc)")
        
        // Get new habit from RMO_Habit
        let fromRMO_Habit = RMO_Habit()
        fromRMO_Habit.title = title
        fromRMO_Habit.desc = desc
        
        let configuration = Realm.Configuration(schemaVersion:5)
        let localRealm = try! Realm(configuration: configuration)
        
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
        let configuration = Realm.Configuration(schemaVersion:5)
        let localRealm = try! Realm(configuration: configuration)
        
        let tasks = localRealm.objects(RMO_Habit.self)
        return tasks.count
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
        
        let configuration = Realm.Configuration(schemaVersion:5)
        let localRealm = try! Realm(configuration: configuration)
        
        let habits = localRealm.objects(RMO_Habit.self)
        let newHabit = habits[indexPath.row]
        let title = newHabit.title
        let desc = newHabit.desc
        
        cell.newHabitTitle.text = title + " - "
        cell.newHabitDesc.text = desc
        
        return cell
    }
    
    
}

//Q. Backview를 2개 만드는거 말고, Habit Builder Nav Bar는 하얗게, 날짜는 색깔입히는거
//Q. 형이 만드 색깔 가지고 오는거
//Q. line 104 v.delegate = self가 하는 일을 다시 한번만 설명을...

//3/30
//1. 근데 realm db를 extension에 생성 하는게 맞는가? scope문제로 인해서 일단 여기다 생성하기는 했는데..
