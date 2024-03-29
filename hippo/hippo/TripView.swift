////
////  TripView.swift
////  hippo
////
////  Created by 自在 on 2024/3/2.
////
//
//import Foundation
//import SwiftUI
//import WebKit
//import ActivityKit
//
//
//
//
//struct TripView: View {
//    @EnvironmentObject var globalData: GlobalData
//    @Binding var isPresented: Bool
//    @Binding var urlString: String
//    @Binding var ButtomLoading: Bool  // 接收 ButtomLoading 的绑定
//    //    @State private var urlString: String = ""
//    // 将 networkService 声明为结构体的属性
//    var networkService = NetworkService.shared
//    let backgroundTaskManager = AppBackgroundTaskManager.shared
////    @EnvironmentObject var backgroundTaskStatus: BackgroundTaskStatus  // 使用环境对象
//    
//    //先重复定义结束灵动岛方法吧，优雅的方法我还不会
//    func endActivity() {
//        // 重新定义的 endActivity 方法
//        Task {
//            for activity in Activity<hippoWidgetAttributes>.activities {
//                //                await activity.end(dismissalPolicy: .immediate)
//                await activity.end(nil, dismissalPolicy: .immediate)
//                print("已关闭灵动岛显示")
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing:0) {
//            WebView(urlString: urlString)
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // 设置 WebView 尽可能大
//                .edgesIgnoringSafeArea(.all)
//            HStack (alignment: .top) {
//                VStack(alignment: .leading, spacing: 4) {
//                    if globalData.GlobalorderStage == "0" || globalData.GlobalorderStage == "1" {
//                        Text("已登陆灵动岛✨")
//                            .font(
//                                Font.custom("PingFang SC", size: 18)
//                                    .weight(.medium)
//                            )
//                            .foregroundColor(.primary)
//                        Text("可以实时关注宝宝行程啦")
//                            .font(Font.custom("PingFang SC", size: 12))
//                            .foregroundColor(.secondary)
//                    } else if globalData.GlobalorderStage == "2" {
//                        Text("宝宝已到家🎉")
//                            .font(
//                                Font.custom("PingFang SC", size: 18)
//                                    .weight(.medium)
//                            )
//                            .foregroundColor(.primary)
//                        Text("不用担心喽")
//                            .font(Font.custom("PingFang SC", size: 12))
//                            .foregroundColor(.secondary)
//                    } else {
//                        Text("遇到了一些神奇问题🥲")
//                            .font(
//                                Font.custom("PingFang SC", size: 18)
//                                    .weight(.medium)
//                            )
//                            .foregroundColor(.primary)
//                        Text("可能是订单早就结束了，去给刘自在提bug吧")
//                            .font(Font.custom("PingFang SC", size: 12))
//                            .foregroundColor(.secondary)
//                    }
//                    
//                }
//                .padding(.leading, 24)
//                Spacer()
//                Button(action: {
//                    //关闭灵动岛
//                    endActivity()
//                    //停止后台保活
//                    backgroundTaskManager.stopBackgroundTask()
//                    //回到首页
//                    self.isPresented = false
//                    //结束后台保活逻辑
//                    globalData.shouldStartBackgroundTask = false
//                    
//                }) {
//                    Text("结束")
//                        .foregroundColor(.primary) // 设置文本颜色为黑色
//                        .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25)) // 添加内边距
//                        .overlay(
//                            Capsule(style: .continuous) // 创建一个胶囊形状的覆盖层
//                                .stroke(Color.gray, lineWidth: 0.33) // 设置灰色描边
//                        )
//                }
//                
//                .padding(.trailing, 24)
//            }
//            .frame(height: 128)
//            .onAppear {
//                // 当 TripView 出现时，停止显示加载状态
//                self.ButtomLoading = false
//                
//            }
//            .background(
//                LinearGradient(
//                    stops: [
//                        Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.98), location: 0.00),
//                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.94), location: 1.00),
//                    ],
//                    startPoint: UnitPoint(x: 0.5, y: 0),
//                    endPoint: UnitPoint(x: 0.5, y: 1)
//                )
//            )
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//
//
//
//struct WebView: UIViewRepresentable {
//    var urlString: String
//    
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.scrollView.contentInset = .zero
//        webView.scrollView.contentOffset = .zero
//        webView.scrollView.scrollIndicatorInsets = .zero
//        return webView
//    }
//    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            uiView.load(request)
//        }
//    }
//}
//
