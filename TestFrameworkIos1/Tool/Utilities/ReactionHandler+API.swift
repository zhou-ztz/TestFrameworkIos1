//
// Created by Francis Yeap on 10/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

extension ReactionHandler {
    func postReaction() {
        guard apiInProgress == false else { return }
        
        apiInProgress = true
        let newReaction: ReactionTypes? = didSelectIcon == nil ? nil : reactions[didSelectIcon!]
        let operation = ReactionUpdateOperation(feedId: feedId, feedItem: feedItem, currentReaction: currentReaction, nextReaction: newReaction)

        operation.onSuccess = { [weak self] (message) in
            self?.onSuccess?(message)
        }

        operation.onError = { [weak self] (fallback, message) in
            self?.onError?(fallback, message)
        }

        backgroundOperationQueue.addOperation(operation)
        operation.completionBlock = { [weak self] in
            self?.apiInProgress = false
        }
    }
}


class TouchAbsorbingView: UIView {
    
    var onTouchInside: EmptyClosure?
    
    private let tapgesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
        
    private func commonInit() {
        self.addGestureRecognizer(tapgesture)
        tapgesture.addActionBlock { [weak self] (_) in
            self?.onTouchInside?()
        }
    }
    
}
