
//AppBackgroundTaskManager.swift

//import Foundation
//import UIKit
//import AVFoundation
//import UserNotifications

//class BackgroundTaskStatus: ObservableObject {
//    @Published var shouldStartBackgroundTask = false
//}
//
//class AppBackgroundTaskManager: NSObject {
//    var audioPlayer: AVAudioPlayer!
//    var audioEngine = AVAudioEngine()
//    var bgTask: UIBackgroundTaskIdentifier = .invalid
//    var applyTimer: Timer?
//    var taskTimer: Timer?
//    
//    static let shared = AppBackgroundTaskManager()
//    
//    func sendNotification() {
//        // 创建通知内容
//        let content = UNMutableNotificationContent()
//        content.title = "后台活着呢"
//        content.body = "这是通知的主体内容。"
//        content.sound = UNNotificationSound.default
//
//        // 创建触发器
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//        // 创建请求
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        // 将请求添加到通知中心
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                // 处理添加通知时的错误
//                print("无法添加通知: \(error.localizedDescription)")
//            }
//        }
//    }
//    func sendNotification2() {
//        // 创建通知内容
//        let content = UNMutableNotificationContent()
//        content.title = "尝试播放音频了"
//        content.body = "保活呢"
//        content.sound = UNNotificationSound.default
//
//        // 设置通知触发器
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//        // 创建通知请求
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        // 将请求添加到通知中心
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("无法添加通知: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func startBackgroundTask() {
//        print("后台保活了")
//        self.bgTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            // 如果我们到达这里，表示后台任务即将过期
//            self?.endBackgroundTask()
//            self?.applyForMoreTime()
//        }
//        
//        // 启动或重新启动定时器
//        applyTimer?.invalidate()
//        applyTimer = Timer.scheduledTimer(timeInterval: 10, target: self,
//                                          selector: #selector(applyForMoreTime), userInfo: nil, repeats: true)
//        taskTimer?.invalidate()
//        taskTimer = Timer.scheduledTimer(timeInterval: 28, target: self,
//                                         selector: #selector(doSomething), userInfo: nil, repeats: true)
//    }
//    
//    func stopBackgroundTask() {
//        // 停止所有定时器
//        applyTimer?.invalidate()
//        applyTimer = nil
//        taskTimer?.invalidate()
//        taskTimer = nil
//        
//        // 结束后台任务
//        endBackgroundTask()
//        print("后台停止保活")
//    }
//    
//    @objc func applyForMoreTime() {
//        if UIApplication.shared.backgroundTimeRemaining < 30 {
//            endBackgroundTask() // 结束当前的后台任务
//            
//            self.bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
//                // 如果我们到达这里，表示后台任务即将过期
//                self?.endBackgroundTask()
//            })
//            
//            // 试图播放静音音频文件以保持后台活动
//            print("试图保活")
////            self.sendNotification2()
//            playSilentAudio()
//        }
//    }
//    
//    @objc func doSomething() {
//        // 在这里执行你希望定时做的事情
//        print("Doing something: \(UIApplication.shared.backgroundTimeRemaining) seconds remaining")
//        // 调用 NetworkService 的 getCurrentOrderStatus 方法
//        NetworkService.shared.getCurrentOrderStatus {
//            // 网络请求完成后的操作
//            print("在后台请求订单状态了")
//        }
////        sendNotification()
//        
//    }
//    
//    private func endBackgroundTask() {
//        if bgTask != .invalid {
//            UIApplication.shared.endBackgroundTask(bgTask)
//            bgTask = .invalid
//        }
//    }
//    
//    private func playSilentAudio() {
//        guard let path = Bundle.main.path(forResource: "TripTips", ofType: "wav") else { return }
//        let filePathUrl = URL(fileURLWithPath: path)
//        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .mixWithOthers)
//            try AVAudioSession.sharedInstance().setActive(true)
//            audioPlayer = try AVAudioPlayer(contentsOf: filePathUrl)
//            audioPlayer.numberOfLoops = -1 // 循环播放
//            audioPlayer.prepareToPlay()
//            audioPlayer.play()
//            print("播放音频了")
//        } catch {
//            print("Audio Session or Audio Player error: \(error)")
//        }
//    }
//    
//}



