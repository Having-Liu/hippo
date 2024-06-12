//
//  CreateDynamicIslandIntent.swift
//  hippoIntents
//
//  Created by 自在 on 2024/4/2.
//

import Foundation
import AppIntents
import ActivityKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CreateDynamicIslandIntent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "CreateDynamicIslandIntent"

    static var title: LocalizedStringResource = "自动从短信创建实时活动"
    static var description = IntentDescription("在快捷指令里，设置为接受到滴滴分享短信，就执行这个快捷操作，就可以在不打开 app 的情况下，自动创建实时活动")

    @Parameter(title: "行程分享链接")
    var parameter: URL?

    static var parameterSummary: some ParameterSummary {
        Summary("用在行程查看") {
            \.$parameter
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$parameter)) { parameter in
            DisplayRepresentation(
                title: "用在行程查看",
                subtitle: ""
            )
        }
    }
    func perform() async throws -> some IntentResult {
        guard let url = parameter else {
//            throw IntentError(code: .parameterMissing) // 创建一个 NSError 对象来表示错误
            throw NSError(domain: "CreateDynamicIslandIntentError", code: 0, userInfo: [NSLocalizedDescriptionKey: "缺少必要的参数。"])
        }
        
  
//        先不请求服务端实时
        // 创建灵动岛并获取 token
        let token = await createDynamicIsland()
        
        // 发送链接和 token 给服务器
        let success = await notifyServer(token: token, url: url.absoluteString)
        
        if success {
            // 如果成功，返回成功的结果
//            return .success(result: "实时活动已创建，请稍等。")
            return .result()
        } else {
            // 如果失败，抛出错误
            throw NSError(domain: "CreateDynamicIslandIntentErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "与服务器通信失败。"])
        }
    }
    
    private func createDynamicIsland() async -> String {
        // 假设创建成功，并获取到了 token
        var token: String? = nil
        
        do {
            print("快捷指令NetworkService开启灵动岛--------------------")
            let attributes = hippoWidgetAttributes(name: "不知道干啥的")
            let initialContentState = hippoWidgetAttributes.ContentState(
                progress: 0.05,
                distance: "0",
                time: "0", orderStatus: "查询中",nickname:"亲友"
            )
            
            // 创建 ActivityContent 实例
            let content = ActivityContent(state: initialContentState, staleDate: Date().addingTimeInterval(10800))
            
            // 使用 ActivityContent 实例调用 request 方法
            let myActivity = try Activity<hippoWidgetAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: .token
            )
            print("创建了实时活动，id： \(myActivity.id)")
            
            // 获取实时活动的唯一推送Token
            for try await tokenData in myActivity.pushTokenUpdates {
                token = tokenData.map { String(format: "%02x", $0) }.joined()
                print("获取到实时活动的推送Token: \(token ?? "nil")")
                break // 获取到 token 后退出循环
            }
        } catch {
            print("创建实时活动失败，原因： \(error.localizedDescription)")
        }
        
        return token ?? "default_token" // 如果没有获取到 token，则返回默认值
    }


    //先注释
    private func notifyServer(token: String, url: String) async -> Bool {
        // 构建请求的URL，包括url和token作为查询参数
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestUrl = URL(
                string: "https://apre-ka-new.quandashi.com/hippo/v1/apple/apns/pushUrl?url=\(encodedUrl)&token=\(token)&sandbox=false&nickname=亲友)"
//                string: "https://apre-d.quandashi.com/hippo/v1/apple/apns/pushUrl?url=\(encodedUrl)&token=\(token)"
              
              ) else {
            print("构建URL失败")
            return false
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 发起网络请求
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let responseString = String(data: data, encoding: .utf8) {
                // 请求成功
                print("收到响应: \(responseString)")
                return true
            }
        } catch {
            // 请求失败
            print("请求失败: \(error.localizedDescription)")
        }
        return false
    }

//    func perform() async throws -> some IntentResult {
//        // TODO: Place your refactored intent handler code here.
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        return .result()
//    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var parameterParameterPrompt: Self {
        "别用我"
    }
}

