//
//  PostTableViewCell.swift
//  ContinuumDeniz
//
//  Created by Deniz Tutuncu on 2/26/19.
//  Copyright © 2019 Deniz Tutuncu. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let post = post else { return }
        postPhotoImageView.image = post.photo
        captionLabel.text = post.caption
        commentCountLabel.text = "Comments: \(post.commentCount)" 
    }
    
}
