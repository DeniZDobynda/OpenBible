import Foundation

protocol SidePanelViewControllerDelegate {
    func didSelect(chapter: Int, in book: Int)
    func setNeedsReload()
}
