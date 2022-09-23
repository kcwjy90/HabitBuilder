//
//  AppDelegate.swift
//  HabitBuilder
//
//  Created by CW on 1/25/22.
//  Copyright © 2022 CW. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate{

     var window: UIWindow?

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         // Override point for customization after application launch.
         
         DBManager.SI.initialize()
                  
         self.window = UIWindow(frame: UIScreen.main.bounds)

         // Declaring TabBar
         let tabBarController = UITabBarController()
        
         tabBarController.tabBar.isTranslucent = false // both lines needed
         tabBarController.tabBar.backgroundColor = .white // to change tabbar color
             
         UITabBar.appearance().tintColor = .tintBlue
         
         NotificationManger.SI.requestNotiAuth()
         
         let mainVC = MainVC()
         let defaultNavi = UINavigationController(rootViewController: mainVC)
         mainVC.title = "Today's Habits"
         mainVC.tabBarItem.image = UIImage(named: "goals")
         
         
//         let allHabitsVC = AllHabitsVC()
//         let allHabitsNavi = UINavigationController(rootViewController: allHabitsVC)
//         allHabitsVC.title = "All Habits"
//         allHabitsVC.tabBarItem.image = UIImage(named: "all")
//
         let progressVC = ProgressVC()
         let progressNavi = UINavigationController(rootViewController: progressVC)
         progressVC.title = "Progress"
         progressVC.tabBarItem.image = UIImage(named: "progress")
         
//         let searchVC = searchVC()
//         let searchNavi = UINavigationController(rootViewController: searchVC)
//         searchVC.title = "Search Habits"
//         searchVC.tabBarItem.image = UIImage(named: "search")
         
         let allHabitSearchVC = AllHabitSearchVC()
         let allHabitSearchNavi = UINavigationController(rootViewController: allHabitSearchVC)
         allHabitSearchVC.title = "Search All Habits"
         allHabitSearchVC.tabBarItem.image = UIImage(named: "search")

         
//         settingVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
                
         self.window!.rootViewController = tabBarController
         
         tabBarController.setViewControllers([defaultNavi, allHabitSearchNavi, progressNavi], animated: false)
         
                  
         self.window!.makeKeyAndVisible()
         return true
         
     }
    
    // MARK: Local notifications. 이 코드는 notification를 통해 app 으로 들어가면 앱 아이콘의 빨간 숫자를 지워준다.
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }


}

