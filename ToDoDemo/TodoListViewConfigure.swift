//
//  TodoListViewConfigure.swift
//  TodoDemo
//
//  Created by Mars on 24/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift

let CELL_CHECKMARK_TAG = 1001
let CELL_TODO_TITLE_TAG = 1002

enum SaveTodoError:Error {
    case canNotSaveToLocalFile
    case cannotCreateFileOnCloud
    case iCloudIsNotEnabled
    case cannotReadLocalFile
}

extension TodoListViewController {
    func configureStatus(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_CHECKMARK_TAG) as! UILabel
        
        if item.isFinished {
            label.text = "✓"
        }
        else {
            label.text = ""
        }
    }
    
    func configureLabel(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_TODO_TITLE_TAG) as! UILabel
        
        label.text = item.name
    }
    
    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
    
    func saveTodoItems() -> Observable<Void> {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(todoitems.value, forKey: "TodoItems")
        archiver.finishEncoding()
        /// 这个是会失败的;失败的时候会返回false
        /// 为了在保存按钮的@IBAction中处理这个问题，我们让saveTodoItems返回一个Observable<Void>
//        data.write(to: dataFilePath(), atomically: true)
        
        return Observable.create({ observer in
            let result = data.write(
                to: self.dataFilePath(), atomically: true)

            if !result {
                observer.onError(SaveTodoError.canNotSaveToLocalFile)
            }
            else {
                observer.onCompleted()
            }

            return Disposables.create()
        })
        /// 思考：为什么在create的closure参数中无需使用[weak self]呢？
    }
    
    func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoitems.accept(unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem])
            
            unarchiver.finishDecoding()
        }
    }
    
    func ubiquityURL(_ filename: String) -> URL? {
        let ubiquityURL =
            FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        if ubiquityURL != nil {
            return ubiquityURL!.appendingPathComponent("filename")
        }
        
        return nil
    }
    /// 同步到iCloud
    func syncTodoToCloud() -> Observable<URL> {

        return Observable.create({ observer in
            
            guard let cloudUrl = self.ubiquityURL("Documents/TodoList.plist") else {
                self.flash(title: "Failed",
                        message: "You should enabled iCloud in Settings first.")

                observer.onError(SaveTodoError.iCloudIsNotEnabled)
                return Disposables.create()
            }
            
            guard let localData = NSData(contentsOf: self.dataFilePath()) else {
                self.flash(title: "Failed",
                        message: "Cannot read local file.")

                observer.onError(SaveTodoError.cannotReadLocalFile)
                return Disposables.create()
            }
            
            let plist = PlistDocument(fileURL: cloudUrl, data: localData)
            
            plist.save(to: cloudUrl, for: .forOverwriting,
                completionHandler: { (success: Bool) -> Void in

                if success {
                    observer.onNext(cloudUrl)
                    /// 要特别强调的是：onCompleted对于自定义Observable非常重要，通常我们要在onNext之后，自动跟一个onCompleted，以确保Observable资源可以正确回收。
                    observer.onCompleted()
                } else {
                    observer.onError(SaveTodoError.cannotCreateFileOnCloud)
                }
            })

            return Disposables.create()
        })
    }
}
