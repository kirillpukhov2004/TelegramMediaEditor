import CoreGraphics

struct StrokeSample {
    private(set) var location: CGPoint
    private(set) var timestamp: Double
    
    init(location: CGPoint, timestamp: Double) {
        self.location = location
        self.timestamp = timestamp
    }
}
