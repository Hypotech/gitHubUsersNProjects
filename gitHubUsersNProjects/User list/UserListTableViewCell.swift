//
//  UserDetailsTableViewCell.swift
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

final class UserListTableViewCellViewModel {
    var image = BehaviorRelay<UIImage>(value:  #imageLiteral(resourceName: "gitHubUser.png"))
    var userName = BehaviorRelay<String>(value: "––––––")
    var repoCount = BehaviorRelay<String>(value: "––––––")
            
    func configureWith(user: GitHubUser) {
        if let userName = user.name {
            self.userName.accept(userName)
        }
        
        if let repoCount = user.public_repos {
            let repoCountString = "Repo: \(repoCount)"
            self.repoCount.accept(repoCountString)
        }
                
        if let avatarURL = user.avatar_url {
            AF.request(avatarURL).responseImage { (response) in
                if case let .success(image) = response.result {
                    self.image.accept(image)
                }
            }
        }
    }
}

final class UserListTableViewCell: UITableViewCell {
    @IBOutlet private var userImageView: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var repoNumberLabel: UILabel!
    
    private var viewModel: UserListTableViewCellViewModel?
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        userImageView.image = nil
        userNameLabel.text = nil
        repoNumberLabel.text = nil
        
        disposeBag = DisposeBag()
    }
        
    func configure(with viewModel: UserListTableViewCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.image.asObservable().subscribe(onNext: {
            self.userImageView.image = $0
        }).disposed(by: disposeBag)

        viewModel.userName.asObservable().subscribe(onNext: {
            self.userNameLabel.text = $0
        }).disposed(by: disposeBag)

        viewModel.repoCount.asObservable().subscribe(onNext: {
            self.repoNumberLabel.text = $0
        }).disposed(by: disposeBag)
    }
}
