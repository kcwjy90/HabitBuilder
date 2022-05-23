//
//  AddHabitVC.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

//MARK: didCreateNewHabit func for NewHabitVCDelegate Protocol
protocol NewHabitVCDelegate: AnyObject {
    func didCreateNewHabit(title: String, desc: String, date: Date, time: Date)
}

class NewHabitVC: UIViewController, UISearchBarDelegate, UITextViewDelegate {
    
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
    
    // newHabitDateBackview 생성
    lazy var newHabitDateBackview: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // newHabitDateLabel 생성
    lazy var newHabitDateLabel: UILabel = {
        let v = UILabel()
        v.text = "Date"
        v.textColor = .systemGray
        return v
    }()
    
    // newHabitDate 생성
    lazy var newHabitDate: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .date
        v.layer.cornerRadius = 15
        return v
    }()
    
    // newHabitTimeBackview 생성
    lazy var newHabitTimeBackview: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    // newHabitTimeLabel 생성
    lazy var newHabitTimeLabel: UILabel = {
        let v = UILabel()
        v.text = "Time"
        v.textColor = .systemGray
        return v
    }()
    
    // newHabitTime 생성
    lazy var newHabitTime: UIDatePicker = {
        let v = UIDatePicker()
        v.datePickerMode = .time
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
        return v
    }()
    
    //FIXME: 일단 얘를 어떻게 처리해야할지 좀더 생각을...Repeat function
    lazy var repeatButton: UIButton = {
        let v = UIButton()
        //        v.layer.borderWidth = 0.5
        //        v.layer.borderColor = UIColor.secondaryLabel.cgColor
        v.layer.cornerRadius = 15
        v.backgroundColor = .systemGray5
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
        backView.addSubview(newHabitDateBackview)
        backView.addSubview(newHabitDateLabel)
        backView.addSubview(newHabitDate)
        backView.addSubview(newHabitTimeBackview)
        backView.addSubview(newHabitTimeLabel)
        backView.addSubview(newHabitTime)
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
        newHabitDateBackview.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitDateLabel size grid
        newHabitDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDesc.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitDate size grid
        newHabitDate.snp.makeConstraints { (make) in
            make.centerY.equalTo(newHabitDateBackview)
            make.right.equalTo(backView).offset(-34)
            make.height.equalTo(60)
        }
        
        // newHabitTimeBackview size grid
        newHabitTimeBackview.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDateBackview.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(16)
            make.right.equalTo(backView).offset(-16)
            make.height.equalTo(60)
        }
        
        // newHabitTimeLabel size grid
        newHabitTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDateBackview.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(39)
            make.height.equalTo(60)
        }
        
        // newHabitTime size grid
        newHabitTime.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitDate.snp.bottom).offset(10)
            make.right.equalTo(backView).offset(-28)
            make.height.equalTo(60)
        }
        
        repeatButton.snp.makeConstraints { (make) in
            make.top.equalTo(newHabitTimeBackview.snp.bottom).offset(10)
            make.width.height.equalTo(50)
            make.right.equalTo(backView).offset(-28)
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
        delegate?.didCreateNewHabit(title: titleText, desc: descText, date: newHabitDate.date, time: newHabitTime.date)
        dismiss(animated: true, completion: nil)
        //와우 modal 에서 ADD 를 누르면 다시 main viewcontroller로 돌아오게 해주는 마법같은 한 줄 보소
    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func repeatButtonPressed(sender: UIButton){
        print("will be repeated")
    }
    
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


