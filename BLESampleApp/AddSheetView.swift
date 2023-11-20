//
//  AddSheetView.swift
//  BLESampleApp
//
//  Created by 한현민 on 11/20/23.
//

import SwiftUI

struct AddSheetView: View {
    @EnvironmentObject var messageStore: MessageStore
    
    @Binding var isShowingAddSheet: Bool
    @State var message: String = ""
    
    var body: some View {
        NavigationStack {
            TextField("Enter your message...", text: $message)
                .padding()
                .navigationTitle("Add Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            print(message)
                            messageStore.appendData(message: Message(message: message, timestamp: Date.now))
                            isShowingAddSheet.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", role: .cancel) {
                            isShowingAddSheet.toggle()
                        }
                    }
                }
        }
        .presentationDetents([.height(150)])
    }
}

#Preview {
    AddSheetView(isShowingAddSheet: .constant(true))
        .environmentObject(MessageStore())
}
