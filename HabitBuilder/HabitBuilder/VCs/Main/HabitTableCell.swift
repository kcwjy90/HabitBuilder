//
//  HabitTableCell.swift
//  HabitBuilder
//
//  Created by CW on 1/27/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

class HabitTableCell: UITableViewCell {
    
    lazy var backView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var newTitle: UILabel = {
        let v = UILabel()
        return v
    }()
    
    lazy var newDetail: UILabel = {
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
        
        backView.addSubview(newTitle)
        newTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(backView).offset(10)
            make.left.equalTo(backView).offset(10)
        }
        
        backView.addSubview(newDetail)
        newDetail.snp.makeConstraints{ (make) in
            make.top.equalTo(newTitle)
            make.left.equalTo(newTitle.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Q. Cell 이 받아서 tablewview 얹어지는 거던가? 그 프로세스를 다시 한번만 설명을..
