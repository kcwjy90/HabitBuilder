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

         // Declaring TabBar
         let tabBar = UITabBarController()
        
    
         let mainVC = MainVC()
         let defaultNavi = UINavigationController(rootViewController: mainVC)
         defaultNavi.title = "HB"
         
         // TabBar를 눌렀을때 가게되는 2번째 VC. 임시
         let secondvc = secondV()
         secondvc.title = "second"
         
         self.window!.rootViewController = tabBar
         
         tabBar.setViewControllers([defaultNavi, secondvc], animated: false)
                  
         self.window!.makeKeyAndVisible()
         return true
     }



}

// Declaring 2번째 viewcontroller. 임시
class secondV: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

//일단 tabbar가 들어가기는 했는데..뭔가..색이 왜이렇지? 뭔가가 잘못 적용되어있어
