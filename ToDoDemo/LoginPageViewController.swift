//
//  LoginPageViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/22.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginPageViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!

    @IBOutlet weak var doSomethingOutlet: UIButton!

    @IBOutlet weak var icon: UIImageView!
    
    let minimalUsernameLength = 6
    let minimalPasswordLength = 6
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        usernameValidOutlet.text = "Username has to be at least \(minimalUsernameLength) characters"
        passwordValidOutlet.text = "Password has to be at least \(minimalPasswordLength) characters"

        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map { $0.count >= self.minimalUsernameLength }
            .share(replay: 1)

        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.count >= self.minimalPasswordLength }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(
              usernameValid,
              passwordValid
            ) { $0 && $1 }
            .share(replay: 1)

        usernameValid
            .bind(to: passwordOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        usernameValid
            .bind(to: usernameValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        passwordValid
            .bind(to: passwordValidOutlet.rx.isHidden)
            .disposed(by: disposeBag)

        everythingValid
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: disposeBag)

        doSomethingOutlet.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert() })
            .disposed(by: disposeBag)
    }
    /// Description init UI
    func initUI() {
        icon.backgroundColor = UIColor.systemBlue
        doSomethingOutlet.backgroundColor = UIColor.systemBlue
        doSomethingOutlet.layer.cornerRadius = 5.0

        // left UIview
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        leftView.backgroundColor = UIColor.clear
        /// UITextField left image
        let userImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        userImageView.image = UIImage(named: "userName")
        userImageView.backgroundColor = UIColor.systemBlue
        leftView.addSubview(userImageView)
        usernameOutlet.leftView = leftView
        usernameOutlet.leftViewMode = .always

        // left UIview
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        leftView1.backgroundColor = UIColor.clear
        let passwordImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        passwordImageView.image = UIImage(named: "password")
        passwordImageView.backgroundColor = UIColor.systemBlue
        leftView1.addSubview(passwordImageView)
        passwordOutlet.leftView = leftView1
        passwordOutlet.leftViewMode = .always
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "x_loginPage"), style: .done, target: self, action: #selector(doneAction))
    }

    @objc private func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert() {
        let alertView = UIAlertView(
            title: "RxExample",
            message: "This is wonderful",
            delegate: nil,
            cancelButtonTitle: "OK"
        )

        alertView.show()
    }
}

