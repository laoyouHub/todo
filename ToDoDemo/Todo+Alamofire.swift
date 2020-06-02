//
//  Todo+Alamofire.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum ToDoError:Error {
    case CustomError(String) // "Cannot read the Todo list from the server."
}

extension Todo {
    class func getList(from router: TodoRouter)
        -> Observable<[Todo]> {
            return Observable.create {
                (observer) -> Disposable in
                
                let request = AF.request(TodoRouter.get(nil))
                    .response { (response) in
                        /// TODO: Handle request here
                        /// 处理错误
                        /// 是虽然正常收到了服务器的响应，但无法转换成对应的数据类型
                        switch response.result {
                        case .failure(let error):
                            print(error.errorDescription ?? "xxx")
                            observer.on(.error(error))
                        case .success(let data):
                            guard let data = data else {
                                print("Cannot read the Todo list from the server.")
                                observer.on(.error(ToDoError.CustomError("Cannot read the Todo list from the server.")))
                                return
                            }
                            do {
                                let todos = try JSONDecoder().decode([Todo].self, from: data)
                                observer.on(.next(todos))
                                observer.onCompleted()
                            } catch _ {
                                observer.on(.error(ToDoError.CustomError("解析出错.")))
                            }
                        }
                }
                return Disposables.create {
                    request.cancel()
                }
            }
    }
}
