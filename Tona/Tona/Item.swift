//
//  Item.swift
//  Tona
//
//  Created by Apple Dev on 06/09/25.
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
