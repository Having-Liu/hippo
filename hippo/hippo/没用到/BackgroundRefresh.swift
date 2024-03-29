////
////  BackgroundRefresh.swift
////  hippo
////
////  Created by 自在 on 2024/3/2.
////
//
//import UIKit
//import BackgroundTasks
//
//class BackgroundRefresh: UIResponder, UIApplicationDelegate {
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // 注册后台任务
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "zizai.hippo.refresh", using: nil) { task in
//            // 强制转换为 BGAppRefreshTask 并处理它
//            self.handleAppRefresh(task: task as! BGAppRefreshTask)
//            print("后台任务已成功注册")
//        }
//        
//        // 安排第一个后台刷新任务
////        scheduleAppRefresh()
//        
//        return true
//    }
//    
//    // 安排后台任务
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "zizai.hippo.refresh")
//        request.earliestBeginDate = nil // 移除时间间隔设置，让系统决定最佳时间
//        
//        print("安排后台任务了")
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("无法安排应用刷新: \(error)")
//        }
//    }
//    
//    // 处理后台刷新任务
//    func handleAppRefresh(task: BGAppRefreshTask) {
//        print("执行后台任务了")
//        // 为了防止任务过早终止，安排一个新的刷新任务
//        scheduleAppRefresh()
//        
//        // 设置失效处理器，以防任务因为超时或系统条件而被取消
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//        }
//        
//        // 在这里执行你的数据获取逻辑
//        let networkService = NetworkService.shared // 如果你使用单例模式
//        networkService.getCurrentOrderStatus {
//            // 数据获取完成，无论成功或失败，都标记任务完成
//            // 如果你有一个从 `getCurrentOrderStatus` 方法返回的成功标志，你应该使用它
//            // 例如：task.setTaskCompleted(success: successFlag)
//            
//            if let orderStage = networkService.orderStage {
//                        // 根据 orderStage 执行不同的逻辑
//                        switch orderStage {
//                        case "0":
//                            // 例如：订单处于等待状态
//                            task.setTaskCompleted(success: true)
//                            
//                            self.scheduleAppRefresh()
//                        case "1":
//                            // 例如：订单进行中
//                            task.setTaskCompleted(success: true)
//                            
//                            self.scheduleAppRefresh()
//                        case "2":
//                            // 例如：订单已完成
//                            print("订单已完成")
//                            task.setTaskCompleted(success: true)
//                        default:
//                            print("未知的订单状态")
//                        }
//                    } else {
//                    }
//            
//            
//            // 这里我们假设任务总是成功完成的
//            task.setTaskCompleted(success: true)
//            
//            self.scheduleAppRefresh()
//        }
//    }
//    
//    // 取消所有后台任务
//    func cancelAllPendingTasks() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//        print("所有后台任务已取消")
//    }
//    
//}
//
//
//
//// 假设 getCurrentOrderStatus 现在接受一个 (Bool) -> Void 的闭包
////        networkService.getCurrentOrderStatus { success in
////            task.setTaskCompleted(success: success)
////        }
