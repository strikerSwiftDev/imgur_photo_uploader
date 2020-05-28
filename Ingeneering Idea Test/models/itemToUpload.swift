

import Foundation

//The container for data receiving from PhotoViewController to NetworkManager for uloading

class ItemToUpload {
    
    let uploadingData: Data
    let identifier: String
    
    init (uploadigData: Data, identifier: String) {
        self.uploadingData = uploadigData
        self.identifier = identifier
    }
    
}
