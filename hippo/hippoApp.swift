//
//  hippoApp.swift
//  hippo
//
//  Created by 自在 on 2024/3/2.
//


//备忘：准备就在这一个代码上，支持两个版本：宝宝到哪啦和亲友行程分享，上线的就是亲友行程分享，宝宝到哪啦就在内测上使用
//每次需要改的的地方，
//主要是用背景图、颜色、提示语这些，每次把注释掉的代码互换一下
//appicon
//其他的地方一起改





import SwiftUI
import BackgroundTasks

@main
struct HippoApp: App {
    var globalData = GlobalData()  // 创建 GlobalData 的实例
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GlobalData.shared) // 传递 GlobalData 为环境对象
        }

    }
}




