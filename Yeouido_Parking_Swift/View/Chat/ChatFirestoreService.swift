import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum ChatServiceError: LocalizedError {
    case firebaseUnavailable
    case invalidUser

    var errorDescription: String? {
        switch self {
        case .firebaseUnavailable:
            return "Firebase 설정이 아직 연결되지 않았습니다."
        case .invalidUser:
            return "로그인 사용자 정보를 확인할 수 없습니다."
        }
    }
}

final class ChatListenerToken {
    private let cancellation: () -> Void

    init(cancellation: @escaping () -> Void) {
        self.cancellation = cancellation
    }

    func cancel() {
        cancellation()
    }
}

enum ChatFirestoreService {
    static var isFirebaseAvailable: Bool {
        #if canImport(FirebaseFirestore)
        true
        #else
        false
        #endif
    }

    static func conversationID(for userID: Int) -> String {
        "user_\(userID)"
    }

    static func observeMessages(
        userID: Int,
        onUpdate: @escaping ([ChatMessage]) -> Void
    ) -> ChatListenerToken {
        #if canImport(FirebaseFirestore)
        let listener = Firestore.firestore()
            .collection("chats")
            .document(conversationID(for: userID))
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, _ in
                let messages = snapshot?.documents.compactMap { document in
                    mapMessage(id: document.documentID, data: document.data())
                } ?? []
                onUpdate(messages)
            }

        return ChatListenerToken {
            listener.remove()
        }
        #else
        onUpdate([])
        return ChatListenerToken {}
        #endif
    }

    static func sendMessage(
        userID: Int,
        userEmail: String,
        userName: String,
        text: String
    ) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let conversationID = conversationID(for: userID)
        let now = Date()
        let conversationRef = db.collection("chats").document(conversationID)
        let messagesRef = conversationRef.collection("messages")

        try await conversationRef.setData([
            "userID": userID,
            "userEmail": userEmail,
            "userName": userName,
            "status": "open",
            "createdAt": Timestamp(date: now),
            "updatedAt": Timestamp(date: now),
            "lastMessage": text
        ], merge: true)

        try await messagesRef.addDocument(data: [
            "text": text,
            "senderType": ChatSenderType.user.rawValue,
            "senderUserID": userID,
            "createdAt": Timestamp(date: now)
        ])
        #else
        throw ChatServiceError.firebaseUnavailable
        #endif
    }

    #if canImport(FirebaseFirestore)
    private static func mapMessage(id: String, data: [String: Any]) -> ChatMessage? {
        guard
            let text = data["text"] as? String,
            let senderRaw = data["senderType"] as? String,
            let senderType = ChatSenderType(rawValue: senderRaw),
            let senderUserID = data["senderUserID"] as? Int
        else {
            return nil
        }

        let createdAt: Date
        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }

        return ChatMessage(
            id: id,
            text: text,
            senderType: senderType,
            senderUserID: senderUserID,
            createdAt: createdAt
        )
    }
    #endif
}
