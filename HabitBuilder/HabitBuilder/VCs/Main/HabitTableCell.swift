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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier )
        
        //아 이것들이 왜 필요한가 했는데, 얘네들이 없으면 tableview에서 안보이는구나..
        addSubview(backView)
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
        backView.addSubview(newHabitTitle)
        newHabitTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView).offset(10)
        }
        
        backView.addSubview(newHabitDesc)
        newHabitDesc.snp.makeConstraints{ (make) in
            make.top.equalTo(newHabitTitle)
            make.left.equalTo(newHabitTitle.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

