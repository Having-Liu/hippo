//
//  IntentHandler.swift
//  hippoIntents
//
//  Created by 自在 on 2024/4/2.
//
//  注：CreateDynamicIslandIntent 是新 AppIntents 框架，跑在主 app 进程，
//  不需要 SiriKit Extension。这个 IntentHandler 现在是空壳，只为保留
//  extension target 不破坏 Xcode project 结构。如果将来确认整个 target
//  可以删，这个文件和 hippoIntents/ 目录可以一起移除。

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
