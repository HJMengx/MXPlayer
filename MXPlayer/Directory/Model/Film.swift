//
//  Film.swift
//  MXPlayer
//
//  Created by mx on 2017/1/31.
//  Copyright © 2017年 mengx. All rights reserved.
//

import Foundation

class Film {
    //第一次执行应该创建表
    private static let manager = FMDatabase.init(path: DBPATH)!
    
    var name : String!
    
    var duration = 0
    
    var fileUrl : String!
    
    var isSeeing = true
    
    var seeingTime = 0
    
    var secret = false
    
    init(name : String,duration : Int,fileUrl : String,isSeeing : Bool,seeingTime : Int,secret : Bool) {
        
        self.name = name
        
        self.duration = duration
        
        self.fileUrl = fileUrl
        
        self.isSeeing = isSeeing
        
        self.secret = secret
        
        self.seeingTime = seeingTime
    }
    
    class func getFilms(completion : MXFilmReturnBack){
        //使用默认的数据库
        
        //没有会自动创建
        if !self.manager.open() {
            //没有获取到数据
            completion(false,nil)
        }else{
            //获取数据
            do{
                let results = try self.manager.executeQuery("SELECT * FROM Film", values: nil)
                
                if results.columnCount() >= 0 {
                    completion(true,results)
                }
            }catch{
                print("database error and error is \(error)")
                
                completion(false,nil)
            }
         
        }
    }
    
    class func addFilm(film : Film){
        //Insert语句
        let sql = "insert into Film (name,fileUrl,duration,seeingTime,isSeeing,secret) values (?,?,?,?,?,?)"
        
        do{
            try self.manager.executeUpdate(sql, values: [film.name,film.fileUrl,film.duration,film.seeingTime,false,film.secret])
            
        }catch{
            mxErrorPrint(message: "\(error)")
        }
    }
    
    class func updateSeeingTime(name : String,time : Int){
        let sql = "update Film set seeingTime = ?,isSeeing = ? where name = ?"
        
        do{
            try self.manager.executeUpdate(sql, values: [time,true,name])
        }catch{
            print("保存失败")
        }
    }
    
    class func updateSecret(name : String,secret : Bool){
        let sql = "update Film set secret = ? where name = ?"
        
        do{
            try self.manager.executeUpdate(sql, values: [secret,name])
        }catch{
            print("保存失败")
        }
    }
    
    class func deleteFilm(films : [Film],completion : MXFilmcompletion){
        //一个一个删除，还是一次性删除？
        let sql = "delete from Film where name = ?"
        
        for film in films{
            do{
                try self.manager.executeUpdate(sql, values: [film.name])
                completion(true)
            }catch{
                print("删除出错")
                completion(false)
            }
        }
    }
}
