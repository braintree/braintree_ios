import Foundation

final class RepeatingTimer {
    
    // MARK: - Private Properties
    
    /// Amount of time, in seconds.
    private let timeInterval: Int
    
    private lazy var timer: DispatchSourceTimer = {
        let timerSource = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timerSource.schedule(
            deadline: .now() + .seconds(timeInterval),
            repeating: .seconds(timeInterval),
            leeway: .seconds(1)
        )
        timerSource.setEventHandler { [weak self] in
            self?.eventHandler?()
        }
        return timerSource
    }()
    
    private var state: State = .suspended
    
    private enum State {
        case suspended
        case resumed
    }
        
    // MARK: - Internal Properties
    
    var eventHandler: (() -> Void)?
    
    // MARK: - Initializer
    
    /// exposed for testing shorter time intervals
    init(timeInterval: Int = 15) {
        self.timeInterval = timeInterval
    }
        
    deinit {
        timer.setEventHandler { }
        timer.cancel()
        /// If the timer is suspended, calling cancel without resuming afterwards
        /// triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
        resume()
        eventHandler = nil
    }
    
    // MARK: - Internal Methods
    
    /// GCD timers are sensitive to errors. It is crucial to maintain balance between calls to `dispatch_suspend` and `dispatch_resume`.
    /// Failure to do so results in crashes with errors similar to: BUG IN CLIENT OF LIBDISPATCH: Over-resume of an object
    ///
    /// Such errors indicate an attempt to resume an already resumed timer. According to the documentation, each call to `dispatch_suspend`
    /// must be matched with a corresponding call to `dispatch_resume` to ensure proper event delivery and avoid crashes.
    /// For more information see: https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW8    
    func resume() {
        guard state != .resumed else { return }
        
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        guard state != .suspended else { return }
        
        state = .suspended
        timer.suspend()
    }
}
