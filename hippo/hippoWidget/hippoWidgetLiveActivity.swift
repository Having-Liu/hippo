//
//  hippoWidgetLiveActivity.swift
//  hippoWidget
//
//  Created by 自在 on 2024/3/2.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct hippoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 动态数据
        var progress: Double
        var distance: String
        var title: String
        var destination: String
        var iconName: String
        var time: String
    }

    // 静态数据
    var name: String
}

//struct hippoWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var progress = 0.05
//        var distance: String
//        var title: String
//        var destination:String
//        var iconName:String
//        var time:String
//    }
//    
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}


struct hippoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: hippoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            // MARK: - 实时活动样式
            ZStack{
                //背景
                Image("background")
                    .resizable() // 使图片可以缩放
                    .aspectRatio(contentMode: .fill) // 保持图片的宽高比
                    .frame(height: 136) // 设置图片的框架大小为宽100点，高100点
                
                //内容展示区
                VStack (alignment: .leading) {
                    //预计时间
                    Text("\(context.state.title)")
                        .font(.title2)
                        .bold()
                    //剩余路程,加个判断：
                    //                    if context.state.title != "宝宝已到达"{
                    HStack (alignment: .lastTextBaseline,spacing: 0){
                        Text("距离\(context.state.destination)")
                            .font(.caption)
                        Text(context.state.distance)
                            .font(.title3)
                            .monospaced()
                        Text("公里")
                            .font(.caption)
                    }.padding(.bottom, 12)
                    //                    }
                    //进度条
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.secondary)
                            .opacity(0.2) // 将这个视图的透明度设置为50%
                            .frame(height: 6) // 进度条背景的高度
                        
                        GeometryReader { geometry in
                            // 根据进度计算蓝色进度条的宽度
                            let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
                            let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
                            let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 15)
                                //                                          .fill(Color.blue)
                                    .fill(Color.pink)
                                    .frame(width: progressBarWidth, height: 6)
                                    .opacity(0.5)
                                
                                // 小汽车图标的位置也根据进度动态调整
                                // 确保小汽车图标不会超出父视图的范围
                                let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
                                Image("car")
                                    .resizable()
                                    .frame(width: 39, height: 18)
                                    .offset(x: carOffset) // 假设小汽车图标宽度为39
                            }
                        }
                        //终点图标
                        HStack {
                            Spacer()
                            Image(systemName: "\(context.state.iconName)")
                                .foregroundColor(.pink)
                                .background(.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, -2)
                    }
                    .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                }
                .padding(15)
            }
            
            // MARK: - 灵动岛样式
            
        } dynamicIsland: { context in
            DynamicIsland {
                
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    //                    VStack{
                    //                        Text(context.state.distance)
                    //                            .multilineTextAlignment(.center)
                    //                            .frame(width: 40)
                    //                            .font(.caption2)
                    //                        Text("公里")
                    //                            .multilineTextAlignment(.center)
                    //                            .frame(width: 40)
                    //                            .font(.system(size: 8))
                    //                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    //                    VStack{
                    //                        Text(context.state.time)
                    //                            .multilineTextAlignment(.center)
                    //                            .frame(width: 40)
                    //                            .font(.caption2)
                    //                        if context.state.destination == "上车点" {
                    //                              Text("分钟上车")
                    //                                  .multilineTextAlignment(.center)
                    //                                  .frame(width: 40)
                    //                                  .font(.system(size: 8))
                    //                          } else if context.state.destination == "目的地" {
                    //                              Text("分钟到达")
                    //                                  .multilineTextAlignment(.center)
                    //                                  .frame(width: 40)
                    //                                  .font(.system(size: 8))
                    //                          }
                    //                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    //                    VStack{
                    //                        Spacer().frame(height: 10)
                    //                        Text("center progress：\(context.state.distance)")
                    //                        Spacer().frame(height: 10)
                    //                    }
                    
                    
                    //内容展示区
                    VStack (alignment: .leading) {
                        //预计时间
                        Text("\(context.state.title)")
                            .font(.title2)
                            .bold()
                        //剩余路程
                        HStack (alignment: .lastTextBaseline,spacing: 0){
                            Text("距离\(context.state.destination)")
                                .font(.caption)
                            Text(context.state.distance)
                                .font(.title3)
                                .monospaced()
                            Text("公里")
                                .font(.caption)
                        }.padding(.bottom, 12)
                        //进度条
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.secondary)
                                .opacity(0.2) // 将这个视图的透明度设置为50%
                                .frame(height: 6) // 进度条背景的高度
                            
                            GeometryReader { geometry in
                                // 根据进度计算蓝色进度条的宽度
                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
                                let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 15)
                                    //                                          .fill(Color.blue)
                                        .fill(Color.pink)
                                        .frame(width: progressBarWidth, height: 6)
                                        .opacity(0.5)
                                    
                                    // 小汽车图标的位置也根据进度动态调整
                                    // 确保小汽车图标不会超出父视图的范围
                                    let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
                                    Image("car")
                                        .resizable()
                                        .frame(width: 39, height: 18)
                                        .offset(x: carOffset) // 假设小汽车图标宽度为39
                                }
                            }
                            //终点图标
                            HStack {
                                Spacer()
                                Image(systemName: "\(context.state.iconName)")
                                    .foregroundColor(.pink)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, -2)
                        }
                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                    }
                    .padding(15)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    //                    Text("😭Bottom n😭")
                    //                    // more content
                }
            } compactLeading: {
                VStack{
                    Text(context.state.distance)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .font(.caption2)
                    Text("公里")
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .font(.system(size: 8))
                }
            } compactTrailing: {
                VStack{
                    Text(context.state.time)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .font(.caption2)
                    if context.state.destination == "上车点" {
                        Text("分钟上车")
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.system(size: 8))
                    } else if context.state.destination == "目的地" {
                        Text("分钟到达")
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.system(size: 8))
                    }
                }
                
            } minimal: {
                //                VStack{
                //                    Text(context.state.time)
                //                        .multilineTextAlignment(.center)
                //                        .frame(width: 40)
                //                        .font(.caption2)
                //                    Text("分钟上车")
                //                        .multilineTextAlignment(.center)
                //                        .frame(width: 40)
                //
                //                }
                VStack{
                    Text(context.state.time)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .font(.caption2)
                    if context.state.destination == "上车点" {
                        Text("分钟上车")
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.system(size: 8))
                    } else if context.state.destination == "目的地" {
                        Text("分钟到达")
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.system(size: 8))
                    }
                }
            }
            //                            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.pink)
        }
    }
}





//struct hippoWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct hippoWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: hippoWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension hippoWidgetAttributes {
//    fileprivate static var preview: hippoWidgetAttributes {
//        hippoWidgetAttributes(name: "World")
//    }
//}
//
//extension hippoWidgetAttributes.ContentState {
//    fileprivate static var smiley: hippoWidgetAttributes.ContentState {
//        hippoWidgetAttributes.ContentState(emoji: "😀")
//     }
//
//     fileprivate static var starEyes: hippoWidgetAttributes.ContentState {
//         hippoWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: hippoWidgetAttributes.preview) {
//   hippoWidgetLiveActivity()
//} contentStates: {
//    hippoWidgetAttributes.ContentState.smiley
//    hippoWidgetAttributes.ContentState.starEyes
//}
