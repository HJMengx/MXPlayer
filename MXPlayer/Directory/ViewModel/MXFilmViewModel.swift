//
//  MXFilmViewModel.swift
//  MXPlayer
//
//  Created by mx on 2017/1/29.
//  Copyright © 2017年 mengx. All rights reserved.
//

import Foundation

enum MXDataBaseOperationType{
    case delete
    case updateSecret
    case updateSeeingTime
    case insert
    case select
}


class MXFilmViewModel {
    
    static let share : MXFilmViewModel = MXFilmViewModel()
    
    //有三个Cell,已看过，没看过，加密
    var films : [[String]] = [[String]]()
    
    var willReadingFilm = [Film]()
    
    var readingFilm = [Film]()
    
    var secretFilm = [Film]()
    
    private init(){
        
    }
    
    class func durationToTime(time : Int)->String{
        //转换
        let hour = time / 3600
        
        let minute = time / 60
        
        let second = time % 60
        
        if hour == 0 {
            if minute == 0 {
                return String.init(format: "00:00:%02d", second)
            }
            return String.init(format: "00:%02d:%02d",minute,second)
        }
        
        return String.init(format: "%02d:%02d:%02d", hour,minute,second)
    }
    
    func getFilmFromLocal(){
        //置空所有数组
        self.willReadingFilm.removeAll()
        self.readingFilm.removeAll()
        self.secretFilm.removeAll()
        //获取数据，并设置
        self.getReadingFilm()
        self.getLocalFilm()
        self.categoryFilms()
    }
    
    fileprivate func getReadingFilm(){
        
        Film.getFilms { (isSuccess : Bool, films : FMResultSet?) in
            //解析数据
                    //name text primary key , fileUrl text,duration integer,seeingTime : integer,isSeeing : boolean,secret : boolean
            //是否成功加载
            if isSuccess {
                
                while films!.next() {
                    let name = films!.string(forColumn: "name")!
                    
                    let fileUrl = films!.string(forColumn: "fileUrl")!
                    
                    let duration = Int(films!.int(forColumn: "duration"))
                    
                    let seeingTime = Int(films!.int(forColumn: "seeingTime"))
                    
                    let secret = films!.bool(forColumn: "secret")
                    
                    let isSeeing = films!.bool(forColumn: "isSeeing")
                    
                    let film = Film.init(name: name, duration: duration, fileUrl: fileUrl, isSeeing: isSeeing, seeingTime: seeingTime, secret: secret)
                    
                    var isContains = false
                    
                    if secret {
                        //已经存在就不需要添加,因为时间的改变，需要重新添加
                        //考虑更优化的算法，解决这个添加问题
                        //存在就不需要添加
                        for haveFilm in self.secretFilm {
                            if haveFilm.name == film.name {
                                isContains = true
                            }
                        }
                        if !isContains {
                            self.secretFilm.append(film)
                        }
                    }else if isSeeing {
                        for haveFilm in self.readingFilm {
                            if haveFilm.name == film.name {
                                isContains = true
                            }
                        }
                        if !isContains {
                            self.readingFilm.append(film)
                        }
                    }else{
                        //没有这种情况
                        
                    }
                }
                
            }else{
                //数据库打开失败
                SVProgressHUD.showError(withStatus: "数据加载失败，请重试")
            }
        }
        
    }
    
    fileprivate func getLocalFilm(){
        //获取一个目录下指定文件
        do {
            var files = try FileManager.default.contentsOfDirectory(atPath: FILEPATH)
            //在这里做就行了
            if UserDefaults.standard.bool(forKey: "isNeedTestFilm") {
                files.append("MXPlayercontent.mov")
                //不行就修改这里，询问用户是否需要删除..
                //UserDefaults.standard.set(false, forKey: "isNeedTestFilm")
            }
            //只能获取到文件名
            for file in files {
                if file.contains(".mp4") || file.contains(".rmvb") || file.contains(".wkv") || file.contains(".mov") || file.contains(".avi")  || file.contains(".flv") || file.contains(".3gp") || file.contains(".mpeg") || file.contains(".mpg") || file.contains(".rm"){
                    //获取名字等属性
                    var name : String!
                    //截串
                    if file.contains(".rmvb"){
                        let index = file.index(file.endIndex, offsetBy: -5)
                        
                        name = file.substring(to: index)
                    }else{
                        let index = file.index(file.endIndex, offsetBy: -4)
                        
                        name = file.substring(to: index)
                    }
                    //预览图，获取不到。。
                    var localFilm : Film!
                    
                    if file == "MXPlayercontent.mov" || file == "MXPlayer.mp4" {
                        localFilm = Film.init(name: file, duration: 0, fileUrl: (Bundle.main.url(forResource: file, withExtension: nil)?.absoluteString)!, isSeeing: false, seeingTime: 0, secret: false)
                    }else{
                        localFilm = Film.init(name: file, duration: 0, fileUrl: (Bundle.init(path: FILEPATH)!.url(forResource: file, withExtension: nil)?.absoluteString)!, isSeeing: false, seeingTime: 0, secret: false)
                    }
                    
                    //阅读过不包含
                    if !self.readingFilm.contains(where: { (film : Film) -> Bool in
                        if film.name == localFilm.name {
                            
                            if film.name == "MXPlayercontent.mov" || film.name == "MXPlayer.mp4" {
                                film.fileUrl = Bundle.main.url(forResource: film.name, withExtension: nil)!.absoluteString
                            }else{
                                
                                film.fileUrl = (Bundle.init(path: FILEPATH)!.url(forResource: file, withExtension: nil)?.absoluteString)!
                            }
                            return true
                        }
                        return false
                    }) {
                        //加密不包含
                        if !self.secretFilm.contains(where: { (film : Film) -> Bool in
                            if film.name == localFilm.name {
                               
                                if film.name == "MXPlayercontent.mov" || film.name == "MXPlayer.mp4" {
                                    film.fileUrl = Bundle.main.url(forResource: film.name, withExtension: nil)!.absoluteString
                                }else{
                                    film.fileUrl = (Bundle.init(path: FILEPATH)!.url(forResource: file, withExtension: nil)?.absoluteString)!
                                }
                                return true
                            }
                            return false
                        }) {
                            //新的电影
                            //判断是否是已经存在的，还是新添加的
                            var isContains = false
                            
                            for haveFilm in self.willReadingFilm {
                                if haveFilm.name == localFilm.name {
                                    isContains = true
                                }
                            }
                            if !isContains {
                                
                                self.willReadingFilm.append(localFilm)
                                //保存到数据库
                                operationDataBase(film: localFilm, type: .insert)
                            }
                        }
                    }
                }
            }
            
        }catch{
            print("加载本地失败")
            SVProgressHUD.showError(withStatus: "加载失败")
        }
    }
    
    //分类，目前不需要这个方法
    fileprivate func categoryFilms(){
        
    }
}
