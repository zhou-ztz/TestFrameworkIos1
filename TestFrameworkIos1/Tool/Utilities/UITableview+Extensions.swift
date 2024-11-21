//
//  UITableview+Extensions.swift
//  Yippi
//
//  Created by Kit Foong on 18/05/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
        { _ in completion() }
    }
    
    func reloadRows(indexPaths: [IndexPath], completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadRows(at: indexPaths, with: .none)
        }) { _ in completion() }
    }
    
    func scrollToRow(indexPath: IndexPath, position: UITableView.ScrollPosition, animated: Bool = false, completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.scrollToRow(at: indexPath, at: position, animated: animated)
        }) { _ in completion() }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func reloadDataWithoutScroll() {
        let offset = contentOffset
        reloadData()
        layoutIfNeeded()
        setContentOffset(offset, animated: false)
    }
    
    //Variable-height UITableView tableHeaderView with autolayout
    func layoutTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerWidth = headerView.bounds.size.width
        let temporaryWidthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
        
        headerView.addConstraint(temporaryWidthConstraint)
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
        
        frame.size.height = height
        headerView.frame = frame
        
        self.tableHeaderView = headerView
        
        headerView.removeConstraint(temporaryWidthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }
}

