//
//  PostCell.swift
//  AbstractShowcase-dev
//
//  Created by Miwand Najafe on 2016-05-06.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    var likeRef:Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTap(_:)))
        tap.numberOfTapsRequired = 1
        heartImg.addGestureRecognizer(tap)
        heartImg.userInteractionEnabled = true
        
        
        
    }
    
    
    func likeTap(sender:UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.heartImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.heartImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
    var post: Post!
    var request: Request?
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configCell(post:Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.instance.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        descriptionText.text = post.postDescription
        likesLbl.text = "\(post.postLikes)"
        
        if post.postImageUrl != nil {
            if img == nil {
                request = Alamofire.request(.GET, post.postImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) in
                    if error == nil {
                        let img = UIImage(data:data!)!
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showcaseImg.image = img
                        })
                        
                        MainVC.imageCache.setObject(img, forKey: self.post.postImageUrl!)
                    } else {
                        print(error.debugDescription)
                    }
                })
        }
        } else {
            self.showcaseImg.hidden = true
        }
        likeRef.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.heartImg.image = UIImage(named: "heart-empty")
            } else {
                self.heartImg.image = UIImage(named: "heart-full")
            }
        })
        
        
    }
    

}
