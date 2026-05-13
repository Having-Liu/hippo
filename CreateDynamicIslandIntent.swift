//
//  CreateDynamicIslandIntent.swift
//  hippoIntents
//
//  Created by 自在 on 2024/4/2.
//

import Foundation
import AppIntents
import ActivityKit

// LiveActivityIntent (iOS 17.2+) 是唯一允许在后台进程创建 Live Activity 的 intent 协议。
// 普通 AppIntent 在 Shortcut 后台触发时会报 "Target is not foreground"。
@available(iOS 17.2, *)
struct CreateDynamicIslandIntent: LiveActivityIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "CreateDynamicIslandIntent"

    static var title: LocalizedStringResource = "自动从短信创建实时活动"
    static var description = IntentDescription("在快捷指令里，设置为接受到滴滴分享短信，就执行这个快捷操作，就可以在不打开 app 的情况下，自动创建实时活动")

    // 短信原文整段（含"我正在使用特惠快车..."文案 + URL）；intent 自己抽取 z.didi.cn 链接。
    // 之前用 URL? 类型 → Shortcuts 把整段短信传过来时 URL 强转失败 → "无效的 URL"。
    @Parameter(title: "行程分享短信内容")
    var parameter: String?

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

    // 与 ContentView 的剪贴板抽取保持一致：从任意文本里捞 z.didi.cn 短链。
    // [^\s] 而不是 [\w\d] —— 后者会把 ?xpsid_share=... 切掉，导致丢 share token。
    private func extractDidiUrl(from text: String) -> String? {
        let pattern = "https://z\\.didi\\.cn/[^\\s]+"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }

    func perform() async throws -> some IntentResult {
        guard let raw = parameter, !raw.isEmpty else {
            throw NSError(domain: "CreateDynamicIslandIntentError", code: 0, userInfo: [NSLocalizedDescriptionKey: "缺少短信内容参数。"])
        }
        guard let url = extractDidiUrl(from: raw) else {
            throw NSError(domain: "CreateDynamicIslandIntentError", code: 2, userInfo: [NSLocalizedDescriptionKey: "短信里没找到 z.didi.cn 行程链接。"])
        }

//        先不请求服务端实时
        // 创建灵动岛并获取 token —— 把 url 塞进 attributes，下次 app 启动可以恢复 TripView
        let token = await createDynamicIsland(tripUrl: url)

        // 发送链接和 token 给服务器
        let success = await notifyServer(token: token, url: url)
        
        if success {
            // 如果成功，返回成功的结果
//            return .success(result: "实时活动已创建，请稍等。")
            return .result()
        } else {
            // 如果失败，抛出错误
            throw NSError(domain: "CreateDynamicIslandIntentErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "与服务器通信失败。"])
        }
    }
    
    private func createDynamicIsland(tripUrl: String) async -> String {
        // 假设创建成功，并获取到了 token
        var token: String? = nil

        do {
            print("快捷指令NetworkService开启灵动岛--------------------")
            // tripUrl 跟着 attributes 走 —— app 启动时靠它恢复 TripView
            // createdAt 用于多 activity 场景下排序取最新
            let attributes = hippoWidgetAttributes(name: "不知道干啥的", tripUrl: tripUrl, createdAt: Date().timeIntervalSince1970)
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

            // 获取实时活动的唯一推送Token —— 用 TaskGroup 加 15 秒超时，
            // 避免 APNS 慢导致 AppIntent 30 秒上限直接超时挂掉。
            token = await withTaskGroup(of: String?.self) { group in
                group.addTask {
                    for await tokenData in myActivity.pushTokenUpdates {
                        return tokenData.map { String(format: "%02x", $0) }.joined()
                    }
                    return nil
                }
                group.addTask {
                    try? await Task.sleep(nanoseconds: 15_000_000_000)
                    return nil
                }
                let first = await group.next() ?? nil
                group.cancelAll()
                return first
            }
            if let t = token {
                print("获取到实时活动的推送Token: \(t)")
            } else {
                print("等待 push token 超时，跳过 notifyServer")
            }
        } catch {
            print("创建实时活动失败，原因： \(error.localizedDescription)")
        }

        return token ?? "default_token" // 如果没有获取到 token，则返回默认值
    }


    //先注释
    private func notifyServer(token: String, url: String) async -> Bool {
        // 后端已迁到 Cloudflare Worker（api.astrocean.love）
        let nickName = UserDefaults.standard.string(forKey: "babyName") ?? "亲友"
        // Debug build 拿到的是 sandbox APNs token，必须告诉 worker 推到 sandbox APNs。
        // Release（TestFlight/App Store）走 production APNs。
        #if DEBUG
        let sandboxFlag = "1"
        #else
        let sandboxFlag = "0"
        #endif
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestUrl = URL(
                string: "https://api.astrocean.love/hippo/v1/apple/apns/pushUrl?url=\(encodedUrl)&token=\(token)&sandbox=\(sandboxFlag)&nickname=\(nickName)"
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

@available(iOS 17.2, *)
fileprivate extension IntentDialog {
    static var parameterParameterPrompt: Self {
        "别用我"
    }
}

