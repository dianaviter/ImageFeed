//
//  ImagesListDataSource.swift
//  ImageFeed
//
//  Created by Diana Viter on 19.03.2025.
//

import UIKit

final class ImagesListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let presenter: ImagesListPresenterProtocol
    weak var viewController: ImagesListViewController?

    init(presenter: ImagesListPresenterProtocol, viewController: ImagesListViewController) {
        self.presenter = presenter
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            fatalError("Unable to dequeue ImagesListCell")
        }

        let photo = presenter.photo(at: indexPath.row)
        cell.delegate = presenter.view
        cell.configure(with: photo, dateFormatter: presenter.displayDateFormatter)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.cellHeight(for: tableView.bounds.width, at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewController?.performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.loadMorePhotosIfNeeded(currentIndex: indexPath.row)
    }
}
