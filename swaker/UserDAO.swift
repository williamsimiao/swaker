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
    
    var currentUserFriends = [User]()
    var currentUser:User?
    static var instance:UserDAO?
    
    static func sharedInstance() -> UserDAO {
        if instance == nil {
            instance = UserDAO()
            if PFUser.currentUser()?.username != nil {
                instance!.currentUser = User(user: PFUser.currentUser()!)
            }
        }
        return instance!
    }
    
    /****************************************************************************************************
        Função de login do usuario
        Parâmetros: Usuário com username e senha
        Retorno   : true = login sucesso ou false = login falhou
    ****************************************************************************************************/
    func login(user:User!) -> Bool {
        if PFUser.currentUser()?.username == nil {
            // Não logado
            var error:NSError?
            if let userDAO = PFUser.logInWithUsername(user.username, password: user.password, error: &error) {
                currentUser = User(user: userDAO)
            }
            else {
                // Log In falhou
                return false
            }
        }
        return true
    }
    
    /****************************************************************************************************
        Função de cadastro
        Parâmetros : Usuario com username, password e email
        Retorno    : true = cadastrou ou false = não cadastrou
    ****************************************************************************************************/
    func signup(user:User!) -> Bool {
        
        var userDAO = PFUser()
        
        userDAO.username = user.username
        userDAO.password = user.password
        userDAO.email = user.email
        userDAO.setObject(user.name, forKey: "name")
        if user.photo != nil {
            userDAO.setObject(user.photo!, forKey: "photo")
        }
        
        return userDAO.signUp()
    }
    
    /****************************************************************************************************
        Função de logout
        Parâmetros : void
        Retorno    : void
    ****************************************************************************************************/
    func logout() {
        PFUser.logOut()
    }
    
    
    /****************************************************************************************************
        Função de excluir usuario
        Parâmetros : Usuario a ser deletado
        Retorno    : true ou false para exclusao
    ****************************************************************************************************/
    func deleteUser(user:User!) -> Bool {
        let userDAO = PFUser(withoutDataWithClassName: "User", objectId: user.objectId)
        return userDAO.delete()
    }

    
    /****************************************************************************************************
        Função de alterar dados
        Parâmetros : Usuario com dados alterados
        Retorno    : True ou false para o update dos dados
    ****************************************************************************************************/
    func updateUser(user:User!) -> Bool {
        
        var sucess = Bool()
        
        let userDAO = PFUser(withoutDataWithClassName: "User", objectId: user.objectId)
        
        userDAO.setObject(user.name, forKey: "name")
        userDAO.setObject(user.password, forKey: "password")
        if user.photo != nil {
            userDAO.setObject(user.photo!, forKey: "photo")
        }
        
        return userDAO.save()
    }
    
    /****************************************************************************************************
        Função que retorna os amigos de um usuário
        Parâmetros : void
        Retorno    : Array de amigos ou array vazio (se você for sozinho na vida)
    ****************************************************************************************************/
    func loadFriendsForCurrentUser(){
        println("counting friends")
        var friends = [User]()
        let query = PFQuery(className: "FriendList").whereKey("userId", equalTo: currentUser!.objectId)
        let anyObjects = query.findObjects()
        let objects = anyObjects as? [PFObject]
        if objects != nil {
            for obj in objects! {
                let user = PFUser.query()?.whereKey("objectId", equalTo: obj["friendId"] as! String).findObjects()!.first as! PFUser
                //                let user = PFUser(withoutDataWithClassName: "_User", objectId: (obj["friendId"] as! String))
                println(user["email"])
                friends.append(User(user: user))
            }
        }
        currentUserFriends = friends
    }
    
    /****************************************************************************************************
        Função de adicionar um amigo
        Parâmetros : Amigo (User)
        Retorno    : true = adicionado false = não adicionado
    ****************************************************************************************************/
    func addFriend(friend:User!) -> Bool {
        var friendStatement = PFObject(className: "FriendList")
        
        friendStatement.setObject(currentUser!.objectId, forKey: "userId")
        friendStatement.setObject(friend.objectId, forKey: "friendId")
        
        var reverseStatement = PFObject(className: "FriendList")
        reverseStatement.setObject(friend.objectId, forKey: "userId")
        reverseStatement.setObject(currentUser!.objectId, forKey: "friendId")
        
        if friendStatement.save() && reverseStatement.save() {
            return true
        }
        return false
    }
    
    func userWithEmail(email:String!) -> User? {
        if let user = PFUser.query()!.whereKey("email", equalTo: email).findObjects()!.first as? PFUser {
            return User(user: user)
        }
        return nil
    }
}