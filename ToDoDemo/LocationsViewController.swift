//
//  LocationsViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/20.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationsViewControllerDelegate: class{
    func controller(_ controller: LocationsViewController,
        didSelectLocation location: CLLocation)
}


class LocationsViewController: UITableViewController {

    var currentLocation: CLLocation?
    var favourites = UserDefaults.loadLocations()
    var delegate: LocationsViewControllerDelegate?

    private let segueAddLocation = "SegueAddLocationView"
    
    private var hasFavourites: Bool {
        return favourites.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case segueAddLocation:
            guard let destination = segue.destination as? AddLocationViewController else {
                fatalError("Invalid destination view controller!")
            }
            destination.delegate = self
        default:
            break
        }
    }
    
    @IBAction func addLocationAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueAddLocation, sender: self)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let section = Section(rawValue: section) else {
            fatalError("Unexpected Section")
        }

        switch section {
        case .current:
            return 1
        case .favourite:
            return max(favourites.count, 1)
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            fatalError("Unexpected Section")
        }

        return section.title
    }
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected section")
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationTableViewCell.reuseIdentifier,
            for: indexPath) as? LocationTableViewCell else {
            fatalError("Unexpected table view cell")
        }

        var vm: LocationsViewModel?

        switch section {
        case .current:
            if let currentLocation = currentLocation {
                vm = LocationsViewModel(
                    location: currentLocation,
                    locationText: nil)
            }
            else {
                cell.label.text = "Current Location Unknown"
            }
        case .favourite:
            if favourites.count > 0 {
                let fav = favourites[indexPath.row]
                vm = LocationsViewModel(
                    location: fav.location,
                    locationText: fav.name)
            }
            else {
                cell.label.text = "No Favourites Yet..."
            }
        }

        if let vm = vm {
            cell.configure(with: vm)
        }

        return cell
    }

    
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unexpected Section") }

        switch section {
        case .current:
            return false
        case .favourite:
            return hasFavourites
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        let location = favourites[indexPath.row]
        UserDefaults.removeLocation(location)

        favourites.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected Section")
        }

        var location: CLLocation?

        switch (section) {
        case .current:
            if let currentLocation = currentLocation {
                location = currentLocation
            }
        case .favourite:
            if hasFavourites {
                location = favourites[indexPath.row].location
            }
        }

        if location != nil {
            delegate?.controller(self, didSelectLocation: location!)
            dismiss(animated: true)
        }
    }
    
    @IBAction func unwindToLocationsViewController(
    segue: UIStoryboardSegue) {}
    
    
}

extension LocationsViewController {
    private enum Section: Int {
        case current
        case favourite

        var title: String {
            switch self {
            case .current:
                return "Current Location"
            case .favourite:
                return "Favourite Locations"
            }
        }

        static var count: Int {
            return Section.favourite.rawValue + 1
        }
    }
}

// In LocationsViewController.swift
extension LocationsViewController:
    AddLocationViewControllerDelegate {
    func controller(_ controller: AddLocationViewController,
        didAddLocation location: Location) {
        // Update User Defaults
        UserDefaults.addLocation(location)

        // Update Locations
        favourites.append(location)

        // Update Table View
        tableView.reloadData()
    }
}
