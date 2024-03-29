//
//  ContentView.swift
//  hippo
//
//  Created by 自在 on 2024/3/2.
//
import SwiftUI
import Foundation
import ActivityKit
import UIKit
import UserNotifications
import WebKit


// NetworkManager 负责执行网络请求并处理数据
class NetworkManager: NSObject, ObservableObject {
    
    // MARK: 变量都写上描述
    //试了下都没必要Published
    
    //上来通过链接获取这 4 个信息
    var orderId: String? //订单id，获取出来后面要用的
    var productType: String?//刚开始获取的打车类型，获取出来后面要用的
    var uid: String?//刚开始获取的uid
    var sign: String?//刚开始获取的sign
    
    //通过上面的 4 个信息获取 driverid
    var driverId: String? //要专门获取的司机id
    
    //有了 driverid 、订单状态等信息，还要把这几个字段改为 int 类型，传递到 NetworkService用来获取实时信息
    var driverIdInt: Int?//把司机ID改为int，用在请求实时信息
    var bizTypeInt: Int?//把打车类型转为int，用在请求实时信息
    
    
    
    
    // MARK: URLSession 用于执行网络请求
    // 使用 lazy var 延迟初始化，以便在需要时才创建
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
    // MARK: 获取 driverId方法
    func fetchDriverId(completion: @escaping () -> Void) {
        let infoUrl = "https://common.diditaxi.com.cn/webapp/sharetrips/page/getShareInfo"
        guard let orderId = orderId,
              let productType = productType,
              let uid = uid,
              let sign = sign,
              var components = URLComponents(string: infoUrl) else {
            print("缺少必要的参数或 sendRequest 接口链接无效")
            return
        }
        components.queryItems = [
            URLQueryItem(name: "oid", value: orderId),
            URLQueryItem(name: "productType", value: productType),
            URLQueryItem(name: "uid", value: uid),
            URLQueryItem(name: "sign", value: sign)
        ]
        
        guard let finalURL = components.url else {
            print("无效的 URL 组件")
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        // 创建并启动数据任务
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("错误: \(error.localizedDescription)")
                } else if let data = data {
                    do {
                        // 尝试解析 JSON 数据
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let shareInfo = jsonObject["shareInfo"] as? [String: Any],
                           let driverInfoString = shareInfo["driverInfo"] as? String,
                           let driverInfoData = driverInfoString.data(using: .utf8),
                           let driverInfo = try JSONSerialization.jsonObject(with: driverInfoData, options: []) as? [String: Any],
                           let driverId = driverInfo["driverId"] as? String {
                            self?.driverId = driverId
                            self?.driverIdInt = Int(driverId)
                            
                            print("contentview：获取到 Driver ID: \(self?.driverIdInt ?? 404)")
                            completion()
                        } else {
                            print("contentview：JSON 解析失败或未找到 driverId")
                            //MARK: 这里可以优化，现在复制了超久链接会永远 loading
//                            // 如果不包含，显示警告信息.这里报错了
//                            self.alertMessage = "复制的内容不太对，请复制分享链接"
//                            self.ButtomLoading = false
//                            self.showAlert = true
                        }
                    } catch {
                        print("contentview：获取 driverid 的JSON 解析错误: \(error.localizedDescription)")
                    }
                } else {
                    print("未收到数据")
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - 禁止重定向后，获取 uid 等最初的 4 个信息用的
    // extractParameters 方法用于从 URL 字符串中提取查询参数
    func extractParameters(from urlString: String) -> [String: String] {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    // MARK: - sendRequest 方法是整个请求流程的起点，对链接进行访问了
    func sendRequest(urlString: String, completion: @escaping () -> Void) {
        print("执行 contentview 的 sendrequest 了")
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 302,
                   let location = httpResponse.allHeaderFields["Location"] as? String {
                    print("重定向到: \(location)")
                    let extractedParams = self?.extractParameters(from: location) ?? [:]
                    self?.orderId = extractedParams["oid"]
                    self?.productType = extractedParams["productType"]
                    self?.uid = extractedParams["uid"]
                    self?.sign = extractedParams["sign"]
                    self?.bizTypeInt = Int(self!.productType!)
                    
                    self?.fetchDriverId {
                        // fetchDriverId 完成后，调用 getCurrentOrderStatus
                        NetworkService.shared.setOrderInfo(orderId: self?.orderId, productType: self?.productType, uid: self?.uid, sign: self?.sign, driverId: self?.driverId, driverIdInt: self?.driverIdInt)
                        NetworkService.shared.getCurrentOrderStatus {
                            // getCurrentOrderStatus 完成后，调用 startActivity
                            NetworkService.shared.startActivity()
                            completion()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    // MARK: ⚠️这个是整个 class 的结束括号，别不小心删除了
    // 这个是整个 class 的结束括号，别不小心删除了
}


// MARK: 这里是 class 的扩展，class 里的方法要用

// URLSessionTaskDelegate 的扩展用于处理任务的重定向
extension NetworkManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // 这里取消了所有重定向，如果你需要处理重定向，可以修改这里的实现
        completionHandler(nil)
    }
}



//MARK: 页面内容开始了

struct ContentView: View {
    
    @EnvironmentObject var globalData: GlobalData  // 使用 GlobalData 环境对象
    @StateObject var networkManager = NetworkManager() // 使用 StateObject 创建 NetworkManager 实例
    
    @State private var showTripview = false
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertMessage =  "还没复制分享链接，先去复制链接吧"
    @State private var ButtomLoading = false  // 新增状态，表示是否正在加载
//    @EnvironmentObject var backgroundTaskStatus: BackgroundTaskStatus  // 使用环境对象

    
    var body: some View {
        
        VStack(spacing:0) {
            Image("hippo")
                .resizable() // 如果需要的话，让图片可缩放
                .scaledToFit() // 保持图片的宽高比适应内容
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                Text("粘贴分享链接，即可登岛查看宝宝行程")
                    .font(
                        Font.custom("PingFang SC", size: 16)
                            .weight(.medium)
                    )
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("消息通知权限已授予")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    self.ButtomLoading = true
                    if let clipboardText = UIPasteboard.general.string {
                        
                        // 检查 urlString 是否为空
                        guard !clipboardText.isEmpty else {
                            self.alertMessage = "还没复制分享链接，先去复制链接吧"
                            self.ButtomLoading = false
                            self.showAlert = true
                            return
                        }
                        
                        // 检查 urlString 是否包含特定子串
                        if clipboardText.contains("https://z.didi.cn") {
                            // 如果包含，则执行请求
                            // 使用正则表达式查找链接
                            let pattern = "https://z\\.didi\\.cn/[\\w\\d]+"
                            if let range = clipboardText.range(of: pattern, options: .regularExpression) {
                                // 提取链接
                                let urlString = String(clipboardText[range])
                                print("提取的链接: \(urlString)")
                                self.urlString = urlString
                                
                                // 使用提取的链接执行请求
                                networkManager.sendRequest(urlString: urlString) {
                                    // 请求完成后的操作
                                    self.showTripview = true
                                    //这时候才需要后台保活
                                    globalData.shouldStartBackgroundTask = true
                                }
                                
                            }
                            
                        } else {
                            // 如果不包含，显示警告信息
                            self.alertMessage = "复制的内容不太对，请复制分享链接"
                            self.ButtomLoading = false
                            self.showAlert = true
                        }
                    }
                }) {
                    
                    HStack {
                        if ButtomLoading {
                            ProgressView()  // 显示加载指示器
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.5)  // 根据需要调整大小
                        }
                        Text(ButtomLoading ? "" : "粘贴分享链接并登岛")
                            .foregroundColor(.primary)
                    }
                    .foregroundColor(.primary)
                    .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
                    .background(Color.gray.opacity(0.25)) // 先设置背景颜色，然后设置透明度
                    .clipShape(Capsule()) // 裁剪背景为胶囊形状
                    
                    //                .frame(maxWidth: .infinity)
                    //                .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
                    //                .background(Color.gray.opacity(0.25))  // 设置背景颜色
                    //                .clipShape(Capsule())  // 设置形状为胶囊形
                    
                }
                .disabled(ButtomLoading)  // 如果正在加载，则禁用按钮
                .fullScreenCover(isPresented: $showTripview) {
                    TripView(isPresented: $showTripview,urlString: $urlString, ButtomLoading: $ButtomLoading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.97, green: 0.76, blue: 0.8), location: 0.00),
                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.94), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
            .edgesIgnoringSafeArea(.bottom)
            
        }
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea(.all)
        //弹窗
        .alert(isPresented: self.$showAlert) {
            Alert(
                title: Text("提示"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("好的")) {
                    // 用户点击 "好" 按钮后的动作
                    self.showAlert = false
                    self.showAlert = true
                }
            )
        }
        .onAppear(){
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("消息权限已授予")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}



struct TripView: View {
    @EnvironmentObject var globalData: GlobalData
    @Binding var isPresented: Bool
    @Binding var urlString: String
    @Binding var ButtomLoading: Bool  // 接收 ButtomLoading 的绑定
    //    @State private var urlString: String = ""
    // 将 networkService 声明为结构体的属性
    var networkService = NetworkService.shared
    let backgroundTaskManager = AppBackgroundTaskManager.shared
//    @EnvironmentObject var backgroundTaskStatus: BackgroundTaskStatus  // 使用环境对象
    
    //先重复定义结束灵动岛方法吧，优雅的方法我还不会
    func endActivity() {
        // 重新定义的 endActivity 方法
        Task {
            for activity in Activity<hippoWidgetAttributes>.activities {
                //                await activity.end(dismissalPolicy: .immediate)
                await activity.end(nil, dismissalPolicy: .immediate)
                print("已关闭灵动岛显示")
            }
        }
    }
    
    var body: some View {
        VStack(spacing:0) {
            WebView(urlString: urlString)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 设置 WebView 尽可能大
                .edgesIgnoringSafeArea(.all)
            HStack (alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if globalData.GlobalorderStage == "0" || globalData.GlobalorderStage == "1" {
                        Text("已登陆灵动岛✨")
                            .font(
                                Font.custom("PingFang SC", size: 18)
                                    .weight(.medium)
                            )
                            .foregroundColor(.primary)
                        Text("可以实时关注宝宝行程啦")
                            .font(Font.custom("PingFang SC", size: 12))
                            .foregroundColor(.secondary)
                    } else if globalData.GlobalorderStage == "2" {
                        Text("宝宝已到家🎉")
                            .font(
                                Font.custom("PingFang SC", size: 18)
                                    .weight(.medium)
                            )
                            .foregroundColor(.primary)
                        Text("不用担心喽")
                            .font(Font.custom("PingFang SC", size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        Text("遇到了一些神奇问题🥲")
                            .font(
                                Font.custom("PingFang SC", size: 18)
                                    .weight(.medium)
                            )
                            .foregroundColor(.primary)
                        Text("可能是订单早就结束了，去给刘自在提bug吧")
                            .font(Font.custom("PingFang SC", size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                }
                .padding(.leading, 24)
                Spacer()
                Button(action: {
                    //关闭灵动岛
                    endActivity()
                    //停止后台保活
                    backgroundTaskManager.stopBackgroundTask()
                    //回到首页
                    self.isPresented = false
                    //结束后台保活逻辑
                    globalData.shouldStartBackgroundTask = false
                    
                }) {
                    Text("结束")
                        .foregroundColor(.primary) // 设置文本颜色为黑色
                        .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25)) // 添加内边距
                        .overlay(
                            Capsule(style: .continuous) // 创建一个胶囊形状的覆盖层
                                .stroke(Color.gray, lineWidth: 0.33) // 设置灰色描边
                        )
                }
                
                .padding(.trailing, 24)
            }
            .frame(height: 128)
            .onAppear {
                // 当 TripView 出现时，停止显示加载状态
                self.ButtomLoading = false
                
            }
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.98), location: 0.00),
                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.94), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}




struct WebView: UIViewRepresentable {
    var urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.contentInset = .zero
        webView.scrollView.contentOffset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


