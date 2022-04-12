//
//  SettingsVC.swift
//  HabitBuilder
//
//  Created by ppc90 on 4/4/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import SnapKit
import RealmSwift


class SettingsVC: UIViewController {
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .red
        view.addSubview(backView)

        backView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(64)
            make.left.right.bottom.equalTo(view)
        }
  
        
    }
    
}

