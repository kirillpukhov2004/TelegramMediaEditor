import UIKit
import Photos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        navigationController.overrideUserInterfaceStyle = .dark
        navigationController.setNavigationBarHidden(true, animated: false)
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            let imagePickerViewController = PickerViewController()
            navigationController.pushViewController(imagePickerViewController, animated: false)
        case .notDetermined, .denied:
            let imagePickerAccessRequestViewController = PickerAccessRequestViewController()
            navigationController.pushViewController(imagePickerAccessRequestViewController, animated: false)
        default:
            print("🔴 Image access restricted")
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
