//
//  hippoWidgetLiveActivity.swift
//  hippoWidget
//
//  Created by 自在 on 2024/3/2.
//

import ActivityKit
import WidgetKit
import SwiftUI

// 把后端传来的公里字符串（可能带任意小数位）规范化为「值 + 单位」。
// - 距离 >= 1 km：保留一位小数，单位 "公里"
// - 距离 <  1 km：换算成米取整，单位 "米"
// - 解析失败：回退到 ("0.0", "公里")，避免空白
fileprivate func formatDistance(_ s: String) -> (value: String, unit: String) {
    guard let km = Double(s) else { return ("0.0", "公里") }
    if km < 1 {
        return (String(Int(round(km * 1000))), "米")
    }
    return (String(format: "%.1f", km), "公里")
}

struct hippoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 动态数据
        var progress: Double
        var distance: String
        var time: String
        var orderStatus:String
        var nickname:String
    }
    // 静态数据，不知道干啥的，一删除就报错
    var name: String
    // 行程分享链接 —— 跟着 activity 走一辈子；app 启动时用它恢复 TripView
    var tripUrl: String = ""
    // 创建时间戳（秒）—— 多个活跃 activity 时取最新那个
    var createdAt: Double = 0
    //    var relativeName = UserDefaults.standard.string(forKey: "babyName") ?? "亲友姓名缺失"

}


struct hippoWidgetLiveActivity: Widget {
    //    var relativeName = UserDefaults.standard.string(forKey: "babyName") ?? "姓名缺失"
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: hippoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            
            if context.state.orderStatus == "查询中"{  //等待后台返回时
                ZStack(alignment: .topLeading) {
                    //背景
                    HStack{
                        Spacer()
                        Image("ditripbackground")//线上版
                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                            .alignmentGuide(.top) { d in d[.top] }
                            .alignmentGuide(.trailing) { d in d[.trailing] }
                    }
                    VStack (alignment: .leading) {
                        Text("行程查询中")
                            .font(.title2)
                            .bold()
                        
                        HStack (alignment: .lastTextBaseline,spacing: 0){
                            Text("请稍等")
                                .font(.caption)
                            Text(" ")
                                .font(.title3)
                                .monospaced()
                        }.padding(.bottom, 12)
                    }
                    .padding(15)
                }
            } else if context.state.orderStatus == "2"{
                ZStack(alignment: .topLeading) {
                    //背景
                    HStack{
                        Spacer()
                        Image("ditripdone")//线上版
                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                            .alignmentGuide(.top) { d in d[.top] }
                            .alignmentGuide(.trailing) { d in d[.trailing] }
                    }
                    VStack (alignment: .leading) {
                        Text("\(context.state.nickname)已到达")
                            .font(.title2)
                            .bold()
                        
                        HStack (alignment: .lastTextBaseline,spacing: 0){
                            Text("稍后将自动关闭实时活动")
                                .font(.caption)
                            Text(" ")
                                .font(.title3)
                                .monospaced()
                        }.padding(.bottom, 12)
                    }
                    .padding(15)
                }
            }else if context.state.orderStatus == "1"{
                ZStack(alignment: .top) {
                    //背景
                    HStack{
                        Spacer()
                        Image("ditripbackground")//线上版
                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                            .alignmentGuide(.top) { d in d[.top] }
                            .alignmentGuide(.trailing) { d in d[.trailing] }
                    }
                    VStack (alignment: .leading) {
                        //预计时间
                        Text("\(context.state.nickname)预计\(context.state.time)分钟到达")
                            .font(.title2)
                            .bold()
                        HStack (alignment: .lastTextBaseline,spacing: 0){
                            let dist = formatDistance(context.state.distance)
                            Text("距离目的地")
                                .font(.caption)
                            Text(dist.value)
                                .font(.title3)
                                .monospaced()
                            Text(dist.unit)
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
                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                        .frame(width: progressBarWidth, height: 6)
                                    //                                    .opacity(0.5)//个人版才需要

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
                                Image(systemName: "house.circle.fill")
                                //                                .foregroundColor(.pink)//个人版
                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, -2)
                        }
                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                        .padding(.top, 8) // 这里设置了20点的上边距
                        .padding(.bottom, 8) // 这里设置了20点的上边距
                    }
                    .padding(15)
                }
            }
            else {
                
                ZStack(alignment: .top) {
                                    //背景
                                    HStack{
                                        Spacer()
                                        Image("ditripbackground")//线上版
                                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                                            .alignmentGuide(.top) { d in d[.top] }
                                            .alignmentGuide(.trailing) { d in d[.trailing] }
                                    }
                    VStack (alignment: .leading) {
                        if context.state.time == "9999" {
                            //预计时间
                            Text("司机已经到达上车点")
                                .font(.title2)
                                .bold()
                            HStack (alignment: .lastTextBaseline,spacing: 0){
                                Text("等待\(context.state.nickname)上车")
                                    .font(.caption)
                                Text(" ")
                                    .font(.title3)
                                    .monospaced()
                            }
                            .padding(.bottom, 12)
                        } else {
                            //预计时间
                            Text("\(context.state.nickname)预计\(context.state.time)分钟上车")
                                .font(.title2)
                                .bold()
                            HStack (alignment: .lastTextBaseline,spacing: 0){
                                let dist = formatDistance(context.state.distance)
                                Text("距离上车点")
                                    .font(.caption)
                                Text(dist.value)
                                    .font(.title3)
                                    .monospaced()
                                Text(dist.unit)
                                    .font(.caption)
                            }.padding(.bottom, 12)

                        }

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
                                    //                                    .fill(Color.pink)//个人版
                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                        .frame(width: progressBarWidth, height: 6)
                                    //                                    .opacity(0.5)//个人版才需要

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
                                Image(systemName: "figure.wave.circle.fill")
                                //                                .foregroundColor(.pink)//个人版
                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, -2)
                        }
                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                        .padding(.top, 8) // 这里设置了20点的上边距
                        .padding(.bottom, 8) // 这里设置了20点的上边距
                    }
                                    .padding(15)
                        }
                 
            }
            
            // MARK: - 灵动岛样式
            
        } dynamicIsland: { context in
            DynamicIsland {
                
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                }
                DynamicIslandExpandedRegion(.trailing) {
                }
                
                DynamicIslandExpandedRegion(.center) {
                    
                    if context.state.orderStatus == "查询中"{  //等待后台返回时
                        ZStack(alignment: .topLeading) {
                            //背景
                            HStack{
                                Spacer()
                                Image("ditripbackground")//线上版
                                    .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                                    .alignmentGuide(.top) { d in d[.top] }
                                    .alignmentGuide(.trailing) { d in d[.trailing] }
                            }
                            VStack (alignment: .leading) {
                                Text("行程查询中")
                                    .font(.title2)
                                    .bold()
                                
                                HStack (alignment: .lastTextBaseline,spacing: 0){
                                    Text("请稍等")
                                        .font(.caption)
                                    Text(" ")
                                        .font(.title3)
                                        .monospaced()
                                }.padding(.bottom, 12)
                            }
                            .padding(15)
                        }
                    } else if context.state.orderStatus == "2"{
                        ZStack(alignment: .topLeading) {
                            //背景
                            HStack{
                                Spacer()
                                Image("ditripdone")//线上版
                                    .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                                    .alignmentGuide(.top) { d in d[.top] }
                                    .alignmentGuide(.trailing) { d in d[.trailing] }
                            }
                            VStack (alignment: .leading) {
                                Text("\(context.state.nickname)已到达")
                                    .font(.title2)
                                    .bold()
                                
                                HStack (alignment: .lastTextBaseline,spacing: 0){
                                    Text("稍后将自动关闭实时活动")
                                        .font(.caption)
                                    Text(" ")
                                        .font(.title3)
                                        .monospaced()
                                }.padding(.bottom, 12)
                            }
                            .padding(15)
                        }
                    }else if context.state.orderStatus == "1"{
                        ZStack(alignment: .top) {
                            //背景
                            HStack{
                                Spacer()
                                Image("ditripbackground")//线上版
                                    .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                                    .alignmentGuide(.top) { d in d[.top] }
                                    .alignmentGuide(.trailing) { d in d[.trailing] }
                            }
                            VStack (alignment: .leading) {
                                //预计时间
                                Text("\(context.state.nickname)预计\(context.state.time)分钟到达")
                                    .font(.title2)
                                    .bold()
                                HStack (alignment: .lastTextBaseline,spacing: 0){
                                    let dist = formatDistance(context.state.distance)
                                    Text("距离目的地")
                                        .font(.caption)
                                    Text(dist.value)
                                        .font(.title3)
                                        .monospaced()
                                    Text(dist.unit)
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
                                                .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                                .frame(width: progressBarWidth, height: 6)
                                            //                                    .opacity(0.5)//个人版才需要
                                            
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
                                        Image(systemName: "house.circle.fill")
                                        //                                .foregroundColor(.pink)//个人版
                                            .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                            .background(.white)
                                            .clipShape(Circle())
                                    }
                                    .padding(.trailing, -2)
                                }
                                .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                                .padding(.top, 8) // 这里设置了20点的上边距
                                .padding(.bottom, 8) // 这里设置了20点的上边距
                            }
                            .padding(15)
                        }
                    }
                    else {
                        
                        ZStack(alignment: .top) {
                                            //背景
                                            HStack{
                                                Spacer()
                                                Image("ditripbackground")//线上版
                                                    .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
                                                    .alignmentGuide(.top) { d in d[.top] }
                                                    .alignmentGuide(.trailing) { d in d[.trailing] }
                                            }
                            VStack (alignment: .leading) {
                                if context.state.time == "9999" {
                                    //预计时间
                                    Text("司机已经到达上车点")
                                        .font(.title2)
                                        .bold()
                                    HStack (alignment: .lastTextBaseline,spacing: 0){
                                        Text("等待\(context.state.nickname)上车")
                                            .font(.caption)
                                        Text(" ")
                                            .font(.title3)
                                            .monospaced()
                                    }
                                    .padding(.bottom, 12)
                                } else {
                                    //预计时间
                                    Text("\(context.state.nickname)预计\(context.state.time)分钟上车")
                                        .font(.title2)
                                        .bold()
                                    HStack (alignment: .lastTextBaseline,spacing: 0){
                                        let dist = formatDistance(context.state.distance)
                                        Text("距离上车点")
                                            .font(.caption)
                                        Text(dist.value)
                                            .font(.title3)
                                            .monospaced()
                                        Text(dist.unit)
                                            .font(.caption)
                                    }.padding(.bottom, 12)
                                    
                                }
                                
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
                                            //                                    .fill(Color.pink)//个人版
                                                .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                                .frame(width: progressBarWidth, height: 6)
                                            //                                    .opacity(0.5)//个人版才需要
                                            
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
                                        Image(systemName: "figure.wave.circle.fill")
                                        //                                .foregroundColor(.pink)//个人版
                                            .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                            .background(.white)
                                            .clipShape(Circle())
                                    }
                                    .padding(.trailing, -2)
                                }
                                .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
                                .padding(.top, 8) // 这里设置了20点的上边距
                                .padding(.bottom, 8) // 这里设置了20点的上边距
                            }
                                            .padding(15)
                                }
                        
                    }
                   
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    //                    Text("😭Bottom n😭")
                    //                    // more content
                }
            } compactLeading: {
                if context.state.orderStatus != "查询中"{
                    let dist = formatDistance(context.state.distance)
                    VStack{
                        Text(dist.value)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.caption2)
                        Text(dist.unit)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.system(size: 8))
                    }
                } else {
                    // car.rear.fill图标
                    Image(systemName: "car.rear.fill")
                    //                        .font(.system(size: 12)) // 调整图标大小
                        .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2)) // 线上版
                    
                    
                }
                
            } compactTrailing: {
                if context.state.orderStatus != "查询中"{
                    VStack{
                        Text(context.state.time)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .font(.caption2)
                        if context.state.orderStatus == "0" {
                            Text("分钟上车")
                                .multilineTextAlignment(.center)
                                .frame(width: 40)
                                .font(.system(size: 8))
                        } else if context.state.orderStatus == "1" {
                            Text("分钟到达")
                                .multilineTextAlignment(.center)
                                .frame(width: 40)
                                .font(.system(size: 8))
                        }
                    }
                    
                } else {
                    VStack{
                        Text("行程")
                            .font(.system(size: 9))
                        Text("查询中")
                            .font(.system(size: 9))
                    }
                }
                
            } minimal: {
                // 显示剩余分钟数；time == "9999" 是后端"司机已到达上车点"的哨兵值，
                // 此时没有"剩余多少分钟"概念，回退为"到达"。
                let label = (context.state.time == "9999") ? "到达" : "\(context.state.time)分"
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            
            //                            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.pink)
        }
    }
}

