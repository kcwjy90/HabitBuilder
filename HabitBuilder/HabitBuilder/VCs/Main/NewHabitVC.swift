//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: didCreateNewHabit func for NewHabitVCDelegate Protocol
protocol NewHabitVCDelegate: AnyObject {
    func didCreateNewHabit()
}


class NewHabitVC: UIViewController, UISearchBarDelegate, UITextViewDelegate {
    
    //realm Noti 에서 쓰는거
    let localRealm = DBManager.SI.realm!
    
    weak var delegate: NewHabitVCDelegate?   // Delegate property var 생성
    
    // backview 생성
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
        v.text = "New Habit"
        v.textColor = .black
        v.font = UIFont.boldSystemFont(ofSize: 16.0)
        return v
    }()
    
    // addHabitButton 생성
    lazy var addHabitButton: UIButton = {
        let v = UIButton()
        v.setTitle("Add", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        return v
    }()
    
    // newHabitTitle TextField 생성
    lazy var newHabitTitle: UITextField = {
        let v = UITextField()
        v.backgroundColor = .systemGray5
        v.placeholder = "Title of your New Habit"
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    // newHabitDesc UITextView (Multi line) 생성
    lazy var newHabitDesc: UITextView = {
        let v = UITextView()
        v.backgroundColor = .systemGray5
        v.text = "Description of your New Habit"
        v.textColor = UIColor.lightGray
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        v.font = UIFont.systemFont(ofSize: 15.0)
        return v
    }()
    
    // newHabitDateTimeBackview 생성
    lazy var newHabitDateTimeBackview: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // newHabitDateTimeLabel 생성
    lazy var newHabitDateTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Date and Time"
        v.textColor = .systemGray
        return v
    }()
    
    // newHabitDateTime 생성
    lazy var newHabitDateTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .dateAndTime
        v.layer.cornerRadius = 15
        return v
    }()
    
    // repeatBackview 생성
    lazy var repeatBackView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // repeatLabel 생성
    lazy var repeatLabel: UILabel = {
        let v = UILabel()
        v.text = "Repeat"
        v.textColor = .systemGray
        return v
    }()
    
    
    //FIXME: 일단 얘를 어떻게 처리해야할지 좀더 생각을...Repeat function
    lazy var repeatButton: UIButton = {
        let v = UIButton()
        v.setTitle("None >", for: .normal)
        v.setTitleColor(.black, for: .normal)
        return v
    }()
    
    //FIXME: 위에거랑 동일
    var isChecked: Bool = false
    
    override func loadView() {
        super.loadView()
        
        // tapGesture - Dismisses Keyboard
        let UITapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(UITapGesture)
        
        view.addSubview(backView)
        backView.addSubview(backButton)
        backView.addSubview(pageLabel)
        backView.addSubview(addHabitButton)
        backView.addSubview(newHabitTitle)
        backView.addSubview(newHabitDesc)
        backView.addSubview(newHabitDateTimeBackview)
        backView.addSubview(newHabitDateTimeLabel)
        backView.addSubview(newHabitDateTime)
        backView.addSubview(repeatBackView)
        backView.addSubview(repeatLabel)
        backView.addSubview(repeatButton)
        
        
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
        
        // pageLabel size grid
        pageLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.centerX.equalTo(backView)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        // addHabitButton size grid
        addHabitButton.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.right.equalTo(backView)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        // newHabitTitle TextField size grid
        newHabitTitle.snp.makeConstraints { (make) in
            make.top.equalTo(pageLabel.snp.bottom).offset(20)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(50)
        }
        newHabitTitle.setLeftPaddingPoints(10)
        newHabitTitle.setRightPaddingPoints(10)
        
        
        // newHabitDesc UITextVIew size grid
        newHabitDesc.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTitle.snp.bottom).offset(5)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(160)
        }
        newHabitDesc.delegate = self //placeholder가 UITextView에는 없어서 비슷한것을 생성하기위한 function.
        textViewDidBeginEditing(newHabitDesc) //을 넣기 위해서 delegate을 해야함.
        textViewDidEndEditing(newHabitDesc)
        newHabitDesc.addPadding()
        newHabitDesc.addPadding()
        
        // newHabitDateBackview size grid
        newHabitDateTimeBackview.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitDateLabel size grid
        newHabitDateTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitDate size grid
        newHabitDateTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(newHabitDateTimeBackview)
            make.right.equalTo(backView).offset(-30)
            make.height.equalTo(60)
        }
        
        // repeatBackview size grid
        repeatBackView.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDateTimeBackview.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // repeatLabel size grid
        repeatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDateTimeBackview.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        repeatButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(repeatBackView)
            make.height.equalTo(40)
            make.right.equalTo(backView).offset(-30)
        }
        
        
        
        //        newHabitDateTime.timeZone = TimeZone.init(identifier: "PST") // have to do this inside of loadview. 더 이상 필요없지만 일단 혹시나
        
        
        //MARK: Button Actions - AddHabitButton & backButton & repeatButton
        addHabitButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatButtonPressed), for: .touchUpInside)
        
    }
    
    //MARK: UITextView "Placeholder" 
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description of your New Habit"
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: Button Funcs - Add, Back, Repeat Buttons
    @objc func addButtonPressed(sender: UIButton) {
        
        guard let titleText = newHabitTitle.text, let descText = newHabitDesc.text else { return }
        let habit = RMO_Habit()
        habit.title = titleText
        habit.desc = descText
        habit.date = newHabitDateTime.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let habitDate = dateFormatter.string(from: newHabitDateTime.date)
        habit.dateString = habitDate
        habit.todayString = dateFormatter.string(from: Date())
                
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
        
        //만약 RMO_Count에 지금 add하는 날짜의 object가 있을경우 그 total 을 +1 한다
        guard let inNumb = countRealm.firstIndex(where: { $0.date == habitDate}) else
        {return}
        let existCount = countRealm[inNumb]
        
        try! localRealm.write {
            existCount.total += 1
            print("+1")
            print(existCount)
        }
        
        try! localRealm.write {
            localRealm.add(habit)
            print("habit added to localrealm")
        }
        
 
        delegate?.didCreateNewHabit()
        dismiss(animated: true, completion: nil)
        //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func repeatButtonPressed(sender: UIButton){
        let v = RepeatVC()
        v.delegate = self
        v.modalPresentationStyle = .pageSheet
        present(v, animated:true)   // modal view 가능케 하는 코드  
    }
}

extension NewHabitVC: RepeatVCDelegate {
}

// for UITextField Padding
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}

//UITextView에 padding을 더하기
extension UITextView {
    func addPadding() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
}


