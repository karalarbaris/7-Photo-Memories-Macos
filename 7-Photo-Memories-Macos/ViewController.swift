//
//  ViewController.swift
//  7-Photo-Memories-Macos
//
//  Created by Baris Karalar on 4.01.2022.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var collectionView: NSCollectionView!
    
    var itemsBeingDragged: Set<IndexPath>?
    
    lazy var photosDirectory: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let saveDirectory = documentsDirectory.appendingPathComponent("slidesforp7", isDirectory: true)
        
        if !fm.fileExists(atPath: saveDirectory.path) {
            try? fm.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        }
        
        return saveDirectory
    }()
    
    var photos = [URL]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeURL as String)])
        
        do {
            let fm = FileManager.default
            let files = try fm.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            for file in files {
                if file.pathExtension == "jpg" || file.pathExtension == "png" {
                    photos.append(file)
                }
            }
        } catch  {
            // failed to read the save directory
            print("Set up error")
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func performInternalDrag(with items: [IndexPath], to indexPath: IndexPath) {
        
        // keep track of where we're moving to
        var targetIndex = indexPath.item
        for fromIndexPath in items {
            // figure out where we're moving from
            let fromItemIndex = fromIndexPath.item
            // this is a move towards the front of the array
            if (fromItemIndex > targetIndex) {
                // call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                // move it in the collection view too
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: IndexPath(item: targetIndex, section: 0))
                // update our destination position
                targetIndex += 1
            }
        }
        // reset the target position – we want to move to the slot before the item the user chose
        targetIndex = indexPath.item - 1
        // loop backwards over our items
        for fromIndexPath in items.reversed() {
            let fromItemIndex = fromIndexPath.item
            // this is a move towards the back of the array
            if (fromItemIndex < targetIndex) {
                // call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                // move it in the collection view too
                let targetIndexPath = IndexPath(item: targetIndex, section: 0)
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: targetIndexPath)
                // update our destination position
                targetIndex -= 1
            }
        } }
    
    
    func performExternalDrag(with items: [NSPasteboardItem], at indexPath: IndexPath) {
        
        // 1. loop over every item on the drag and drop pasteboard
        for item in items {
            
            // 2. pull out the string containing the URL for this item
            guard let stringURL = item.string(forType: NSPasteboard.PasteboardType.fileURL)  else { continue }
            
            //                    item.string(forType: NSPasteboard.PasteboardType(kUTTypeURL as String)) else { continue }
            
            // 3. attempt to convert the string into a real URL
            guard let sourceURL = URL(string: stringURL) else { continue }
            
            // 4. create a destination URL by combining `photosDirectory` with the last path component
            let destinationURL = photosDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            
            // 5. attempt to copy the file to our app's folder
            do {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Could not copy \(sourceURL)")
            }
            
            // 6. Update the array and collection view
            photos.insert(destinationURL, at: indexPath.item)
            collectionView.insertItems(at: [indexPath])
            
            
        }
    }
    
}

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Photo"), for: indexPath)
        guard let pictureItem = item as? Photo else { return item }
        
        let img = NSImage(contentsOf: photos[indexPath.item])
        pictureItem.imageView?.image = img
        
        return pictureItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        itemsBeingDragged = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        itemsBeingDragged = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        if let moveItems = itemsBeingDragged?.sorted() {
            // internal drag
            performInternalDrag(with: moveItems, to: indexPath)
        } else {
            //external drag
            let pasteboard = draggingInfo.draggingPasteboard
            guard let items = pasteboard.pasteboardItems else { return true }
            performExternalDrag(with: items, at: indexPath)
        }
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        return photos[indexPath.item] as NSPasteboardWriting?
    }
    
    
}

extension Array {
    mutating func moveItem(from: Int, to: Int) {
        let item = self[from]
        self.remove(at: from)
        if to <= from {
            self.insert(item, at: to)
        } else {
            self.insert(item, at: to - 1)
        } }
}
