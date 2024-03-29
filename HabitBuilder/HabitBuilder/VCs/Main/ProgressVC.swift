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
    
    // numberOfHundred 생성
    lazy var numberOfHundredLabel: UILabel = {
        let v = UILabel()
        v.text = "Number of 100% Reached :"
        v.font = UIFont.systemFont(ofSize: 17.0)
        v.textColor = .black
        return v
    }()
    
    lazy var numberOfHundred: UILabel = {
        let v = UILabel()
        v.text = "No Data"
        v.font = UIFont.systemFont(ofSize: 30.0)
        v.textColor = .black
        return v
    }()
    
    // mostFrequentPercent 생성
    lazy var mostFrequentPercentLabel: UILabel = {
        let v = UILabel()
        v.text = "Most Frequent % :"
        v.font = UIFont.systemFont(ofSize: 17.0)
        v.textColor = .black
        return v
    }()
    
    lazy var mostFrequentPercent: UILabel = {
        let v = UILabel()
        v.text = "No Data"
        v.font = UIFont.systemFont(ofSize: 30.0)
        v.textColor = .black
        return v
    }()
    
    // currentSuccessRate 생성
    lazy var currentSuccessRateLabel: UILabel = {
        let v = UILabel()
        v.text = "Current Success Rate :"
        v.font = UIFont.systemFont(ofSize: 17.0)
        v.textColor = .black
        return v
    }()
    
    lazy var currentSuccessRate: UILabel = {
        let v = UILabel()
        v.text = "No Data"
        v.font = UIFont.systemFont(ofSize: 30.0)
        v.textColor = .black
        return v
    }()
    
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
        backView.addSubview(totalLineChart)
        backView.addSubview(mostFrequentPercentLabel)
        backView.addSubview(mostFrequentPercent)
        backView.addSubview(numberOfHundredLabel)
        backView.addSubview(numberOfHundred)
        backView.addSubview(currentSuccessRateLabel)
        backView.addSubview(currentSuccessRate)
        
        
        view.backgroundColor = .white
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // BackView grid
        backView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // mostFrequentPercentLabel size grid
        mostFrequentPercentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backView)
            make.left.equalTo(backView).offset(10)
            make.height.equalTo(40)
        }
        
        // mostFrequentPercent size grid
        mostFrequentPercent.snp.makeConstraints { (make) in
            make.top.equalTo(mostFrequentPercentLabel)
            make.left.equalTo(mostFrequentPercentLabel.snp.right).offset(10)
            make.height.equalTo(40)
        }
        
        // numberOfHundredLabel size grid
        numberOfHundredLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mostFrequentPercentLabel.snp.bottom).offset(10)
            make.left.equalTo(mostFrequentPercentLabel)
            make.height.equalTo(40)
        }
        
        // numberOfHundred size grid
        numberOfHundred.snp.makeConstraints { (make) in
            make.top.equalTo(numberOfHundredLabel)
            make.left.equalTo(numberOfHundredLabel.snp.right).offset(10)
            make.height.equalTo(40)
        }
        
        // currentSuccessRateLabel size grid
        currentSuccessRateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(numberOfHundredLabel.snp.bottom).offset(10)
            make.left.equalTo(backView).offset(10)
            make.height.equalTo(40)
        }
        
        // currentSuccessRate size grid
        currentSuccessRate.snp.makeConstraints { (make) in
            make.top.equalTo(currentSuccessRateLabel)
            make.left.equalTo(currentSuccessRateLabel.snp.right).offset(10)
            make.height.equalTo(40)
        }
        
        // todayPiChart grid
        totalLineChart.snp.makeConstraints{ (make) in
            make.top.equalTo(currentSuccessRateLabel.snp.bottom).offset(20)
            make.left.equalTo(backView).offset(10)
            make.right.equalTo(backView).offset(-15)
            make.bottom.equalTo(backView).offset(-20)
            
        }
        totalLineChart.center = backView.center
        totalLineChart.isUserInteractionEnabled = false
        totalLineChart.xAxis.labelPosition = .bottom
        totalLineChart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        totalLineChart.xAxis.setLabelCount(4, force: false)
        totalLineChart.rightAxis.enabled = false
        totalLineChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        totalLineChart.leftAxis.setLabelCount(6, force: false)
        totalLineChart.leftAxis.labelTextColor = .black
        totalLineChart.leftAxis.axisLineColor = .black
        totalLineChart.leftAxis.axisMinimum = 0
        totalLineChart.leftAxis.axisMaximum = 100
        
    }
    
    
    //MARK: code that creates the piechart. Needs to reload so graph gets updated
    func reloadChart() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateDisplay = DateFormatter()
        dateDisplay.dateFormat = "MMM d, yyyy"
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        
        let countRealm = self.localRealm.objects(RMO_Count.self)
        
        //MARK: todayLineChart 에 들어가는 count들을 넣어주는 코드
        guard let indexNumb = countRealm.firstIndex(where: { $0.date == todayDate}) else
        {return}
        let todayCount = countRealm[indexNumb] //todayCount = 오늘 날짜에 해당하는 RMO_Count 의 successRate을 불러옴
        success = Float(todayCount.finalPercent)
        
        habits = localRealm.objects(RMO_Count.self).toArray() //updating habits []
        
        habits = habits.sorted(by: {
            $0.date.compare($1.date) == .orderedAscending
        })
        
        print("progressVC line 101=========================================\(habits)")
        
        //Make today the last day to show the graph
        guard let indexNumb = habits.firstIndex(where: { $0.date == todayDate}) else
        {return}
        
        //Displaying Current SuccessRate, [Most Frequent %, Number of 100% reached] - will be added later
        if habits[indexNumb].finalPercent == -123 {
            currentSuccessRate.text = "No Habit"
        } else {
            currentSuccessRate.text = "\(String(format: "%.1f", habits[indexNumb].finalPercent*100))%"
        }
        
        //MARK: counting how many 100% there are
        let numbHundred = localRealm.objects(RMO_Count.self).filter("finalPercent == 1")
        
        if numbHundred.count == 1 {
            numberOfHundred.text = "1 time"
        } else {
            numberOfHundred.text = "\(numbHundred.count) times"
        }
        
        
        //MARK: finding the most frequent %
        var finalArray: [Float] = []
        
        for final in 0...indexNumb{
            finalArray.append(habits[final].finalPercent)
        }
        
        print(finalArray)
        
        let countedSet = NSCountedSet(array: finalArray)
        let mostFrequent = countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) }
                
        //MARK: Changing mostFrequent number which is NSNumber to "string" in decimal -> converting back to Float to *100 -> back to String
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let freqValString = formatter.string(from: mostFrequent as! NSNumber) ?? ""
        let freqValFloat = Float(freqValString)

        guard let freqValPercent = freqValFloat else {return}
        let freqRound = freqValPercent*10/10.0 //round up to 10th decimal
        let freqValFinal = String((freqRound)*100)

        mostFrequentPercent.text = "\(freqValFinal)%"
        
        
        // 1. Set ChartDataEntry
        var entries = [ChartDataEntry]()
        var xAxis: [String] = []
        
        if indexNumb == 0 {
            entries.append(ChartDataEntry(x: Double(indexNumb), y: Double((habits[indexNumb].finalPercent)*100)))
            xAxis.append(habits[indexNumb].date)
        } else {
            for x in 0...indexNumb{
                entries.append(ChartDataEntry(x: Double(x), y: Double((habits[x].finalPercent)*100)))
                xAxis.append(habits[x].date)
            }
        }
        
        //Formatting xAxis from Numb to String
        totalLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxis)
        
        // 2. Set ChartDataSet
        let set = LineChartDataSet(entries: entries, label: "% Succeeded")
        // Makes the line smooth, changes radius of circle = 3 + line thickness = 2
        //        set.mode = .cubicBezier
        set.circleRadius = 3
        set.lineWidth = 2
        //            set.drawCirclesEnabled = false //Removes points on the graph
        
        // 3. Set ChartData
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false) //Removes label
        print(xAxis)
        
        // 4. Assign it to the chart’s data
        totalLineChart.data = data
        
        if xAxis.count < 10 {
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


//How I used to calculate current Rate
//        print(entries)
//        guard let currentRate = entries.last else {return}
//
//
//        if currentRate == nil {
//            currentSuccessRate.text = "0.0%"
//        } else {
//            currentSuccessRate.text = "\(String(currentRate.y))%"
//        }
//
//Most Frequent
//        let countHundred = [entries].filter { $0 == 100.0 }.count
//        if countHundred == 1 {
//            numberOfHundred.text = "\(String(countHundred)) Time"
//        } else {
//            numberOfHundred.text = "\(String(countHundred)) Times"
//        }
