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
    
    // 날짜 Label 생성
    lazy var date: UILabel = {
        let v = UILabel()
        v.text = "1/21/2022"
        v.font = UIFont.systemFont(ofSize: 20.0)
        return v
    }()
    
    
    public var myArray: [[String:String]] =
        [
            ["title": "Habit Builder", "detail": "숙제 정해진거 끝내기"]
    ]
    
    override func loadView() {
        super.loadView()
                
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
        title = "Habit Builder"
        navBar()
        
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
    func navBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addItem))
    }
    
    @objc func addItem(){
        let v = AddHabitVC()
        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
        v.modalPresentationStyle = .fullScreen
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
}

// extension 은 class 밖에
extension MainVC: addHabitVCDelegate {
    func addedGoal (title: String, detail: String) {
        print("HabitVC - title : \(title), detail: \(detail)")
        
        
        // Open the local-only default realm
        let localRealm = try! Realm()

        // Add some tasks
        let task = HabitBuilderDB()
        task.title = title
        task.desc = detail

        try! localRealm.write {
            localRealm.add(task)
        }

        // Get all tasks in the realm
        let tasks = localRealm.objects(HabitBuilderDB.self)

        print(tasks)
        
        goalTableView.reloadData()
    }
    
}

//Adding tableview and content

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
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
        
        let localRealm = try! Realm()
        
        
        let tasks = localRealm.objects(HabitBuilderDB.self)
                
        print(tasks)
        let d = tasks[indexPath.row]
        print("-------")
        print(d)
        let title = tasks[16].title
        let detail = d.desc
        
        cell.newTitle.text = title + " - "
        cell.newDetail.text = detail

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
