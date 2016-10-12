//
//  CommentViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet var tableSource: CommentTableSource!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let cellClassName = String(describing: CommentTableViewCell.self)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 140
            self.tableView.isScrollEnabled = false
            tableView.register(UINib(nibName: cellClassName, bundle: Bundle.main), forCellReuseIdentifier: cellClassName)
        }
    }
    fileprivate lazy var refreshControl: UIRefreshControl = {
       let control = UIRefreshControl()
        control.tintColor = UIColor(ColorConstants.appBlue)
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    var viewModel: CommentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.getComments()
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
             let swipGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(gesture:)))
            swipGesture.direction = direction
            swipGesture.delegate = self
            tableView.addGestureRecognizer(swipGesture)
        }
        
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(gesture:)))
        tableView.addGestureRecognizer(longPressGesture)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(tapGesture)
        
        refreshControl.beginRefreshing()
    }

    func refresh() {
        viewModel.getComments()
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        viewModel.goToNextTopLevel()
    }
    
    func didLongPress(gesture: UILongPressGestureRecognizer) {
        viewModel.dismiss()
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        viewModel.didSwipe(gesture: gesture)
    }
}

extension CommentViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CommentViewController: CommentDisplayDelegate {
    internal func cellForIndex(indexPath: IndexPath) -> CommentTableViewCell? {
        return tableView.cellForRow(at: indexPath) as? CommentTableViewCell
    }

    internal func scrollTo(indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func display(comments: [Comment]) {
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            UIView.animate(withDuration: 0.3, animations: { 
                self.tableView.alpha = 1
            })
            self.tableSource.comments = comments
            self.tableView.reloadData()
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
