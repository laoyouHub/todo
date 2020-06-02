//
//  CLLocationManager+Rx.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/21.
//  Copyright © 2020 Mars. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

class CLLocationManagerDelegateProxy:
    DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType,
CLLocationManagerDelegate{
    weak private(set) var locationManager: CLLocationManager?

    init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager,
            delegateProxy: CLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { CLLocationManagerDelegateProxy(locationManager: $0) }
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: CLLocationManagerDelegateProxy {
        return CLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        let sel = #selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))

        return delegate.methodInvoked(sel).map {
            parameters in parameters[1] as! [CLLocation]
        }
    }
}

/*
    扩展CoreLocation
    实话说，搞清楚RxCocoa处理UIKit delegate的机制略显复杂。简单来说，就是它设置了一个delegate proxy，这个proxy可以替我们从原生delegate获取数据，然后变成Observables供我们使用。而我们要做的，就是自己为CLLocationManager定义一个这样的proxy，然后注册到RxCocoa就行了。这个过程要比理解这个机制的细节，简单多了。大体上说，分成三步。

    首先，在Extensions group中，添加一个CLLocationManager+Rx.swift文件，这也是符合RxCocoa命名约定的做法；

    其次，我们要告诉RxCocoa，CLLocationManager是一个有delegate的类型，这是让它遵从HasDelegate实现的。HasDelegate是RxCocoa定义的一个protocol，它有两个约束，一个是Delegate，表示原生delegate的类型，这里，当然就是CLLocationManagerDelegate：
 */
