import UIKit

class TransitionAnimationContorller: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.30
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if let pickerVC = transitionContext.viewController(forKey: .from) as? PickerViewController,
           let canvasVC = transitionContext.viewController(forKey: .to) as? CanvasViewController {
            containerView.addSubview(canvasVC.view)
            
            guard let selectedCellIndexPath = pickerVC.collectionView.indexPathsForSelectedItems?.first,
                  let cell = pickerVC.collectionView.cellForItem(at: selectedCellIndexPath) as? PickerCollectionViewPhotoCell else {
                transitionContext.completeTransition(false); return
            }
            canvasVC.view.layoutIfNeeded()
            
            let canvasImageViewFrame = canvasVC.scrollView.convert(canvasVC.drawingRect, to: containerView)
            let cellImageViewFrame = pickerVC.collectionView.convert(cell.frame, to: containerView)
            let imageView = UIImageView(frame: cellImageViewFrame)
            imageView.image = canvasVC.backgroundImage
            imageView.contentMode = cell.imageView.contentMode
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)
            
            cell.alpha = 0
            
            canvasVC.view.alpha = 0
            canvasVC.backgroundImageView.alpha = 0
            
            UIView.animate(withDuration: duration, delay: 0, animations: {
                imageView.frame = canvasImageViewFrame
                canvasVC.view.alpha = 1
            }) { _ in
                imageView.removeFromSuperview()
                canvasVC.backgroundImageView.alpha = 1
                
                cell.alpha = 1
                
                transitionContext.completeTransition(true)
            }
        } else if let canvasVC = transitionContext.viewController(forKey: .from) as? CanvasViewController,
                  let pickerVC = transitionContext.viewController(forKey: .to) as? PickerViewController {
            pickerVC.view.layoutIfNeeded()
            containerView.insertSubview(pickerVC.view, belowSubview: canvasVC.view)
            
            if canvasVC.transitionType == .cancel {
                guard let indexPath = pickerVC.selectedCellIndexPath,
                      let cell = pickerVC.collectionView.cellForItem(at: indexPath) as? PickerCollectionViewPhotoCell else {
                    transitionContext.completeTransition(false); return
                }
                
                let cellImageViewFrame = pickerVC.collectionView.convert(cell.frame, to: containerView)
                let imageViewFrame = canvasVC.scrollView.convert(canvasVC.drawingRect, to: containerView)
                let imageView = UIImageView(frame: imageViewFrame)
                imageView.image = canvasVC.backgroundImage
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
                
                canvasVC.canvasWrapperView.alpha = 0
                
                cell.alpha = 0
                
                UIView.animate(withDuration: duration,
                               delay: 0,
                               animations: {
                    imageView.frame = cellImageViewFrame
                    canvasVC.view.alpha = 0
                }) { _ in
                    imageView.removeFromSuperview()
                    
                    cell.alpha = 1
                    
                    transitionContext.completeTransition(true)
                }
            } else {
                let indexPath = IndexPath(item: 0, section: 0)
                guard let cell = pickerVC.collectionView.cellForItem(at: indexPath) as? PickerCollectionViewPhotoCell else {
                    transitionContext.completeTransition(false); return
                }
                
                let cellImageViewFrame = pickerVC.collectionView.convert(cell.frame, to: containerView)
                let imageViewFrame = canvasVC.scrollView.convert(canvasVC.drawingRect, to: containerView)
                let imageView = UIImageView(frame: imageViewFrame)
                imageView.image = canvasVC.generateImage()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
                
                canvasVC.canvasWrapperView.alpha = 0
                
                cell.alpha = 0
                
                UIView.animate(withDuration: duration,
                               delay: 0,
                               animations: {
                    imageView.frame = cellImageViewFrame
                    canvasVC.view.alpha = 0
                }) { _ in
                    imageView.removeFromSuperview()
                    
                    cell.alpha = 1
                    
                    transitionContext.completeTransition(true)
                }
            }
            
        } else {
            guard let destinationView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false); return
            }
            containerView.addSubview(destinationView)
            transitionContext.completeTransition(true)
        }
    }
}
