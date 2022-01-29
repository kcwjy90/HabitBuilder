//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

// 이게 AddHabitVC랑 MainVC랑 연결 시켜주는 거든가?
protocol addHabitVCDelegate: class {
    func addedGoal(title: String, detail: String)
}

class AddHabitVC: UIViewController {
    
    // Delegate property var 생성
    weak var delegate: addHabitVCDelegate?
    
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .exoticLiras
        return v
    }()
    
    // Add title TextField
    lazy var addTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.placeholder = " Title of your Goal"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    // Add Detail TextField
    lazy var addDetail: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.placeholder = " Description of your Goal"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    // Add button 생성
    lazy var addButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .blue
        v.setTitle("Add", for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 25
        return v
    }()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(backView)
        view.addSubview(addTitle)
        view.addSubview(addDetail)
        view.addSubview(addButton)
        
        // backview grid
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
        
        // addTitle TextField size grid
        addTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backView).offset(150)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }
        
        // addDetail TextField size grid
        addDetail.snp.makeConstraints { (make) in
            make.top.equalTo(addTitle).offset(60)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }
        // addButton size grid
        addButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView.snp.bottom).offset(-100)
            make.centerX.equalTo(backView)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        // addButton Action
        addButton.addTarget(self, action: #selector(addDirectory), for: .touchUpInside)
    }
    
    @objc func addDirectory(sender: UIButton) {
        
        delegate?.addedGoal(title: addTitle.text!, detail: addDetail.text!)
        dismiss(animated: true, completion: nil)  //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
    }
    
    
}


//Q. Line11에 protocol 의미. 저거를 위해서 line 19 weak var delegate 을 만드는거지?
