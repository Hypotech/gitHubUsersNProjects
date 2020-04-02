//
//  UserDetailsVC.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 01/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class UsersListVC: UIViewController {
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    private let loadingIndicator: UIActivityIndicatorView = {
       let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()

    private let disposeBag = DisposeBag()
    private var viewModel = UsersListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GitHub Searcher"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.searchTextField.delegate = self
        searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged().filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] searchTerm in
                self?.loadingIndicator.startAnimating()
                
                self?.viewModel.searchUsersWith(searchTerm: searchTerm) {
                    self?.tableView.reloadData()
                    self?.loadingIndicator.stopAnimating()
                }
            }).disposed(by: disposeBag)
        
        self.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loadingIndicator.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            loadingIndicator.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
}

//MARK: - UITableViewDelegate
extension UsersListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCellID",
                                                 for: indexPath) as! UserListTableViewCell
        cell.configure(with: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userDetailsViewModel = viewModel.userDetailsViewModel(at: indexPath.row)

        let userDetailsVC = storyboard?.instantiateViewController(identifier: "UserDetailsVCID") as! UserDetailsVC
        userDetailsVC.viewModel = userDetailsViewModel
        
        self.navigationController?.pushViewController(userDetailsVC, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension UsersListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
}

//MARK: - UITextFieldDelegate
extension UsersListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
