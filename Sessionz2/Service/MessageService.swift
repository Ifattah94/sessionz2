//
//  MessageService.swift
//  Sessionz2
//
//  Created by C4Q on 6/25/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import Foundation
import FirebaseAuth

struct MessageService {
    
    private init() {}
    
   let currentUid = Auth.auth().currentUser?.uid
   static let shared = MessageService()
    
    
    func uploadMessage(user: AppUser?, with properties: [String:AnyObject], text: String?) {
        guard let currentUid = FirebaseAuthService.manager.currentUser?.uid else { return }
        guard let user = user else {return}
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        guard let uid = user.uid else { return }
        
        var values: [String: AnyObject] = [toIdKey: uid as AnyObject, fromIdKey: currentUid as AnyObject, creationDateKey : creationDate as AnyObject, readKey: false as AnyObject]
         properties.forEach({values[$0] = $1})
        
        let messageRef = REF_MESSAGES.childByAutoId()
        
        guard let messageKey = messageRef.key else {return}
        
        messageRef.updateChildValues(values) { (err, ref) in
            USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([messageKey: 1])
            
            USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([messageKey: 1])
        }
        
        uploadMessageNotification(type: .Text, text: text, toId: uid, fromId: currentUid)
        
        
        
    }
    
    func uploadMessageNotification(type: MessageContent, text: String?, toId: String, fromId: String) {
        var messageText: String!
        switch type {
        case .Image :
            messageText = "Sent an Image"
        case .Video :
            messageText = "Sent A Video"
        case .Text :
            messageText = text
        }
        
        let values = [fromIdKey: fromId, toIdKey: toId, messageTextKey: messageText] as [String: Any]
        
        USER_MESSAGE_NOTIFICATIONS_REF.child(toId).childByAutoId().updateChildValues(values)
    }
    
    func observeMessages(chatPartnerId: String?, completion: @escaping (String) -> ()) {
        guard let currentUid = self.currentUid else {return}
        guard let chatPartnerId = chatPartnerId else {return}
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            completion(messageId)
        }
        
    }
    
    
    func fetchMessage(with messageId: String, completion: @escaping (Message) -> ()) {
        REF_MESSAGES.child(messageId).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            completion(message)
        }
    }
    
    func setMessageToRead(for messageId: String, fromId: String) {
        if fromId != Auth.auth().currentUser?.uid {
            REF_MESSAGES.child(messageId).child(readKey).setValue(true)
               }
    }
    
}
