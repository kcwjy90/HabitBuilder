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
    var totalLineChart = LineChartView()
    
    // RMO_Habit에서 온 data를 넣을 empty한 array들
    var habits: [RMO_Count] = []
    var rates: Results<RMO_Count>? = nil

    var success: Float?
    
//    lazy var currentSuccessRate: UILabel = {
//        let v = UILabel()
//        v.text = ""
//        v.font = UIFont.systemFont(ofSize: 40.0)
//        v.textColor = .black
//        return v
//    }()
//
    //MARK: ViewController Life Cycle
    override func loadView() {
        super.loadView()
        
        setNaviBar()
        totalLineChart.delegate = self
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
        view.addSubview(totalLineChart)
        
        view.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // todayPiChart grid
        totalLineChart.snp.makeConstraints{ (make) in
            make.edges.equalTo(backView)
        }
        totalLineChart.center = backView.center
        
    }
    
    
    //MARK: code that creates the piechart. Needs to reload so graph gets updated
    func reloadChart() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        let countRealm = self.localRealm.objects(RMO_Count.self)
        
        //MARK: todayLineChart 에 들어가는 count들을 넣어주는 코드
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return}
        let todayCount = countRealm[indexNumb] //todayCount = 오늘 날짜에 해당하는 RMO_Count 의 successRate을 불러옴
        success = Float(todayCount.finalPercent)
                
        habits = localRealm.objects(RMO_Count.self).toArray() //updating habits []

        //FIXME: somehoe do order by year. then date. so......flip the date and save it as reverse date so it's yy/mm/dd
        habits = habits.sorted(by: {
            $0.date.compare($1.date) == .orderedAscending
        })

        print("progressVC line 101=========================================\(habits)")
 
        let dayDifference = habits.count - 1
        print(dayDifference)
        
        // 1. Set ChartDataEntry
        var entries = [ChartDataEntry]()
        var xAxis: [String] = []
  
        
        for x in 0...dayDifference{
            entries.append(ChartDataEntry(x: Double(x), y: Double((habits[x].finalPercent)*100)))
            xAxis.append(habits[x].date)
        }
        
        //FIMXE: also fix later
//        let last = entries.last
        
//        //Updating last rate as % in currentSuccessRate
//        if last == nil {
//            currentSuccessRate.text = "0.0%"
//        } else {
//            let lastRate = habitRates[dayDifference].rate
//            currentSuccessRate.text = "\(String(format: "%.1f", Double(lastRate)))%"
//        }
//
        //Formatting xAxis from Numb to String
        totalLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxis)
        
        // 2. Set ChartDataSet
        let set = LineChartDataSet(entries: entries, label: "% Succeeded")
        // Makes the line smooth, changes radius of circle = 3 + line thickness = 2
        set.mode = .cubicBezier
        set.circleRadius = 3
        set.lineWidth = 2
        //            set.drawCirclesEnabled = false //Removes points on the graph
        
        // 3. Set ChartData
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false) //Removes label
        print(xAxis)
        
        // 4. Assign it to the chart’s data
        totalLineChart.data = data
        
        if xAxis.count <= 10 {
            totalLineChart.xAxis.axisMaximum = 10
            totalLineChart.xAxis.axisMinimum = 0
        } else {
            totalLineChart.xAxis.axisMaximum = Double(xAxis.count + 1)
            totalLineChart.xAxis.axisMinimum = 0
        }
        
    }
 
    
    //Navi Bar 만드는 func.
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }
}
