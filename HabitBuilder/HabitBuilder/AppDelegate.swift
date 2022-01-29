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
         

        
         self.window = UIWindow(frame: UIScreen.main.bounds)

         let mainVC = MainVC()
         let defaultNavi = UINavigationController(rootViewController: mainVC)
         self.window!.rootViewController = defaultNavi
         
         self.window!.makeKeyAndVisible()
         return true
     }



}

