//
//  MessageStore.swift
//  BLESampleApp
//
//  Created by 한현민 on 11/18/23.
//

import Foundation

class MessageStore: ObservableObject {
    @Published var messages: [Message] = []
    
    func fetchData() {
        messages = Message.dummyData
    }
    
    func overwriteData(_ messages: [Message]) {
        self.messages = messages
    }
    
    func appendData(message: Message) {
        self.messages.append(message)
    }
    
    func popData() -> Message? {
        guard messages.count <= 0 else {
            return nil
        }
        let ret = messages[messages.count - 1]
        messages.removeLast()
        return ret
    }
}
