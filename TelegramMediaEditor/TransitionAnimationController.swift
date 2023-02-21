import UIKit

class TransitionAnimationContorller: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.viewController(forKey: .from) is PickerViewController,
           transitionContext.viewController(forKey: .to) is CanvasViewController {
            transitionFromPickerToCanvas(transitionContext: transitionContext)
        } else if transitionContext.viewController(forKey: .from) is CanvasViewController,
                  transitionContext.viewController(forKey: .to) is PickerViewController {
            transitionFromCanvasToPicker(transitionContext: transitionContext)
        } else {
            simpleTransition(transitionContext: transitionContext)
        }
    }
    
    private func simpleTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false); return
        }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, animations: {
            containerView.addSubview(destinationView)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    private func transitionFromPickerToCanvas(transitionContext: UIViewControllerContextTransitioning) {
        guard let pickerVC = transitionContext.viewController(forKey: .from) as? PickerViewController,
              let canvasVC = transitionContext.viewController(forKey: .to) as? CanvasViewController else {
            transitionContext.completeTransition(false); return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(canvasVC.view)
        containerView.layoutIfNeeded()
        
        guard let selectedCellIndexPath = pickerVC.collectionView.indexPathsForSelectedItems?.first,
              let cell = pickerVC.collectionView.cellForItem(at: selectedCellIndexPath) as? PickerCollectionViewPhotoCell else {
            transitionContext.completeTransition(false); return
        }
        
        let canvasImageViewFrame = canvasVC.scrollView.convert(canvasVC.drawingRect, to: containerView)
        let cellImageViewFrame = pickerVC.collectionView.convert(cell.frame, to: containerView)
        
        let imageView = UIImageView(frame: cellImageViewFrame)
        imageView.image = canvasVC.image
        imageView.contentMode = cell.imageView.contentMode
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        canvasVC.view.alpha = 0
        
        canvasVC.imageView.alpha = 0
        cell.imageView.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext) * 1.5
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.1,
            animations: {
                imageView.frame = canvasImageViewFrame
                canvasVC.view.alpha = 1
            }
        ) { _ in
            imageView.removeFromSuperview()
            
            canvasVC.imageView.alpha = 1
            cell.imageView.alpha = 1
            
            transitionContext.completeTransition(true)
        }
    }
    
    private func transitionFromCanvasToPicker(transitionContext: UIViewControllerContextTransitioning) {
        guard let canvasVC = transitionContext.viewController(forKey: .from) as? CanvasViewController,
              let pickerVC = transitionContext.viewController(forKey: .to) as? PickerViewController else {
            transitionContext.completeTransition(false); return
        }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(pickerVC.view, belowSubview: canvasVC.view)
        containerView.layoutIfNeeded()
        
        
        let pickerCellIndexPath: IndexPath
        let canvasImage: UIImage
        
        if canvasVC.transitionType == .cancel {
            guard let indexPath = pickerVC.selectedCellIndexPath else {
                transitionContext.completeTransition(false); return
            }
            pickerCellIndexPath = indexPath
            
            canvasImage = canvasVC.image
        } else {
            pickerCellIndexPath = IndexPath(item: 0, section: 0)
            pickerVC.collectionView.scrollToItem(at: pickerCellIndexPath, at: .top, animated: false)
            pickerVC.collectionView.reloadData()
            
            canvasImage = canvasVC.generateImage()
        }
        
        guard let pickerCell = pickerVC.collectionView.cellForItem(at: pickerCellIndexPath) as? PickerCollectionViewPhotoCell else {
            print("🔴 \(#function): Can't get cell for for indexPath: \(pickerCellIndexPath)")
            transitionContext.completeTransition(false); return
        }
        
        let cellImageViewFrame = pickerVC.collectionView.convert(pickerCell.frame, to: containerView)
        let imageViewFrame = canvasVC.scrollView.convert(canvasVC.drawingRect, to: containerView)
        let imageView = UIImageView(frame: imageViewFrame)
        imageView.image = canvasImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        canvasVC.canvasWrapperView.alpha = 0
        pickerCell.imageView.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext) * 1.0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.1,
            animations: {
                imageView.frame = cellImageViewFrame
                canvasVC.view.alpha = 0
            }
        ) { _ in
            imageView.removeFromSuperview()
            
            canvasVC.imageView.alpha = 1
            pickerCell.imageView.alpha = 1
            
            transitionContext.completeTransition(true)
        }
    }
}
