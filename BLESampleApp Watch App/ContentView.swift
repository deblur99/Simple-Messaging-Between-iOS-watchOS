//
//  ContentView.swift
//  BLESampleApp Watch App
//
//  Created by 한현민 on 11/18/23.
//

import SwiftUI
import WatchConnectivity

class Monitor: ObservableObject {
    enum Status {
        case INITIAL, WAITING, RECEIVED, FAILURE
        
        var label: String {
            switch self {
            case .INITIAL:
                return "초기화됨"
            case .WAITING:
                return "대기 중"
            case .RECEIVED:
                return "수신 성공"
            case .FAILURE:
                return "수신 실패"
            }
        }
    }
    
    @Published var status: Status = .INITIAL
}

struct ContentView: View {
    // @StateObject를 쓰자니 선언과 동시에 초기화를 안 하면 못 쓰고,
    // 동시에 초기화를 하면 ObservedObject 2개를 넘길 수 없다.
    // -> @State로 클래스의 객체를 nil로 초기화하고 onAppear {} 내에서 초기화!
    @State var watchDelegate: WatchDelegate? = nil
    
    @EnvironmentObject var messageStore: MessageStore
    @StateObject var monitor: Monitor = .init()
    
    @State var isShowingAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(messageStore.messages) { message in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(message.message)
                                Text("\(message.formattedTimestamp)")
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                            Button {
                                // send to iPhone
                                isShowingAlert.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(monitor.status.label)
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .onAppear {
                messageStore.fetchData()
                watchDelegate = .init(messageStore: messageStore, monitor: monitor)
                WCSession.default.delegate = watchDelegate // Delegate 생성 후 WCSession에 지정
                WCSession.default.activate() // 워치 세션 활성화
            }
            .alert("전송 완료", isPresented: $isShowingAlert) {
                Button("확인") {
                    isShowingAlert.toggle()
                }
            }
        }
    }
}

class WatchDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @ObservedObject var messageStore: MessageStore
    @ObservedObject var monitor: Monitor
    
    init(messageStore: MessageStore, monitor: Monitor) {
        self.messageStore = messageStore
        self.monitor = monitor
    }
    
    // 워치 세션 활성화 완료될 때 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        monitor.status = .WAITING
        print("Activated Watch Session!!")
    }
    
    // 워치가 iOS로부터 데이터 받았을 때 호출
    func session(_ session: WCSession, didReceiveMessage messageData: Data) {
        do {
            let data = try PropertyListDecoder().decode([Message].self, from: messageData)
            debugPrint(data)
            print("전송 완료")
            messageStore.overwriteData(data)
            monitor.status = .RECEIVED
        } catch {
            print("Error encoding messages: \(error)")
            // 처리할 수 없는 에러가 발생하면 알림 처리
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        do {
            let data = try PropertyListDecoder().decode([Message].self, from: messageData)
            debugPrint(data)
            print("전송 완료")
            messageStore.overwriteData(data)
            monitor.status = .RECEIVED
        } catch {
            print("Error encoding messages: \(error)")
            // 처리할 수 없는 에러가 발생하면 알림 처리
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MessageStore())
}
