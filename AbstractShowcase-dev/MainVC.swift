//
//  MainVC.swift
//  AbstractShowcase-dev
//
//  Created by Miwand Najafe on 2016-05-06.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class MainVC: UIViewController {
    
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imgSelectorImage: UIImageView!
    @IBOutlet weak var feedTableView: UITableView!
    var posts = [Post]()
    static var imageCache = NSCache()
    var imgPicker: UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        feedTableView.estimatedRowHeight = 358
        
        DataService.instance.REF_POSTS.observeEventType(.Value, withBlock:  { (snapshot) in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? [String:AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.feedTableView.reloadData()
        })
    }
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            if let img = imgSelectorImage.image where img != UIImage(named: "camera") {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string:urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = KEY_IMAGE_SHACK.dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                Alamofire.upload(.POST, url, multipartFormData: { (multipartFormData) in
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                }) { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { (response) in
                            
                            if let info = response.result.value as? NSDictionary {
                                if let links = info["links"] as? NSDictionary {
                                    if let imgLink = links["image_link"] as? String {
                                        self.postToFirebase(imgLink)
                                    }
                                }
                            }
                        })
                    case .Failure(let error):
                        print(error)
                    }
                }
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl:String?) {
        var post: Dictionary<String,AnyObject> =
        [  "description": postField.text!,
           "likes":0
        ]
        if let imgURLString = imgUrl {
            post["imageUrl"] = imgURLString
        }
        
        let firebasePost = DataService.instance.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        postField.text = ""
        imgSelectorImage.image = UIImage(named: "camera")
        feedTableView.reloadData()
    }
}

extension MainVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.postImageUrl == nil {
            return 150
        }
        return tableView.estimatedRowHeight
    }
}
extension MainVC: UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        var img: UIImage?
        
        if let imgUrl = post.postImageUrl {
            img = MainVC.imageCache.objectForKey(imgUrl) as? UIImage
        }
        
        if let cell =  tableView.dequeueReusableCellWithIdentifier(POST_CELL_IDENTIFIER) as? PostCell {
            cell.request?.cancel()
            cell.configCell(post,img: img)
            return cell
        } else {
            let cell = PostCell()
            cell.configCell(post,img: img)
            return cell
        }
    }
}

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func selectedImage(sender: AnyObject) {
        presentViewController(imgPicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelectorImage.image = image
    }
}