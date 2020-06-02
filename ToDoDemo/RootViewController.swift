//
//  RootViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/15.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift

class RootViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    private let segueCurrentWeather = "SegueCurrentWeather"
    private let segueweekWeather = "SegueWeekWeather"
    private let segueSettings = "SegueSettings"
    private let segueLocations = "SegueLocations"
    
    var currentWeatherViewController: CurrentWeatherController!
    var weekWeatherViewController:WeekWeatherViewController!
    
    
    private var currentLocation: CLLocation? {
        didSet {
            // Fetch the city name
            fetchCity()
            // Fetch the weather data
            fetchWeather()
        }
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 1000
        manager.desiredAccuracy = 1000
        
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupActiveNotification()
        
        requestLocation()
    }
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case segueCurrentWeather:
            guard let destination = segue.destination as? CurrentWeatherController else {
                fatalError("Invalid destination view controller!")
            }
            destination.delegate = self
//            destination.viewModel = CurrentWeatherViewModel()
            currentWeatherViewController = destination
        case segueweekWeather:
            guard let destination = segue.destination as? WeekWeatherViewController else {
                fatalError("Invalid destination view controller!")
            }
            weekWeatherViewController = destination
        case segueSettings:
            guard let navigationController =
                segue.destination as? UINavigationController else {
                    fatalError("Invalid destination view controller!")
            }
            
            guard let destination =
                navigationController.topViewController as?
                SettingsViewController else {
                    fatalError("Invalid destination view controller!")
            }
            
            destination.delegate = self
        case segueLocations:
            guard let navigationController =
                segue.destination as? UINavigationController else {
                    fatalError("Invalid destination view controller!")
            }
            
            guard let destination =
                navigationController.topViewController as?
                LocationsViewController else {
                    fatalError("Invalid destination view controller!")
            }
            
            destination.delegate = self
            destination.currentLocation = currentLocation
        default:
            break
        }
    }
    
    @objc func applicationDidBecomeActive(
        notification: Notification) {
        
        requestLocation()
    }
    
    
}

extension RootViewController: LocationsViewControllerDelegate {
    func controller(_ controller: LocationsViewController,
        didSelectLocation location: CLLocation) {
        self.currentWeatherViewController.weatherVM.accept(.empty)
        self.currentWeatherViewController.locationVM.accept(.empty)
        currentLocation = location
    }
}

extension RootViewController {
    
    private func setupActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                RootViewController.applicationDidBecomeActive(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    private func requestLocation() {
        if CLLocationManager.authorizationStatus()
            == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            self.locationManager
                .rx.didUpdateLocations
                .take(1)
                .subscribe(onNext: {
                    self.currentLocation = $0.first
                }).disposed(by: bag)
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func fetchCity() {
        
        guard let currentLocation = currentLocation else { return }

        CLGeocoder().reverseGeocodeLocation(currentLocation) {
            placemarks, error in
            if let error = error {
                dump(error)
                self.currentWeatherViewController.locationVM.accept(.invalid)
            } else if let city = placemarks?.first?.locality {
                let location = Location(
                name: city,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude)

                self.currentWeatherViewController
                    .locationVM
                    .accept(CurrentLocationViewModel(location: location))
            }
        }
        
//        guard let currentLocation =
//            currentLocation else { return }
//
//        CLGeocoder().reverseGeocodeLocation(currentLocation) {
//            placemarks, error in
//            if let error = error {
//                dump(error)
//            } else if let city = placemarks?.first?.locality {
//                // Todo: Notify CurrentWeatherViewController
//                let location = Location(
//                    name: city,
//                    latitude: currentLocation.coordinate.latitude,
//                    longitude: currentLocation.coordinate.longitude)
//                self.currentWeatherViewController.viewModel?.location = location
//            }
//        }
    }
    
    func fetchWeather() {
        
        guard let currentLocation = currentLocation else { return }

        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        let weather = WeatherDataManager.shared.weatherDataAt(
        latitude: lat, longitude: lon)
        .share(replay: 1, scope: .whileConnected)
        .observeOn(MainScheduler.instance)
        
        weather.map { CurrentWeatherViewModel(weather: $0) }
        .bind(to: self.currentWeatherViewController.weatherVM)
        .disposed(by: bag)
        
        weather.map {
            WeekWeatherViewModel(weatherData: $0.daily.data)
        }
        .subscribe(onNext: {
            self.weekWeatherViewController.viewModel = $0
        })
        .disposed(by: bag)
//        .subscribe(onNext: {
//            self.currentWeatherViewController
//                .weatherVM
//                .accept(CurrentWeatherViewModel(weather: $0))
//            /// ...
//        })
//        .disposed(by: bag)
        
        
//
//        WeatherDataManager.shared.weatherDataAt(
//            latitude: lat,
//            longitude: lon,
//            completion: { response, error in
//                if let error = error {
//                    dump(error)
//                }
//                else if let response = response {
//                    // Todo: Notify CurrentWeatherViewController
//                    self.currentWeatherViewController.viewModel?.weather = response
//                    self.weekWeatherViewController.viewModel =
//                        WeekWeatherViewModel(weatherData: response.daily.data)
//                }
//        })
    }
}

//extension RootViewController: CLLocationManagerDelegate {
//    /// 当权限发生变化的时候，我们只有在.authorizedWhenInUse的时候，才重新请求位置：
//    func locationManager(
//        _ manager: CLLocationManager,
//        didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            manager.requestLocation()
//        }
//    }
//
//    func locationManager(
//        _ manager: CLLocationManager,
//        didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            currentLocation = location
//            manager.delegate = nil
//
//            manager.stopUpdatingLocation()
//        }
//    }
//    /// 当定位发生错误的时候，我们只是简单的把错误dump出来
//    func locationManager(
//        _ manager: CLLocationManager,
//        didFailWithError error: Error) {
//        dump(error)
//    }
//}

extension RootViewController: CurrentWeatherViewControllerDelegate {
    func locationButtonPressed(controller: CurrentWeatherController) {
        print("Open locations.")
        performSegue(withIdentifier: segueLocations, sender: self)
    }
    
    func settingsButtonPressed(controller: CurrentWeatherController) {
        print("Open Settings")
        performSegue(withIdentifier: segueSettings, sender: self)
    }
    
    @IBAction func unwindToRootViewController(
        segue: UIStoryboardSegue) {
    }
}

extension RootViewController: SettingsViewControllerDelegate {
    private func reloadUI() {
        currentWeatherViewController.updateView()
        weekWeatherViewController.updateView()
    }
    
    func controllerDidChangeTimeMode(
        controller: SettingsViewController) {
        reloadUI()
    }
    
    func controllerDidChangeTemperatureMode(
        controller: SettingsViewController) {
        reloadUI()
    }
}
