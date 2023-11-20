//
//  ContentView.swift
//  BLESampleApp
//
//  Created by 한현민 on 11/18/23.
//

import SwiftUI
import WatchConnectivity // for supporting BLE comm with watchOS

class Monitor: ObservableObject {
    enum Status {
        case INITIAL, WAITING, SENT, FAILURE
        
        var label: String {
            switch self {
            case .INITIAL:
                return "초기화됨"
            case .WAITING:
                return "대기 중"
            case .SENT:
                return "송신 성공"
            case .FAILURE:
                return "송신 실패"
            }
        }
    }
    
    @Published var status: Status = .INITIAL
}

struct ContentView: View {
    // 워치와의 통신을 위한 Delegate 객체 생성
    @State var watchDelegate: WatchDelegate? = nil
    
    @EnvironmentObject var messageStore: MessageStore
    @StateObject var monitor: Monitor = .init()
    
    @State var editingIndex: Int = 0
    @State var editingText: String = ""
    
    @State var isShowingAddSheet: Bool = false
    @State var isShowingCommErrorAlert: Bool = false
    @State var commErrorDescription: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                VStack(spacing: 20) {
                    LazyVStack(spacing: 16) {
                        ForEach(0 ..< messageStore.messages.count, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .foregroundColor(index == editingIndex ? Color(uiColor: .blue.withAlphaComponent(0.5)) : Color.clear)
                                
                                HStack {
                                    Text(messageStore.messages[index].message)
                                    Spacer()
                                    Text("\(messageStore.messages[index].formattedTimestamp)")
                                        .font(.footnote)
                                }
                                .padding(20)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    editingIndex = index
                                    editingText = messageStore.messages[index].message
                                }
                            }
                        }
                        .listRowSeparator(.hidden, edges: .all)
                    }
                    .listRowSeparator(.hidden, edges: .all)
                    
                    Divider()
                    
                    HStack {
                        TextField("Change...", text: $editingText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Change") {
                            print("changed from \(messageStore.messages[editingIndex].message) to \(editingText)")
                            messageStore.messages[editingIndex].message = editingText
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .listRowSeparator(.hidden, edges: .all)
                    .padding(.bottom, 20)
                    
                    Button("SEND TO WATCH") {
                        // 워치 접근 가능하면 데이터를 워치로 전송][[]
                        if WCSession.default.isReachable {
                            do {
                                let data = try PropertyListEncoder().encode(messageStore.messages)
                                WCSession.default.sendMessageData(data) { response in
                                    debugPrint(response)
                                    print("전송 완료")
                                    monitor.status = .SENT
                                } errorHandler: { error in
                                    monitor.status = .FAILURE
                                    commErrorDescription = error.localizedDescription
                                    isShowingCommErrorAlert.toggle()
                                }
                            } catch {
                                print("Error encoding messages: \(error)")
                                // 처리할 수 없는 에러가 발생하면 알림 처리
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowSeparator(.hidden, edges: .all)
                }
                .listRowSeparator(.hidden, edges: .all)
            }
            .listStyle(.plain)
            .navigationTitle("\(WCSession.default.isReachable ? "통신 가능" : "통신 불가능") | \(monitor.status.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        isShowingAddSheet.toggle()
                    }
                }
            }
            .padding()
        }
        
        .onAppear {
            messageStore.fetchData()
            
            // iOS 앱 내부에서도 WCSession의 delegate를 지정하고, 세션을 활성화해줘야 한다.
            if WCSession.isSupported() {
                watchDelegate = .init(messageStore: messageStore, monitor: monitor)
                WCSession.default.delegate = watchDelegate // 초기화 후 지정
                WCSession.default.activate() // iOS에서의 세션 활성화
                print("세션 활성화")
                monitor.status = .WAITING
            }
        }
        
        .sheet(isPresented: $isShowingAddSheet) {
            // sheet 안에 @State 변수를 쓰면 저장 기능을 못한다.
            // sheet가 닫힐 때 @State 변수가 먼저 해제되기 때문이다.
            // @State 변수를 쓰겠다면, 별도의 화면으로 빼서 써야 한다.
            AddSheetView(isShowingAddSheet: $isShowingAddSheet)
        }
        
        .alert("통신 실패", isPresented: $isShowingCommErrorAlert) {
            Button("확인") {
                isShowingCommErrorAlert.toggle()
            }
        } message: {
            Text(commErrorDescription)
        }
    }
}

class WatchDelegate: NSObject, WCSessionDelegate {
    @ObservedObject var messageStore: MessageStore
    @ObservedObject var monitor: Monitor
    
    init(messageStore: MessageStore, monitor: Monitor) {
        self.messageStore = messageStore
        self.monitor = monitor
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        monitor.status = .WAITING
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        monitor.status = .INITIAL
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        monitor.status = .INITIAL
    }
    
    // 아이폰에서 워치의 연결 상태 변화할 때 호출되는 메서드
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("전송 가능!")
            monitor.status = .WAITING
        } else {
            print("전송 불가능!")
            monitor.status = .FAILURE
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MessageStore())
}
