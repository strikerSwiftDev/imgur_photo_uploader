

import UIKit



class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var stupidBG: UIView!
    @IBOutlet weak var waitingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadedLabel: UILabel!
    @IBOutlet weak var failedLabel: UILabel!
    
//update UI (collectionViewCell) due current state of the PhotoItem
    func setVisualsWith(item: PhotoItem) {
        image.image = item.image
        if !item.isUploaded, !item.isUploading, !item.isWaitingToUpload, !item.isFailed {
            setDefault()
        }else if item.isUploading {
            setUploading()
        }else if item.isUploaded {
            setUploaded()
        }else if item.isWaitingToUpload {
            setWaitingToUpload()
        }else if item.isFailed {
            setFailed()
        }
    }
    
    func setDefault() {
        stupidBG.alpha = 0
        waitingIndicator.stopAnimating()
        loadingIndicator.stopAnimating()
        loadedLabel.alpha = 0
        failedLabel.alpha = 0
    }
    
    func setWaitingToUpload() {
        setDefault()
        stupidBG.alpha = 1
        waitingIndicator.startAnimating()
    }
    
    func setUploading() {
        setDefault()
        stupidBG.alpha = 1
        loadingIndicator.startAnimating()
    }
    
    func setFailed() {
        setDefault()
        stupidBG.alpha = 1
        failedLabel.alpha = 1
    }
    
    func setUploaded() {
        setDefault()
        stupidBG.alpha = 1
        loadedLabel.alpha = 1
    }
    
}
