import UIKit

protocol ColorPickerViewControllerDelegate: AnyObject {
    func colorPickerViewControllerColorChanged(_ colorPickerViewController: ColorPickerViewController)
}
