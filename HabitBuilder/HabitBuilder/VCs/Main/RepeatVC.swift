//
//  RepeatVC.swift
//  HabitBuilder
//
//  Created by ppc90 on 5/26/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import UserNotifications

protocol RepeatVCDelegate: AnyObject {
    //    func didCreateNewHabit(title: String, desc: String, date: Date, time: Date)
}

class Section {
    let title: String
    let options: [String]
    var isOpened: Bool = false
    
    init(title: String,
         options: [String],
         isOpened: Bool = false
    ) {
        self.title = title
        self.options = options
        self.isOpened = isOpened
    }
}

class RepeatVC: UIViewController {
    
    weak var delegate: RepeatVCDelegate?   // Delegate property var 생성
    
    let localRealm = DBManager.SI.realm!
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // backButton 생성
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setTitle("Back", for: .normal)
        v.setTitleColor(.red, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // pageLabel 생성
    lazy var pageLabel: UILabel = {
        let v = UILabel()
        v.text = "Repeat Option"
        v.textColor = .black
        v.font = UIFont.boldSystemFont(ofSize: 16.0)
        return v
    }()
    
    // saveButton 생성
    lazy var saveButton: UIButton = {
        let v = UIButton()
        v.setTitle("Save", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    
    // repeatTableView 생성
    lazy var repeatTableView: UITableView = {
        let v = UITableView()
        v.register(RepeatTableCell.self,
                   forCellReuseIdentifier:"MyCell")
                    v.delegate = self
                    v.dataSource = self
        return v
    }()
    
    private var sections = [Section]()
        
    override func loadView() {
        super.loadView()
        
        sections = [
            Section(title: "Daily", options:["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"].compactMap({return "\($0)"})),
            Section(title: "Weekly", options:["Every Week","Every 2 Weeks","Every 3 Weeks","Every 4 Weeks","Every 5 Weeks"].compactMap({return " \($0)"})),
            Section(title: "Monthly", options:["1st of Each Month","5th of Each Month","10th of Each Month","15th of Each Month","20th of Each Month","25th of Each Month","Last day of Each Month"].compactMap({return "\($0)"})),
            Section(title: "Custom", options:["Once Every __ Days"].compactMap({return "\($0)"}))
        ]
        
        view.addSubview(backView)
        backView.addSubview(backButton)
        backView.addSubview(pageLabel)
        backView.addSubview(saveButton)
        backView.addSubview(repeatTableView)
        backView.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // backToMainButton size grid
        backButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // pageLabel size grid
        pageLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.centerX.equalTo(backView)
            make.height.equalTo(40)
        }
        
        // addHabitButton size grid
        saveButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.right.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // repeatTableView grid
        repeatTableView.snp.makeConstraints { (make) in
            make.top.equalTo(pageLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(backView)
        }
        
    }
    
}


//Adding tableview and content
extension RepeatVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        
        if section.isOpened {
            return section.options.count + 1
        } else {
            return 1
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 { //이렇게 하지 않으면 cell을 tap한 순간 collapse 된다.
            sections[indexPath.section].isOpened = !sections[indexPath.section].isOpened
            tableView.reloadSections([indexPath.section], with: .none)
        } else {
            print(indexPath.row)
        }
        
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0 //Choose your custom row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? RepeatTableCell
        else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.cellTitle.text = sections[indexPath.section].title
        } else {
            cell.cellTitle.text = sections[indexPath.section].options[indexPath.row - 1]
        }
        
        return cell
    }
    

}
