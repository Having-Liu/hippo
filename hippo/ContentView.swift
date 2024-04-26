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
import CoreMotion


// MARK: 全局变量
public class GlobalData: ObservableObject {
    public static let shared = GlobalData()
    
    @Published var progress = 0.02//灵动岛进度条
    @Published var distance: String?//给灵动岛的距离
    @Published var title: String?//根据不同状态传不同的title：未上车：预计几分钟上车 / 在路上：预计几分钟到达 / 已到达：已到达目的地
    @Published var destination:String?//根据不同状态传不同的名字：未上车：上车点 / 在路上：目的地 / 已到达：目的地 。 拼起来的时候就是：距离目的地几公里
    @Published var iconName:String?//根据不同状态传不同的 icon 名字，未上车：figure.wave.circle.fill / 在路上：house.circle.fill / 已到达：house.circle.fill
    @Published var time:String?//剩余时间
    var sentTokens = Set<String>() // 用于存储已发送的Token
    var currentToken: String? // 存储当前活动的token
    var currentUrl: String? // 存储当前活动的token
    
    // 使用 @Published 使属性变化时能够通知视图更新
        @Published var babyName: String = UserDefaults.standard.string(forKey: "babyName") ?? "亲友"
        
    
}

struct ContentView: View {
    @EnvironmentObject var globalData: GlobalData  // 使用 GlobalData 环境对象
    @State private var showTripview = false
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertMessage =  "还没复制分享链接，先去复制链接吧"
    @State private var ButtomLoading = false  // 新增状态，表示是否正在加载
    @StateObject private var motionManager = MotionManager() // 使用 StateObject 而不是 ObservedObject
    @State private var showSettings = false
    // 从 UserDefaults 中获取 babyName 的值
//    @State private var babyName: String = UserDefaults.standard.string(forKey: "babyName") ?? "亲友"

    
    var body: some View {
        VStack(spacing:0) {
            
            // 使用 GeometryReader 来获取当前视图的尺寸
            GeometryReader { geometry in
                ZStack{
                    Image("bgback")//线上版
                    //            Image("hippo") //个人版
                        .resizable() // 如果需要的话，让图片可缩放
                        .scaledToFill() // 保持图片的宽高比适应内容
                        .edgesIgnoringSafeArea(.all)
                    
                    // 创建一个 ZStack 用于叠加图层
                    ZStack {
                        // 创建四个图层
                        ForEach(1..<4) { index in
                            Image("bg\(index)") // 确保你有 bg0, bg1, bg2, bg3 这四个图片资源
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .offset(x: motionManager.xTilt * CGFloat(index) * 6, // 根据陀螺仪数据调整水平偏移
                                        y: motionManager.yTilt * CGFloat(index) * 6) // 根据陀螺仪数据调整垂直偏移
                        }
                    }
                    Image("bgfront")//线上版
                    //            Image("hippo") //个人版
                        .resizable() // 如果需要的话，让图片可缩放
                        .scaledToFill() // 保持图片的宽高比适应内容
                        .edgesIgnoringSafeArea(.all)
                }
            }
            
            //MARK: 需要切换
            //                Image("ditrip")//线上版
//                //            Image("hippo") //个人版
//                    .resizable() // 如果需要的话，让图片可缩放
//                    .scaledToFill() // 保持图片的宽高比适应内容
//                    .edgesIgnoringSafeArea(.all)
            VStack{
                Text("粘贴分享链接\n即可在灵动岛和实时活动查看\(globalData.babyName)行程")//线上版
//                Text("粘贴分享链接\n即可在灵动岛和实时活动查看宝宝行程")//个人版
                    .font(
                        Font.custom("PingFang SC", size: 16)
                            .weight(.medium)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.bottom,50)
//                Spacer()
                Button(action: {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("消息通知权限已授予")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    self.ButtomLoading = true
                    // 检查粘贴板是否为空
                    guard let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty else {
                        self.alertMessage = "还没复制分享链接，先去复制链接吧"
                        self.ButtomLoading = false
                        self.showAlert = true
                        print("weiking")
                        return
                    }
                    print("粘贴板内容：\(clipboardText)")
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
                            
                            //这里要加逻辑：把链接给后端，创建一个灵动岛，把 token 给后端，后端返回数据了，才进入tripview
//                            startActivity()
                            startActivity { success in
                                if success {
                                    self.showTripview = true
                                }else {
                                    // 如果失败，显示错误信息
                                    self.alertMessage = "遇到了网络问题，请稍后重试。"
                                    self.showAlert = true
                                }
                                self.ButtomLoading = false
                            }
                        }
                        
                    } else {
                        // 如果不包含，显示警告信息
                        self.alertMessage = "复制的内容不太对，请复制分享链接"
                        self.ButtomLoading = false
                        self.showAlert = true
                    }
                    
                }) {
                    
                    HStack {
                        if ButtomLoading {
                            ProgressView()  // 显示加载指示器
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.5)  // 根据需要调整大小
                        }
                        Text(ButtomLoading ? "" : "粘贴并创建实时活动")
//                            .foregroundColor(.primary)//个人版
                            .foregroundColor(.white)//线上版
                    }
                    .foregroundColor(.primary)
                    .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
// 个人版
//                    .background(Color.gray.opacity(0.25))
// 线上版
                    .background(
                    LinearGradient(
                    stops: [
                    Gradient.Stop(color: Color(red: 1, green: 0.46, blue: 0.29), location: 0.00),
                    Gradient.Stop(color: Color(red: 1, green: 0.55, blue: 0.25), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5)
                    )
                    )
                    
                    .clipShape(Capsule()) // 裁剪背景为胶囊形状
                }
                .disabled(ButtomLoading)  // 如果正在加载，则禁用按钮
                .fullScreenCover(isPresented: $showTripview) {
                    TripView(isPresented: $showTripview,urlString: $urlString, ButtomLoading: $ButtomLoading)
                }
                Spacer()
                Button("使用说明&设置") {
                    showSettings = true
                }
                .padding(.bottom, 40)
                .foregroundColor(.secondary)
//                .sheet(isPresented:  $showSettings) {
//                    SettingsView(isPresented: $showSettings)
//                        }
                .popover(isPresented: $showSettings) {
                    SettingsView(isPresented: $showSettings)
                }
            }
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
//个人版
//            .background(
//                LinearGradient(
//                    stops: [
//                        Gradient.Stop(color: Color(red: 0.97, green: 0.76, blue: 0.8), location: 0.00),
//                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.94), location: 1.00),
//                    ],
//                    startPoint: UnitPoint(x: 0.5, y: 0),
//                    endPoint: UnitPoint(x: 0.5, y: 1)
//                )
//            )
//线上版
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.96, blue: 0.92), location: 0.00),
                        Gradient.Stop(color: .white, location: 1.00),
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
    // MARK: 灵动岛相关的所有方法
    //开启灵动岛显示功能
    func startActivity(completion: @escaping (Bool) -> Void){
        Task{
            print("NetworkService开启灵动岛--------------------")
            let attributes = hippoWidgetAttributes(name:"不知道干啥的")
            let initialContentState = hippoWidgetAttributes.ContentState(
                progress: globalData.progress,
                distance: globalData.distance ?? "0",
                time:globalData.time ?? "0", orderStatus: "查询中"
            )
            do {
                // 创建 ActivityContent 实例
                let content = ActivityContent(state: initialContentState, staleDate: Date().addingTimeInterval(10800))
                
                // 使用 ActivityContent 实例调用 request 方法
                let myActivity = try Activity<hippoWidgetAttributes>.request(
                    attributes: attributes,
                    content: content, // 使用 content 而不是 initialContentState
                    pushType: .token
                    //                    pushType: nil
                )
                print("创建了实时活动，id： \(myActivity.id)")
                Task {
                    // 获取实时活动的唯一推送Token
                        for await tokenData in myActivity.pushTokenUpdates {
                            let token = tokenData.map { String(format: "%02x", $0) }.joined()
                            print("获取到实时活动的推送Token: \(token)")
                            
                            // 检查Token是否已经发送过
                            if !GlobalData.shared.sentTokens.contains(token) {
                                // 如果没有发送过，将Token发送给后端服务器
                                NetworkService.shared.notifyServer(token: token, url: urlString, type: 0) { success in
                                    DispatchQueue.main.async {
                                        if success {
                                            // Token发送成功，显示TripView
                                            self.showTripview = true
                                        } else {
                                            // Token发送失败，处理错误
                                            self.alertMessage = "遇到了一些问题，请稍后重试。"
                                            self.showAlert = true
                                        }
                                        self.ButtomLoading = false
                                    }
                                }
                                // 将Token添加到已发送集合中
                                GlobalData.shared.sentTokens.insert(token)
                                GlobalData.shared.currentToken = token
                                completion(true)
                            } else {
                                // 如果Token已经发送过，可以在这里处理（例如什么都不做或打印日志）
                                print("Token已经发送过，不再重复发送")
                                completion(true)
                            }
                        }

                }
            } catch (let error) {
                print("创建实时活动失败，原因： \(error.localizedDescription)")
                completion(false)

            }
        }
    }
}



struct TripView: View {
    @Binding var isPresented: Bool
    @Binding var urlString: String
    @Binding var ButtomLoading: Bool  // 接收 ButtomLoading 的绑定
    
    //先重复定义结束灵动岛方法吧，优雅的方法我还不会
    func endActivity() {
        // 重新定义的 endActivity 方法
        Task {
            for activity in Activity<hippoWidgetAttributes>.activities {
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
                    Text("已登陆灵动岛✨")
                        .font(
                            Font.custom("PingFang SC", size: 18)
                                .weight(.medium)
                        )
                        .foregroundColor(.primary)
//                    Text("可以实时关注宝宝行程啦")//个人版
                    Text("可以实时关注亲友行程啦")//线上版
                        .font(Font.custom("PingFang SC", size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 24)
                Spacer()
                Button(action: {
                    //关闭灵动岛
                    endActivity()
                    //回到首页
                    self.isPresented = false
                    
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
//                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.94), location: 1.00),//个人版
                        Gradient.Stop(color: Color(red: 1, green: 0.96, blue: 0.92), location: 1.00),//线上版
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

class NetworkService {
    static let shared = NetworkService()

    private init() {}
   
    func notifyServer(token: String, url: String?, type: Int, completion: @escaping (Bool) -> Void) {
        // 根据 UserDefaults 中的 UseTestEnvironment 值来选择不同的 URL
        let baseUrl = UserDefaults.standard.bool(forKey: "UseTestEnvironment") ? "https://apre-ka-new.quandashi.com" : "https://ka.quandashi.com"
        // 根据 UserDefaults 中的 UseSandbox 值来选择不同的 sandbox 参数
        let UseSandbox = UserDefaults.standard.bool(forKey: "UseSandbox") ? "1" : "0"
        
        // 构建请求的URL，包括url和token以及sandbox作为查询参数
        guard let encodedUrl = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestUrl = URL(string: "\(baseUrl)/hippo/v1/apple/apns/pushUrl?url=\(encodedUrl)&token=\(token)&sandbox=\(UseSandbox)") else {
            print("构建URL失败")
            completion(false)
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 发起网络请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 请求失败
                print("请求失败: \(error.localizedDescription)")
                completion(false)
            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                // 请求成功
                print("收到响应: \(responseString)")
                completion(true)
            } else {
                // 其他情况
                completion(false)
            }
        }
        task.resume()
    }
}


//class NetworkService {
//    static let shared = NetworkService()
//
//    private init() {}
//   
//    func notifyServer(token: String, url: String?, type: Int, completion: @escaping (Bool) -> Void) {
//        print("构建URL失败")
//        // 根据 UserDefaults 中的 UseTestEnvironment 值来选择不同的 URL
//           let baseUrl = UserDefaults.standard.bool(forKey: "UseTestEnvironment") ? "https://ka.quandashi.com" : "https://apre-ka-new.quandashi.com"
//        let UseSandbox = UserDefaults.standard.bool(forKey: "UseSandbox") ? "0" : "1"
//        // 构建请求的URL，包括url和token作为查询参数
//        guard let encodedUrl = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let requestUrl = URL(string: "\(baseUrl)/hippo/v1/apple/apns/pushUrl?url=\(baseUrl)&token=\(token)&sandbox=\(UseSandbox)") else {
//            print("构建URL失败")
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = "GET"
//        request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // 发起网络请求
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                // 请求失败
//                print("请求失败: \(error.localizedDescription)")
//                completion(false)
//            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                // 请求成功
//                print("收到响应: \(responseString)")
//                completion(true)
//            } else {
//                // 其他情况
//                completion(false)
//            }
//        }
//        task.resume()
//    }
//}

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var xTilt: CGFloat = 0
    @Published var yTilt: CGFloat = 0
    let maxTilt: CGFloat = 0.5 // 最大倾斜角度，可以根据需要调整
    var lastFeedbackX: CGFloat = 0 // 上次震动时的X倾斜角度
    var lastFeedbackY: CGFloat = 0 // 上次震动时的Y倾斜角度
    let feedbackThreshold: CGFloat = 0.2 // 触发震动的倾斜阈值

    init() {
        motionManager.gyroUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            let xTilt = CGFloat(motion.attitude.roll)
            let yTilt = CGFloat(motion.attitude.pitch)
            self?.xTilt = min(max(xTilt, -self!.maxTilt), self!.maxTilt)
            self?.yTilt = min(max(yTilt, -self!.maxTilt), self!.maxTilt)

            // 检查是否达到触发震动的阈值
            if abs(self!.xTilt - self!.lastFeedbackX) > self!.feedbackThreshold ||
               abs(self!.yTilt - self!.lastFeedbackY) > self!.feedbackThreshold {
//                self?.triggerFeedback()
                if UserDefaults.standard.bool(forKey: "HapticFeedback") {
                                   self?.triggerFeedback()
                               }
                self?.lastFeedbackX = self!.xTilt // 更新上次震动时的X倾斜角度
                self?.lastFeedbackY = self!.yTilt // 更新上次震动时的Y倾斜角度
            }
        }
    }

    // 触发震动反馈的方法
    func triggerFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var enableVibration: Bool = UserDefaults.standard.bool(forKey: "HapticFeedback")
    @State private var useTestEnvironment: Bool = UserDefaults.standard.bool(forKey: "UseTestEnvironment")
    @State private var relativeName: String = UserDefaults.standard.string(forKey: "babyName") ?? ""
    @State private var UseSandbox: Bool = UserDefaults.standard.bool(forKey: "UseSandbox")
    @EnvironmentObject var globalData: GlobalData // 确保 GlobalData 作为环境对象传递进来

    var body: some View {
        NavigationView {
            List {
                Section(
//                    header: Text(" "),
                    footer: Text("您对亲友的昵称，将会在实时活动卡片上进行显示。最多支持6个字符。")
                ) {
                    HStack {
                        Text("亲友昵称")
                        Spacer()
                        TextField("输入亲友称呼", text: $relativeName)
                            .multilineTextAlignment(.trailing) // 文本输入框内的文本右对齐
                            .keyboardType(.default) // 默认键盘类型
                            .submitLabel(.done) // 将键盘的回车键设置为“确定”样式
                            .onChange(of: relativeName) { newValue in
                                // 限制文本最多 6 个字符
                                if newValue.count > 6 {
                                    relativeName = String(newValue.prefix(6))
                                }
                            }
                            .onSubmit {
                                // 当用户按下键盘的“确定”键时执行
                                UserDefaults.standard.set(relativeName, forKey: "babyName")
                                globalData.babyName = relativeName
                            }
                    }
                }
                VStack{
                    Text("按住亲友分享的链接")
                    Image("tips1")
                        .resizable() // 如果需要的话，让图片可缩放
                        .scaledToFill() // 保持图片的宽高比适应内容
                    Text("选择 拷贝")
                    Image("tips2")
                        .resizable() // 如果需要的话，让图片可缩放
                        .scaledToFill() // 保持图片的宽高比适应内容
                }
                .background(Color.gray.opacity(0.2))
                .listRowInsets(EdgeInsets()) // 去除内边距
                
                Section(header: Text("使用说明")) {
                    VStack{
                        Text("按住亲友分享的链接")
                        Image("tips1")
                            .resizable() // 如果需要的话，让图片可缩放
                            .scaledToFill() // 保持图片的宽高比适应内容
                        Text("选择 拷贝")
                        Image("tips2")
                            .resizable() // 如果需要的话，让图片可缩放
                            .scaledToFill() // 保持图片的宽高比适应内容
                    }
                    .listRowInsets(EdgeInsets()) // 去除内边距
                    .background(Color.gray.opacity(0.2))
                }
                Section(
                    header: Text("这几个设置基本不用改，除非您认识开发者")
//                    ,footer: Text("这几个设置基本不用改，除非您认识开发者")
                
                ) {
                    Toggle("开启震动反馈", isOn: $enableVibration)
                        .onChange(of: enableVibration) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "HapticFeedback")
                        }
                    
                    Toggle("使用测试环境", isOn: $useTestEnvironment)
                        .onChange(of: useTestEnvironment) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "UseTestEnvironment")
                        }
                    Toggle("使用沙盒环境", isOn: $UseSandbox)
                        .onChange(of: UseSandbox) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "UseSandbox")
                        }
                }

            }
//            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill") // 使用系统提供的关闭图标
                            .symbolRenderingMode(.hierarchical) // 设置为分层渲染模式
                            .foregroundColor(.secondary) // 设置为二级色
                    }
                }
            }
        }
    }
}




//struct SettingsView: View {
//    @Binding var isPresented: Bool
//    @State private var enableVibration: Bool = UserDefaults.standard.bool(forKey: "HapticFeedback")
//    @State private var useTestEnvironment: Bool = UserDefaults.standard.bool(forKey: "UseTestEnvironment")
//    @State private var relativeName: String = UserDefaults.standard.string(forKey: "babyName") ?? ""
//    @EnvironmentObject var globalData: GlobalData // 确保 GlobalData 作为环境对象传递进来
//    
//    var body: some View {
//        NavigationView {
//            List {
//                HStack {
//                    Text("亲友称呼")
//                    Spacer()
//                    TextField("输入亲友称呼", text: $relativeName)
//                        .multilineTextAlignment(.trailing) // 文本输入框内的文本右对齐
//                        .keyboardType(.default) // 默认键盘类型
//                        .submitLabel(.done) // 将键盘的回车键设置为“确定”样式
//                        .onChange(of: relativeName) { newValue in
//                            // 限制文本最多 6 个字符
//                            if newValue.count > 6 {
//                                relativeName = String(newValue.prefix(6))
//                            }
//                        }
//                        .onSubmit {
//                            // 当用户按下键盘的“确定”键时执行
//                            UserDefaults.standard.set(relativeName, forKey: "babyName")
//                            globalData.babyName = relativeName
//                        }
//                }
//                Toggle("开启震动反馈", isOn: $enableVibration)
//                    .onChange(of: enableVibration) { newValue in
//                        UserDefaults.standard.set(newValue, forKey: "HapticFeedback")
//                    }
//                
//                Toggle("使用测试环境", isOn: $useTestEnvironment)
//                    .onChange(of: useTestEnvironment) { newValue in
//                        UserDefaults.standard.set(newValue, forKey: "UseTestEnvironment")
//                    }
//            }
//            .navigationTitle("设置")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("完成") {
//                        isPresented = false
//                    }
//                }
//                
//            }
//        }
//    }
//}





//class MotionManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var xTilt: CGFloat = 0
//    @Published var yTilt: CGFloat = 0
//    let maxTilt: CGFloat = 0.5 // 最大倾斜角度，可以根据需要调整
//
//    // 添加一个用于触发震动的方法
//    func triggerFeedback() {
//        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
//        feedbackGenerator.impactOccurred()
//    }
//
//    init() {
//        motionManager.gyroUpdateInterval = 1.0 / 60.0
//        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
//            guard let motion = motion, error == nil else { return }
//            let xTilt = CGFloat(motion.attitude.roll)
//            let yTilt = CGFloat(motion.attitude.pitch)
//            self?.xTilt = min(max(xTilt, -self!.maxTilt), self!.maxTilt)
//            self?.yTilt = min(max(yTilt, -self!.maxTilt), self!.maxTilt)
//
//            // 当检测到运动时触发震动反馈
//            self?.triggerFeedback()
//        }
//    }
//}


//class MotionManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var xTilt: CGFloat = 0
//    @Published var yTilt: CGFloat = 0
//    let maxTilt: CGFloat = 0.5 // 最大倾斜角度，可以根据需要调整
//
//    init() {
//        motionManager.gyroUpdateInterval = 1.0 / 60.0
//        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
//            guard let motion = motion, error == nil else { return }
//            // 使用设备的倾斜角度而不是旋转速率
//            let xTilt = CGFloat(motion.attitude.roll)
//            let yTilt = CGFloat(motion.attitude.pitch)
//            // 限制倾斜角度
//            self?.xTilt = min(max(xTilt, -self!.maxTilt), self!.maxTilt)
//            self?.yTilt = min(max(yTilt, -self!.maxTilt), self!.maxTilt)
//            
//            
//        }
//    }
//}


//class MotionManager: ObservableObject {
//    private var motionManager = CMMotionManager()
//    @Published var xTilt: CGFloat = 0
//    @Published var yTilt: CGFloat = 0
//
//    init() {
//        motionManager.gyroUpdateInterval = 1.0 / 60.0
//        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
//            guard let motion = motion, error == nil else { return }
//            // 使用设备的倾斜角度而不是旋转速率
//            self?.xTilt = CGFloat(motion.attitude.roll)
//            self?.yTilt = CGFloat(motion.attitude.pitch)
//        }
//    }
//}
