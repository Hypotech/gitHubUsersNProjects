//
//  UserDetailsViewModel.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 02/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RxSwift
import RxCocoa

struct Repository {
    var name: String?
    var forks_count: Int
    var stargazers_count: Int
    var urlString: String?
    
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String
        forks_count = (dictionary["forks_count"] as? Int) ?? 0
        stargazers_count = (dictionary["stargazers_count"] as? Int) ?? 0
        urlString = dictionary["html_url"] as? String
    }
}

protocol UserDetailsViewModelDelegate: class {
    func reloadTableView()
}

final class UserDetailsViewModel {
    var avatarImage = BehaviorRelay<UIImage>(value:  #imageLiteral(resourceName: "gitHubUser.png"))
    var username = BehaviorRelay<String>(value: "Username: --")
    var email = BehaviorRelay<String>(value: "Email: --")
    var location = BehaviorRelay<String>(value: "Location: --")
    var joinDate = BehaviorRelay<String>(value: "Join Date: --")
    var followers = BehaviorRelay<String>(value: "Followers: --")
    var following = BehaviorRelay<String>(value: "Following: --")
    
    var numberOfRows: Int {
        return filteredRepositories.count
    }
    
    weak var delegate: UserDetailsViewModelDelegate?
    
    private var repositories = [Repository]()
    private var filteredRepositories = [Repository]()
    private let authToken = "fee015c0b6fe841bcda05e4c0b5b4380c3213ee6"
    private var login: String = ""
    
    func configureWith(user: GitHubUser, login: String) {
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
                
                guard let date = dateFormatter.date(from: created_at) else {
                    return "Join Date: (Error)"
                }

                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none

                return "Join Date: " + dateFormatter.string(from: date)
            }()
            
            self.joinDate.accept(joinDateString)
        }

        if let followers = user.followers {
            self.followers.accept("Followers: \(followers)")
        }

        if let following = user.following {
            self.following.accept("Following: \(following)")
        }
        
        self.login = login
    }
    
    func cellViewModel(at index: Int) -> RepoCellViewModel {
        let repository = filteredRepositories[index]
        return RepoCellViewModel(repository: repository)
    }
    
    func fetchRepositories(completion:@escaping (() -> Void)) {
        let url = "https://api.github.com/users/\(login)/repos"
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "token \(authToken)")])
        let function = #function

        AF.request(url, headers: headers).responseJSON {[weak self] (response) in
            defer {
                completion()
            }
            
            guard let self = self else {
                return
            }

            guard response.error == nil else {
                print("Error fetching users from API service in \(function)")
                return
            }
            
            func showErrorConvertingResposeToJson() {
                print("Error converting response to JSON in \(function)")
            }
            
            do {
                guard let jsonArray = try response.result.get() as? [[String: Any]] else {
                    showErrorConvertingResposeToJson()
                    return
                }
                                
                self.repositories = jsonArray.map {
                    Repository(dictionary: $0)
                }
                                
                self.filteredRepositories = self.repositories
                    
                self.delegate?.reloadTableView()
            }
            catch {
                showErrorConvertingResposeToJson()
            }
        }
    }
    
    func filterRepositories(by searchTerm: String) {
        guard !searchTerm.isEmpty else {
            filteredRepositories = repositories
            return
        }
        
        let searchTermLowerCased = searchTerm.lowercased()
        
        self.filteredRepositories = repositories.filter {
            guard $0.name != nil else {
                return false
            }
            
            return $0.name!.lowercased().contains(searchTermLowerCased)
        }
    }
}

