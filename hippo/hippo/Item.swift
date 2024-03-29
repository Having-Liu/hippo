//
//  Item.swift
//  hippo
//
//  Created by 自在 on 2024/3/2.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
