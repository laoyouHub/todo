//
//  AddLocationViewController.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/20.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddLocationViewControllerDelegate: class {
    func controller(
        _ controller: AddLocationViewController,
        didAddLocation location: Location)
}

class AddLocationViewController: UITableViewController {
    
    var viewModel: AddLocationViewModel!
    
    @IBOutlet weak var searchBar: UISearchBar!

    var delegate: AddLocationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add a location"
        viewModel = AddLocationViewModel()
        
        viewModel.locationsDidChange = {
            [unowned self] locations in
            self.tableView.reloadData()
        }

        viewModel.queryingStatusDidChange = {
            [unowned self] isQuerying in
            if isQuerying {
                self.title = "Searching..."
            }
            else {
                self.title = "Add a location"
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show Keyboard
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
    }
    
}

extension AddLocationViewController {
    // MARK: - Table view data source

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLocations
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationTableViewCell.reuseIdentifier,
            for: indexPath) as? LocationTableViewCell else {
                fatalError("Unexpected table view cell")
            }

        if let viewModel = viewModel.locationViewModel(
            at: indexPath.row) {
            cell.configure(with: viewModel)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        guard let location =
            viewModel.location(at: indexPath.row) else { return }

        delegate?.controller(self, didAddLocation: location)

        navigationController?.popViewController(animated: true)
    }
}


extension AddLocationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(
        _ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.queryText = searchBar.text ?? ""
    }

    func searchBarCancelButtonClicked(
        _ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.queryText = searchBar.text ?? ""
    }
}
