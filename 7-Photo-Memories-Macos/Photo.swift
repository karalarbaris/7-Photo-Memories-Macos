//
//  Photo.swift
//  7-Photo-Memories-Macos
//
//  Created by Baris Karalar on 5.01.2022.
//

import Cocoa

class Photo: NSCollectionViewItem {

    let selectedBorderThichness: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.blue.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = selectedBorderThichness
            } else {
                view.layer?.borderWidth = 0
            }
        }
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            if highlightState == .forSelection {
                view.layer?.borderWidth = selectedBorderThichness
            } else {
                if !isSelected {
                    view.layer?.borderWidth = 0
                }
            }
        }
    }
    
    
}
