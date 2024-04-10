//
//  ContentView.swift
//  hippowatch Watch App
//
//  Created by 自在 on 2024/4/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//        ZStack{
//            //背景
//            Image("background")
////                    .resizable() // 使图片可以缩放
////                    .aspectRatio(contentMode: .fill) // 保持图片的宽高比
////                    .frame(height: 136) // 设置图片的框架大小为宽100点，高100点
//                .resizable() // 使图片可以缩放
//                .aspectRatio(contentMode: .fill) // 保持图片的宽高比
//                .alignmentGuide(.top) { d in d[.top] }
//                .alignmentGuide(.trailing) { d in d[.trailing] }
//            // 如果需要在容器小的时候优先显示右上角的内容，可以使用 clipped() 方法
//                .clipped()
//            
//            //内容展示区
//            VStack (alignment: .leading) {
//                //预计时间
//                Text("\(context.state.title)")
//                    .font(.title2)
//                    .bold()
//                //剩余路程,加个判断：
//                if context.state.title != "行程查询中"{
//                    HStack (alignment: .lastTextBaseline,spacing: 0){
//                        Text("距离\(context.state.destination)")
//                            .font(.caption)
//                        Text(context.state.distance)
//                            .font(.title3)
//                            .monospaced()
//                        Text("公里")
//                            .font(.caption)
//                    }.padding(.bottom, 12)
//                } else {
//                    HStack (alignment: .lastTextBaseline,spacing: 0){
//                        Text("稍等哦")
//                            .font(.caption)
//                        Text(" ")
//                            .font(.title3)
//                            .monospaced()
//                        
//                    }.padding(.bottom, 12)
//                    
//                    
//                }
//                //进度条
//                ZStack(alignment: .leading) {
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color.secondary)
//                        .opacity(0.2) // 将这个视图的透明度设置为50%
//                        .frame(height: 6) // 进度条背景的高度
//                    
//                    GeometryReader { geometry in
//                        // 根据进度计算蓝色进度条的宽度
//                        let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
//                        let progressBarWidth = max(geometry.size.width * CGFloat(context.state.progress), 25) // 进度条宽度至少为25
//                        let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
//                        
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 15)
//                            //                                          .fill(Color.blue)
//                                .fill(Color.pink)
//                                .frame(width: progressBarWidth, height: 6)
//                                .opacity(0.5)
//                            
//                            // 小汽车图标的位置也根据进度动态调整
//                            // 确保小汽车图标不会超出父视图的范围
//                            let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
//                            Image("car")
//                                .resizable()
//                                .frame(width: 39, height: 18)
//                                .offset(x: carOffset) // 假设小汽车图标宽度为39
//                        }
//                    }
//                    //终点图标
//                    HStack {
//                        Spacer()
//                        Image(systemName: "\(context.state.iconName)")
//                            .foregroundColor(.pink)
//                            .background(.white)
//                            .clipShape(Circle())
//                    }
//                    .padding(.trailing, -2)
//                }
//                .frame(height: 12) // 设定 GeometryReader 的高度，确保它不会占据整个屏幕
//            }
//            .padding(15)
//        }
        ZStack{
            //背景
            Image("background")
//                    .resizable() // 使图片可以缩放
//                    .aspectRatio(contentMode: .fill) // 保持图片的宽高比
//                    .frame(height: 136) // 设置图片的框架大小为宽100点，高100点
                .resizable() // 使图片可以缩放
                .aspectRatio(contentMode: .fill) // 保持图片的宽高比
                .alignmentGuide(.top) { d in d[.top] }
                .alignmentGuide(.trailing) { d in d[.trailing] }
            // 如果需要在容器小的时候优先显示右上角的内容，可以使用 clipped() 方法
                .clipped()
            
            //内容展示区
            VStack (alignment: .leading) {
                //预计时间
                Text("还有 1 公里")
                    .font(.title2)
                    .bold()
                //剩余路程,加个判断：
                
                    HStack (alignment: .lastTextBaseline,spacing: 0){
                        Text("距离目的地")
                            .font(.caption)
                        Text("1")
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
                    
//                    GeometryReader { geometry in
//                        // 根据进度计算蓝色进度条的宽度
//                        let maxProgressBarWidth = geometry.size.width - 48 // 最大宽度为父视图宽度减去15
//                        let progressBarWidth = max(geometry.size.width * 25 ) // 进度条宽度至少为25
//                        let adjustedProgressBarWidth = min(progressBarWidth, maxProgressBarWidth) // 保证进度条宽度不超过最大宽度
//                        
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 15)
//                            //                                          .fill(Color.blue)
//                                .fill(Color.pink)
//                                .frame(width: progressBarWidth, height: 6)
//                                .opacity(0.5)
//                            
//                            // 小汽车图标的位置也根据进度动态调整
//                            // 确保小汽车图标不会超出父视图的范围
//                            let carOffset = min(adjustedProgressBarWidth - 10, geometry.size.width - 20)
//                            Image("car")
//                                .resizable()
//                                .frame(width: 39, height: 18)
//                                .offset(x: carOffset) // 假设小汽车图标宽度为39
//                        }
//                    }
                    //终点图标
                    HStack {
                        Spacer()
                        Image(systemName: "house.circle.fill")
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
    }
}

#Preview {
    ContentView()
}
