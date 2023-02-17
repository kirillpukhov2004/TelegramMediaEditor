import UIKit

protocol CanvasToolBarViewDelegate: AnyObject {
    func canvasToolBarViewActiveToolChanged(_ canvasToolBarView: CanvasToolBarView)
    
    func canvasToolBarCancelButtonPressed(_ canvasToolBarView: CanvasToolBarView)
    
    func canvasToolBarSaveButtonPressed(_ canvasToolBarView: CanvasToolBarView)
}
