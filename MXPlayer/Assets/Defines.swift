//
//  Defines.swift
//  MXPlayer
//
//  Created by mx on 2017/1/30.
//  Copyright © 2017年 mengx. All rights reserved.
//

import Foundation

let MXPlayerFilmsRefresh = "MXPlayerFilmsRefresh"

func operationDataBase(film : Film,type : MXDataBaseOperationType){
    //操作数据库
    switch type {
        case .delete:
            
            Film.deleteFilm(films: [film], completion: { (isSuccess : Bool) in
                //删除本地
                //如果是测试文件，直接删除
                if film.name == "MXPlayercontent.mov" {
                    return
                }
                
                DispatchQueue.global().async {
                    do{
                        if film.name == "MXPlayercontent.mov" || film.name == "MXPlayer.mp4" {
                            try FileManager.default.removeItem(at:Bundle.main.url(forResource: film.name, withExtension: nil)!)
                        }else{
                            try FileManager.default.removeItem(at: Bundle.init(path: FILEPATH)!.url(forResource: film.name, withExtension: nil)!)
                        }
                    }catch{
                        mxErrorPrint(message: "\(error)")
                        SVProgressHUD.showError(withStatus: "删除本地文件失败")
                    }
                    
                }
            })
            break
            
        case .insert:
            
            Film.addFilm(film: film)
            break
            
        case .updateSeeingTime:
            Film.updateSeeingTime(name: film.name, time: film.seeingTime)
            break
            
        case .updateSecret:
            Film.updateSecret(name: film.name,secret : film.secret)
            break
        default:
            //select
            break
        }
    
}
func mxErrorPrint(message : String,isAssert : Bool = false) {
    if isAssert {
        assert(true, message)
    }else{
        print("*****\nerror is \(message)\n******")
    }
}
//多处用到匹配
func isWhiteSpace(operation : String)->Bool{
    let whiteSpace = CharacterSet.whitespaces
    
    return operation.trimmingCharacters(in: whiteSpace) == ""
}

//当前应用代理
let mxDelegate = UIApplication.shared.delegate as! AppDelegate

//FMDB不会创建文件夹，需要手动创建
let FILEPATH =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!

let DBPATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!.appending("/mxplayer.db")

let MXFILMCELL = "MXFilmCell"

let MXFILMSELETEDCELL = "MXFilmSeletedCell"

typealias MXFilmcompletion = (_ isSuccess : Bool) -> Void

typealias MXFilmReturnBack = (_ isSuccess : Bool,_ films : FMResultSet?)->Void
