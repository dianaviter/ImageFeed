//
// ProfilePresenter.swift
//  ImageFeed
//
//  Created by Diana Viter on 17.03.2025.
//

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func viewDidLayoutSubviews()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: (any ProfileViewControllerProtocol)?
    
    func viewDidLoad() {
        <#code#>
    }
    
    func viewDidLayoutSubviews() {
        <#code#>
    }
    
    func didTapLogout() {
        <#code#>
    }
}
