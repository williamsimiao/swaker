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
    
    /****************************************************************************************************
        Função de login do usuario
    
        Parâmetros: Usuário com username e senha
        Retorno   : Usuário com dados ou nil
    ****************************************************************************************************/
    func login(user:User!) -> User? {
        
        if PFUser.currentUser() == nil {
            var error:NSError?
            
            
            PFUser.logInWithUsernameInBackground(user.username, password: user.password){
                (userR:PFUser?, error: NSError?) -> Void in
                
                if userR != nil {
                    
                    self.currentUser = User(username: user.username,
                                            password: user.password,
                                               email: userR!.email,
                                                name: userR!.objectForKey("name") as! String,
                                               photo: userR!.objectForKey("photo") as? NSData)
                } else {
                    //Log in falhou
                }
            }
        } else {
            let aUser = PFUser.currentUser()!
            currentUser = User(username: aUser.username!,
                               password: "",
                                  email: aUser.email!,
                                   name: aUser.objectForKey("name") as! String,
                                  photo: aUser.objectForKey("photo") as? NSData)
        }
        return currentUser!
    }
    
    
    
    /****************************************************************************************************
        Função de cadastro
    
        Parâmetros : Usuario com username, password e email
        Retorno    : true = cadastrou ou false = não cadastrou
    ****************************************************************************************************/
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
    
    /****************************************************************************************************
        Função de logout
    
        Parâmetros : void
        Retorno    : void
    ****************************************************************************************************/
    func logout() ->Bool{
        PFUser.logOutInBackground()
        var sucess = Bool()
        
        PFUser.logOutInBackgroundWithBlock {
            (error) -> Void in
            
            if (error != nil){

                sucess = true
                
            } else {
                
                sucess = false
                
            }
            
        }
        
        return sucess
    }
    
    
    /****************************************************************************************************
        Função de excluir usuario
    
        Parâmetros : Usuario a ser deletado
        Retorno    : true ou false para exclusao
    ****************************************************************************************************/
    func deleteUser(user:User!) ->Bool{
        
        var userDAO = PFUser()
        var sucess = Bool()
        
       userDAO = PFUser(withoutDataWithClassName: "User", objectId: user.objectId)
        
        userDAO.deleteInBackgroundWithBlock{
            (succeded: Bool, error:NSError?) -> Void in
            sucess = succeded
        }
      
        return sucess
  
    }

    
    /****************************************************************************************************
        Função de alterar dados
    
        Parâmetros : Usuario com dados alterados
        Retorno    : True ou false para o update dos dados
    ****************************************************************************************************/
    
    func updateUser(user:User!) ->Bool{
        
        var sucess = Bool()
        
        var query : PFQuery = PFQuery(className: "User")
        query.getObjectInBackgroundWithId(user.objectId){
            (userDAO, error) -> Void in
            
            if (error != nil){
        
                userDAO!.setObject(user.name, forKey: "name")
                userDAO!.setObject(user.password, forKey: "password")
                userDAO!.setObject(user.photo!, forKey: "photo")
                
                userDAO?.saveInBackgroundWithBlock{
                    (succeeded,error2) -> Void in
                    
                    sucess = succeeded
                    
                }
                
            }
            else{
                sucess = false
            }
     
        }
        return sucess
    }
}