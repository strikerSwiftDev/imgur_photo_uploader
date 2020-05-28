

import Foundation
import  CoreData
import UIKit
// CoreData entity class
class UploadedItemEntity: NSManagedObject {
    
}



class DataManager {
    
    static let shared = DataManager()
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var links = [URL]()
    private var uploadedIdentifiers = [String]()
    
    private var uploadedEntities = [UploadedItemEntity]()
    
    private init(){
        
    }
    
// load saved data before UI initialization
    func initSavedEntities()  {
        let request: NSFetchRequest<UploadedItemEntity> = UploadedItemEntity.fetchRequest()
        
        
        do {
            uploadedEntities = try viewContext.fetch(request)
            
            for entity in uploadedEntities {
                
                if let identifier = entity.photoIdentifier {
                    uploadedIdentifiers.append(identifier)
                } else {
                    print("MISSING IDENTIFIER IN SAVED ENTITY")
                }
                
                guard let url = entity.url else {
                    print("MISSING URL IN SAVED ENTITY")
                    return
                }
                
                let range: Int = Int(entity.rangeInLst)
                links.insert(url, at: range)
            }
            
        } catch {
            print("\(error.localizedDescription)")
        }
        
        
    }
    
    
//adding URL of uploaded photo
    func add(link: URL?, identifier: String) {
        if let url = link {
            links.append(url)
        }
        
        uploadedIdentifiers.append(identifier)
        
        let uploadedEntity = UploadedItemEntity(context: viewContext)
        uploadedEntity.url = link
        uploadedEntity.photoIdentifier = identifier
        uploadedEntity.rangeInLst = Int64(links.count - 1)
        
//
//        do {
//
//            try viewContext.save()
//
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
        
    }
    
    
//uploaded photos links
    func detLinks() -> [URL] {
        return links
    }
//uploaded photos identifiers
    func getUploadedIdentifiers() -> [String] {
        return uploadedIdentifiers
    }
    
    
    
    
    
    
}
