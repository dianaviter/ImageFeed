//
//  ViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 02.11.2024.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject, ImagesListCellDelegate {
    func reloadData()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet var tableView: UITableView!
    var presenter: ImagesListPresenterProtocol
    var dataSource: ImagesListDataSource?
    
    init(tableView: UITableView!, presenter: ImagesListPresenterProtocol, dataSource: ImagesListDataSource? = nil) {
        self.tableView = tableView
        self.presenter = presenter
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        let defaultPresenter = ImagesListPresenter()
        let defaultDataSource = ImagesListDataSource(presenter: defaultPresenter)

        self.presenter = defaultPresenter
        self.dataSource = defaultDataSource

        super.init(coder: coder)

        self.presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPresenter()
    }

    private func setupTableView() {
        dataSource = ImagesListDataSource(presenter: presenter)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func setupPresenter() {
        presenter.view = self
        presenter.fetchInitialPhotos()
    }

    func reloadData() {
        tableView.reloadData()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter.toggleLike(at: indexPath.row) { _ in 
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}
