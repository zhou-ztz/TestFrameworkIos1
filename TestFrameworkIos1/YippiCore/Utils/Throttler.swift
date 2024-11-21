//
//    Repeat
//    A modern alternative to NSTimer made in GCD with debouncer and throttle
//    ---------------------
//    Created by:    Daniele Margutti
//                hello@danielemargutti.com
//                http://www.danielemargutti.com
//
//    Twitter:    @danielemargutti
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation

open class Repeater: Equatable {
    
    /// State of the timer
    ///
    /// - paused: idle (never started yet or paused)
    /// - running: timer is running
    /// - executing: the observers are being executed
    /// - finished: timer lifetime is finished
    public enum State: Equatable, CustomStringConvertible {
        case paused
        case running
        case executing
        case finished
        
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.paused, .paused),
                 (.running, .running),
                 (.executing, .executing),
                 (.finished, .finished):
                return true
            default:
                return false
            }
        }
        
        /// Return `true` if timer is currently running, including when the observers are being executed.
        public var isRunning: Bool {
            guard self == .running || self == .executing else { return false }
            return true
        }
        
        /// Return `true` if the observers are being executed.
        public var isExecuting: Bool {
            guard case .executing = self else { return false }
            return true
        }
        
        /// Is timer finished its lifetime?
        /// It return always `false` for infinite timers.
        /// It return `true` for `.once` mode timer after the first fire,
        /// and when `.remainingIterations` is zero for `.finite` mode timers
        public var isFinished: Bool {
            guard case .finished = self else { return false }
            return true
        }
        
        /// State description
        public var description: String {
            switch self {
            case .paused: return "idle/paused"
            case .finished: return "finished"
            case .running: return "running"
            case .executing: return "executing"
            }
        }
        
    }
    
    /// Repeat interval
    public enum Interval {
        case nanoseconds(_: Int)
        case microseconds(_: Int)
        case milliseconds(_: Int)
        case minutes(_: Int)
        case seconds(_: Double)
        case hours(_: Int)
        case days(_: Int)
        
        internal var value: DispatchTimeInterval {
            switch self {
            case .nanoseconds(let value):        return .nanoseconds(value)
            case .microseconds(let value):        return .microseconds(value)
            case .milliseconds(let value):        return .milliseconds(value)
            case .seconds(let value):            return .milliseconds(Int( Double(value) * Double(1000)))
            case .minutes(let value):            return .seconds(value * 60)
            case .hours(let value):                return .seconds(value * 3600)
            case .days(let value):                return .seconds(value * 86400)
            }
        }
    }
    
    /// Mode of the timer.
    ///
    /// - infinite: infinite number of repeats.
    /// - finite: finite number of repeats.
    /// - once: single repeat.
    public enum Mode {
        case infinite
        case finite(_: Int)
        case once
        
        /// Is timer a repeating timer?
        internal var isRepeating: Bool {
            switch self {
            case .once: return false
            default:    return true
            }
        }
        
        /// Number of repeats, if applicable. Otherwise `nil`
        public var countIterations: Int? {
            switch self {
            case .finite(let counts):    return counts
            default:                    return nil
            }
        }
        
        /// Is infinite timer
        public var isInfinite: Bool {
            guard case .infinite = self else {
                return false
            }
            return true
        }
        
    }
    
    /// Handler typealias
    public typealias Observer = ((Repeater) -> Void)
    
    /// Token assigned to the observer
    public typealias ObserverToken = UInt64
    
    /// Current state of the timer
    public private(set) var state: State = .paused {
        didSet {
            self.onStateChanged?(self, state)
        }
    }
    
    /// Callback called to intercept state's change of the timer
    public var onStateChanged: ((_ timer: Repeater, _ state: State) -> Void)?
    
    /// List of the observer of the timer
    private var observers = [ObserverToken: Observer]()
    
    /// Next token of the timer
    private var nextObserverID: UInt64 = 0
    
    /// Internal GCD Timer
    private var timer: DispatchSourceTimer?
    
    /// Is timer a repeat timer
    public private(set) var mode: Mode
    
    /// Number of remaining repeats count
    public private(set) var remainingIterations: Int?
    
    /// Interval of the timer
    private var interval: Interval
    
    /// Accuracy of the timer
    private var tolerance: DispatchTimeInterval
    
    /// Dispatch queue parent of the timer
    private var queue: DispatchQueue?
    
    /// Initialize a new timer.
    ///
    /// - Parameters:
    ///   - interval: interval of the timer
    ///   - mode: mode of the timer
    ///   - tolerance: tolerance of the timer, 0 is default.
    ///   - queue: queue in which the timer should be executed; if `nil` a new queue is created automatically.
    ///   - observer: observer
    public init(interval: Interval, mode: Mode = .infinite, tolerance: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue? = nil, observer: @escaping Observer) {
        self.mode = mode
        self.interval = interval
        self.tolerance = tolerance
        self.remainingIterations = mode.countIterations
        self.queue = (queue ?? DispatchQueue(label: "com.repeat.queue"))
        self.timer = configureTimer()
        self.observe(observer)
    }
    
    /// Add new a listener to the timer.
    ///
    /// - Parameter callback: callback to call for fire events.
    /// - Returns: token used to remove the handler
    @discardableResult
    public func observe(_ observer: @escaping Observer) -> ObserverToken {
        var (new, overflow) = self.nextObserverID.addingReportingOverflow(1)
        if overflow { // you need to add an incredible number of offset...sure you can't
            self.nextObserverID = 0
            new = 0
        }
        self.nextObserverID = new
        self.observers[new] = observer
        return new
    }
    
    /// Remove an observer of the timer.
    ///
    /// - Parameter id: id of the observer to remove
    public func remove(observer identifier: ObserverToken) {
        self.observers.removeValue(forKey: identifier)
    }
    
    /// Remove all observers of the timer.
    ///
    /// - Parameter stopTimer: `true` to also stop timer by calling `pause()` function.
    public func removeAllObservers(thenStop stopTimer: Bool = false) {
        self.observers.removeAll()
        
        if stopTimer {
            self.pause()
        }
    }
    
    /// Configure a new timer session.
    ///
    /// - Returns: dispatch timer
    private func configureTimer() -> DispatchSourceTimer {
        let associatedQueue = (queue ?? DispatchQueue(label: "com.repeat.\(NSUUID().uuidString)"))
        let timer = DispatchSource.makeTimerSource(queue: associatedQueue)
        let repeatInterval = interval.value
        let deadline: DispatchTime = (DispatchTime.now() + repeatInterval)
        if self.mode.isRepeating {
            timer.schedule(deadline: deadline, repeating: repeatInterval, leeway: tolerance)
        } else {
            timer.schedule(deadline: deadline, leeway: tolerance)
        }
        
        timer.setEventHandler { [weak self] in
            if let unwrapped = self {
                unwrapped.timeFired()
            }
        }
        return timer
    }
    
    /// Destroy current timer
    private func destroyTimer() {
        self.timer?.setEventHandler(handler: nil)
        self.timer?.cancel()
        
        if state == .paused || state == .finished {
            self.timer?.resume()
        }
    }
    
    /// Create and schedule a timer that will call `handler` once after the specified time.
    ///
    /// - Parameters:
    ///   - interval: interval delay for single fire
    ///   - queue: destination queue, if `nil` a new `DispatchQueue` is created automatically.
    ///   - observer: handler to call when timer fires.
    /// - Returns: timer instance
    @discardableResult
    public class func once(after interval: Interval, tolerance: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue? = nil, _ observer: @escaping Observer) -> Repeater {
        let timer = Repeater(interval: interval, mode: .once, tolerance: tolerance, queue: queue, observer: observer)
        timer.start()
        return timer
    }
    
    /// Create and schedule a timer that will fire every interval optionally by limiting the number of fires.
    ///
    /// - Parameters:
    ///   - interval: interval of fire
    ///   - count: a non `nil` and > 0  value to limit the number of fire, `nil` to set it as infinite.
    ///   - queue: destination queue, if `nil` a new `DispatchQueue` is created automatically.
    ///   - handler: handler to call on fire
    /// - Returns: timer
    @discardableResult
    public class func every(_ interval: Interval, count: Int? = nil, tolerance: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue? = nil, _ handler: @escaping Observer) -> Repeater {
        let mode: Mode = (count != nil ? .finite(count!) : .infinite)
        let timer = Repeater(interval: interval, mode: mode, tolerance: tolerance, queue: queue, observer: handler)
        timer.start()
        return timer
    }
    
    /// Force fire.
    ///
    /// - Parameter pause: `true` to pause after fire, `false` to continue the regular firing schedule.
    public func fire(andPause pause: Bool = false) {
        self.timeFired()
        if pause == true {
            self.pause()
        }
    }
    
    /// Reset the state of the timer, optionally changing the fire interval.
    ///
    /// - Parameters:
    ///   - interval: new fire interval; pass `nil` to keep the latest interval set.
    ///   - restart: `true` to automatically restart the timer, `false` to keep it stopped after configuration.
    public func reset(_ interval: Interval?, restart: Bool = true) {
        if self.state.isRunning {
            self.setPause(from: self.state)
        }
        
        // For finite counter we want to also reset the repeat count
        if case .finite(let count) = self.mode {
            self.remainingIterations = count
        }
        
        // Create a new instance of timer configured
        if let newInterval = interval {
            self.interval = newInterval
        } // update interval
        self.destroyTimer()
        self.timer = configureTimer()
        self.state = .paused
        
        if restart {
            self.timer?.resume()
            self.state = .running
        }
    }
    
    /// Start timer. If timer is already running it does nothing.
    @discardableResult
    public func start() -> Bool {
        guard self.state.isRunning == false else {
            return false
        }
        
        // If timer has not finished its lifetime we want simply
        // restart it from the current state.
        guard self.state.isFinished == true else {
            self.state = .running
            self.timer?.resume()
            return true
        }
        
        // Otherwise we need to reset the state based upon the mode
        // and start it again.
        self.reset(nil, restart: true)
        return true
    }
    
    /// Pause a running timer. If timer is paused it does nothing.
    @discardableResult
    public func pause() -> Bool {
        guard state != .paused && state != .finished else {
            return false
        }
        
        return self.setPause(from: self.state)
    }
    
    /// Pause a running timer optionally changing the state with regard to the current state.
    ///
    /// - Parameters:
    ///   - from: the state which the timer should only be paused if it is the current state
    ///   - to: the new state to change to if the timer is paused
    /// - Returns: `true` if timer is paused
    @discardableResult
    private func setPause(from currentState: State, to newState: State = .paused) -> Bool {
        guard self.state == currentState else {
            return false
        }
        
        self.timer?.suspend()
        self.state = newState
        
        return true
    }
    
    /// Called when timer is fired
    private func timeFired() {
        self.state = .executing
        
        if case .finite = self.mode {
            self.remainingIterations! -= 1
        }
        
        // dispatch to observers
        self.observers.values.forEach { $0(self) }
        
        // manage lifetime
        switch self.mode {
        case .once:
            // once timer's lifetime is finished after the first fire
            // you can reset it by calling `reset()` function.
            self.setPause(from: .executing, to: .finished)
        case .finite:
            // for finite intervals we decrement the left iterations count...
            if self.remainingIterations! == 0 {
                // ...if left count is zero we just pause the timer and stop
                self.setPause(from: .executing, to: .finished)
            }
        case .infinite:
            // infinite timer does nothing special on the state machine
            break
        }
        
    }
    
    deinit {
        self.observers.removeAll()
        self.destroyTimer()
    }
    
    public static func == (lhs: Repeater, rhs: Repeater) -> Bool {
        return lhs === rhs
    }
}

open class Throttler {
    
    /// Callback type
    public typealias Callback = (() -> Void)
    
    /// Behaviour mode of the throttler.
    ///
    /// - fixed: When execution is available, dispatcher will try to keep fire on a fixed rate.
    /// - deferred: When execution is provided the dispatcher will always delay invocation.
    public enum Mode {
        case fixed
        case deferred
    }
    
    /// In case you want the first invocation the be invoken immediately
    private(set) var immediateFire: Bool
    
    /// Operation mode
    private(set) var mode: Throttler.Mode = .fixed
    
    /// Queue in which the throotle will work.
    private var queue: DispatchQueue
    
    /// Callback to call
    public var callback: Callback?
    
    /// Last scheduled callback job
    private var callbackJob = DispatchWorkItem(block: {})
    
    /// Previous scheduled time
    private var previousScheduled: DispatchTime?
    
    /// Last executed time
    private var lastExecutionTime: DispatchTime?
    
    /// Need to delay before perform
    private var waitingForPerform: Bool = false
    
    /// Throotle interval
    public private(set) var throttle: DispatchTimeInterval
    
    /// Initialize a new throttler with given time interval.
    ///
    /// - Parameters:
    ///   - time: throttler interval.
    ///   - queue: execution queue; if `nil` default's background queue is used.
    ///   - mode: operation mode, if not specified `fixed` is used instead.
    ///   - fireNow: immediate fire first execution of the throttle.
    ///   - callback: callback to throttle.
    public init(time: Repeater.Interval, queue: DispatchQueue? = nil, mode: Mode = .fixed, immediateFire: Bool = false, _ callback: Callback? = nil) {
        self.throttle = time.value
        self.queue = (queue ?? DispatchQueue.global(qos: .background))
        self.mode = mode
        self.immediateFire = immediateFire
        self.callback = callback
    }
    
    /// Execute callback in throotle mode.
    public func call() {
        callbackJob.cancel()
        callbackJob = DispatchWorkItem { [weak self] in
            if let selfStrong = self {
                selfStrong.lastExecutionTime = .now()
                selfStrong.waitingForPerform = false
            }
            self?.callback?()
        }
        
        let (now, dispatchTime) = self.evaluateDispatchTime()
        self.previousScheduled = now
        self.waitingForPerform = true
        
        queue.asyncAfter(deadline: dispatchTime, execute: callbackJob)
    }
    
    /// Evaluate the dispatch time of the job since now based upon the operation mode set.
    ///
    /// - Returns: a tuple with now interval and evaluated interval based upon the current mode.
    private func evaluateDispatchTime() -> (now: DispatchTime, evaluated: DispatchTime) {
        let now: DispatchTime = .now()
        
        switch self.mode {
        case .fixed:
            
            // Case A.
            // If the time since last execution plus the throotle interval is > direct execution
            // then execute the callback at delayed interval.
            if let lastExecutionTime = self.lastExecutionTime {
                let evaluatedTime = (lastExecutionTime + self.throttle)
                if evaluatedTime > now {
                    return (now, evaluatedTime)
                }
            }
            
            // Case B.
            // If throotle is not waiting to perform the execution and previous scheduled time is
            // > than direct execution then execute on that delayed time else execute directly.
            guard self.waitingForPerform else {
                return ( self.immediateFire ? (now, now) : (now, (now + self.throttle)) )
            }
            
            // Case C.
            // If passFirstDispatch == true execute directly else execute on current + throttle time*/
            if let previousScheduled = self.previousScheduled, previousScheduled > now {
                return (now, previousScheduled)
            }
            return (now, now)
            
        case .deferred:
            
            // If previous execution + throttle time is greater than direct execution
            // then execute on that delayed time.
            if let lastExecutionTime = self.lastExecutionTime {
                let evaluatedTime = (lastExecutionTime + self.throttle)
                if evaluatedTime > now {
                    return (now, evaluatedTime)
                }
            }
            
            // Keep delaying unless passFirstDispatch == true and not waiting on execution
            if !self.waitingForPerform && self.immediateFire {
                return (now, now)
            }
            return (now, (now + self.throttle))
        }
    }
    
}
