//
//  UserDAO.swift
//  swaker
//
//  Created by Joao Paulo Lopes da Silva on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class UserDAO: NSObject {
    
    var currentUser:User?
    
    /*
        Função de login do usuario
        Parâmetros: Usuário com user name e senha
        retorno: Usuário com dados ou nil
    */
    func login(user:User!) -> User? {
        if PFUser.currentUser() == nil {
            var error:NSError?
            PFUser.logInWithUsernameInBackground(user.username, password: user.password){
                (userR:PFUser?, error: NSError?) -> Void in
                if userR != nil {
                    self.currentUser = User(username: user.username, password: user.password, email: userR!.email, name: userR!.objectForKey("name") as! String, photo: userR!.objectForKey("photo") as? NSData)
                } else { //Log in falhou
                    
                }
            }
        } else {
            let aUser = PFUser.currentUser()!
            currentUser = User(username: aUser.username!, password: aUser.password!, email: aUser.email!, name: aUser.objectForKey("name") as! String, photo: aUser.objectForKey("photo") as? NSData)
        }
        return currentUser!
    }
    
    
    /*
    Função de cadastro
    Parâmetros:
    retorno: 
    */
    
    
    
    
   
}
