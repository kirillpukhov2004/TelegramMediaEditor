import UIKit

private let Timeout: Double = 0.25 // Timeout for two-finger gesture

// I use this delegate because addTarget(_:action:) doesn't provide state parameter update for possible value
protocol StrokeGestureRecognizerDelegate {
    func touchPossible()
    func touchBegun()
    func touchMoved()
    func touchCancelled()
    func touchFailed()
    func touchEnded()
}

extension StrokeGestureRecognizerDelegate {
    func touchPossible() { }
    func touchBegun() { }
    func touchMoved() { }
    func touchCancelled() { }
    func touchFailed() { }
    func touchEnded() { }
}

class StrokeGestureRecognizer: UIGestureRecognizer {
    private(set) var stroke: Stroke?
    public var strokeDelegate: StrokeGestureRecognizerDelegate?
    
    private(set) var trackingTouch: UITouch?
    private(set) var touchStartTimestamp: Double?
    private var timeoutTimer: Timer?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if touches.count >= 2 {
            state = .failed
        } else if let trackingTouch = trackingTouch {
            if (event.timestamp - touchStartTimestamp!) < Timeout {
               timeoutTimer?.invalidate()
               state = .failed
               
               strokeDelegate?.touchFailed()
            } else {
               touches.filter { $0 !== trackingTouch }.forEach { ignore($0, for: event) }
            }
        } else {
            stroke = Stroke()
            trackingTouch = touches.first!
            touchStartTimestamp = event.timestamp
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: Timeout, repeats: false) { [weak self] _ in
                self?.state = .began
                self?.strokeDelegate?.touchBegun()
            }
            appendStrokeSample(with: trackingTouch!, usePredictedTouches: false)
            
            strokeDelegate?.touchPossible()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let trackingTouch = trackingTouch, touches.contains(trackingTouch) else { return }
        
        if state == .began {
            state = .changed
        }
        
        if let touches = event.coalescedTouches(for: trackingTouch) {
            for touch in touches {
                appendStrokeSample(with: touch, usePredictedTouches: false)
            }
        } else {
            appendStrokeSample(with: trackingTouch, usePredictedTouches: false)
        }
        
        strokeDelegate?.touchMoved()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
        
        strokeDelegate?.touchCancelled()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
        
        strokeDelegate?.touchEnded()
    }
    
    override func reset() {
        super.reset()
        stroke = nil
        trackingTouch = nil
        touchStartTimestamp = nil
        timeoutTimer = nil
    }
    
    // MARK: Private Functions
    
    private func appendStrokeSample(with touch: UITouch, usePredictedTouches: Bool) {
        let location = touch.location(in: view)
        let timestamp = touch.timestamp
        let strokeSample = StrokeSample(location: location, timestamp: timestamp)
        stroke?.addSmaple(strokeSample)
    }
    
    private func failGesture() {
        
    }
}
