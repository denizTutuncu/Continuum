//
//  PostDetailTableViewController.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var followPostButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            reloadViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = post else { return }
        PostController.shared.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func reloadViews() {
        guard let post = post else { return }
        photoImageView.image = post.photo
        tableView.reloadData()
        updateFollowPostButtonText()
    }
    
    func updateFollowPostButtonText(){
        guard let post = post else { return }
        //Check CloudKit for a subscription to this post and adjust the text of the button to reflect this
        PostController.shared.checkForSubscription(to: post) { (found) in
            DispatchQueue.main.async {
                let followPostButtonText = found ? "Unfollow Post" : "Follow Post"
                self.followPostButton.setTitle(followPostButtonText, for: .normal)
                //Asks the stackview to resize the button if it is necesssary to accomodate the new text
                self.buttonsStackView.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        let alertController = AlertController.shared.presentCommentAlertController()
        let commentAction = UIAlertAction(title: "Comment", style: .default) { (_) in
            guard let commentText = alertController.textFields?.first?.text, !commentText.isEmpty, let post = self.post else { return }
            
            PostController.shared.addComment(text: commentText, post: post, completion: { (comment) in
            })
            self.tableView.reloadData()
        }
        alertController.addAction(commentAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let comment = post?.caption else { return }
        let shareSheet = UIActivityViewController(activityItems: [comment], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func followPostButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (success, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                return
            }
            self.updateFollowPostButtonText()
        }
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringWith(dateStyle: .medium, timeStyle: .short)
        
        return cell
    }
    
}
