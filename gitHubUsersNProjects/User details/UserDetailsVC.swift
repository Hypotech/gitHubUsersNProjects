//
//  UserDetailsVC.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 01/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RxSwift
import RxCocoa

struct Repository {
    var name: String?
    var forks_count: Int
    var stargazers_count: Int
}

final class UserDetailsViewModel {
    var avatarImage = BehaviorRelay<UIImage>(value:  #imageLiteral(resourceName: "gitHubUser.png"))
    var username = BehaviorRelay<String>(value: "Username: --")
    var email = BehaviorRelay<String>(value: "Email: --")
    var location = BehaviorRelay<String>(value: "Location: --")
    var joinDate = BehaviorRelay<String>(value: "Join Date: --")
    var followers = BehaviorRelay<String>(value: "Followers: --")
    var following = BehaviorRelay<String>(value: "Following: --")
    
    private var repositories = [Repository]()
    
    func configureWith(user: GitHubUser) {
        if let avatarURL = user.avatar_url {
            AF.request(avatarURL).responseImage { (response) in
                if case let .success(image) = response.result {
                    self.avatarImage.accept(image)
                }
            }
        }

        if let userName = user.name {
            self.username.accept("Username: \(userName)")
        }

        if let email = user.email {
            self.email.accept("Email: \(email)")
        }

        if let location = user.location {
            self.location.accept("Location: \(location)")
        }

        if let created_at = user.created_at {
            let joinDateString: String = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                
                guard let date = dateFormatter.date(from: created_at) else {
                    return "Join Date: (Error)"
                }
                
                return dateFormatter.string(from: date)
            }()
            
            self.joinDate.accept(joinDateString)
        }

        if let followers = user.followers {
            self.followers.accept("Followers: \(followers)")
        }

        if let following = user.following {
            self.following.accept("Following: \(following)")
        }
    }
}

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
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GitHub Searcher"        
    }
    
    func configureWith(viewModel: UserDetailsViewModel) {
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
            self.usernameLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.following.asObservable().subscribe(onNext: {
            self.usernameLabel.text = $0
        }).disposed(by: disposeBag)
    }
}
