//
//  Item.swift
//  tona
//
//  Created by Apple Dev on 04/07/25.
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
