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
import Charts


class ProgressVC: UIViewController, ChartViewDelegate {
    
    let localRealm = DBManager.SI.realm!
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    var habitLineChart = LineChartView()
    
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        habitLineChart.delegate = self
        
        setNaviBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(backView)
        backView.addSubview(habitLineChart)
        
        backView.snp.makeConstraints{ (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
//        habitLineChart.snp.makeConstraints{(make) in
//            make.edges.equalTo(backView)
//        }
        habitLineChart.frame = CGRect(x: 0, y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.width)
        habitLineChart.center = view.center
        habitLineChart.backgroundColor = .white
        
        
        view.addSubview(habitLineChart)
        
        var entries = [ChartDataEntry]()
        
        for x in 0..<10{
            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
        }
        
        let set = LineChartDataSet(entries: entries, label: "")
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        habitLineChart.data = data
        
    }


    //MARK: Navi Bar
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }
}

