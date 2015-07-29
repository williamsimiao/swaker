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
        Retorno   : true = login sucesso ou false = login falhou
    ****************************************************************************************************/
    func login(user:User!) -> Bool {
        if PFUser.currentUser() == nil {
            // Não logado
            var error:NSError?
            if let userDAO = PFUser.logInWithUsername(user.username, password: user.password, error: &error) {
                currentUser = User(user: userDAO)
            }
            else {
                // Log In falhou
                return false
            }
        } else {
            // Já logado
            currentUser = User(user: PFUser.currentUser()!)
        }
        return true
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
    func deleteUser(user:User!) ->Bool{
        let userDAO = PFUser(withoutDataWithClassName: "User", objectId: user.objectId)
        
        return userDAO.delete()
    }

    
    /****************************************************************************************************
        Função de alterar dados
    
        Parâmetros : Usuario com dados alterados
        Retorno    : True ou false para o update dos dados
    ****************************************************************************************************/
    
    func updateUser(user:User!) ->Bool{
        
        var sucess = Bool()
        
        let userDAO = PFUser(withoutDataWithClassName: "User", objectId: user.objectId)
        
        userDAO.setObject(user.name, forKey: "name")
        userDAO.setObject(user.password, forKey: "password")
        if user.photo != nil {
            userDAO.setObject(user.photo!, forKey: "photo")
        }
        
        return userDAO.save()
    }
}