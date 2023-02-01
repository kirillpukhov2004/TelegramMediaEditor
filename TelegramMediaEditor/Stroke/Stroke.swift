import UIKit

class Stroke {
    var width: CGFloat
    var color: CGColor
    
    private(set) var samples: [StrokeSample]
    
    init(_ tool: Tool? = nil) {
        self.width = tool?.width ?? 1
        self.color = tool?.color ?? UIColor.black.cgColor
        
        self.samples = [StrokeSample]()
    }
    
    func addSmaple(_ sampleSample: StrokeSample) {
        samples.append(sampleSample)
    }
}
