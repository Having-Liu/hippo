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
        var time: String
        var orderStatus:String
        var nickname:String
    }
    // 静态数据，不知道干啥的，一删除就报错
    var name: String
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
                            Text("距离目的地")
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
                                                Text("距离上车点")
                                                    .font(.caption)
                                                Text(context.state.distance)
                                                    .font(.title3)
                                                    .monospaced()
                                                Text("公里")
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
                                        
                                        //MARK: 进度条升级中
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.secondary)
                                                .opacity(0.2) // 将这个视图的透明度设置为50%
                                                .frame(height: 6) // 进度条背景的高度
                                            
                                            GeometryReader { geometry in
                                                // 根据进度计算蓝色进度条的宽度
                                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
                                                let progressBarWidth = max(geometry.size.width * (1/3 * CGFloat(context.state.progress)), 25)
                                                
                                                //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
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
                                                //                            }
                                                //起点图标
                                                Image(systemName: "figure.wave.circle.fill")
                                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                                    .background(.white)
                                                    .clipShape(Circle())
                                                    .frame(width: geometry.size.width / 3, height: geometry.size.height / 3, alignment: .center) // 设置图片的宽度为ZStack宽度的1/3，高度自适应
                                                    .position(x: geometry.size.width / 3, y: geometry.size.height / 2) // 设置图片的位置
                                                
                                            }
                                            //终点图标
                                            HStack {
                                                Spacer()
                                                Image(systemName: "house.circle.fill")
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
                
                
//                ZStack(alignment: .top) {
//                    //背景
//                    HStack{
//                        Spacer()
//                        Image("ditripbackground")//线上版
//                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
//                            .alignmentGuide(.top) { d in d[.top] }
//                            .alignmentGuide(.trailing) { d in d[.trailing] }
//                    }
//                    VStack (alignment: .leading) {
//                        if context.state.time == 9999 {
//                            //预计时间
//                            Text("司机已经到达上车点")
//                                .font(.title2)
//                                .bold()
//                            HStack (alignment: .lastTextBaseline,spacing: 0){
//                                Text("等待亲友上车")
//                                    .font(.caption)
//                                Text(" ")
//                                    .font(.title3)
//                                    .monospaced()
//                            }.padding(.bottom, 12)
//                            
//                            
//                            
//                        } else {
//                            //预计时间
//                            Text("预计\(context.state.time)分钟上车")
//                                .font(.title2)
//                                .bold()
//                            HStack (alignment: .lastTextBaseline,spacing: 0){
//                                Text("距离上车点")
//                                    .font(.caption)
//                                Text(context.state.distance)
//                                    .font(.title3)
//                                    .monospaced()
//                                Text("公里")
//                                    .font(.caption)
//                            }.padding(.bottom, 12)
//                            
//                        }
//                        
//                        //进度条
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.secondary)
//                                .opacity(0.2) // 将这个视图的透明度设置为50%
//                                .frame(height: 6) // 进度条背景的高度
//                            
//                            GeometryReader { geometry in
//                                // 根据进度计算蓝色进度条的宽度
//                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
//                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
//                                let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
//                                
//                                ZStack(alignment: .leading) {
//                                    RoundedRectangle(cornerRadius: 15)
//                                    //                                          .fill(Color.blue)
//                                    //                                    .fill(Color.pink)//个人版
//                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
//                                        .frame(width: progressBarWidth, height: 6)
//                                    //                                    .opacity(0.5)//个人版才需要
//                                    
//                                    // 小汽车图标的位置也根据进度动态调整
//                                    // 确保小汽车图标不会超出父视图的范围
//                                    let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
//                                    Image("car")
//                                        .resizable()
//                                        .frame(width: 39, height: 18)
//                                        .offset(x: carOffset) // 假设小汽车图标宽度为39
//                                }
//                            }
//                            //终点图标
//                            HStack {
//                                Spacer()
//                                Image(systemName: "figure.wave.circle.fill")
//                                //                                .foregroundColor(.pink)//个人版
//                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
//                                    .background(.white)
//                                    .clipShape(Circle())
//                            }
//                            .padding(.trailing, -2)
//                        }
//                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
//                        .padding(.top, 8) // 这里设置了20点的上边距
//                        .padding(.bottom, 8) // 这里设置了20点的上边距
//                        
//                        //MARK: 进度条升级中
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.secondary)
//                                .opacity(0.2) // 将这个视图的透明度设置为50%
//                                .frame(height: 6) // 进度条背景的高度
//                            
//                            GeometryReader { geometry in
//                                // 根据进度计算蓝色进度条的宽度
//                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
//                                let progressBarWidth = max(geometry.size.width * (1/3 * CGFloat(context.state.progress)), 25)
//                                
//                                //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
//                                let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
//                                
//                                ZStack(alignment: .leading) {
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
//                                        .frame(width: progressBarWidth, height: 6)
//                                    //                                    .opacity(0.5)//个人版才需要
//                                    
//                                    // 小汽车图标的位置也根据进度动态调整
//                                    // 确保小汽车图标不会超出父视图的范围
//                                    let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
//                                    Image("car")
//                                        .resizable()
//                                        .frame(width: 39, height: 18)
//                                        .offset(x: carOffset) // 假设小汽车图标宽度为39
//                                }
//                                //                            }
//                                //起点图标
//                                Image(systemName: "figure.wave.circle.fill")
//                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
//                                    .background(.white)
//                                    .clipShape(Circle())
//                                    .frame(width: geometry.size.width / 3, height: geometry.size.height / 3, alignment: .center) // 设置图片的宽度为ZStack宽度的1/3，高度自适应
//                                    .position(x: geometry.size.width / 3, y: geometry.size.height / 2) // 设置图片的位置
//                                
//                            }
//                            //终点图标
//                            HStack {
//                                Spacer()
//                                Image(systemName: "house.circle.fill")
//                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
//                                    .background(.white)
//                                    .clipShape(Circle())
//                            }
//                            .padding(.trailing, -2)
//                        }
//                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
//                        .padding(.top, 8) // 这里设置了20点的上边距
//                        .padding(.bottom, 8) // 这里设置了20点的上边距
//                        
//                    }
//                    .padding(15)
//                }
                
                
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
                                    Text("距离目的地")
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
                                //MARK: 进度条升级中
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.secondary)
                                        .opacity(0.2) // 将这个视图的透明度设置为50%
                                        .frame(height: 6) // 进度条背景的高度
                                    
                                    GeometryReader { geometry in
                                        // 根据进度计算蓝色进度条的宽度
                                        let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
                                        let progressBarWidth = max(geometry.size.width * (1/3 + 2/3 * CGFloat(context.state.progress)), 25)
                                        
                                        //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
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
                                        //                            }
                                        //起点图标
                                        Image(systemName: "figure.wave.circle.fill")
                                            .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                            .background(.white)
                                            .clipShape(Circle())
                                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 3, alignment: .center) // 设置图片的宽度为ZStack宽度的1/3，高度自适应
                                            .position(x: geometry.size.width / 3, y: geometry.size.height / 2) // 设置图片的位置
                                        
                                    }
                                    //终点图标
                                    HStack {
                                        Spacer()
                                        Image(systemName: "house.circle.fill")
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
                                                        Text("距离上车点")
                                                            .font(.caption)
                                                        Text(context.state.distance)
                                                            .font(.title3)
                                                            .monospaced()
                                                        Text("公里")
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
                                                
                                                //MARK: 进度条升级中
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.secondary)
                                                        .opacity(0.2) // 将这个视图的透明度设置为50%
                                                        .frame(height: 6) // 进度条背景的高度
                                                    
                                                    GeometryReader { geometry in
                                                        // 根据进度计算蓝色进度条的宽度
                                                        let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
                                                        let progressBarWidth = max(geometry.size.width * (1/3 * CGFloat(context.state.progress)), 25)
                                                        
                                                        //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
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
                                                        //                            }
                                                        //起点图标
                                                        Image(systemName: "figure.wave.circle.fill")
                                                            .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
                                                            .background(.white)
                                                            .clipShape(Circle())
                                                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 3, alignment: .center) // 设置图片的宽度为ZStack宽度的1/3，高度自适应
                                                            .position(x: geometry.size.width / 3, y: geometry.size.height / 2) // 设置图片的位置
                                                        
                                                    }
                                                    //终点图标
                                                    HStack {
                                                        Spacer()
                                                        Image(systemName: "house.circle.fill")
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
                        
                        
        //                ZStack(alignment: .top) {
        //                    //背景
        //                    HStack{
        //                        Spacer()
        //                        Image("ditripbackground")//线上版
        //                            .frame(width: 140, height: 100) // 设置图片的框架大小为宽100点，高100点
        //                            .alignmentGuide(.top) { d in d[.top] }
        //                            .alignmentGuide(.trailing) { d in d[.trailing] }
        //                    }
        //                    VStack (alignment: .leading) {
        //                        if context.state.time == 9999 {
        //                            //预计时间
        //                            Text("司机已经到达上车点")
        //                                .font(.title2)
        //                                .bold()
        //                            HStack (alignment: .lastTextBaseline,spacing: 0){
        //                                Text("等待亲友上车")
        //                                    .font(.caption)
        //                                Text(" ")
        //                                    .font(.title3)
        //                                    .monospaced()
        //                            }.padding(.bottom, 12)
        //
        //
        //
        //                        } else {
        //                            //预计时间
        //                            Text("预计\(context.state.time)分钟上车")
        //                                .font(.title2)
        //                                .bold()
        //                            HStack (alignment: .lastTextBaseline,spacing: 0){
        //                                Text("距离上车点")
        //                                    .font(.caption)
        //                                Text(context.state.distance)
        //                                    .font(.title3)
        //                                    .monospaced()
        //                                Text("公里")
        //                                    .font(.caption)
        //                            }.padding(.bottom, 12)
        //
        //                        }
        //
        //                        //进度条
        //                        ZStack(alignment: .leading) {
        //                            RoundedRectangle(cornerRadius: 15)
        //                                .fill(Color.secondary)
        //                                .opacity(0.2) // 将这个视图的透明度设置为50%
        //                                .frame(height: 6) // 进度条背景的高度
        //
        //                            GeometryReader { geometry in
        //                                // 根据进度计算蓝色进度条的宽度
        //                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
        //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
        //                                let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
        //
        //                                ZStack(alignment: .leading) {
        //                                    RoundedRectangle(cornerRadius: 15)
        //                                    //                                          .fill(Color.blue)
        //                                    //                                    .fill(Color.pink)//个人版
        //                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
        //                                        .frame(width: progressBarWidth, height: 6)
        //                                    //                                    .opacity(0.5)//个人版才需要
        //
        //                                    // 小汽车图标的位置也根据进度动态调整
        //                                    // 确保小汽车图标不会超出父视图的范围
        //                                    let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
        //                                    Image("car")
        //                                        .resizable()
        //                                        .frame(width: 39, height: 18)
        //                                        .offset(x: carOffset) // 假设小汽车图标宽度为39
        //                                }
        //                            }
        //                            //终点图标
        //                            HStack {
        //                                Spacer()
        //                                Image(systemName: "figure.wave.circle.fill")
        //                                //                                .foregroundColor(.pink)//个人版
        //                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
        //                                    .background(.white)
        //                                    .clipShape(Circle())
        //                            }
        //                            .padding(.trailing, -2)
        //                        }
        //                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
        //                        .padding(.top, 8) // 这里设置了20点的上边距
        //                        .padding(.bottom, 8) // 这里设置了20点的上边距
        //
        //                        //MARK: 进度条升级中
        //                        ZStack(alignment: .leading) {
        //                            RoundedRectangle(cornerRadius: 15)
        //                                .fill(Color.secondary)
        //                                .opacity(0.2) // 将这个视图的透明度设置为50%
        //                                .frame(height: 6) // 进度条背景的高度
        //
        //                            GeometryReader { geometry in
        //                                // 根据进度计算蓝色进度条的宽度
        //                                let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
        //                                let progressBarWidth = max(geometry.size.width * (1/3 * CGFloat(context.state.progress)), 25)
        //
        //                                //                                let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
        //                                let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
        //
        //                                ZStack(alignment: .leading) {
        //                                    RoundedRectangle(cornerRadius: 15)
        //                                        .fill(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
        //                                        .frame(width: progressBarWidth, height: 6)
        //                                    //                                    .opacity(0.5)//个人版才需要
        //
        //                                    // 小汽车图标的位置也根据进度动态调整
        //                                    // 确保小汽车图标不会超出父视图的范围
        //                                    let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
        //                                    Image("car")
        //                                        .resizable()
        //                                        .frame(width: 39, height: 18)
        //                                        .offset(x: carOffset) // 假设小汽车图标宽度为39
        //                                }
        //                                //                            }
        //                                //起点图标
        //                                Image(systemName: "figure.wave.circle.fill")
        //                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
        //                                    .background(.white)
        //                                    .clipShape(Circle())
        //                                    .frame(width: geometry.size.width / 3, height: geometry.size.height / 3, alignment: .center) // 设置图片的宽度为ZStack宽度的1/3，高度自适应
        //                                    .position(x: geometry.size.width / 3, y: geometry.size.height / 2) // 设置图片的位置
        //
        //                            }
        //                            //终点图标
        //                            HStack {
        //                                Spacer()
        //                                Image(systemName: "house.circle.fill")
        //                                    .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2))//线上版
        //                                    .background(.white)
        //                                    .clipShape(Circle())
        //                            }
        //                            .padding(.trailing, -2)
        //                        }
        //                        .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
        //                        .padding(.top, 8) // 这里设置了20点的上边距
        //                        .padding(.bottom, 8) // 这里设置了20点的上边距
        //
        //                    }
        //                    .padding(15)
        //                }
                        
                        
                    }
                   
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    //                    Text("😭Bottom n😭")
                    //                    // more content
                }
            } compactLeading: {
                if context.state.orderStatus != "查询中"{
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
                } else {
                    // car.rear.fill图标
                    Image(systemName: "car.rear.fill")
                    //                        .font(.system(size: 12)) // 调整图标大小
                    //                        .foregroundColor(.pink) // 个人版
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
                
                ZStack {
                    
                    // 背景色
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90)) // 从顶部开始
                        .foregroundColor(.white) // 进度条颜色
                        .opacity(0.15) // 设置图标的透明度为50%
                    
                    // 圆环进度条
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(context.state.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90)) // 从顶部开始
                    //                        .foregroundColor(.pink) // 个人版
                        .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2)) // 线上版
                    
                    // car.rear.fill图标
                    Image(systemName: "car.rear.fill")
                        .font(.system(size: 8)) // 调整图标大小
                    //                        .foregroundColor(.pink) // 个人版
                        .foregroundColor(Color(red: 0.98, green: 0.39, blue: 0.2)) // 线上版
                }
                .frame(width: 20, height: 20) // 调整整个ZStack的大小
            }
            
            //                            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.pink)
        }
    }
}

