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
    func didAddRepeat(repeatType: RepeatType)
}

let repeatSelection: [String] = ["None", "Daily", "Weekly", "Monthly", "Yearly"]

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
    
    
    override func loadView() {
        super.loadView()

        
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
        
        //MARK: Button Actions - AddHabitButton & backButton & repeatButton
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)        
    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
}


//Adding tableview and content
extension RepeatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatSelection.count
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
        
        cell.cellTitle.text = repeatSelection[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        guard let repeatType = RepeatType(rawValue: indexPath.row) else { return }
        delegate?.didAddRepeat(repeatType: repeatType)
        self.dismiss(animated: true, completion: nil)
    }

}

