//
//  NetworkService.swift
//  hippo
//
//  Created by 自在 on 2024/3/2.
//

import Foundation
import UserNotifications
import ActivityKit
import UIKit
import AVFoundation


// MARK: 唯一一个全局变量：订单状态
public class GlobalData: ObservableObject {
    public static let shared = GlobalData()
    
    @Published var GlobalorderStage: String?
    @Published var shouldStartBackgroundTask = false
    // ... 其他全局状态
}

// 使用
// GlobalData.shared.orderId = "新的订单ID"


// NetworkManager 负责执行网络请求并处理数据
public class NetworkService: NSObject, ObservableObject, URLSessionDelegate {
    
    let backgroundTaskManager = AppBackgroundTaskManager.shared
    
    static let shared = NetworkService()
    
//    @Published public var showAlert: Bool = false
//    @Published public var alertMessage: String = "" // 确保这个属性存在
//    
//    public var showAlertBinding: Binding<Bool> {
//        Binding(
//            get: { self.showAlert },
//            set: { self.showAlert = $0}
//        )
//    }
    
    
    // MARK: 变量都写上描述
    
    // 使用 @Published 修饰符来允许 SwiftUI 监听这些属性的变化
    
    //上来通过链接获取这 4 个信息
    @Published var orderId: String? //订单id，获取出来后面要用的
    @Published var productType: String?//刚开始获取的打车类型，获取出来后面要用的
    @Published var uid: String?//刚开始获取的uid
    @Published var sign: String?//刚开始获取的sign
    
    //通过上面的 4 个信息获取 driverid
    @Published var driverId: String? //要专门获取的司机id
    
    //通过上面的 4 个信息获取订单状态·
    @Published var orderStage: String?//接口返回的订单状态
    
    //有了 driverid 、订单状态等信息，还要把这几个字段改为 int 类型，用来获取实时信息
    @Published var driverIdInt: Int?//把司机ID改为int，用在请求实时信息
    @Published var bizTypeInt: Int?//把打车类型转为int，用在请求实时信息
    @Published var orderStageInt: Int?//把订单状态转为int，用在请求实时信息，别忘了在原来的基础上+3
    
    //通过getOrderRouteStatus接口，获取的信息，提取出etaString，再从中提出时间和地点
    @Published var etaString: String?//实时信息里返回的一句话描述，里面有剩余时间和剩余路程，提出出来后，在灵动岛显示
    @Published var originaldistance: Double?//提取出来的剩余路程信息
    @Published var originaltime : Int?//提取出来的剩余时间，别忘了传到灵动岛
    
    //记录下第一次的路程，并计算出百分比
    @Published var journey: Double?//第一次获取的路程，未上车和在路上用一个就行，后面的覆盖前面的
    @Published var progress: Double?//计算出来的百分比未上车和在路上用一个就行，后面的覆盖前面的
    @Published var matchStage: String?//记录一个用来对比状态是否变化的值，状态变化的时候，重制journey
    
    //推送到灵动岛和实时活动的信息
    //    @Published var progress = 0.05//上面已经有了
    //    @Published var distance: String//上面已经有了
    @Published var title: String?//根据不同状态传不同的title：未上车：预计几分钟上车 / 在路上：预计几分钟到达 / 已到达：已到达目的地
    @Published var destination:String?//根据不同状态传不同的名字：未上车：上车点 / 在路上：目的地 / 已到达：目的地 。 拼起来的时候就是：距离目的地几公里
    @Published var iconName:String?//根据不同状态传不同的 icon 名字，未上车：figure.wave.circle.fill / 在路上：house.circle.fill / 已到达：house.circle.fill
    
    var timer: Timer?
    
    
    public func setOrderInfo(orderId: String?, productType: String?, uid: String?, sign: String?, driverId: String?,driverIdInt:Int?) {
        self.orderId = orderId
        self.productType = productType
        self.uid = uid
        self.sign = sign
        self.driverId = driverId
        self.driverIdInt = driverIdInt
    }
    
    
    
    // MARK: URLSession 用于执行网络请求
    // 使用 lazy var 延迟初始化，以便在需要时才创建
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: 灵动岛相关的所有方法
    //开启灵动岛显示功能
    func startActivity(){
       
        Task{
            print("NetworkService开启灵动岛--------------------")
            let attributes = hippoWidgetAttributes(name:"我是名字")
            let initialContentState = hippoWidgetAttributes.ContentState(progress: self.progress ?? 0.05,distance: "\(String(self.originaldistance ?? 0))", title:self.title ?? "行程查询中，稍等哦",destination: self.destination ?? "查询中",iconName:self.iconName ?? "poweroutlet.type.b.fill",time:"\(String(self.originaltime ?? 0))")
            do {
                // 创建 ActivityContent 实例
                let content = ActivityContent(state: initialContentState, staleDate: Date().addingTimeInterval(10800))
                
//                // 使用 ActivityContent 实例调用 request 方法
//                let myActivity = try Activity<hippoWidgetAttributes>.request(
//                    attributes: attributes,
//                    content: content, // 使用 content 而不是 initialContentState
//                    pushType: nil
//                )
//                print("Requested a Live Activity \(myActivity.id)")
//                print("NetworkService已开启灵动岛显示 App切换到后台即可看到")
                
                // 使用 ActivityContent 实例调用 request 方法
                let myActivity = try Activity<hippoWidgetAttributes>.request(
                    attributes: attributes,
                    content: content, // 使用 content 而不是 initialContentState
//                    pushType: .token
                    pushType: nil
                )
                print("Requested a Live Activity \(myActivity.id)")
                print("NetworkService已开启灵动岛显示 App切换到后台即可看到")
                Task {
                    // 获取实时活动的唯一推送Token
                    for await tokenData in myActivity.pushTokenUpdates {
//                        let token = tokenData.map { String(format: "%02x", \$0) }.joined()
                        let token = tokenData.map { String(format: "%02x", $0) }.joined()
                        print("获取到实时活动的推送Token: \(token)")
                        
                        // 将Token发送给后端服务器
                        sendTokenToServer(token: token)
                    }
                    
                }
            } catch (let error) {
                print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
            }
        }
        startTimer()
        backgroundTaskManager.startBackgroundTask()
    }
        

    
    
    func sendTokenToServer(token: String) {
        // 构建请求的URL
        let baseURL = "https://api2.pushdeer.com/message/push"
        let pushkey = "PDU26873Twau9PEPWaMC81CXZAFd0lYbOAmGjtP6S"
        let text = "获取到的token: \(token)"
        
        // 对text进行URL编码
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("无法编码text")
            return
        }
        
        // 拼接完整的URL
        let urlString = "\(baseURL)?pushkey=\(pushkey)&text=\(encodedText)"
        
        // 确保URL有效
        guard let url = URL(string: urlString) else {
            print("无效的URL")
            return
        }
        
        // 创建URLRequest对象
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 发起网络请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 在这里处理响应
            if let error = error {
                print("请求失败: \(error.localizedDescription)")
            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("收到响应: \(responseString)")
            }
        }
        task.resume()
    }

    
    
    //更新灵动岛
    func updateActivity(){
        Task{
            let updatedStatus = hippoWidgetAttributes.ContentState(progress: self.progress ?? 0.05,distance: "\(String(self.originaldistance ?? 0))", title:self.title ?? "遇到了二些问题哦",destination: self.destination ?? "出错了",iconName:self.iconName ?? "poweroutlet.type.b.fill",time:"\(String(self.originaltime ?? 0))")
            for activity in Activity<hippoWidgetAttributes>.activities{
                //                await activity.update(using: updatedStatus)
                // 创建一个 ActivityContent 实例，假设 updatedStatus 是 ContentState 类型的实例
                let updatedContent = ActivityContent(state: updatedStatus, staleDate: Date().addingTimeInterval(10800))
                
                // 使用新的 API 调用 update 方法
                await activity.update(updatedContent)
                
                print("NetworkService已更新灵动岛显示,Value值已更新 请展开灵动岛查看")
            }
        }
    }
    
    //结束灵动岛显示
    func endActivity(){
        Task{
            for activity in Activity<hippoWidgetAttributes>.activities{
                //                await activity.end(dismissalPolicy: .immediate)
                // 使用新的 API 结束活动
                //                await activity.end(dismissalPolicy: .immediate)
                await activity.end(nil, dismissalPolicy: .immediate)
                
                print("NetworkService已关闭灵动岛显示")
            }
        }
    }
    
    
    
    // MARK: - 获取当前订单状态
    
    // getCurrentOrderStatus 方法用于获取当前订单状态
    func getCurrentOrderStatus(completion: @escaping () -> Void) {
        print("networksrervice 获取订单状态")
        // 确保所有必要的参数都存在
        guard let orderId = orderId, let uid = uid, let sign = sign, let productType = productType else {
            print("缺少必要的参数来获取行程状态")
            completion() // 调用 completion，无论成功与否
            return
        }
        
        // 构建请求的 URL 组件
        var components = URLComponents(string: "https://common.diditaxi.com.cn/webapp/sharetrips/page/getCurrentOrderStatus")
        components?.queryItems = [
            URLQueryItem(name: "oid", value: orderId),
            URLQueryItem(name: "uid", value: uid),
            URLQueryItem(name: "sign", value: sign),
            URLQueryItem(name: "productType", value: productType)
        ]
        
        // 检查 URL 是否正确构建
        guard let url = components?.url else {
            print("无法构建有效的 URL")
            completion() // 调用 completion，无论成功与否
            return
        }
        
        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 发起网络请求
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("获取订单状态错误: \(error.localizedDescription)")
                } else if let data = data {
                    do {
                        // 将返回的数据解码为 JSON
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let orderStatus = jsonObject["orderStatus"] as? Int { // 根据您提供的 JSON 结构，orderStatus 是一个整数
                            // 更新 orderStage 属性
                            self?.orderStage = String(orderStatus)
                            self?.orderStageInt = Int(self!.orderStage!)! + 3
                            // 同步更新全局状态
                            GlobalData.shared.GlobalorderStage = self?.orderStage
                            print("GlobalorderStage改为\(String(describing: GlobalData.shared.GlobalorderStage))")
                            print("订单int状态已更新: \(String(describing: self?.orderStageInt))")
                            
                            
                            //这里根据状态给一些灵动岛的变量赋值
                            if self?.orderStage == "0"{
                                self?.destination = "上车点"
                                self?.iconName = "figure.wave.circle.fill"
                                self?.getOrderRouteStatus{}
                                
                            }else if self?.orderStage == "1" {
                                self?.destination = "目的地"
                                self?.iconName = "house.circle.fill"
                                
                                self?.getOrderRouteStatus{}
                                
                            } else if self?.orderStage == "2"
                            {
                                self?.destination = "目的地"
                                self?.iconName = "house.circle.fill"
                                self?.title = "宝宝已到达"
                                self?.originaldistance = 0
                                self?.originaltime = 0
                                self?.progress = 1.0
                                self?.updateActivity()
                                self?.stopfresh()
                                
                            }else
                            {
                                self?.destination = "出错了"
                                self?.iconName = "poweroutlet.type.b.fill"
                                self?.updateActivity()
                                self?.stopfresh()
                            }
                            
                            completion() // 调用 completion，无论成功与否
                        } else {
                            print("JSON 解析失败或找不到 orderStatus")
                            self?.stopfresh()
                        }
                    } catch {
                        print("订单状态JSON 解析错误: \(error.localizedDescription)")
                        self?.stopfresh()
                        completion() // 调用 completion，无论成功与否
                    }
                } else {
                    print("获取订单状态时未收到数据")
                    self?.stopfresh()
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - 分析etaString用的
    // 修改 extractNumbers 函数，以适应可能存在的小时和分钟的情况
    func extractNumbers(from input: String) -> [Double] {
        let pattern = "\\d+"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(input.startIndex..<input.endIndex, in: input)
            let matches = regex.matches(in: input, range: nsRange)
            
            return matches.compactMap { match -> Double? in
                guard let range = Range(match.range, in: input) else { return nil }
                let numberString = input[range]
                return Double(numberString)
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
//    func extractNumbers(from input: String) -> [Double] {
//        let pattern = "\\{(\\d+(\\.\\d+)?)\\}"
//        do {
//            let regex = try NSRegularExpression(pattern: pattern)
//            let nsRange = NSRange(input.startIndex..<input.endIndex, in: input)
//            let matches = regex.matches(in: input, range: nsRange)
//            
//            return matches.compactMap { match -> Double? in
//                guard let range = Range(match.range, in: input) else { return nil }
//                let numberString = input[range].trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
//                return Double(numberString)
//            }
//        } catch {
//            print("Invalid regex: \(error.localizedDescription)")
//            return []
//        }
//    }
    
    
    // MARK: - 获取订单实时信息
    func getOrderRouteStatus(completion: @escaping () -> Void)  {
        print("networkservice请求更新状态")
        guard let driverIdInt = self.driverIdInt else {
            print("driverIdInt 为 nil，请确保在 fetchDriverId 方法中已经成功赋值，这里是networkservice")
            return
        }
        
        let urlString = "https://api.map.diditaxi.com.cn/navi/v1/passenger/orderroute/"
        guard let url = URL(string: urlString) else {
            print("orderroute 接口链接无效")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // 准备请求的 JSON 数据
        print("准备请求getOrderRouteStatus的 JSON 数据")
        let parameters: [String: Any] = [
            "orderId": orderId ?? 1234567,
            "driverId": driverIdInt,
            "bizType": bizTypeInt  ?? 260,
            "orderStage": self.orderStageInt ?? 4,
            "caller": "sharetravel"
        ]
        print(parameters as Any)
        
        // 尝试将参数编码为 JSON
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("无法创建 JSON 请求体")
            return
        }
        
        request.httpBody = postData
        // 发起请求
        // ...之前的代码
        
        // 发起请求
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("获取行程状态失败: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("获取行程状态时未收到数据")
                    return
                }
                
                let dataString = String(data: data, encoding: .utf8) ?? "无法将数据转换为文本"
                print("getOrderRouteStatus接口收到的数据: \(dataString)")  // 这里打印出返回的数据
                
                do {
                    print("开始解析当前行程")
                    // 将返回的数据解码为 JSON
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // 尝试从 etaStr 字段中提取数字
                        if let etaStr = jsonObject["etaStr"] as? String, etaStr.contains("公里") {
                            let numbers = self?.extractNumbers(from: etaStr) ?? []
                            if numbers.count >= 2 {
                                // 从etaStr中提取距离和时间
                                self?.originaldistance = numbers[0] // 距离（公里）
                                self?.originaltime = Int(numbers[1] * 60 + (numbers.count > 2 ? numbers[2] : 0)) // 时间（分钟）
                            }
                        } else if let eta = jsonObject["eta"] as? Int,
                                  let distance = jsonObject["distance"] as? Int {
                            // 如果 etaStr 不包含公里，或者不可用，则直接查找 eta 和 distance 字段
                            self?.originaltime = eta // 时间（分钟）
                            self?.originaldistance = Double(distance) / 1000.0 // 距离（公里），将米转换为公里
                        }
                        
                        // 更新逻辑处理...
                        // 确保在主线程上更新UI
                        // ...
                    } else {
                        self?.stopfresh()
                        print("JSON 解析失败或找不到 etaStr")
                    }
                } catch {
                    print("JSON 解析错误: \(error.localizedDescription)")
                }
            }
        }
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async { [self] in
//                if let error = error {
//                    print("获取行程状态失败: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let data = data else {
//                    print("获取行程状态时未收到数据")
//                    return
//                }
//                
//                let dataString = String(data: data, encoding: .utf8) ?? "无法将数据转换为文本"
//                print("getOrderRouteStatus接口收到的数据: \(dataString)")  // 这里打印出返回的数据
//                
//                do {
//                    print("开始解析当前行程")
//                    // 将返回的数据解码为 JSON
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let etaStr = jsonObject["etaStr"] as? String {
//                        self?.etaString = etaStr
//                        let numbers = self?.extractNumbers(from: etaStr) ?? []
//                        if numbers.count >= 2 {
//                            self?.originaldistance = numbers[0] // 公里数
//                            self?.originaltime = Int(numbers[1]) // 时间（分钟）
//                            
//                            print("距离：\(self?.originaldistance ?? 0)公里, 时间：\(self?.originaltime ?? 0)分钟")
//                            
//                            //计算进度条
//                            if self?.matchStage != self?.orderStage {
//                                self?.matchStage = self?.orderStage
//                                self?.journey = self?.originaldistance
//                            }
//                            
//                            
//                            //这里根据状态给一些灵动岛的变量赋值
//                            if self?.orderStage == "0"{
//                                self?.destination = "上车点"
//                                self?.iconName = "figure.wave.circle.fill"
//                                self?.title = "预计\(String(self?.originaltime ?? 0))分钟上车"
//                                print("准备给灵动岛的标题\(String(describing: self?.title))")
//                                self?.progress = 1 - (self?.originaldistance)! / (self?.journey)!
////                                self?.sendNotification2()
//                                self?.updateActivity()
//                                
//                                
//                            }else if self?.orderStage == "1" {
//                                self?.destination = "目的地"
//                                self?.iconName = "house.circle.fill"
//                                self?.title = "预计\(String(self?.originaltime ?? 0))分钟到达"
//                                print("准备给灵动岛的标题\(String(describing: self?.title))")
//                                self?.progress = 1 - (self?.originaldistance)! / (self?.journey)!
////                                self?.sendNotification2()
//                                self?.updateActivity()
//                                
//                            } else
//                            {
//                                self?.destination = "出错了"
//                                self?.iconName = "poweroutlet.type.b.fill"
////                                self?.sendNotification2()
//                                self?.updateActivity()
//                                self?.stopfresh()
//                                
//                            }
//                            
//                            // 这里执行你需要更新UI的代码，例如刷新UI或者发送通知
//                            // 确保在主线程上更新UI
////                            Task { [weak self] in
////                                self?.updateActivity()
////                            }
//                            
////                            DispatchQueue.main.async {
////                                // 更新UI的代码
////                            }
//                        } else {
//                            print("无法从etaStr中提取距离和时间")
//                        }
//                    } else {
//                        self?.stopfresh()
//                        print("JSON 解析失败或找不到 etaStr")
//                    }
//                } catch {
//                    print("JSON 解析错误: \(error.localizedDescription)")
//                }
//            }
//        }
        
        // 注意 task.resume() 应该在闭包外调用
        task.resume()
    }
    
    
    
    
    func startTimer() {
        // 创建并启动定时器
        print("networkservice 定时器创建")
        self.timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            // 定时器触发时执行的代码
            self.getCurrentOrderStatus {
            }
            print("后台循环了一次")
        }
    }
    
    func stopTimer() {
        // 停止并释放定时器
        print("停止定时任务")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func restartTimer() {
        // 停止现有的定时器
        self.stopTimer()
        // 重新启动定时器
        self.startTimer()
    }
    
    
    
    func stopfresh() {
        stopTimer()
        print("10 分钟后停止保活")
        self.timer = Timer.scheduledTimer(withTimeInterval: 600.0, repeats: false) { _ in
            // 定时器触发时执行的代码
            
            self.backgroundTaskManager.stopBackgroundTask()
            self.sendNotification()
            self.endActivity()
            
            print("后台已停止保活")
        }
        
        
    }
    
    func sendNotification2() {
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "查询订单状态了"
        content.body = "app还在后台运行"
        content.sound = UNNotificationSound.default

        // 设置通知触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 将请求添加到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("无法添加通知: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification() {
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "宝宝已到家"
        content.body = "已自动停止实时活动"
        content.sound = UNNotificationSound.default

        // 设置通知触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 将请求添加到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("无法添加通知: \(error.localizedDescription)")
            }
        }
    }


    
}


//class BackgroundTaskStatus: ObservableObject {
//    @Published var shouldStartBackgroundTask = false
//}

class AppBackgroundTaskManager: NSObject {
    var audioPlayer: AVAudioPlayer!
    var audioEngine = AVAudioEngine()
    var bgTask: UIBackgroundTaskIdentifier = .invalid
    var applyTimer: Timer?
    var taskTimer: Timer?
    
    static let shared = AppBackgroundTaskManager()
    
    func sendNotification() {
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "后台活着呢"
        content.body = "这是通知的主体内容。"
        content.sound = UNNotificationSound.default

        // 创建触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 将请求添加到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // 处理添加通知时的错误
                print("无法添加通知: \(error.localizedDescription)")
            }
        }
    }
    func sendNotification2() {
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "尝试播放音频了"
        content.body = "保活呢"
        content.sound = UNNotificationSound.default

        // 设置通知触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 将请求添加到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("无法添加通知: \(error.localizedDescription)")
            }
        }
    }
    
    func startBackgroundTask() {
        print("后台保活了")
        self.bgTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // 如果我们到达这里，表示后台任务即将过期
            self?.endBackgroundTask()
            self?.applyForMoreTime()
        }
        
        // 启动或重新启动定时器
        applyTimer?.invalidate()
        applyTimer = Timer.scheduledTimer(timeInterval: 10, target: self,
                                          selector: #selector(applyForMoreTime), userInfo: nil, repeats: true)
        taskTimer?.invalidate()
        taskTimer = Timer.scheduledTimer(timeInterval: 28, target: self,
                                         selector: #selector(doSomething), userInfo: nil, repeats: true)
    }
    
    func stopBackgroundTask() {
        // 停止所有定时器
        applyTimer?.invalidate()
        applyTimer = nil
        taskTimer?.invalidate()
        taskTimer = nil
        
        // 结束后台任务
        endBackgroundTask()
        print("后台停止保活")
    }
    
    @objc func applyForMoreTime() {
        if UIApplication.shared.backgroundTimeRemaining < 30 {
            endBackgroundTask() // 结束当前的后台任务
            
            self.bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
                // 如果我们到达这里，表示后台任务即将过期
                self?.endBackgroundTask()
            })
            
            // 试图播放静音音频文件以保持后台活动
            print("试图保活")
//            self.sendNotification2()
            playSilentAudio()
        }
    }
    
    @objc func doSomething() {
        // 在这里执行你希望定时做的事情
        print("Doing something: \(UIApplication.shared.backgroundTimeRemaining) seconds remaining")
        // 调用 NetworkService 的 getCurrentOrderStatus 方法
        NetworkService.shared.getCurrentOrderStatus {
            // 网络请求完成后的操作
            print("在后台请求订单状态了")
        }
//        sendNotification()
        
    }
    
    private func endBackgroundTask() {
        if bgTask != .invalid {
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = .invalid
        }
    }
    
    private func playSilentAudio() {
        guard let path = Bundle.main.path(forResource: "TripTips", ofType: "wav") else { return }
        let filePathUrl = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: filePathUrl)
            audioPlayer.numberOfLoops = -1 // 循环播放
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("播放音频了")
        } catch {
            print("Audio Session or Audio Player error: \(error)")
        }
    }
    
}




