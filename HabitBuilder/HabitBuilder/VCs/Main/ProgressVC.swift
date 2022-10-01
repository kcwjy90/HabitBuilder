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
        
        habitLineChart.snp.makeConstraints{ (make) in
            make.width.equalTo(backView)
            make.height.equalTo(habitLineChart.snp.width)
        }
        habitLineChart.center = view.center
        habitLineChart.backgroundColor = .white
        
        //MARK: time function that returns timeInterval
        func time(lsh: Date, rhs: Date) -> TimeInterval {
            return lsh.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
        }
        //TEST 용
        let calendar = Calendar.current
        let tmr = calendar.date(byAdding: .day, value: 3, to: Date())

        var xAxisStart = Date()
        var xAxisEnd = tmr
        
        //두 날짜의 차이를 계산한것. 역시나 테스트용
        let secondDifference = time(lsh: xAxisEnd!, rhs: xAxisStart)
        let dayDifference = round(secondDifference/(60*60*24))
        
        //역시나 test용. 나중에 y axis에 갈것. success/fail 중 눌러지는것에 반응
        let success = 3
        let fail = 1
        let total = Int(dayDifference) + 1
        
        //formula는 나중에 구상하자. rate var에 success/total을 넣을예정. fail은 필요 없을수도
        print("===============================")
        print(Double(success)/Double(total))
        
        let rate = [100, 50, 75, 82.5]
        //나중에 dayDifference대신 habitdate(current date) - habit.startdate 을 적용하면 됨.
        
        // 1. Set ChartDataEntry
        var entries = [ChartDataEntry]()
        for x in 0...Int(dayDifference){
            entries.append(ChartDataEntry(x: Double(x), y: Double(rate[x])))
        }
        
        // 2. Set ChartDataSet
        let set = LineChartDataSet(entries: entries, label: "")
        set.colors = ChartColorTemplates.material()
        
        // 3. Set ChartData
        let data = LineChartData(dataSet: set)
        
        // 4. Assign it to the chart’s data
        habitLineChart.data = data
        
    }


    //MARK: Navi Bar
    func setNaviBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
    }
}

