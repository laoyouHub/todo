//
//  RxCocoaViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/22.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RxCocoaViewController: UIViewController {

    let disposebag = DisposeBag()
    
    let scroller = UIScrollView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.backgroundColor = UIColor.systemRed
        button.center = view.center
        view.addSubview(button)
        
        
        
        button.rx.tap.subscribe { (event) in
            print("\(event)")
            self.goToLoginPage()
        }.disposed(by: disposebag)
        
        
    }
    
    private func goToLoginPage() {
        let loginPage = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        loginPage.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(loginPage, animated: true)
        
    }
}
