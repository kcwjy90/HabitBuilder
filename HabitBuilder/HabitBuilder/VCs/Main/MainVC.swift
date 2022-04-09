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
    
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    
    // 음...Habit Builder라는곳 색은 흰색으로 놔두고 날짜 있는 부분은 색을 바꾸기  위해. 근데 다른 방법이 있지 않을까?
    lazy var secondBackView: UIView = {
        let v = UIView()
        v.backgroundColor = .exoticLiras
        return v
    }()
    
    // TablewView 생성
    lazy var goalTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    // Date Label 생성
    lazy var date: UILabel = {
        let autoDate = Date() //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" //왜 DD 로 하면 09 대신에 99가 찍히며 mm 하면 04 대신에 15가 찍히는가?
        let currentDate = dateFormatter.string(from: autoDate)
        let v = UILabel()
        v.text = currentDate
        v.font = UIFont.systemFont(ofSize: 20.0)
        return v
    }()
    
    
    override func loadView() {
        super.loadView()
        
        // migration
        let configuration = Realm.Configuration(schemaVersion:3)
        let localRealm = try! Realm(configuration: configuration)
        
        setNaviBar()
        
        view.addSubview(backView)
        view.addSubview(secondBackView)
        view.addSubview(date)
        view.addSubview(goalTableView)
        
        // backview grid
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
        
        // second backveiw grid
        secondBackView.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(150)
            make.left.right.bottom.equalTo(backView)
        }
        
        // NAVIGATION BAR 밑에 바로 넣을라면 어떡해야 하나....
        date.snp.makeConstraints{ (make) in
            make.top.equalTo(secondBackView).offset(20)
            make.right.equalTo(secondBackView).offset(-10)
        }
        
        // goal tableview size grid
        goalTableView.snp.makeConstraints { (make) in
            make.top.equalTo(date.snp.bottom).offset(20)
            make.left.right.bottom.equalTo(backView)
        }
    }
    
    //Nav Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        title = "Habit Builder"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
        navigationController?.navigationBar.prefersLargeTitles = true
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
    func newGoal (title: String, detail: String) {
        print("HabitVC - title : \(title), detail: \(detail)")
        
        // Add some tasks
        let task = RMO_HB()
        task.title = title
        task.desc = detail
        
        let configuration = Realm.Configuration(schemaVersion:3)
        let localRealm = try! Realm(configuration: configuration)
        
        try! localRealm.write {
            localRealm.add(task)
        }
        
        // Get all tasks in the realm
        let tasks = localRealm.objects(RMO_HB.self)
        
        print(tasks)
        
        goalTableView.reloadData()
    }
    
}

//Adding tableview and content

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let configuration = Realm.Configuration(schemaVersion:3)
        let localRealm = try! Realm(configuration: configuration)
        
        let tasks = localRealm.objects(RMO_HB.self)
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
        
        let configuration = Realm.Configuration(schemaVersion:3)
        let localRealm = try! Realm(configuration: configuration)
        
        let tasks = localRealm.objects(RMO_HB.self)
        let habit = tasks[indexPath.row]
        let title = habit.title
        let desc = habit.desc
        
        cell.newTitle.text = title + " - "
        cell.newDetail.text = desc
        
        return cell
    }
    
    
}

//Q. Backview를 2개 만드는거 말고, Habit Builder Nav Bar는 하얗게, 날짜는 색깔입히는거
//Q. 형이 만드 색깔 가지고 오는거
//Q. line 104 v.delegate = self가 하는 일을 다시 한번만 설명을...
//Q. TabBar를 AppDelegate에 넣는거는 끝끝내 못했는디..다 가르쳐 주지 마시고, 조금만 힌트를..

//3/30
//1. 근데 realm db를 extension에 생성 하는게 맞는가? scope문제로 인해서 일단 여기다 생성하기는 했는데..
//2.indexpath를 바꿔야 하는건가?? 근데 그러려면 어떻게 바꿔야 하는거지? indexpath 는 tablecell이랑 연관이 있고,
