//
//  File.swift
//  Yippi
//
//  Created by francis on 27/12/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import Combine

enum TaskPriority: Int {
    case low = 1
    case normal = 2
    case high = 3
}


protocol QueueTaskProtocol {
    associatedtype T
    var executable: (() -> Future<T, Error>) { get set }
    var priority: TaskPriority { get set }
}

class WorkPoolQueue<T, Queue: QueueTaskProtocol> {
    private(set) var tasks: [Queue] = []
    
    func hasTask() -> Bool {
        return tasks.count > 0
    }
    
    func remainingTaskCount() -> Int {
        return tasks.count
    }
    
    func enqueue(task: Queue) {
        tasks.append(task)
        tasks.sort { (pre, next) -> Bool in
            return pre.priority.rawValue > next.priority.rawValue
        }
    }
    
    func dequeue() -> (() -> Future<Queue.T, Error>)? {
        guard tasks.count > 0 else { return nil }
        
        let task = tasks.removeFirst()
        return task.executable
    }
}

class WorkerPool<T, Queue: QueueTaskProtocol> {
    var cancellables = Set<AnyCancellable>()
    var onFinishAJob: ((_ onSuccess: Queue.T?, _ onError: Error?) -> Void)?
    
    enum Status {
        case idle, working
    }
    
    private(set) var status: Status = .idle
    private(set) var workPool = WorkPoolQueue<T, Queue>()
    /// default max simultaneous jobs = 1
    var maxSimultaneousJob: Int {
        return workers.count
    }
    private(set) var workers: [Worker] = []
    
    /// assuming 1 worker can take a job at any moment
    init(queue: WorkPoolQueue<T, Queue>, maxWorker: Int) {
        guard maxWorker > 0 else {
            fatalError("must have more than 1 worker")
        }
        self.workPool = queue
        
        for _ in 0..<maxWorker {
            workers.append(Worker())
        }
    }
    
    /// return false if workerpool is busy
    @discardableResult
    func startTakingJob() -> Bool {
        workerTakeJob()
        return true
    }
    
    @discardableResult
    func workerTakeJob() -> Bool {

        guard workPool.remainingTaskCount() > 0 else {
            print("~~ Finish - \(workers.filter { $0.status == .idle }.count)")
            return false// no job to take
        }
        let idleWorker: Worker? = workers.filter { $0.status == .idle }.first
        guard let slave = idleWorker else {
            return  false// no idle worker
        }
        
        guard let job = workPool.dequeue() else { return false }
        
        slave.setWorking()
        
        let remainingIdleWorkerCount = workers.filter { $0.status == .idle }.count
        if remainingIdleWorkerCount > 0 {
            notifyNext()
        }
        
        job().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.onFinishAJob?(nil, error)
                slave.setIdle()
                self?.notifyNext()
                
            case .finished: break
            }
            
        }, receiveValue: { [weak self] value in
            self?.onFinishAJob?(value, nil)
            slave.setIdle()
            self?.notifyNext()
        }).store(in: &cancellables)
        
        return true
    }
    
    func notifyNext() {
        guard self.workPool.hasTask() == true else {
            status = .idle
            return
        }
        
        workerTakeJob()
    }
    
}

class Worker {
    enum Status {
        case idle, working
    }
    
    private(set) var status: Status = .idle
    
    init() {
        status = .idle
    }
    
    func setWorking() {
        status = .working
    }
    
    func setIdle() {
        status = .idle
    }
}
