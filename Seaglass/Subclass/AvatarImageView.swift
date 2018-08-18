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
import SwiftMatrixSDK

class AvatarImageView: NSImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        wantsLayer = true
        canDrawSubviewsIntoLayer = true
        
        layer = CALayer()
        layer?.masksToBounds = true
        layer?.contentsGravity = kCAGravityResizeAspectFill
    }
    
    override func layout() {
        super.layout()
        layer?.cornerRadius = (frame.width)/2
    }
    
    override var image: NSImage? {
        set {
            self.layer?.contents = newValue
            super.image = newValue
        }
        get {
            return super.image
        }
    }
    
    func setAvatar(forMxcUrl: String?, defaultImage: NSImage, useCached: Bool = true) {
        self.image? = defaultImage
        if forMxcUrl == nil {
            return
        }
        if forMxcUrl!.hasPrefix("mxc://") {
            let url = MatrixServices.inst.client.url(ofContentThumbnail: forMxcUrl, toFitViewSize: CGSize(width: 96, height: 96), with: MXThumbnailingMethodScale)!
            if url.hasPrefix("http://") || url.hasPrefix("https://") {
                let path = MXMediaManager.cachePathForMedia(withURL: url, andType: nil, inFolder: kMXMediaManagerAvatarThumbnailFolder)
                if path == nil {
                    return
                }
                if FileManager.default.fileExists(atPath: path!) && useCached {
                    { [weak self] in
                        if self != nil {
                            let image = MXMediaManager.loadThroughCache(withFilePath: path)
                            if image != nil {
                                self?.image? = image!
                            }
                        }
                        }()
                } else {
                    DispatchQueue.main.async {
                        MXMediaManager.downloadMedia(fromURL: url, andSaveAtFilePath: path, success: { [weak self] in
                            if self != nil {
                                let image = MXMediaManager.loadThroughCache(withFilePath: path)
                                if image != nil {
                                    self?.image? = image!
                                }
                            }
                        }) { [weak self] (error) in
                            if self != nil {
                                self?.image? = defaultImage
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setAvatar(forUserId userId: String, useCached: Bool = true) {
        if MatrixServices.inst.session.user(withUserId: userId) == nil {
            self.setAvatar(forText: "?")
            return
        }
        let user = MatrixServices.inst.session.user(withUserId: userId)!
        if user.avatarUrl != "" {
            self.setAvatar(forMxcUrl: user.avatarUrl, defaultImage: NSImage.create(withLetterString: user.displayname ?? "?"), useCached: useCached)
        } else {
            self.setAvatar(forText: user.displayname)
        }
    }
    
    func setAvatar(forRoomId roomId: String, useCached: Bool = true) {
        if MatrixServices.inst.session.room(withRoomId: roomId) == nil {
            self.setAvatar(forText: "?")
            return
        }
        let room = MatrixServices.inst.session.room(withRoomId: roomId)!
        if room.summary.avatar != "" {
            self.setAvatar(forMxcUrl: room.summary.avatar, defaultImage: NSImage.create(withLetterString: room.summary.displayname ?? "?"), useCached: useCached)
        } else {
            self.setAvatar(forText: room.summary.displayname)
        }
    }
    
    func setAvatar(forText: String) {
        self.image? = NSImage.create(withLetterString: forText)
    }
    
}
