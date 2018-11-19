import Foundation

protocol SidePanelViewControllerDelegate {
    func didSelectModule(_ module: Module?)
    func didSelect(chapter: Int, in book: Int)
    func setNeedsReload()
}
