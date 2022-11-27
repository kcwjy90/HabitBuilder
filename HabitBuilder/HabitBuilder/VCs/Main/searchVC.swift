import UIKit

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
    var habits: [RMO_Habit] = []
    var searchedHabits: [RMO_Habit] = []
    
    
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
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        searchedHabits = habits
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
        //        print("Row: \(indexPath.row)")  print(habits[indexPath.row].date)
        
        var habit: RMO_Habit
        
        //MARK: cell을 touch 하면 이 data들이 HabitDetailVC로 날라간다.
        if habitSearched {
            habit = searchedHabits[indexPath.row]
        } else {
            habit = habits[indexPath.row]
        }
        
        print("지금 tap 헀음. 현제 IndexPath.row는 \(indexPath.row)")
        
        //MARK: CONSTRUCTOR. HabitDetailVC에 꼭 줘야함.
        let habitDetailVC = HabitDetailVC(habit: habit)
        habitDetailVC.delegate = self
        
        habitDetailVC.modalPresentationStyle = .pageSheet
        present(habitDetailVC, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if habitSearched {
            print("search 됨 - searchedHabtits.count =  \(searchedHabits.count)")
            
            // 결국 여기서 걸려서 에러가 나는데..문제가 filter된 row랑 지워야 되는 row가 아직도 안 맞는다는 건데...분명히 rr로 업데이트를 했으면 맞아야 하는거 아닌가...???
            
            return searchedHabits.count //원래는 Habits였으나 searchedHabits []으로 바뀜
            
        } else {
            print("search 안됨 - habits.count =  \(habits.count)")
            return habits.count
        }
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
            
            let newHabit = searchedHabits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        } else {
            
            let newHabit = habits[indexPath.row] //원래는 habits[indexPath.row] 였으나 searchedHabits으로
            let title = newHabit.title
            let desc = newHabit.desc
            
            cell.newHabitTitle.text = title + " - "
            cell.newHabitDesc.text = desc
            
        }
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedHabits = []
        
        if searchText != "" {
            habitSearched = true
            searchedT = searchText //search한 text를 저장.
            
            searchedHabits = habits.filter { habit in
                return habit.title.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            habitSearched = false
        }
        self.searchedTableView.reloadData() // search 했고 안했고를 반영해주는 reload
    }
}
