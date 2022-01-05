//
//  ViewController.swift
//  7-Photo-Memories-Macos
//
//  Created by Baris Karalar on 4.01.2022.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var collectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Photo"), for: indexPath)
        guard let pictureItem = item as? Photo else { return item }
        
        pictureItem.view.layer?.backgroundColor = NSColor.red.cgColor
        
        return pictureItem
    }
    
    
}
