import UIKit

protocol SavedColorsViewDelegate: AnyObject {
    func savedColorsViewColorSelected(_ savedColorsView: SavedColorsView)
    func savedColorsViewPlusButtonPressed(_ savedColorsView: SavedColorsView)
}
