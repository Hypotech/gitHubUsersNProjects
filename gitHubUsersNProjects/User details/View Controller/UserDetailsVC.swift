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

final class UserDetailsVC: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var joinDateLabel: UILabel!
    @IBOutlet private var followersLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    
    var viewModel: UserDetailsViewModel?
    
    private var disposeBag = DisposeBag()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GitHub Searcher"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: tableView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            activityIndicator.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            activityIndicator.rightAnchor.constraint(equalTo: tableView.rightAnchor)
        ])

        searchBar.searchTextField.delegate = self
        
        searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] (searchTerm) in
                self?.viewModel?.filterRepositories(by: searchTerm)
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        
        configureWithViewModel()
    }
    
    private func configureWithViewModel() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.delegate = self
        
        activityIndicator.startAnimating()
        viewModel.fetchRepositories { [weak self] in
            self?.activityIndicator.stopAnimating()
        }

        viewModel.avatarImage.asObservable().subscribe(onNext: {
            self.avatarImageView.image = $0
        }).disposed(by: disposeBag)

        viewModel.username.asObservable().subscribe(onNext: {
            self.usernameLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.email.asObservable().subscribe(onNext: {
            self.emailLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.location.asObservable().subscribe(onNext: {
            self.locationLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.joinDate.asObservable().subscribe(onNext: {
            self.joinDateLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.followers.asObservable().subscribe(onNext: {
            self.followersLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.following.asObservable().subscribe(onNext: {
            self.followingLabel.text = $0
        }).disposed(by: disposeBag)
    }
}

//MARK: - UITableViewDataSource
extension UserDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.numberOfRows) ?? 0
    }
}

//MARK: - UITableViewDelegate
extension UserDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel!.cellViewModel(at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsCellID",
                                                 for: indexPath) as! RepoTableViewCell
        cell.configureWith(viewModel: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel!.cellViewModel(at: indexPath.row)
        guard let url = cellViewModel.url else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: - UserDetailsViewModelDelegate
extension UserDetailsVC: UserDetailsViewModelDelegate {
    func reloadTableView() {
        tableView.reloadData()
    }
}

//MARK: - UITextFieldDelegate
extension UserDetailsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
