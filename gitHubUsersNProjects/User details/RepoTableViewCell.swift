//
//  RepoTableViewCell.swift
//  gitHubUsersNProjects
//
//  Created by Christian Hipolito on 01/04/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit

final class RepoCellViewModel {
    private(set) var name: String?
    private(set) var forksCount: String?
    private(set) var starsCount: String?
    private(set) var url: URL?

    init(repository: Repository) {
        name = repository.name
        forksCount = "\(repository.forks_count) forks"
        starsCount = "\(repository.stargazers_count) Stars"
        
        if let urlString = repository.urlString {
            url = URL(string: urlString)
        }
    }
}

class RepoTableViewCell: UITableViewCell{
    @IBOutlet private var repoName: UILabel!
    @IBOutlet private var forks: UILabel!
    @IBOutlet private var starsLabel: UILabel!
    
    func configureWith(viewModel: RepoCellViewModel) {
        repoName.text = viewModel.name
        forks.text = viewModel.forksCount
        starsLabel.text = viewModel.starsCount
    }
}
