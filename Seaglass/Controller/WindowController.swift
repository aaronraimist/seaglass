//
// Seaglass, a native macOS Matrix client
// Copyright © 2018, Neil Alexander
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate, NSTouchBarDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.hide(nil)
        return false
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        guard let viewController = contentViewController else {
            return nil
        }
        return viewController.makeTouchBar()
    }

}
