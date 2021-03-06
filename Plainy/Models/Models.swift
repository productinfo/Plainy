//
//  Created by martin on 08.12.17.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation
import Files

class BrowseFileSystemItem: Equatable {
    static func == (lhs: BrowseFileSystemItem, rhs: BrowseFileSystemItem) -> Bool {
        return URL(fileURLWithPath: lhs.item.path) == URL(fileURLWithPath: rhs.item.path)
    }

    var item: FileSystem.Item

    init(item: FileSystem.Item) {
        self.item = item
    }

    func move(to folderItem: BrowseFolderItem) -> Int? {
        return nil
    }
}

class BrowseFolderItem: BrowseFileSystemItem {
    var parent: BrowseFolderItem?

    var folder: Folder

    lazy var allItems: [BrowseFileSystemItem] = {
        return uncachedAllItems
    }()

    private var uncachedAllItems: [BrowseFileSystemItem] {
        let all = folder.allItems
        let mappedItems: [BrowseFileSystemItem] = all.flatMap({ item in
            if let folderItem = item as? Folder {
                return BrowseFolderItem(folder: folderItem, parent: self)
            } else if let fileItem = item as? File {
                return BrowseFileItem(file: fileItem)
            }

            return nil
        })

        return mappedItems
    }

    func refreshAllItems() {
        do {
            folder = try Folder(path: folder.path)
            item = folder
            allItems = uncachedAllItems
        } catch {
            // TODO: Show error
        }
    }

    var allItemsCount: Int {
        return allItems.count
    }

    init(folder: Folder, parent: BrowseFolderItem?) {
        self.folder = folder
        self.parent = parent
        super.init(item: folder)
    }

    override func move(to folderItem: BrowseFolderItem) -> Int? {
        do {
            try folder.move(to: folderItem.folder)
            parent?.refreshAllItems()
            folderItem.refreshAllItems()
            refreshAllItems()
            parent = folderItem
            let index = folderItem.allItems.index(of: self)
            return index
        } catch {
            return nil
        }
    }

    func itemsToExpand(at path: String, homepath: String = PreferencesManager.shared.rootPath) -> [BrowseFileSystemItem] {
        let normalisedItemPath = path.replacingOccurrences(of: homepath, with: "")
        let itemNames = normalisedItemPath.split(separator: "/")
        var nextFolder: BrowseFileSystemItem = self
        var folders = [nextFolder]

        for item in itemNames {
            if let folder = nextFolder as? BrowseFolderItem,
            let foundItem = folder.subitem(named: String(item)) {
                nextFolder = foundItem
            }

            folders.append(nextFolder)
        }

        return folders
    }

    func subitem(named name: String) -> BrowseFileSystemItem? {
        return allItems.first(where: {
            $0.item.name == name
        })
    }
}

class BrowseFileItem: BrowseFileSystemItem {
    var file: File

    init(file: File) {
        self.file = file
        super.init(item: file)
    }

    override func move(to folderItem: BrowseFolderItem) -> Int? {
        do {
            try file.move(to: folderItem.folder)
            file = try File(path: file.path)
            item = file
            folderItem.refreshAllItems()
            let index = folderItem.allItems.index(of: self)
            return index
        } catch {
            return nil
        }
    }
}
