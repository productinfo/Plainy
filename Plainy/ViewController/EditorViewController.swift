//
//  Created by Martin Hartl on 30.11.17.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Cocoa
import Files
import Notepad

enum EditorFont {
    case menlo

    func font(with size: CGFloat) -> NSFont {
        switch self {
        case .menlo:
            return NSFont(name: "Menlo", size: size)!
        }
    }
}

class EditorViewController: NSViewController {
    var theme = Theme("one-dark") {
        didSet {
            updateTheme()
        }
    }

    var browseFile: BrowseFileItem? {
        didSet {
            guard let browseFile = browseFile,
                let data = try? browseFile.file.readAsString() else {
                textView.string = ""
                view.window?.title = "Plainy"
                return
            }
            view.window?.title = "Plainy - \(browseFile.file.name)"
            textView.string = data
        }
    }

    private let storage = Storage()
    private let notificationCenter: NotificationCenter = .default

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(EditorViewController.saveOnLoosingFocus), name: NSWindow.didResignKeyNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc private func saveOnLoosingFocus() {
        ShortCutManager.shared.saveAction!()
    }

    func save() {
        guard let browseFile = browseFile,
        let readString = try? browseFile.file.readAsString(),
        textView.string != readString  else { return }

        try? browseFile.file.write(string: textView.string)
    }

    @IBOutlet private var textView: NSTextView! {
        didSet {
            textView.delegate = self
            textView.font = EditorFont.menlo.font(with: 14)
        }
    }
}

extension EditorViewController: NSTextViewDelegate {
    func textDidEndEditing(_ notification: Notification) {
        ShortCutManager.shared.saveAction!()
    }
}

extension EditorViewController {
    func updateTheme() {
        storage.theme = theme
        textView.backgroundColor = theme.backgroundColor
        textView.insertionPointColor = theme.tintColor
        textView.layoutManager?.replaceTextStorage(storage)
    }
}