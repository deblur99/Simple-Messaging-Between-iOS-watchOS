//
//  BLESampleAppApp.swift
//  BLESampleApp Watch App
//
//  Created by 한현민 on 11/18/23.
//

import SwiftUI

@main
struct BLESampleApp_Watch_AppApp: App {
    @StateObject var messageStore: MessageStore = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageStore)
        }
    }
}
