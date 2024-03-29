//
//  hippoApp.swift
//  hippo
//
//  Created by 自在 on 2024/3/2.
//

import SwiftUI
import BackgroundTasks

@main
struct HippoApp: App {
    var globalData = GlobalData()  // 创建 GlobalData 的实例
    @Environment(\.scenePhase) var scenePhase
    let backgroundTaskManager = AppBackgroundTaskManager.shared


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GlobalData.shared) // 传递 GlobalData 为环境对象
//                .environmentObject(backgroundTaskStatus) // 传递 BackgroundTaskStatus 为环境对象
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                print("App is in background")
                if globalData.shouldStartBackgroundTask {
                    backgroundTaskManager.startBackgroundTask()
                }
            case .active:
                print("App is active")
                backgroundTaskManager.stopBackgroundTask()
            case .inactive:
                print("App is inactive")
            default:
                break
            }
        }

    }
}




