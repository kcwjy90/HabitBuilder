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


class progressVC: UIViewController, ChartViewDelegate {

    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
 
    let localRealm = DBManager.SI.realm!
    var todayPiChart = PieChartView()
    var habits: [RMO_Habit] = []

    
    //지금은 좀 조잡한데 어찌돼었든 일단 그래프가 뜨니가 성공. 이제 자러가장.
    let results = ["Completed", "Failed", "Pending"]
    var counts = [0,0,0]
    var comp: Int = 0
    var failed: Int = 0
    var pending: Int = 0

    override func loadView() {
        super.loadView()
        todayPiChart.delegate = self
        habits = localRealm.objects(RMO_Habit.self).toArray() //updating habits []
        for habit in habits {
            if (habit.title == "One") {
            comp = comp + 1
            } else if (habit.title == "Two") {
                failed = failed + 1
                }  else if (habit.title == "Four") {
                    pending = pending + 1
                    }
        }
        counts[0] = comp
        counts[1] = failed
        counts[2] = pending

        
        customizeChart(dataPoints: results, values: counts.map{ Double($0) })
        setNaviBar()
    }

    override func viewDidLayoutSubviews() { //이렇게 해야지만 그래프가 뜨는데 왜인지는 모름.
        super.viewDidLayoutSubviews()
        
        view.addSubview(backView)
        view.addSubview(todayPiChart)
        
        view.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        todayPiChart.snp.makeConstraints{ (make) in
            make.edges.equalTo(backView)
        }
        todayPiChart.center = backView.center
        
     
//        var entries = [ChartDataEntry]()
//        for x in 0..<10 {
//            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
//        }
        
//        let set = PieChartDataSet(entries: entries)
//        set.colors = ChartColorTemplates.joyful()
//        let data = PieChartData(dataSet: set)
//        pieChart.data = data
        
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
      
      // 1. Set ChartDataEntry
      var dataEntries: [ChartDataEntry] = []
      for i in 0..<dataPoints.count {
        let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
        dataEntries.append(dataEntry)
      }
      // 2. Set ChartDataSet
      let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = ChartColorTemplates.colorful()
        
      // 3. Set ChartData
      let pieChartData = PieChartData(dataSet: pieChartDataSet)
      let format = NumberFormatter()
        format.numberStyle = .percent
      let formatter = DefaultValueFormatter(formatter: format)
      pieChartData.setValueFormatter(formatter)
        
      // 4. Assign it to the chart’s data
      todayPiChart.data = pieChartData
    }
    
    //Navi Bar 만드는 func.
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }
    


}
