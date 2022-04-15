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
    func newHabit(title: String, desc: String, date: String, time: String, dateTime: Date)
}


class NewHabitVC: UIViewController {
    
    weak var delegate: NewHabitVCDelegate?   // Delegate property var 생성
    
    // backview 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .exoticLiras
        return v
    }()
    
    // backToMainButton 생성
    lazy var backToMainButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .purple
        v.setTitle("Back", for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // addHabitButton 생성
    lazy var addHabitButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .blue
        v.setTitle("Add", for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
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
    
    lazy var newHabitDateTime: UIDatePicker = {
        let v = UIDatePicker()
        v.layer.cornerRadius = 15
        v.backgroundColor = .orange
        return v
    }()
    
    override func loadView() {
        super.loadView()
        
        // tapGasture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(backToMainButton)
        backView.addSubview(addHabitButton)
        backView.addSubview(newHabitTitle)
        backView.addSubview(newHabitDesc)
        backView.addSubview(newHabitDate)
        backView.addSubview(newHabitTime)
        backView.addSubview(newHabitDateTime)

        
        // backView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        // backToMainButton size grid
        backToMainButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(5)
            make.left.equalTo(backView).offset(5)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        // addHabitButton size grid
        addHabitButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(5)
            make.right.equalTo(backView).offset(-5)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        // newHabitTitle TextField size grid
        newHabitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(backView).offset(74)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(50)
        }
        
        // newHabitDesc TextField size grid
        newHabitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(160)
        }
        
        // newHabitDate size grid
        newHabitDate.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }

        // newHabitTime size grid
        newHabitTime.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDate.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        newHabitDateTime.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTime.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        newHabitDateTime.timeZone = TimeZone.init(identifier: "PST") // have to do this inside of loadview. 더 이상 필요없지만 일단 혹시나
        
   
        
        // Button Actions - AddHabitButton & backToMainButton
        addHabitButton.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
  
        backToMainButton.addTarget(self, action: #selector(goBackToMain), for: .touchUpInside)
    }
    
    
    @objc func addNewHabit(sender: UIButton) {
        
        // 지정한 date과 time의 format을 string으로 바꿔준다.
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "MM/dd/yyyy"
        let newHabitDateString = dateFormatterDate.string(from: newHabitDate.date)
        print(newHabitDateString)
        
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.timeStyle = .short
        let newHabitTimeString = dateFormatterTime.string(from: newHabitTime.date)
        print(newHabitTimeString)

        delegate?.newHabit(title: newHabitTitle.text!, desc: newHabitDesc.text!, date: newHabitDateString, time: newHabitTimeString, dateTime: newHabitDateTime.date)
        dismiss(animated: true, completion: nil)  //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
    
    }
    
    @objc func goBackToMain(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//Q. Line11에 protocol 의미. 저거를 위해서 line 19 weak var delegate 을 만드는거지?
//Q. 엄청 이상한게 newHabitDate.date을 찍었을때는 내가 지정한 date보다 항상 하루가 더 지난 날이 나왔는데..
//    예) 4/29를 찍으면 4/30 이 뜸. 그래서 그것을 방지하기 위해 밑에 코드를 loadview 안에 넣었단 말이지
//        newHabitDate.timeZone = TimeZone.init(identifier: "UTC")
//   근데 dateFormatter.dateStyler = .short를 적용하고, dateformatter가 적용된 날짜가 담긴 variable을 print 하니 다시 하루 전 날짜가 찍힘.
//.   예) 4/29를 찍으면 4/30 이 떠서 timezone 을 새로 set up 하니 4/29가 찍힘. 근데 이 date에 dateformatter을 적용하니 이제는 4/28 이 찍힘..

// Q. 4/14/22 newHabitDateTime 이라는 date() type을 새로 만들었는데....date이랑 시간이 맞게 찍히지가 않아요. 오늘은 4/14/22 저녁 10시 인데 po 해서 찍히는건 자꾸 4/15/22 시간도 새벽 왜그러지요? 그래서 일단 string으로 되어있는 newhabitdate 이랑 newhabittime 으로 진행을 해보겠음.

