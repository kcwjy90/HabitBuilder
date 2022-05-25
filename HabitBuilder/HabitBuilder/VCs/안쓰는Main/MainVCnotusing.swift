import SwiftUI
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
//
//class MainVC: UIViewController {
//
//    // backview 생성
//    lazy var backView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .white
//        return v
//    }()
//
//    // 음...Habit Builder라는곳 색은 흰색으로 놔두고 날짜 있는 부분은 색을 바꾸기  위해. 근데 다른 방법이 있지 않을까?
//    lazy var secondBackView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .exoticLiras
//        return v
//    }()
//
//    // TablewView 생성
//    lazy var goalTableView: UITableView = {
//        let v = UITableView()
//        v.register(HabitTableCell.self,
//                   forCellReuseIdentifier:"MyCell")
//        v.delegate = self
//        v.dataSource = self
//        return v
//    }()
//
//    // 날짜 Label 생성
//    lazy var date: UILabel = {
//        let v = UILabel()
//        v.text = "1/21/2022"
//        v.font = UIFont.systemFont(ofSize: 20.0)
//        return v
//    }()
//
//
//    public var myArray: [[String:String]] =
//        [
//            ["title": "Habit Builder", "detail": "숙제 정해진거 끝내기"]
//    ]
//
//    override func loadView() {
//        super.loadView()
//
//        navigationController?.navigationBar.prefersLargeTitles = true
//
//        // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
//        title = "Habit Builder"
//        navBar()
//
//        view.addSubview(backView)
//        view.addSubview(secondBackView)
//        view.addSubview(date)
//        view.addSubview(goalTableView)
//
//        // backview grid
//        backView.snp.makeConstraints { (make) in
//            make.top.left.right.bottom.equalTo(view)
//        }
//
//        // second backveiw grid
//        secondBackView.snp.makeConstraints{ (make) in
//            make.top.equalTo(backView).offset(150)
//            make.left.right.bottom.equalTo(backView)
//        }
//
//        // NAVIGATION BAR 밑에 바로 넣을라면 어떡해야 하나....
//        date.snp.makeConstraints{ (make) in
//            make.top.equalTo(secondBackView).offset(20)
//            make.right.equalTo(secondBackView).offset(-10)
//        }
//
//        // goal tableview size grid
//        goalTableView.snp.makeConstraints { (make) in
//            make.top.equalTo(date.snp.bottom).offset(20)
//            make.left.right.bottom.equalTo(backView)
//        }
//    }
//
//    //Nav Bar 만드는 func. loadview() 밖에!
//    func navBar() {
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Add",
//            style: .done,
//            target: self,
//            action: #selector(addItem))
//    }
//
//   SearchController 더하는 코드
//        let searchController = UISearchController(searchResultsController: MainVC())
//        navigationItem.searchController = searchController

//    @objc func addItem(){
//        let v = AddHabitVC()
//        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
//        v.modalPresentationStyle = .fullScreen
//        present(v, animated:true)   // modal view 가능케 하는 코드
//    }
//}
//
//// extension 은 class 밖에
//extension MainVC: addHabitVCDelegate {
//    func addedGoal (title: String, detail: String) {
//        print("HabitVC - title : \(title), detail: \(detail)")
//
//        myArray.append(["title":title, "detail": detail])
//
//        goalTableView.reloadData()
//    }
//
//}
//
////Adding tableview and content
//
//extension MainVC: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Row: \(indexPath.row)")
//        print("Value: \(myArray[indexPath.row])")
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return myArray.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 44.0 //Choose your custom row
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
//            else {
//                return UITableViewCell()
//        }
//
//        let d = myArray[indexPath.row]
//        let title = d["title"] ?? ""
//        let detail = d["detail"] ?? ""
//
//        cell.newTitle.text = title + " - "
//        cell.newDetail.text = detail
//
//        return cell
//    }
//
//
//}


//        Old SchemaVersion controller
//        let configuration = Realm.Configuration(schemaVersion:6)
//        let localRealm = try! Realm(configuration: configuration)


//N NewHabitVC - How to change format from date to string EXAMPLE
//@objc func addButtonPressed(sender: UIButton) {
//
//    // 지정한 date과 time의 format을 string으로 바꿔준다.
//    let dateFormatterDate = DateFormatter()
//    dateFormatterDate.dateFormat = "MM/dd/yyyy"
//    let newHabitDateString = dateFormatterDate.string(from: newHabitDate.date)
//    print(newHabitDateString)
//
//    let dateFormatterTime = DateFormatter()
//    dateFormatterTime.timeStyle = .short
//    let newHabitTimeString = dateFormatterTime.string(from: newHabitTime.date)
//    print(newHabitTimeString)
//
//    delegate?.didCreateNewHabit(title: newHabitTitle.text!, desc: newHabitDesc.text!, date: newHabitDateString, time: newHabitTimeString)
//    dismiss(animated: true, completion: nil)  //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
//
//}


// filter 말고 if 문을 돌려서 searchText filter 했던코드
//        if searchText != "" { //만약 searchText가 비었으면 habits전체를 나타냄.
//            searchedHabits = habits
//        }
//
//        for habit in habits { //만약 habits 안에 있는 habit.title이 검색된 것에 해당하면 그것을 searchedHabits[] 안으로
//            if habit.title.lowercased().contains(searchText.lowercased()) {
//                searchedHabits.append(habit)
//            }
//        }


// 시간 포멧할때 am/pm 나오게 하는법
//        let dateFormatter = DateFormatter()
//        let timeFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        timeFormatter.dateFormat = "h:mm a"
//        timeFormatter.amSymbol = "AM"
//        timeFormatter.pmSymbol = "PM"
//        habitDetailVC.habitDate.text = dateFormatter.string(from: habits[indexPath.row].date)
//        habitDetailVC.habitTime.text = timeFormatter.string(from: habits[indexPath.row].date)


//textfield, textview, datepicker등 user가 못 만지게 하는 코드
//habitDate.isUserInteractionEnabled = false

//// tapGasture - Dismisses Keyboard
//let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
//view.addGestureRecognizer(UITapGesture)
//


//swipe 하는거 처음 썼던 버전
//swipe 해서 지우는 function
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            let realm = localRealm.objects(RMO_Habit.self)
//            let habit = searchedHabits[indexPath.row]
//            let thisId = habit.id
//
//            try! localRealm.write {
//
//                let deleteHabit = realm.where {
//                    $0.id == thisId
//                }
//                localRealm.delete(deleteHabit)
//
//            }
//
//            //위에는 RMO_Habit에서 지워주는 코드. 밑에는 tableView자체에서 지워지는 코드
//            tableView.beginUpdates()
//            searchedHabits.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
//        }
//
//    }
//
