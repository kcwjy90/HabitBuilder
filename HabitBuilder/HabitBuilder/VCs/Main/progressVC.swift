//
//  progressVC.swift
//  HabitBuilder
//
//  Created by ppc90 on 5/17/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import SwiftUI

class progressVC: UIViewController {

    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    override func loadView() {
        super.loadView()

        setNaviBar()

        view.addSubview(backView)
        view.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        

    }
    
    //Navi Bar 만드는 func.
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }


}
