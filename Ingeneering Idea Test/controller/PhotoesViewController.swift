

import UIKit
import Photos

class PhotoesViewController: UIViewController {
//UrlsViewControllerIdentifier
    
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
        
    private var photosArr = [PhotoItem]()
    private var uploadedIdentifiers = [String]()
    
    private var offsetBetweenCells: CGFloat = 20
    private var cellSize: CGFloat {
//the issue - photos should be displayed as squares; 3 columns on portrait, and 5 on landscape.
        if view.frame.height > view.frame.width {
            return (view.frame.width - CGFloat(40 + offsetBetweenCells * 2)) / 3
        }else{
            return (view.frame.width - CGFloat(40 + offsetBetweenCells * 4)) / 5
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
// determine permissions of the access to the galery
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            
            PHPhotoLibrary.requestAuthorization { (status) in
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
//app starts load UI only if access granted
                    DispatchQueue.main.async {

                        self.getPhotos()
                    }

                }else {
                    DispatchQueue.main.async {
                        self.proceedNoPermissionAlert()
                    }
                    
                }
            }
            
        } else {
                self.getPhotos()
        }
    }
//updating UI when the device rotated
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        photosCollectionView.reloadData()

    }
    
    
    func getPhotos() {
// load saves
        DataManager.shared.initSavedEntities()
        
        uploadedIdentifiers = DataManager.shared.getUploadedIdentifiers()
// load assets for the LQ photos to present in collection view.
//the issue - save LQ photos in device RAM for correct and fast collection view working
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        
        if assets.count > 0 { //check that user has photos in galery
//load photos
            for i in 0..<assets.count {
                let asset = assets[i]
                
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .fastFormat
                
                let targetSize = CGSize(width: asset.pixelHeight, height: asset.pixelWidth)
                
                PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { (image, _)  in
                    if let usableImage = image {
//create and initiate the data container for every photo
                        let item = PhotoItem(image: usableImage)
                        item.identifier = asset.localIdentifier
                       
                        let found = self.uploadedIdentifiers.filter({$0 == item.identifier})
                        if found.count > 0 {
                            item.isUploaded = true
                        }
                        
                        self.photosArr.append(item)
//check that all photos have loaded and initiate UI
                        if self.photosArr.count == assets.count {
                            
                            self.initAfterImageLoading()

                        }
                        
                    }
                    
                }
                
            }
            
        }else {
            proceedNoPhotosAlert()
        }
        

    }
    
//app UI initialization
    private func initAfterImageLoading(){
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        NetworkManager.shared.delegate = self
        photosCollectionView.reloadData()
    }
    
    // MARK: alerts
    private func  proceedNoPhotosAlert() {
        let alert = UIAlertController(title: "No Photos", message: "You have no photos in galery", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func proceedNoPermissionAlert() {
        let alert = UIAlertController(title: "No permission", message: "You have grant the access to your photolibrary", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func failedUploadAlert() {
        let alert = UIAlertController(title: "FAIL", message: "Photo was not uploaded", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func badUserDataAlert() {
        let alert = UIAlertController(title: "FAIL", message: "bad user data. Please upate your CLIENT_ID and ACCESS_TOKEN in sourse code and rebuld app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    

//send original sized photo to upload
    private func uploadPhoto(item: PhotoItem) {
        item.setWaitingToUpload()
        photosCollectionView.reloadData()
//set LQ photo in case HD photo is unavailable
        var imageToUpload = item.image
        
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [item.identifier], options: nil).firstObject {
            
            let targetSize = PHImageManagerMaximumSize
            
            let requestOptions = PHImageRequestOptions()
//          requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in

                if image != nil {
                    
                    imageToUpload = image!

                }
                
            }

        }
        
        guard let data = imageToUpload.pngData() else {
            print("NO IMAGE DATA FOR DOUNLOADING")
            return}
        
        let itemToUpload = ItemToUpload(uploadigData: data, identifier: item.identifier)
        NetworkManager.shared.addItemToUploadQueue(item: itemToUpload)
    }
    
//present table view with links of loaded photos
    @IBAction func urlsButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let targetVC = storyboard.instantiateViewController(withIdentifier: "UrlsViewControllerIdentifier")
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
}

//MARK: extentions
extension PhotoesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return photosArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellIdentifier", for: indexPath) as! PhotoCollectionViewCell
        cell.setVisualsWith(item: photosArr[indexPath.row])
        
        return cell
    }
    
}

extension PhotoesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = photosArr[indexPath.row]
        if !item.isUploaded, !item.isUploading, !item.isWaitingToUpload {
            uploadPhoto(item: item)
        }
        
    }

}

extension PhotoesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return offsetBetweenCells
    }
}
//receive events from NetworkManager when photo start to upload and uploaded
extension PhotoesViewController: NetworkManagerDelegate {
    func incorrectUserData() {
        badUserDataAlert()
    }
    
    func uploadComplete(successfull: UploadingResultMessage, photoIdentifier: String) {
        let item = photosArr.filter({$0.identifier == photoIdentifier}).first
        
        switch successfull {
        case .positive:
            item?.setUploaded()
        case .negative:
            item?.setFailed()
            self.failedUploadAlert()
            break
        }

        photosCollectionView.reloadData()
    }
    
    func uploadingStartedForItemWith(identifier: String) {
        let item = photosArr.filter({$0.identifier == identifier}).first
        item?.setUploading()
        photosCollectionView.reloadData()
    }
    
}
