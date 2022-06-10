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
    
    // backView 생성
    lazy var backView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    let localRealm = DBManager.SI.realm!
    var todayPiChart = PieChartView()
    
    //지금은 좀 조잡한데 어찌돼었든 일단 그래프가 뜨니가 성공.
    let results = ["Succeeded", "Failed", "Working"]
    var counts = [0,0,0]
    var compCount: Int = 0
    
    
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        
        todayPiChart.delegate = self
        
        reloadChart()
        
    }
    
    //MARK: viewWillAppear -> reload graph
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadChart()  // 이게 있어야 그레프가 업데이트됨
    }
    
    override func viewDidLayoutSubviews() { //이렇게 따로 viewDidLayoutSubview에 넣어야지만 그래프가 뜨는데 왜인지는 모름.
        super.viewDidLayoutSubviews()
        
        view.addSubview(backView)
        view.addSubview(todayPiChart)
        
        view.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // todayPiChart grid
        todayPiChart.snp.makeConstraints{ (make) in
            make.edges.equalTo(backView)
        }
        todayPiChart.center = backView.center
        
    }
    
    //MARK: code that creates the piechart. Needs to reload so graph gets updated
    func reloadChart() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        
        //MARK: today's piechart에 들어가는 count들을 넣어주는 코드
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return}
        let todayCount = countRealm[indexNumb] //todayCount = 오늘 날짜에 해당하는 RMO_Count obj
        counts[0] = todayCount.success
        counts[1] = todayCount.fail
        counts[2] = todayCount.total - (todayCount.success + todayCount.fail + todayCount.remove)

        
        customizeChart(dataPoints: results, values: counts.map{ Double($0) })
        
    }
    //MARK: Chart Customize하는 func
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
        print("pie chart complete")
    }
    
    //Navi Bar 만드는 func.
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }
}


//        var entries = [ChartDataEntry]()
//        for x in 0..<10 {
//            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
//        }

//        let set = PieChartDataSet(entries: entries)
//        set.colors = ChartColorTemplates.joyful()
//        let data = PieChartData(dataSet: set)
//        pieChart.data = data
