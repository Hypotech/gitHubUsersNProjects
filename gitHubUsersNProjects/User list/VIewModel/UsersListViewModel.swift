//
//  UserDetailsViewModel.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 01/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation
import Alamofire

final class UsersListViewModel {
    var numberOfRows: Int {
        return logins.count
    }
    
    private var logins = [String]()
    private var cellViewModels = [UserListTableViewCellViewModel]()
    private var users = [GitHubUser]()
    private var userDetailsViewModels = [UserDetailsViewModel]()
    
    func searchUsersWith(searchTerm: String, completionHandler: @escaping (() -> Void)) {
        let url = "https://api.github.com/search/users?q=\(searchTerm)"
        let function = #function
        
        AF.request(url).responseJSON {[weak self] (response) in
            guard let self = self else {
                return
            }

            guard response.error == nil else {
                print("Error fetching logins from API service in \(function)")
                return
            }
            
            func showErrorConvertingResposeToJson() {
                print("Error converting response to JSON in \(function)")
            }
            
            do {
                guard let jsonDictionary = try response.result.get() as? [String: Any],
                      let items = jsonDictionary["items"] as? [[String: Any]] else {
                    showErrorConvertingResposeToJson()
                    return
                }
                
                self.logins = items.map {
                    return $0["login"] as! String
                }
            }
            catch {
                showErrorConvertingResposeToJson()
            }
            
            completionHandler()
        }
    }
    
    func cellViewModel(at index: Int) -> UserListTableViewCellViewModel {
        guard cellViewModels.isEmpty ||
              !(cellViewModels.startIndex..<cellViewModels.endIndex).contains(index) else {
            return cellViewModels[index]
        }
                
        let cellViewModel = UserListTableViewCellViewModel()
        cellViewModels.append(cellViewModel)
        
        fetchUser(at: index)
        
        return cellViewModel
    }
    
    func userDetailsViewModel(at index: Int) -> UserDetailsViewModel {
        guard userDetailsViewModels.isEmpty ||
              !(userDetailsViewModels.startIndex..<userDetailsViewModels.endIndex).contains(index) else {
            return userDetailsViewModels[index]
        }

        let userDetailsViewModel = UserDetailsViewModel()
        
        userDetailsViewModels.append(userDetailsViewModel)
        
        return userDetailsViewModel
    }
    
    private func fetchUser(at index: Int) {
        let login = logins[index]
        let url = "https://api.github.com/users/\(login)"
        let function = #function
        
        AF.request(url).responseJSON {[weak self] (response) in
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
                guard let jsonDictionary = try response.result.get() as? [String: Any] else {
                    showErrorConvertingResposeToJson()
                    return
                }
                
                guard jsonDictionary["message"] == nil else {
                    return
                }
                                
                let user = GitHubUser(dictionary: jsonDictionary)
                self.users.append(user)
                
                let cellViewModel = self.cellViewModels[index]
                cellViewModel.configureWith(user: user)

                guard self.userDetailsViewModels.isEmpty ||
                      !(self.userDetailsViewModels.startIndex..<self.userDetailsViewModels.endIndex).contains(index) else {
                    let userDetailsViewModel = self.userDetailsViewModels[index]
                    userDetailsViewModel.configureWith(user: user)
                    return
                }

                let userDetailsViewModel = UserDetailsViewModel()
                userDetailsViewModel.configureWith(user: user)
                
                self.userDetailsViewModels.append(userDetailsViewModel)
            }
            catch {
                showErrorConvertingResposeToJson()
            }
        }
    }
}

