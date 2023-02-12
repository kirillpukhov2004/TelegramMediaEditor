import UIKit
import Photos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authorizationStatus == .notDetermined || authorizationStatus == .denied {
            let imagePickerAccessRequestViewController = ImagePickerAccessRequestViewController()
            navigationController.pushViewController(imagePickerAccessRequestViewController, animated: false)
        } else {
            let imagePickerViewController = ImagePickerViewController()
            navigationController.pushViewController(imagePickerViewController, animated: false)
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

