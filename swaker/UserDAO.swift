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
    
    /*//////////////////////////////CLASS ATTS AND FUNCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
    //MARK: Class atts and functions
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
    
    static func unload() {
        self.instance = nil
        PFInstallation.currentInstallation().setObject([], forKey: "channels")
        PFInstallation.currentInstallation().removeObjectForKey("user")
        PFInstallation.currentInstallation().save()
    }
    
    /*//////////////////////////////INSTANCE ATTS AND FUNCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
    //MARK: Current User Property
    var currentUser:User?
    
    //MARK: Functions
    //MARK: User Functions
    /****************************************************************************************************
        Função de login do usuario
        Parâmetros: Usuário com username e senha
        Retorno   : true = login sucesso ou false = login falhou
    ****************************************************************************************************/
    func login(user:User!) -> Bool {
            var error:NSError?
            if let userDAO = PFUser.logInWithUsername(user.username, password: user.password, error: &error) {
                if currentUser == nil {
                    currentUser = User(user: userDAO)
                    PFInstallation.currentInstallation().setObject(userDAO, forKey: "user")
                    PFInstallation.currentInstallation().saveInBackground()
                }
                return true
            }
        return false
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
        userDAO.setObject(PFFile(data:user.photo!), forKey: "photo")
        if userDAO.signUp() {
            self.logout()
            return true
        }
        return false
    }
    
    /****************************************************************************************************
        Função de logout
        Parâmetros : void
        Retorno    : void
    ****************************************************************************************************/
    func logout() {
        PFUser.logOut()
        AlarmDAO.unload()
        UserDAO.unload()
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
    func updateUser(user:User!) {
        var sucess = Bool()
        let userDAO = PFUser.currentUser()!
        userDAO.setObject(user.name, forKey: "name")
        userDAO.setObject(PFFile(data: user.photo!), forKey: "photo")
        userDAO.saveEventually()
    }
    
    /****************************************************************************************************
    Função que reseta a senha do usuário
    Parâmetros : email do usuário
    Retorno    : true = resetado, false = não resetado
    ****************************************************************************************************/
    func resetPasswordForEmail(email:String!) -> Bool {
        return PFUser.requestPasswordResetForEmail(email)
    }
    
    //MARK: Friends Functions
    /****************************************************************************************************
        Função que retorna os amigos de um usuário para a propriedade self.currentUserFriends
        Parâmetros : void
        Retorno    : void
    ****************************************************************************************************/
    func loadFriendsForCurrentUser() {
        println("Loading friends")
        var friendsIds = [String]()
        for friend in currentUser!.friends {
            friendsIds.append(friend.objectId)
        }
        let query = PFQuery(className: "FriendList").whereKey("userId", equalTo: currentUser!.objectId)
        query.findObjectsInBackgroundWithBlock { (friendListObjects, error) -> Void in
            if error == nil {
                var friends = [User]()
                let friendListObjects = friendListObjects as! [PFObject]
                for object in friendListObjects {
                    let friend = PFUser(withoutDataWithObjectId: object["friendId"] as! String)
                    friend.fetch()
                    friends.append(User(user: friend))
                }
                self.currentUser!.friends = friends
            }
        }
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
            PFInstallation.currentInstallation().addObject("f"+friend.objectId, forKey: "channels")
            PFInstallation.currentInstallation().save()
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
        currentUser!.friends.removeAtIndex(find(currentUser!.friends, friend)!)
        return true
    }
}