import Foundation

final class RepeatingTimer {
    
    /// Amount of time, in seconds.
    private let timeInterval: Int
    
    init(timeInterval: Int) {
        self.timeInterval = timeInterval
    }
    
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
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    deinit {
        timer.setEventHandler { }
        timer.cancel()
        // If the timer is suspended, calling cancel without resuming afterwards
        // triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
        resume()
        eventHandler = nil
    }
    
    // MARK: - GCD Timer Management
    
    /*
     GCD timers are sensitive to errors. It is crucial to maintain
     balance between calls to `dispatch_suspend` and `dispatch_resume`. Failure to do so
     results in crashes with errors similar to:

       BUG IN CLIENT OF LIBDISPATCH: Over-resume of an object

     Such errors indicate an attempt to resume an already resumed timer. According to the
     documentation, each call to `dispatch_suspend` must be matched with a corresponding
     call to `dispatch_resume` to ensure proper event delivery and avoid crashes.
     For more information: https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW8
    */
    private var state: State = .suspended
    
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
