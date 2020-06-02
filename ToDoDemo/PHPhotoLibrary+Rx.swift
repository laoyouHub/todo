//
// Created by Mars on 26/05/2017.
// Copyright (c) 2017 Mars. All rights reserved.
//

import Foundation
import Photos
import RxSwift
/*
    用到了PHPhotoLibrary的两个API：

    authorizationStatus获取当前授权状态；
    requestAuthorization申请用户授权；
    至于为什么要把通知observer的代码放在DispatchQueue.main.async里，是为了避免在自定义的事件序列中影响其它Observable的订阅，
    甚至是把整个UI卡住。理解了这些之后，上面的代码就很好理解了，就是之前那个事件流的代码表示。接下来，我们只要订阅这个Observable就好了。
 */
extension PHPhotoLibrary {
    static var isAuthorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    requestAuthorization {
                        observer.onNext($0 == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
/*
    订阅用户的授权结果
    订阅的部分，应该写在PhotoCollectionViewController.viewDidLoad方法里。先别着急，这个过程要比我们想象的复杂一点，我们不能直接订阅isAuthorized的onNext并处理true/false的情况，因为单一的事件值并不能反映真实的授权情况。按照之前分析的：

    授权成功的序列可能是：.next(true)，.completed或.next(false)，.next(true)，.completed；
    授权失败的序列则是：.next(false)，.next(false)，.completed；
    因此，我们需要把isAuthorized这个事件序列处理一下，分别处理授权成功和失败的情况。
 
    订阅成功事件
 
    首先来订阅授权成功事件，我们只要忽略掉事件序列中所有的false，并读到第一个true，就可以认为授权成功了。使用“过滤型”operator可以轻松完成这个任务：
    
 */
