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
    
    // search 됐느냐 안됐느냐에 따라 section이 다르게 나누기 위해.
    var habitSearched: Bool = false
    
    let localRealm = DBManager.SI.realm!
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit] = []
    var searchedT: String = ""
    
    var sectionedHabit = [Date:Results<RMO_Habit>]() // section하기 위해서
    var itemDates = [Date]() //이것도 section하기 위해서
    
    
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        
        // 날짜대로 section만드는 func
        createSection()
        
        setNaviBar()
        
        searchBar.delegate = self
        
        view.backgroundColor = .white
        view.addSubview(backView)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    //MARK: Navi Bar 만드는 func. loadview() 밖에!
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
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swipe to dismiss tableView
        allHabitsTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    
    //MARK: Navi Bar에 있는 'Add' Button을 누르면 작동함.
    @objc func addItem(){
        let v = NewHabitVC()
        v.delegate = self   //와.. 이거 하나 comment out 했더니 막 아무것도 안됐는데...
        v.modalPresentationStyle = .pageSheet //fullscreen 에서 pagesheet으로 바꾸니 내가 원하는 모양이 나옴. Also, you can swipe page down to go back.
        present(v, animated:true)   // modal view 가능케 하는 코드
    }
    
    //MARK: tableView reload 시킴
    func reloadData() {
        // Get all habits in the realm
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        searchedHabits = habits
        createSection() // Section을 다시 reload해서 만약 날짜가 edit 되었으면 section도 update시킴
        allHabitsTableView.reloadData()
    }
    
    //MARK: Section 나누는 코드
    func createSection() {
        
        //Find each unique day for which an Item exists in your Realm
        itemDates = localRealm.objects(RMO_Habit.self).reduce(into: [Date](), { results, currentItem in
            let date = currentItem.date
            guard let beginningOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0)),
                  let endOfDay = Calendar.current.date(from: DateComponents(
                    year: Calendar.current.component(.year, from: date),
                    month: Calendar.current.component(.month, from: date),
                    day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))
            else { return }
            
            //Only add the date if it doesn't exist in the array yet
            if !results.contains(where: { addedDate->Bool in
                return addedDate >= beginningOfDay && addedDate <= endOfDay
            }) {
                results.append(beginningOfDay)
            }
        })
        
        //sorting by Date
        itemDates = itemDates.sorted()
        
        //Filter each Item in realm based on their date property and assign the results to the dictionary
        sectionedHabit = itemDates.reduce(into: [Date:Results<RMO_Habit>](), { results, date in
            
            guard let beginningOfDay = Calendar.current.date(from: DateComponents(
                year: Calendar.current.component(.year, from: date),
                month: Calendar.current.component(.month, from: date),
                day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0)),
                  let endOfDay = Calendar.current.date(from: DateComponents(
                    year: Calendar.current.component(.year, from: date),
                    month: Calendar.current.component(.month, from: date),
                    day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))
            else { return }
            
            results[beginningOfDay] = localRealm.objects(RMO_Habit.self).filter("date >= %@ AND date <= %@", beginningOfDay, endOfDay)
        })
    }
    
}

//MARK: NewHabitVC에서 새로 생성된 habit들. RMO_Habit에 넣을 예정
extension AllHabitsVC: NewHabitVCDelegate {
    func didCreateNewHabit (title: String, desc: String, date: Date, time: Date) {
        //        print("HabitVC - title : \(title), detail: \(desc)")
        
        // Get new habit from RMO_Habit
        let newHabit = RMO_Habit()
        newHabit.title = title
        newHabit.desc = desc
        newHabit.date = date
        newHabit.time = time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let habitDate = dateFormatter.string(from: date) // habitDate = 방금받은 habit의 date
        let countRealm = localRealm.objects(RMO_Count.self)
        
        //MARK:RMO_Count 확인 -> either 새로운 날짜 추가 or existing 날짜에 total +1
        //새로 생성된 habit의 날짜가 RMO_Count에 있는지 확인하고, 없을 경우 RMO_Count에 추가한다.
        if !countRealm.contains(where: { $0.date == habitDate} )
        {
            let newCount = RMO_Count()
            newCount.date = habitDate
            
            try! localRealm.write {
                localRealm.add(newCount)
                print("생성")
                print(newCount)
            }
        }
        
        try! localRealm.write {
            localRealm.add(newHabit)
        }
        
        //만약 RMO_Count에 지금 add하는 날짜의 object가 있을경우 그 total 을 +1 한다
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == habitDate}) else
        {return}
        let existCount = countRealm[indexNumb]
        
        try! localRealm.write {
            existCount.total += 1
            print("+1")
            print(existCount)
        }
        
        createSection()
        reloadData()
    }
}

//MARK: HabitDetail에서 Habit을 수정 할경우 다시 tableview가 reload 됨
extension AllHabitsVC: habitDetailVCDelegate {
    func editComp() {
        if habitSearched {
            searchedHabits = habits.filter { habit in
                //Search한 상태에서 title의 value를 바꾸고 난후 reload 되었을때 계속 search한 상태의 스크린이 뜬다. 원래는 tableView가 그냥 reload 되서, search 안 한 상태로 바뀌어 버렸다.
                return habit.title.lowercased().contains(searchedT.lowercased())
            }
            habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
            createSection()
            self.allHabitsTableView.reloadData()
        } else {
            self.reloadData()
        }
    }
}


//Adding tableview and content
extension AllHabitsVC: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: searched vs unsearched에 따라 section 수가 나뉨.
    func numberOfSections(in tableView: UITableView) -> Int {
        if habits.count == 0 {
            print("없음")
            return 0
        }
        
        if habitSearched == true { //search 하고 있을때는 section 이 하나로
            print("설치됨")
            return 1
        } else {
            print("설치는안돼")
            return itemDates.count //search 안할때는 itemDates 수에 따라서
        }
    }
    
    //MARK: searched vs unsearched에 따라 section title이 나뉨.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if habits.count == 0 {
            return ""
        }
        
        if habitSearched == true { //search 하고 있을때는 Heading 이 Search Result로
            return ""
        } else {
            if let data = sectionedHabit[itemDates[section]], let first = data.first { // search 날짜를 heading으로
                let dateFormmater = DateFormatter()
                dateFormmater.dateFormat = "MM/dd/YYYY"
                return dateFormmater.string(from: first.date)
            } else {
                return nil
            }
        }
    }
    
    //MARK: searched vs unsearched에 따라 section안에 있는 cell 수가 나뉨.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if habits.count == 0 {
            return 0
        }
        
        if habitSearched == true {
            return searchedHabits.count //serach 를 하면 searchedHabits row number 를
        } else {
            if let data = sectionedHabit[itemDates[section]] { // search
                return data.count  // 안하면 sectionedHabit row number 를
            } else {
                return 0 //return 0 를 안넣으면 안되네 또..
            }
        }
    }
    
    //MARK: cell을 tap 했을때 무슨일이 일어나나? data들이 HabitDetailVC로 날라간다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var habit: RMO_Habit? //? optional 로 안하고 if let/guard let 쓰면 에러 뜸. "Initializer for conditional binding must have Optional type, not 'RMO_Habit'"
        
        if habits.count == 0 {
            return
        }
        
        if habitSearched == true {
            print(indexPath.row)
            habit = searchedHabits[indexPath.row]
        } else {
            
            //옵셔널 벗기기 해서
            if let sectionedData = sectionedHabit[itemDates[indexPath.section]] {
                habit = sectionedData[indexPath.row]
            }
        }
        
        //이것을 guard let으로
        guard let gHabit = habit else {
            print("error")
            return
        }
        
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: gHabit)
        habitDetailVC.delegate = self
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0 //Choose your custom row
    }
    
    
    //MARK: cell에 넣을 정보를 어디서 뽑아 오는가?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? HabitTableCell
        else {
            return UITableViewCell()
        }
        
        if habits.count == 0 {
            return cell
        }
        
        if habitSearched == true { //search 가 되었을경우는 searchedHabit 에서만 object를..
            let newHabit = searchedHabits[indexPath.row]
            var title = newHabit.title
            let desc = newHabit.desc
            let date = newHabit.date
            let time = newHabit.time
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else { //아닌경우는 groupedHabits에서 뽑아온다
            if let itemsForDate = sectionedHabit[itemDates[indexPath.section]] {
                var habit = itemsForDate[indexPath.row]
                cell.newHabitTitle.text = habit.title + " - "
                cell.newHabitDesc.text = habit.desc
            }
        }
        return cell
    }
    
    //MARK: searchBar가 비어있느냐 안 비어있느냐에 따라 display되는 habit이 다름
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = [] //비어있는 searchedHabits
        let habits = localRealm.objects(RMO_Habit.self).toArray() // RMO_Habit 을 array로
        
        if searchText != "" { //만약 searchText가 비어있지 않으면
            habitSearched = true
            searchedT = searchText //search한 text를 저장.
            
            searchedHabits = habits.filter { habit in //searchedHabits은 Habit 을 filter한것과 =
                return habit.title.lowercased().contains(searchText.lowercased()) //filter내용은 title = searchText
            }
        } else {
            self.searchedHabits = self.habits // searchText가 비어 있으면 searchedHabits = habits.
            habitSearched = false
            
        }
        self.allHabitsTableView.reloadData() //tableView를 reload
    }
    
    
    
    
    
    
    
    //MARK: swipe 해서 지우는 function
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //MARK: searched vs unsearched 상황에서 delete 하기
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if habits.count == 0 {
                return
            }
            
            if habitSearched == true {
                
                let realm = localRealm.objects(RMO_Habit.self)
                let habit = searchedHabits[indexPath.row]
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
                
            } else {
                
                let realm = localRealm.objects(RMO_Habit.self)
                
                var habit: RMO_Habit?
                var toArray: [RMO_Habit]?
                
                
                if let sectionedData = sectionedHabit[itemDates[indexPath.section]] {
                    habit = sectionedData[indexPath.row]
                }
                
                guard let gHabit = habit else {
                    print("error")
                    return
                }
                
                //일단 toArray로 해야만 .remove를 쓸수 있기 때문에 이렇게 꼭 써야하고, 왜 인지는 모르겠는데 toArray를 try!localRealm.write 코드 아래에서 실행할경우 마지막 row를 지울떄 error가 남
                if let sectionedArray = sectionedHabit[itemDates[indexPath.section]] {
                    toArray = sectionedArray.toArray()
                }
                
                guard var gToArray = toArray else {
                    print("error")
                    return
                }
                
                let thisId = gHabit.id
                
                try! localRealm.write {
                    let deleteHabit = realm.where {
                        $0.id == thisId
                    }
                    localRealm.delete(deleteHabit)
                }
                
                tableView.beginUpdates()
                gToArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                
            }
        }
    }
}
