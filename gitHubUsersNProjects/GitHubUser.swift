//
//  GitHubUser.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 01/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation

struct GitHubUser {
    var avatar_url: String?
    var name: String?
    var public_repos: Int?
    
    var location: String?
    var email: String?
    var created_at: String?
    var followers: Int?
    var following: Int?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.public_repos = dictionary["public_repos"] as? Int
        self.avatar_url = dictionary["avatar_url"] as? String
        self.location = dictionary["location"] as? String
        self.email = dictionary["email"] as? String
        self.created_at = dictionary["created_at"] as? String
        self.followers = dictionary["followers"] as? Int
        self.following = dictionary["following"] as? Int
    }
}
