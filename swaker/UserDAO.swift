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
    static var instance:UserDAO?
    
    static func sharedInstance() -> UserDAO {
        if instance == nil {
            instance = UserDAO()
        }
        return instance!
    }
    
    /******************************************************************************
        Função de login do usuario
        Parâmetros: Usuário com username e senha
        retorno: Usuário com dados ou nil
    ******************************************************************************/
    func login(user:User!) -> User? {
        if PFUser.currentUser() == nil {
            var error:NSError?
            PFUser.logInWithUsernameInBackground(user.username, password: user.password){
                (userR:PFUser?, error: NSError?) -> Void in
                if userR != nil {
                    self.currentUser = User(objectId: userR!.objectId,username: user.username, password: user.password, email: userR!.email, name: userR!.objectForKey("name") as! String, photo: userR!.objectForKey("photo") as? NSData)
                } else { //Log in falhou
                    
                }
            }
        } else {
            let aUser = PFUser.currentUser()!
            currentUser = User(objectId: aUser.objectId, username: aUser.username!, password: aUser.password!, email: aUser.email!, name: aUser.objectForKey("name") as! String, photo: aUser.objectForKey("photo") as? NSData)
        }
        return currentUser!
    }
    
    
    
    /******************************************************************************
        Função de cadastro
        Parâmetros: Usuario com username, password e email
        retorno: true = cadastrou ou false = não cadastrou
    ******************************************************************************/
    func signup(user:User!) -> Bool{
        
        var userDAO = PFUser()
        userDAO.username = user.username
        userDAO.password = user.password
        userDAO.email = user.email
        
        var sucess = Bool()
        
        userDAO.signUpInBackgroundWithBlock{
            (succeded: Bool, error:NSError?) -> Void in
            sucess = succeded
  
        }
        return sucess
    }
    
    /******************************************************************************
        Função de logout
        Parâmetros: void
        retorno: void
    ******************************************************************************/
    func logout(){
        PFUser.logOut()
    }
    
    
    /******************************************************************************
        Função de excluir usuario
        Parâmetros:
        retorno:
    ******************************************************************************/
    
    
    /******************************************************************************
        Função de alterar dados
        Parâmetros:
        retorno:
    ******************************************************************************/
    
    
    
    

}
