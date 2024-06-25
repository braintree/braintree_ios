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
        timerSource.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return timerSource
    }()
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming afterwards
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
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
