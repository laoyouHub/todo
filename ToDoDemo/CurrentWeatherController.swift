//
//  CurrentWeatherController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import RxRelay
import RxSwift
/*
    为了实现这个在当前controller中触发，在其它controller中执行代码的效果。我们可以借助delegate完成
 */
protocol CurrentWeatherViewControllerDelegate: class {
    func locationButtonPressed(
        controller: CurrentWeatherController)
    func settingsButtonPressed(
        controller: CurrentWeatherController)
}

class CurrentWeatherController: WeatherViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var retryBtn: UIButton!
    
    weak var delegate: CurrentWeatherViewControllerDelegate?
    
    private var bag = DisposeBag()

    // 如同BehaviorSubject一样，我们需要在创建的时候，给这个事件序列创建一个初始值
    var weatherVM: BehaviorRelay<CurrentWeatherViewModel> =
        BehaviorRelay(value: CurrentWeatherViewModel.empty)
    var locationVM: BehaviorRelay<CurrentLocationViewModel> =
        BehaviorRelay(value: CurrentLocationViewModel.empty)
    
//    var viewModel: CurrentWeatherViewModel? {
//        didSet {
//            DispatchQueue.main.async { self.updateView() }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 我们合并出一个包含weatherVM和locationVM事件值的Observable

        let combined = Observable
        .combineLatest(locationVM, weatherVM) { ($0, $1) }
        .share(replay: 1, scope: .whileConnected)
        
        // 处理正常的数据
        let viewModel = combined.filter {
            self.shouldDisplayWeatherContainer(
                locationVM: $0.0, weatherVM: $0.1)
        }.asDriver(onErrorJustReturn: (.empty, .empty))
        
//        let viewModel = Observable.combineLatest(locationVM, weatherVM) {
//            return ($0, $1)
//        }
//        .filter {
//            let (location, weather) = $0
//            // 筛选一下过滤的结果，要求它们的事件值都不为“空”
//            return !(location.isEmpty) && !(weather.isEmpty)
//        }
//        .share(replay: 1, scope: .whileConnected)
        /*
             什么是Driver呢？简单来说，它就是一个定制过的Observable，拥有下面的特性：
             确保在主线程中订阅，这样也就保证了事件发生后的订阅代码也一定会在主线程中执行；
             不会发生.error事件，我们无需在“订阅”一个Driver的时候，想着处理错误事件的情况。正是由于这个约束，
             asDriver方法有一个onErrorJustReturn参数，要求我们指定发生错误的生成的事件。这里，我们返回了(CurrentLocationViewModel.empty, CurrentWeatherViewModel.empty)，于是，在任何情况，我们都可以用统一的代码来处理用户交互了；
             */
            
//        .asDriver(onErrorJustReturn:
//        (CurrentLocationViewModel.empty,
//        CurrentWeatherViewModel.empty))
            /*
                确保订阅者在主线程上执行代码。因为稍后我们就会看到，
                位置和天气数据，都不是在主线程中获得的，这就导致了，默认情况下，订阅这个Observable的代码，
                也不会在主线程中执行，进而，我们更新UI的代码就会发生问题
             */
//        .observeOn(MainScheduler.instance) // 指定主线程
        // 写到这里，我们就可以确信了，只要订阅到事件，我们就可以安全的使用事件值来更新UI了
//        .subscribe(onNext: { [unowned self] in
//                let (location, weather) = $0
//
//                self.weatherContainerView.isHidden = false
//                self.locationLabel.text = location.city
//
//                self.temperatureLabel.text = weather.temperature
//                self.weatherIcon.image = weather.weatherIcon
//                self.humidityLabel.text = weather.humidity
//                self.summaryLabel.text = weather.summary
//                self.dateLabel.text = weather.date
//        }).disposed(by: bag)

        viewModel.map { _ in false }
            .drive(self.activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
        viewModel.map { _ in false }
            .drive(self.weatherContainerView.rx.isHidden)
            .disposed(by: bag)

        viewModel.map { $0.0.city }
            .drive(self.locationLabel.rx.text)
            .disposed(by: bag)

        viewModel.map { $0.1.temperature }
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: bag)
        viewModel.map { $0.1.weatherIcon }
            .drive(self.weatherIcon.rx.image)
            .disposed(by: bag)
        viewModel.map { $0.1.humidity }
            .drive(self.humidityLabel.rx.text)
            .disposed(by: bag)
        viewModel.map { $0.1.summary }
            .drive(self.summaryLabel.rx.text)
            .disposed(by: bag)
        viewModel.map { $0.1.date }
            .drive(self.dateLabel.rx.text)
            .disposed(by: bag)
        
        combined.map {
            self.shouldHideWeatherContainer(
                locationVM: $0.0, weatherVM: $0.1)
        }
        .asDriver(onErrorJustReturn: true)
        .drive(self.weatherContainerView.rx.isHidden)
        .disposed(by: bag)
        
        combined.map {
            self.shouldHideActivityIndicator(
                locationVM: $0.0, weatherVM: $0.1)
        }
        .asDriver(onErrorJustReturn: false)
        .drive(self.activityIndicatorView.rx.isHidden)
        .disposed(by: bag)
        
        combined.map {
            self.shouldAnimateActivityIndicator(locationVM: $0.0, weatherVM: $0.1)
        }
        .asDriver(onErrorJustReturn: true)
        .drive(self.activityIndicatorView.rx.isAnimating)
        .disposed(by: bag)
        
        
        let errorCond = combined.map {
            self.shouldDisplayErrorPrompt(locationVM: $0.0, weatherVM: $0.1)
        }.asDriver(onErrorJustReturn: true)

        errorCond.map { !$0 }
            .drive(self.retryBtn.rx.isHidden)
            .disposed(by: bag)
        errorCond.map { !$0 }
            .drive(self.loadingFailedLabel.rx.isHidden)
            .disposed(by: bag)
        errorCond.map { _ in return String.ok }
            .drive(self.loadingFailedLabel.rx.text)
            .disposed(by: bag)
        
        self.retryBtn.rx.tap.subscribe(onNext: { _ in
            self.weatherVM.accept(.empty)
            self.locationVM.accept(.empty)

            (self.parent as? RootViewController)?.fetchCity()
            (self.parent as? RootViewController)?.fetchWeather()
        }).disposed(by: bag)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        delegate?.locationButtonPressed(controller: self)
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        delegate?.settingsButtonPressed(controller: self)
    }

}
//MARK:-
extension CurrentWeatherController {
    func updateView() {
        
        weatherVM.accept(weatherVM.value)
        locationVM.accept(locationVM.value)
        
//        activityIndicatorView.stopAnimating()
//
//        // Update UI from view model
//        if let vm = viewModel, vm.isUpdateReady {
//            updateWeatherContainer(with: vm)
//        }
//        else {
//            loadingFailedLabel.isHidden = false
//            loadingFailedLabel.text =
//                "Load weather/location failed."
//        }
    }
    
//    func updateWeatherContainer(
//        with vm: CurrentWeatherViewModel) {
//        weatherContainerView.isHidden = false
//
//        locationLabel.text = vm.city
//        temperatureLabel.text = vm.temperature
//        weatherIcon.image = vm.weatherIcon
//        humidityLabel.text = vm.humidity
//        summaryLabel.text = vm.summary
//        dateLabel.text = vm.date
//    }
    
    
    
}
fileprivate extension CurrentWeatherController {
    func shouldDisplayWeatherContainer(
        locationVM: CurrentLocationViewModel,
        weatherVM: CurrentWeatherViewModel) -> Bool {
        return !locationVM.isEmpty &&
            !locationVM.isInvalid &&
            !weatherVM.isEmpty &&
            !weatherVM.isInvalid
    }
    
    func shouldHideWeatherContainer(
        locationVM: CurrentLocationViewModel,
        weatherVM: CurrentWeatherViewModel) -> Bool {
        return locationVM.isEmpty ||
            locationVM.isInvalid ||
            weatherVM.isEmpty ||
            weatherVM.isInvalid
    }
    
    func shouldHideActivityIndicator(
        locationVM: CurrentLocationViewModel,
        weatherVM: CurrentWeatherViewModel) -> Bool {
        return (!locationVM.isEmpty && !weatherVM.isEmpty) ||
            locationVM.isInvalid ||
            weatherVM.isInvalid
    }
    
    func shouldAnimateActivityIndicator(
        locationVM: CurrentLocationViewModel,
        weatherVM: CurrentWeatherViewModel) -> Bool {
        return locationVM.isEmpty || weatherVM.isEmpty
    }
    
    func shouldDisplayErrorPrompt(
        locationVM: CurrentLocationViewModel,
        weatherVM: CurrentWeatherViewModel) -> Bool {
        return locationVM.isInvalid || weatherVM.isInvalid
    }
}


extension String {
    
    static let ok = "ok"
    
}
