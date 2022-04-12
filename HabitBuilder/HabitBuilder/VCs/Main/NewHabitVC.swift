//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

// 이게 NewHabitVC랑 MainVC랑 연결 시켜주는 거든가?
protocol NewHabitVCDelegate: class {
    func newHabit(title: String, desc: String, date: String, time: String)
}


class NewHabitVC: UIViewController {
    
    weak var delegate: NewHabitVCDelegate?   // Delegate property var 생성
    
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .exoticLiras
        return v
    }()
    
    // newHabitTitle TextField 생성
    lazy var newHabitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.placeholder = " Title of your Goal"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    //  newHabitDesc TextField 생성
    lazy var newHabitDesc: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.placeholder = " Description of your Goal"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    // newHabitDate 생성
    lazy var newHabitDate: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .date
        v.layer.cornerRadius = 15
        v.backgroundColor = .green
        return v
    }()
    
    // newHabitTime 생성
    lazy var newHabitTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .time
        v.layer.cornerRadius = 15
        v.backgroundColor = .blue
        return v
    }()
    
    // addButton 생성
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
        backView.addSubview(newHabitTitle)
        backView.addSubview(newHabitDesc)
        backView.addSubview(newHabitDate)
        backView.addSubview(newHabitTime)
        backView.addSubview(addButton)
   
        
        // backView grid
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
        
        // newHabitTitle TextField size grid
        newHabitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backView).offset(150)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }
        
        // newHabitDesc TextField size grid
        newHabitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTitle.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }
        
        // newHabitDate size grid
        newHabitDate.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }

        // newHabitTime size grid
        newHabitTime.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDate.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(30)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(50)
        }
//        newHabitTime.timeZone = TimeZone.init(identifier: "UTC") // have to do this inside of loadview. 더 이상 필요없지만 일단 혹시나
        
        // addButton size grid
        addButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView.snp.bottom).offset(-100)
            make.centerX.equalTo(backView)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        // addButton Action
        addButton.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
  
    }
    
    @objc func addNewHabit(sender: UIButton) {
        
        // 지정한 date과 time의 format을 string으로 바꿔준다.
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateStyle = .short
        let newHabitDateString = dateFormatterDate.string(from: newHabitDate.date)
        print(newHabitDateString)
        
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.timeStyle = .short
        let newHabitTimeString = dateFormatterTime.string(from: newHabitTime.date)
        print(newHabitTimeString)

        delegate?.newHabit(title: newHabitTitle.text!, desc: newHabitDesc.text!, date: newHabitDateString, time: newHabitTimeString)
        dismiss(animated: true, completion: nil)  //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
    
    }
    
}

//Q. Line11에 protocol 의미. 저거를 위해서 line 19 weak var delegate 을 만드는거지?
//Q. 엄청 이상한게 newHabitDate.date을 찍었을때는 내가 지정한 date보다 항상 하루가 더 지난 날이 나왔는데..
//    예) 4/29를 찍으면 4/30 이 뜸. 그래서 그것을 방지하기 위해 밑에 코드를 loadview 안에 넣었단 말이지
//        newHabitDate.timeZone = TimeZone.init(identifier: "UTC")
//   근데 dateFormatter.dateStyler = .short를 적용하고, dateformatter가 적용된 날짜가 담긴 variable을 print 하니 다시 하루 전 날짜가 찍힘.
//.   예) 4/29를 찍으면 4/30 이 떠서 timezone 을 새로 set up 하니 4/29가 찍힘. 근데 이 date에 dateformatter을 적용하니 이제는 4/28 이 찍힘..
