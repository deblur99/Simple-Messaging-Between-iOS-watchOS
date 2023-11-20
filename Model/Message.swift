//
//  Message.swift
//  BLESampleApp
//
//  Created by 한현민 on 11/18/23.
//

import Foundation

class DatetimeHandler {
    private static var handler: DatetimeHandler?
    private var formatter = DateFormatter()
    
    private init() {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    static func getInstance() -> DatetimeHandler {
        if handler == nil {
            handler = .init()
        }
        return handler!
    }
    
    func format(from timestamp: Date) -> String {
        return formatter.string(from: timestamp)
    }
}

struct Message: Identifiable, Codable {
    var id = UUID()
    var message: String
    var timestamp: Date
    
    var formattedTimestamp: String {
        return DatetimeHandler.getInstance().format(from: timestamp)
    }
}

extension Message {
    static let dummyData: [Message] = [
        .init(message: "ddddd", timestamp: .now),
        .init(message: "ddddd", timestamp: .now),
        .init(message: "ddddd", timestamp: .now),
        .init(message: "ddddd", timestamp: .now),
    ]
}
