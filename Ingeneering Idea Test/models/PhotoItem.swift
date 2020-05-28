

import Foundation
import UIKit

// base data container

class PhotoItem {
    var image = UIImage()
    var identifier = ""
    var isUploaded = false
    var isUploading = false
    var isFailed = false
    var isWaitingToUpload = false
    
    init (image: UIImage)
    {
        self.image = image
    }
    
    func setDefault() {
        isUploaded = false
        isUploading = false
        isFailed = false
        isWaitingToUpload = false
    }
    
    func setWaitingToUpload() {
        setDefault()
        isWaitingToUpload = true
    }
    
    func setUploading() {
        setDefault()
        isUploading = true
    }
    
    func setFailed() {
        setDefault()
        isFailed = true
    }
    
    func setUploaded() {
        setDefault()
        isUploaded = true
    }
    
}



