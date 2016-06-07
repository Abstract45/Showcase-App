//
//  DataService.swift
//  AbstractShowcase-dev
//
//  Created by Miwand Najafe on 2016-05-06.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Firebase

class  DataService {
    static let instance = DataService()
    private init() {}
    
    private var _REF_BASE = Firebase(url: URL_BASE_Firebase)
    private var _REF_POSTS = Firebase(url: URL_BASE_Firebase + "/posts")
    private var _REF_USERS = Firebase(url: URL_BASE_Firebase + "/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE_Firebase)").childByAppendingPath("users").childByAppendingPath(uid)
        return user
    }
    
    
    
    func createFirebaseUser(uid: String, user: [String:String] ) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
}