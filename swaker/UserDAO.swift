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
                instance?.loadFriendsForCurrentUser()
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
        currentUser = nil
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
        Função que retorna os amigos de um usuário para a propriedade self.currentUserFriends
        Parâmetros : void
        Retorno    : void
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
    
    /****************************************************************************************************
        Função que retorna um user a partir de um email
        Parâmetros : email
        Retorno    : o usuário correspondente ao email, ou nil caso não exista
    ****************************************************************************************************/
    func userWithEmail(email:String!) -> User? {
        if let user = PFUser.query()!.whereKey("email", equalTo: email).findObjects()!.first as? PFUser {
            return User(user: user)
        }
        return nil
    }
    
    /****************************************************************************************************
        Função que remove um usuário da lista de amigos do currentUser
        Parâmetros : usuário a ser removido
        Retorno    : true = removido, false = não removido
    ****************************************************************************************************/
    func deleteFriend(friend:User) -> Bool {
        if let objects = PFQuery(className: "FriendList").whereKey("userId", equalTo: currentUser!.objectId).whereKey("friendId", equalTo: friend.objectId).findObjects() {
            if !(objects.first as! PFObject).delete() {
                return false
            }
        } else {
            return false
        }
        if let objects = PFQuery(className: "FriendList").whereKey("userId", equalTo: friend.objectId).whereKey("friendId", equalTo: currentUser!.objectId).findObjects() {
            if !(objects.first as! PFObject).delete() {
                PFObject(className: "FriendList", dictionary: ["userId":currentUser!.objectId, "friendId":friend.objectId]).saveEventually()
                return false
            }
        } else {
            PFObject(className: "FriendList", dictionary: ["userId":currentUser!.objectId, "friendId":friend.objectId]).saveEventually()
            return false
        }
        return true
    }
}