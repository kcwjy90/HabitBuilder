//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

class HabitDetailVC: UIViewController, UISearchBarDelegate {
        
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    // backButton 생성
    lazy var backButton: UIButton = {
        let v = UIButton()
        //        v.backgroundColor = .purple
        v.setTitle("Back", for: .normal)
        v.setTitleColor(.red, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // addHabitButton 생성
//    lazy var addHabitButton: UIButton = {
//        let v = UIButton()
//        //        v.backgroundColor = .blue
//        v.setTitle("Add", for: .normal)
//        v.setTitleColor(.blue, for: .normal)
//        v.layer.masksToBounds = true
//        v.layer.cornerRadius = 20
//        return v
//    }()
    
    // pageLabel 생성
    lazy var pageLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.text = ""
        v.font = UIFont.boldSystemFont(ofSize: 16.0)
        v.backgroundColor = .blue
        return v
    }()
    
    // habitTitle TextField 생성
    lazy var habitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .systemGray5
        v.placeholder = "No Title"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.setLeftPaddingPoints(10)
        v.setRightPaddingPoints(10)
        return v
    }()
    
    //  habitDesc TextField 생성
    lazy var habitDesc: UITextField = {
        let v = UITextField()
        v.backgroundColor = .systemGray5
        v.placeholder = "No Description"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.setLeftPaddingPoints(10)
        v.setRightPaddingPoints(10)
        return v
    }()
    
    // habitDateBackview 생성
    lazy var habitDateBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // habitDateLabel 생성
    lazy var habitDateLabel: UILabel = {
        let v = UILabel()
        v.text = "Date"
        v.textColor = .black
        return v
    }()
    
    //  habitDate TextField 생성
    lazy var habitDate: UILabel = {
        let v = UILabel()
        v.text = ""
        v.textColor = .black
        v.font = UIFont.boldSystemFont(ofSize: 16.0)
        return v
    }()
    
    // habitTimeBackview 생성
    lazy var habitTimeBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // habitTimeLabel 생성
    lazy var habitTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Time"
        v.textColor = .black
        return v
    }()
    
    //  habitTime TextField 생성
    lazy var habitTime: UILabel = {
        let v = UILabel()
        v.text = ""
        v.textColor = .black
        v.font = UIFont.boldSystemFont(ofSize: 16.0)
        return v
    }()
        

    override func loadView() {
        super.loadView()
        
        // tapGasture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(backButton)
//        backView.addSubview(addHabitButton)
        backView.addSubview(habitTitle)
        backView.addSubview(habitDesc)
        backView.addSubview(habitDateBackView)
        backView.addSubview(habitDateLabel)
        backView.addSubview(habitDate)
        backView.addSubview(habitTimeBackView)
        backView.addSubview(habitTimeLabel)
        backView.addSubview(habitTime)
        backView.addSubview(pageLabel)
        
        // backView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        // backToMainButton size grid
        backButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // addHabitButton size grid
//        addHabitButton.snp.makeConstraints{ (make) in
//            make.top.equalTo(backView).offset(10)
//            make.right.equalTo(backView)
//            make.width.equalTo(60)
//            make.height.equalTo(40)
//        }
        
        // newHabitTitle TextField size grid
        habitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(50)
        }
        habitTitle.isUserInteractionEnabled = false
        
        // newHabitDesc TextField size grid
        habitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(habitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(160)
        }
        habitDesc.isUserInteractionEnabled = false
        habitDesc.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top

        
        // newHabitDateBackview size grid
        habitDateBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitDateLabel size grid
        habitDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitDate size grid
        habitDate.snp.makeConstraints { (make) in
            make.centerY.equalTo(habitDateBackView)
            make.right.equalTo(backView).offset(-34)
            make.height.equalTo(60)
        }
        
        // newHabitTimeBackview size grid
        habitTimeBackView.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateBackView.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitTimeLabel size grid
        habitTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitDateBackView.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitTime size grid
        habitTime.snp.makeConstraints { (make) in
            make.top.equalTo(habitDate.snp.bottom).offset(10)
            make.right.equalTo(backView).offset(-28)
            make.height.equalTo(60)
        }
        
        pageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(habitTime.snp.bottom).offset(10)
            make.right.equalTo(backView).offset(-28)
            make.height.equalTo(60)
        }
        
//        newHabitDateTime.timeZone = TimeZone.init(identifier: "PST") // have to do this inside of loadview. 더 이상 필요없지만 일단 혹시나
        
        
        
        // Button Actions - AddHabitButton & backToMainButton
//        addHabitButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
//
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }

    
//    @objc func addButtonPressed(sender: UIButton) {
//
//        delegate?.didCreateNewHabit(title: newHabitTitle.text!, desc: newHabitDesc.text!, date: newHabitDate.date, time: newHabitTime.date)
//        dismiss(animated: true, completion: nil)
//      //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
//        let mainVC = MainVC()
//        mainVC.sendNotification() //이걸 해야 sendNotification 이 방금 들어간 habit까지 check 할수 있음
//    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

// for UITextField Padding

//extension UITextField {
//    func setLeftPaddingPoints(_ amount:CGFloat){
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//    func setRightPaddingPoints(_ amount:CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
//        self.rightView = paddingView
//        self.rightViewMode = .always
//    }
//
//}
