

import Foundation
import UIKit



enum UploadingResultMessage {
    case positive
    case negative
}

protocol NetworkManagerDelegate: class {
    func uploadComplete(successfull: UploadingResultMessage, photoIdentifier: String)
    func uploadingStartedForItemWith(identifier: String)
    func incorrectUserData()
}

class NetworkManager {
    
    static var shared = NetworkManager()
    

    
    private let clientID = ""// enter your imgur.com CLIENT_ID
    private let accessToken = ""// enter your imgur.com ACCESS_TOKEN
    
    private var itemsForUpload = [ItemToUpload]()
    private var uploadingItem: ItemToUpload?
    weak var delegate: NetworkManagerDelegate?
    
    var isUserCredsValid = false
    
    private init () {
        
    }
//add data to apload from collection view and start the task execution
    func addItemToUploadQueue(item: ItemToUpload) {
        if isUserCredsValid {
            itemsForUpload.append(item)
            proceedNewUpload()

        } else {
            incorrectUserData()
        }
        
    }
    
    private func proceedNewUpload() {
        if itemsForUpload.count > 0, uploadingItem == nil {
            
            if itemsForUpload.first != nil {
                uploadingItem = itemsForUpload.first
                UploadStartedForCurrentItem()
                uploadPhotoWith(data: uploadingItem!.uploadingData)
            }
            
            itemsForUpload.remove(at: 0)
            proceedNewUpload()
            
        }
    }
    
//upload photo data on server
  private func uploadPhotoWith(data: Data) {
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else {
            
            print("BAD URL TO UPLOAD")
            uploadComplete(success:.negative)
            return
        }
        
        var request = URLRequest(url: url)
        let autorizationHeader = "Bearer" + " " + accessToken
        
        request.setValue(autorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { (receivedData, response, error) in
            
            if let unwrapedError = error {
                
                print("Erorr - \(unwrapedError.localizedDescription)")
                self.uploadComplete(success: .negative)
                
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//get and save URL of loaded photo
                if let jsonData = receivedData {
                    do {
                        let respData = try JSONDecoder().decode(UploadSuccsessfullResponseData.self, from: jsonData)
                        DataManager.shared.add(link: respData.data.link, identifier: self.uploadingItem!.identifier)
                    } catch {
                        print("\(error.localizedDescription)")
                    }
                }
                self.uploadComplete(success: .positive)
                
            } else {
                
                self.uploadComplete(success: .negative)
                print("BAD RESPONSE")
            }
            
        }
        task.resume()
        
    }
//inform collection view about bad user creds

    private func incorrectUserData() {
        delegate?.incorrectUserData()
    }
    
//inform collection view about start downloading
    private func UploadStartedForCurrentItem() {
        delegate?.uploadingStartedForItemWith(identifier: uploadingItem!.identifier)
    }
//inform collection view about finish downloading and proceed next task
    private func uploadComplete(success: UploadingResultMessage) {
        
        DispatchQueue.main.async {
            
            let identifier = self.uploadingItem!.identifier
            self.delegate?.uploadComplete(successfull: success, photoIdentifier: identifier)
            self.uploadingItem = nil
            self.proceedNewUpload()
        }
        
    }
    
    
}
