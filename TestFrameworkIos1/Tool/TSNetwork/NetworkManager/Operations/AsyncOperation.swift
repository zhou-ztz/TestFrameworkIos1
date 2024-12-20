//
// Created by Francis Yeap on 10/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation

public let backgroundOperationQueue = OperationQueue()

class AsyncOperation: Operation {
    public enum State: String {
        case ready, executing, finished

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}


extension AsyncOperation {

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    override func start() {
        if isCancelled {
            return
        }
        main()
        state = .executing
    }
}
