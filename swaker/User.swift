//
//  User.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class User: NSObject {
    var objectId:String!
    var username:String!
    var password:String!
    var email:String!
    var name:String!
    var photo:NSData?
    var submissionDate:NSDate?
    var friends:Array<User>?
    
    
    
    init(username:String!, password:String!) {
        self.username = username
        self.password = password
    }
    
    init(objectId:String!, username:String!, password:String?, email:String!, name:String!, photo:NSData?) {
        self.objectId = objectId
        self.username = username
        self.password = password
        self.email = email
        self.name = name
        self.photo = photo
    }
    
}
