//
//  Post.swift
//  AbstractShowcase-dev
//
//  Created by Miwand Najafe on 2016-05-07.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Firebase
struct Post {
    private var _postDescription: String!
    private var _postImageUrl: String?
    private var _postLikes: Int!
    private var _postUser: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    
    var postDescription:String {
        return _postDescription
    }
    
    var postLikes: Int {
        return _postLikes
    }
    
    var postImageUrl: String? {
        return _postImageUrl
    }
    
    var username: String {
        return _postUser
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(postKey:String, dictionary:[String:AnyObject]) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._postLikes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._postImageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String  {
            self._postDescription = desc
        }
        
        self._postRef = DataService.instance.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    mutating func adjustLikes(addLike:Bool) {
        if addLike {
            _postLikes = _postLikes + 1
        } else {
            _postLikes = _postLikes - 1
        }
        _postRef.childByAppendingPath("likes").setValue(_postLikes)
        
    }
}