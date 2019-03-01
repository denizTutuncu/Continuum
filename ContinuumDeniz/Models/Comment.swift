//
//  Comment.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let typeKey = "Comment"
    static let textKey = "text"
    static let timestampkey = "timestamp"
    static let postKey = "post"
    static let postReferenceKey = "postReference"
}

class Comment {
    
    let text: String
    let timestamp: Date
    weak var post: Post?
    let recordID: CKRecord.ID
    
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
//    func postReference() -> CKRecord.Reference?{
//        guard let post = post else { return nil }
//        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
//    }
//
    init(text: String, timestamp: Date = Date(), post: Post, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timestamp = ckRecord[CommentConstants.timestampkey] as? Date else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: post, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentConstants.typeKey, recordID: comment.recordID)
        
        self.setValue(comment.text, forKey: CommentConstants.typeKey)
        self.setValue(comment.timestamp, forKey: CommentConstants.timestampkey)
        self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
    }
    
}

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}
