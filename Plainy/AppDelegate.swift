//
//  Created by Martin Hartl on 30.11.17.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Cocoa
import Files
import CoreData

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
//        NSApplication.shared.mainWindow?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        SearchModelController.shared.index()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return SearchModelController.shared.terminate(sender)
    }

    // MARK: - Shortcuts

    @IBAction func newFile(_ sender: Any) {
        ShortCutManager.shared.newFileAction?()
    }

    @IBAction func newFolder(_ sender: Any) {
        ShortCutManager.shared.newFolderAction?()
    }

    @IBAction func save(_ sender: Any) {
        ShortCutManager.shared.saveAction?()
    }

    @IBAction func deleteAction(_ sender: Any) {
        ShortCutManager.shared.deleteAction?()
    }

    @IBAction func openQuicklyAction(_ sender: Any) {
        ShortCutManager.shared.presentOpenQuickly?()
    }
}

class ShortCutManager {
    static let shared = ShortCutManager()

    var saveAction: (() -> Void)?
    var newFileAction: (() -> Void)?
    var newFolderAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var presentOpenQuickly: (() -> Void)?
}

class PreferencesManager {
    static let shared = PreferencesManager()

    private let userDefaults = UserDefaults.standard
    private let defaultFolderName = "Plainy"

    var didChangeRootPath: (String) -> Void = { _ in }

    var rootPath: String {
        get {
            guard let savedPath = userDefaults.string(forKey: #function) else {
                let folder = (try? Folder.home.createSubfolder(named: defaultFolderName)) ?? (try? Folder.home.subfolder(named: defaultFolderName))
                return folder!.path
            }
            return savedPath
        }

        set {
            if newValue != rootPath {
                userDefaults.set(newValue, forKey: #function)
                didChangeRootPath(newValue)
            }
        }
    }
}
