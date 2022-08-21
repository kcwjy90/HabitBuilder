//
//  HabitTableCell.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

//:MARK Cells
class HabitTableCell: UITableViewCell {
    
    lazy var backView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var newHabitTitle: UILabel = {
        let v = UILabel()
        v.font = UIFont.boldSystemFont(ofSize: 28.0)
        return v
    }()
    
    lazy var titleBackground: UIButton = {
        let v = UIButton()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        v.backgroundColor = .darkGreen
        return v
    }()
    
    lazy var newHabitDesc: UILabel = {
        let v = UILabel()
        return v
    }()
    
    lazy var newHabitRepeat: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        return v
    }()
    
    lazy var repeatBackground: UIButton = {
        let v = UIButton()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        return v
    }()
    
    lazy var newHabitDate: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        return v
    }()
    
    lazy var boxCell: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.backgroundColor = .dateGreen
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var cellStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.backgroundColor = .white
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        v.layer.cornerRadius = 10
        return v
    }()
    
    lazy var titleStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var middleLine: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.distribution = .equalSpacing
        return v
    }()
    
    lazy var dateStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.distribution = .equalSpacing
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier )
        
        //Cell은 왜 굳이 addSubView가 필요할까 했는데, 이게 없으면 tableview에서 안 보임
        addSubview(backView)
        backView.addSubview(boxCell)
        boxCell.addSubview(cellStackView)
        cellStackView.addArrangedSubview(titleStackView)
        cellStackView.addArrangedSubview(middleLine)
        cellStackView.addArrangedSubview(dateStackView)
        titleStackView.addArrangedSubview(newHabitTitle)
        dateStackView.addSubview(titleBackground)
        titleStackView.addArrangedSubview(newHabitDesc)
        dateStackView.addArrangedSubview(newHabitRepeat)
        dateStackView.addSubview(repeatBackground)
        dateStackView.addArrangedSubview(newHabitDate)
        

        
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
        boxCell.snp.makeConstraints{ (make) in
            make.edges.equalTo(backView)
        }
        
        cellStackView.snp.makeConstraints{ (make) in
            make.top.equalTo(boxCell).offset(5)
            make.bottom.equalTo(boxCell).offset(-5)
            make.right.equalTo(boxCell).offset(-10)
            make.left.equalTo(boxCell).offset(10)
        }
//        cellStackView.layer.borderWidth = 3.0
//        cellStackView.layer.shadowOpacity = 0.2
//        cellStackView.layer.shadowRadius = 0.2
        cellStackView.layer.masksToBounds = false;
//        cellStackView.layer.borderColor = UIColor.white.cgColor
        
        titleStackView.snp.makeConstraints{ (make) in
            make.left.equalTo(cellStackView)
            make.right.equalTo(middleLine.snp.left)
            make.height.equalTo(70)
        }
        
        middleLine.snp.makeConstraints{ (make) in
            make.left.equalTo(cellStackView).offset(275)
            make.width.equalTo(5)
            make.height.equalTo(70)
        }
        
        dateStackView.snp.makeConstraints{ (make) in
            make.left.equalTo(middleLine.snp.right)
            make.right.equalTo(cellStackView)
            make.height.equalTo(70)
        }
        
        newHabitTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(titleStackView)
            make.height.equalTo(45)
            make.left.equalTo(titleBackground).offset(35)
        }
        
        titleBackground.snp.makeConstraints{ (make) in
            make.height.equalTo(25)
            make.bottom.equalTo(newHabitTitle.snp.bottom).offset(-10)
            make.width.equalTo(25)
            make.left.equalTo(titleStackView.snp.left).offset(10)
        }
        
        newHabitDesc.snp.makeConstraints{ (make) in
            make.height.equalTo(25)
            make.left.equalTo(titleStackView).offset(15)
        }
        
        newHabitRepeat.snp.makeConstraints{ (make) in
            make.height.equalTo(35)
            make.left.equalTo(dateStackView)
        }
        
        repeatBackground.snp.makeConstraints{ (make) in
            make.height.equalTo(10)
            make.bottom.equalTo(newHabitRepeat.snp.bottom)
            make.left.equalTo(newHabitRepeat).offset(35)
            make.right.equalTo(newHabitRepeat).offset(-35)
        }
        
        newHabitDate.snp.makeConstraints{ (make) in
            make.height.equalTo(35)
            make.left.equalTo(dateStackView)
        }
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

