//
//  searchVC.swift
//  HabitBuilder
//
//  Created by ppc90 on 7/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import RealmSwift

class searchVC: UIViewController, UISearchBarDelegate {
    
    
    let localRealm = DBManager.SI.realm!
    
    //realm Noti 에서 쓰는거
    deinit {
        print("deinit - NewHabitVC")
        notificationToken?.invalidate()
    }
    
    //realm Noti 에서 쓰는거
    var status: NewHabitVCStatus = .initialize
    var notificationToken: NotificationToken? = nil
    
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
    
    // searchTableView 생성
    lazy var searchedTableView: UITableView = {
        let v = UITableView()
        v.register(HabitTableCell.self,
                   forCellReuseIdentifier:"MyCell")
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    // habit이 검색됨에 따라 tableView에 보여지는걸 다르게 하기 위해서
    var habitSearched: Bool = false
    var searchedT: String = ""
    
    // RMO_Habit에서 온 data를 넣을 empty한 array들
    var habits: Results<RMO_Habit>? = nil
    
    
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        searchBar.delegate = self
        
        view.addSubview(backView)
        view.backgroundColor = .white
        backView.addSubview(searchBar)
        backView.addSubview(searchedTableView)
        
        // BackView size grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // searchBar size grid
        searchBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backView)
            make.height.equalTo(44)
        }
        
        // allHabitsTableView size grid
        searchedTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(backView)
        }
        
        realmNoti()
    }
    
    
    
    //MARK: Navi Bar 만드는 func. loadview() 밖에!
    func setNaviBar() {
        title = "Search Habits"         // Nav Bar. 와우 간단하게 title 만 적어도 생기는구나..
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        
        overrideUserInterfaceStyle = .light //이게 없으면 앱 실행시키면 tableView가 까만색
        
        // Swipe to dismiss tableView
        searchedTableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
}



//Adding tableview and content
extension searchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        guard let habit = habits?[indexPath.row] else { return }
        
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if habitSearched {
            habits = self.localRealm.objects(RMO_Habit.self).where {
                ($0.title.contains(searchedT, options: .caseInsensitive))
            }
            
        } else {
            habits = self.localRealm.objects(RMO_Habit.self)
        }
        
        guard let theHabits = habits else {return 0}
        return theHabits.count
        
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
        
        if habitSearched {
            
            habits = self.localRealm.objects(RMO_Habit.self).where {
                ($0.title.contains(searchedT, options: .caseInsensitive))
            }
            
            guard let theHabits = habits else {return UITableViewCell()
}
            let newHabit = theHabits[indexPath.row]
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else {
            
            habits = self.localRealm.objects(RMO_Habit.self)
            guard let theHabits = habits else {return UITableViewCell()}
            
            let newHabit = theHabits[indexPath.row]
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        }
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                
        if searchText != "" {
            habitSearched = true
            searchedT = searchText //search한 text를 저장.
            
            habits = self.localRealm.objects(RMO_Habit.self).where {
                ($0.title.contains(searchedT, options: .caseInsensitive))
            }
            
            (habits) = habitsUpdatedAfterFilter()
            print("habits after searched \(habits)")
            
        } else {
            habitSearched = false
            habits = self.localRealm.objects(RMO_Habit.self)
            print("habits not searched \(habits)")

        }
        
        self.searchedTableView.reloadData() // search 했고 안했고를 반영해주는 reload. 이건 아마 realm noti랑은 상관없는듯..왜냐 이건 realm 에 바뀐게 아니라, 지금 화면에 뜨는 tableView에 바뀌는것을 반영해주는 거니까
    }
    
    
    
    //MARK: Realm Notification function
    func realmNoti() {
        
        print("여기는 뭘까요 \(habits)")

        habits = self.localRealm.objects(RMO_Habit.self)
        
        //notificationToken 은 ViewController 가 닫히기 전에 꼭 release 해줘야 함. 에러 나니까 코멘트
        guard let theHabits = self.habits else {return}
        notificationToken = theHabits.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.searchedTableView else { return }
            
            print("여기는 뭘까요 \(self?.habits)")

            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                
                
                // Query results have changed, so apply them to the UITableView
                tableView.performBatchUpdates({
                    
                    // Always apply updates in the following order: deletions, insertions, then modifications.
                    // Handling insertions before deletions may result in unexpected behavior.
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    
                    
                }, completion: { finished in
                })
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    func habitsUpdatedAfterFilter () -> (RealmSwift.Results<HabitBuilder.RMO_Habit>){
        
        if habitSearched == true {
            habits = self.localRealm.objects(RMO_Habit.self).where {
                ($0.title.contains(searchedT, options: .caseInsensitive))
            }
        }
    
            //FIXME: 고쳐야함
        return(habits!)
        
    }
    
}



