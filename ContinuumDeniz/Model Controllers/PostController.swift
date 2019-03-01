//
//  PostController.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    //Singleton
    static let shared = PostController()
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        
        let record = CKRecord(comment: comment)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error adding a comment: \(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            guard let record = record else { completion(nil); return }
            let comment = Comment(ckRecord: record, post: post)
            self.addCommentCounts(for: post, completion: nil)
            completion(comment)
        }
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: photo, caption: caption)
        self.posts.append(post)
        
        let record = CKRecord(post: post)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error creating a post: \(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            guard let record = record,
                let post = Post(ckRecord: record) else { completion(nil); return }
            
            completion(post)
        }
    }
    
    func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil); return
            }
            guard let records = records else { completion(nil); return }
            
            let posts = records.compactMap( {Post(ckRecord: $0)} )
            self.posts = posts
            completion(posts)
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping ([Comment]?) -> Void) {
        
        let postReference = post.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postReference)
        
        let commentIDs = post.comments.compactMap({ $0.recordID })
        
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: CommentConstants.typeKey, predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching comments from cloudKit \(#function) \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let records = records else { completion(nil); return }
            
            let comments = records.compactMap( {Comment(ckRecord: $0, post: post)} )
            
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
    }
    
    func addCommentCounts(for post: Post, completion: ((Bool) -> Void)?) {
        
        post.commentCount += 1
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error Modify Records Op: \(error.localizedDescription) \(error) in function: \(#function)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
        publicDB.add(modifyOperation)
    }
    
    func subscribeToNewPosts(completion: ((Bool) -> Void)? ) {
        
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: PostConstants.typeKey, predicate: predicate, subscriptionID: "AllPosts", options: .firesOnRecordCreation)

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Continuum"
        notificationInfo.alertBody = "There is a new post."
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("Error subscription from post: \(error.localizedDescription)")
                completion?(false); return
            }
            completion?(true)
            print("Post subscription is successful")
        }
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        let postRecordID = post.recordID

        let predicate = NSPredicate(format: "%K = %@", CommentConstants.postReferenceKey, postRecordID)
        
        let subscription = CKQuerySubscription(recordType: "Comment", predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Continuum"
        notificationInfo.alertBody = "There is a new comment"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = nil
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false, error)
            }else{
                completion?(true, nil)
            }
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> ())?){
        let subscriptionID = post.recordID.recordName
        //Delete the subscription with the same ID as the given post
        publicDB.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false)
                return
            }else {
                print("Subscription deleted")
                completion?(true)
            }
        }
    }
    
    func checkForSubscription(to post: Post, completion: ((Bool) -> ())?){
        let subscriptionID = post.recordID.recordName
        //Check for a subscription under this post's recordID.  This will complete with an error if it does not find one
        CKContainer.default().publicCloudDatabase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false)
                return
            }
            if subscription != nil{
                completion?(true)
            }else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        //Check for a subsciption to this post.  If there is one, we'll remove it, otherwise we will add a new subscription
        checkForSubscription(to: post) { (isSubscribed) in
            if isSubscribed{
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                    if success{
                        print("Successfully removed the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    }else{
                        print("Whoops somthing went wrong removing the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                })
            }else {
                self.addSubscriptionTo(commentsForPost: post, completion: { (success, error) in
                    if let error = error {
                        print("Error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    if success{
                        print("Successfully added the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    }else{
                        print("Whoops somthing went wrong adding the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                })
            }
        }
    }
}
