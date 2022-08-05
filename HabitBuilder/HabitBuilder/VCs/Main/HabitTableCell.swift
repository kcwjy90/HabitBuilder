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
        return v
    }()
    
    lazy var newHabitDesc: UILabel = {
        let v = UILabel()
        return v
    }()
    
    lazy var newHabitDate: UILabel = {
        let v = UILabel()
        return v
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier )
        
        //Cell은 왜 굳이 addSubView가 필요할까 했는데, 이게 없으면 tableview에서 안 보임
        addSubview(backView)
        backView.addSubview(newHabitTitle)
        backView.addSubview(newHabitDesc)
        backView.addSubview(newHabitDate)

        
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
        newHabitTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView).offset(10)
        }
        
        newHabitDesc.snp.makeConstraints{ (make) in
            make.top.equalTo(newHabitTitle)
            make.left.equalTo(newHabitTitle.snp.right)
        }
        
        newHabitDate.snp.makeConstraints{ (make) in
            make.top.equalTo(newHabitTitle)
            make.right.equalTo(backView).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

