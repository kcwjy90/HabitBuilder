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
        v.backgroundColor = .orange
        return v
    }()
    
    lazy var newHabitDesc: UILabel = {
        let v = UILabel()
        v.backgroundColor = .gray
        return v
    }()
    
    lazy var newHabitRepeat: UILabel = {
        let v = UILabel()
        v.backgroundColor = .gray
        return v
    }()
    
    lazy var newHabitDate: UILabel = {
        let v = UILabel()
        v.backgroundColor = .cyan
        return v
    }()
    
    lazy var boxCell: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.backgroundColor = .white
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var cellStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.backgroundColor = .red
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var titleStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.backgroundColor = .blue
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var middleLine: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.backgroundColor = .black
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
        return v
    }()
    
    lazy var dateStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.vertical
        v.backgroundColor = .green
        v.distribution = .equalSpacing
        v.alignment = UIStackView.Alignment.leading
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
        titleStackView.addArrangedSubview(newHabitDesc)
        dateStackView.addArrangedSubview(newHabitRepeat)
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
            make.right.equalTo(boxCell).offset(-5)
            make.left.equalTo(boxCell).offset(5)
        }
        cellStackView.layer.borderWidth = 0.5
        cellStackView.layer.shadowOpacity = 0.3
        cellStackView.layer.shadowRadius = 1.0
        cellStackView.layer.masksToBounds = false;
        
        titleStackView.snp.makeConstraints{ (make) in
            make.left.equalTo(cellStackView)
            make.right.equalTo(middleLine.snp.left)
            make.height.equalTo(70)
        }
        
        middleLine.snp.makeConstraints{ (make) in
            make.left.equalTo(cellStackView).offset(300)
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
            make.height.equalTo(50)
            make.left.equalTo(titleStackView).offset(5)
        }
        
        newHabitDesc.snp.makeConstraints{ (make) in
            make.height.equalTo(20)
            make.left.equalTo(titleStackView).offset(5)
        }
        
        newHabitRepeat.snp.makeConstraints{ (make) in
            make.height.equalTo(35)
            //왜 right.equalTo하면 안되지?
            //그리고 왜 여기 left.equalto 가 newHabitDate의 equalto에도 영향을 주지???
            make.left.equalTo(dateStackView).offset(70)
        }
        
        newHabitDate.snp.makeConstraints{ (make) in
            make.height.equalTo(35)
            make.right.equalTo(dateStackView).offset(-5)
            make.left.equalTo(dateStackView)
        }
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

