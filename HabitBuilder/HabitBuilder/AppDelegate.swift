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
    
         UITabBar.appearance().tintColor = .red
         
         let mainVC = NotiTestVC()
         let defaultNavi = UINavigationController(rootViewController: mainVC)
         mainVC.title = "Habits"
         mainVC.tabBarItem.image = UIImage(named: "goals")
         
         
         let allHabitsVC = AllHabitsVC()
         let allHabitsNavi = UINavigationController(rootViewController: allHabitsVC)
         allHabitsVC.title = "All Habits"
         allHabitsVC.tabBarItem.image = UIImage(named: "all")
         
//         settingVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
                
         self.window!.rootViewController = tabBarController
         
         tabBarController.setViewControllers([defaultNavi, allHabitsNavi], animated: false)
         
                  
         self.window!.makeKeyAndVisible()
         return true
     }



}

