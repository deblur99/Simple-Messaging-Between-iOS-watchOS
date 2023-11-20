//
//  BLESampleAppApp.swift
//  BLESampleApp
//
//  Created by 한현민 on 11/18/23.
//

import SwiftUI

@main
struct BLESampleAppApp: App {
    @StateObject var messageStore: MessageStore = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageStore)
        }
    }
}
