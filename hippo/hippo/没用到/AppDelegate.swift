////
////  AppDelegate.swift
////  hippo
////
////  Created by 自在 on 2024/3/5.
////
//
//import UIKit
//import SwiftUI
//
//@main
////@UIApplicationMain
//
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//
//    var window: UIWindow?
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // 创建一个 UIWindow 并将其设置为屏幕的大小
//        window = UIWindow(frame: UIScreen.main.bounds)
//        
//        // 创建 SwiftUI 视图，用来作为 UIHostingController 的根视图
//        let contentView = ContentView()
//        
//        // 使用根视图创建 UIHostingController
//        window?.rootViewController = UIHostingController(rootView: contentView)
//        
//        // 显示窗口
//        window?.makeKeyAndVisible()
//        
//        return true
//    }
//    
//
////    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
////        // Override point for customization after application launch.
////        return true
////    }
//
//    // MARK: UISceneSession Lifecycle
//
////    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
////        // Called when a new scene session is being created.
////        // Use this method to select a configuration to create the new scene with.
////        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
////    }
////
////    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
////        // Called when the user discards a scene session.
////        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
////        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
////    }
//    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        AppBackgroundTaskManager.shared.startBackgroundTask(app: application)
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        AppBackgroundTaskManager.shared.stopBackgroundTask()
//    }
//
//
//}
//
//
