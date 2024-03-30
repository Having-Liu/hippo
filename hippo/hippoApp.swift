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
        }

    }
}




