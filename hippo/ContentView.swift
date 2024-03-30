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


struct ContentView: View {
    @EnvironmentObject var globalData: GlobalData  // 使用 GlobalData 环境对象
    @State private var showTripview = false
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertMessage =  "还没复制分享链接，先去复制链接吧"
    @State private var ButtomLoading = false  // 新增状态，表示是否正在加载
    
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
                        Text(ButtomLoading ? "" : "粘贴分享链接并登岛")
                            .foregroundColor(.primary)
                    }
                    .foregroundColor(.primary)
                    .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
                    .background(Color.gray.opacity(0.25)) // 先设置背景颜色，然后设置透明度
                    .clipShape(Capsule()) // 裁剪背景为胶囊形状
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
                        Text("可以实时关注宝宝行程啦")
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


