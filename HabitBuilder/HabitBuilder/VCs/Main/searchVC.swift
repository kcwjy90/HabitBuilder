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
        
        reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
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
    
    //MARK: tableView reload 시킴
    func reloadData() {
        // Get all habits in the realm
        habits = self.localRealm.objects(RMO_Habit.self)
        searchedTableView.reloadData()
    }
    
    
}


extension searchVC: habitDetailVCDelegate {
    func editComp() {
        
    }
}

//Adding tableview and content
extension searchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        guard let habit = habits?[indexPath.row] else { return }
        
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        habitDetailVC.delegate = self
        
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
        return habits!.count
        
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
            let newHabit = habits![indexPath.row]
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else {
            
            habits = self.localRealm.objects(RMO_Habit.self)
            let newHabit = habits![indexPath.row]
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        }
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        habits = self.localRealm.objects(RMO_Habit.self)
        
        if searchText != "" {
            habitSearched = true
            searchedT = searchText //search한 text를 저장.
            
            habits = self.localRealm.objects(RMO_Habit.self).where {
                ($0.title.contains(searchedT, options: .caseInsensitive))
            }
        } else {
            
            habitSearched = false
        }
        
        
        self.searchedTableView.reloadData() // search 했고 안했고를 반영해주는 reload
    }
    
    
    //MARK: rr Functio to update AFTER filtered
    //        func rrUpdateAfterFilter () -> (RealmSwift.Results<HabitBuilder.RMO_Habit>){
    //
    //
    //            if habitSearched == true {
    //                 hbs = self.localRealm.objects(RMO_Habit.self).where {
    //                    ($0.title.contains(searchedT, options: .caseInsensitive))
    //                }
    //
    //                print("새로운 rr= \(hbs)")
    //            }
    //
    //            //FIXME: 고쳐야함
    //            return(hbs!)
    //
    //        }
    
}
