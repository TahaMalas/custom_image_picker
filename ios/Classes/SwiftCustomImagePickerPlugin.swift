import Flutter
import UIKit
import Photos

public class SwiftCustomImagePickerPlugin: NSObject, FlutterPlugin {
    
    var callbackById: [Int: () -> ()] = [:]
    static var channel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
 
        channel = FlutterMethodChannel(name: "custom_image_picker", binaryMessenger: registrar.messenger())
       
        let instance = SwiftCustomImagePickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func startListening(args: Any, flutterResult: FlutterResult, methodName:String ) {
        print("Method name is \(methodName)")
        
        let argsMap = args as! [String: Any]
        let currentListenerId = argsMap["id"] as! Int
        
        print("id is \(currentListenerId)")

        let fun = {
            if (self.callbackById.contains(where: { (key, _) -> Bool in
                print("does contain key \(key == currentListenerId)")
                return key == currentListenerId
            })) {
                print("inside if")
                switch methodName {
                case "getAllImages":
                    DispatchQueue.main.async {
                        var argsMap: [String: Any] = [:]
                        argsMap["id"] = currentListenerId
                        let imgManager = PHImageManager.default()
                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isSynchronous = true
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                        var allImages = [String]()

                        var totalIteration = 0
                        print("fetchResult.count : \(fetchResult.count)")

                        var savedLocalIdentifiers = [String]()

                        for index in 0..<fetchResult.count
                        {
                            let asset = fetchResult.object(at: index) as PHAsset
                            let localIdentifier = asset.localIdentifier
                            savedLocalIdentifiers.append(localIdentifier)
                            imgManager.requestImage(for: asset, targetSize: CGSize(width: 512.0, height: 512.0), contentMode: PHImageContentMode.aspectFit, options: PHImageRequestOptions(), resultHandler:{(image, info) in

                                if image != nil {
                                    var imageData: Data?
                                    if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                            imageData = image!.jpegData(compressionQuality: 0.8)
                                    }
                                    else {
                                        imageData = image!.pngData()
                                    }
                                    let guid = ProcessInfo.processInfo.globallyUniqueString;
                                    let tmpFile = String(format: "image_picker_%@.jpg", guid);
                                    let tmpDirectory = NSTemporaryDirectory();
                                    let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                                    if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                            allImages.append(tmpPath)
                                    }
                                }
                                totalIteration += 1
                                if totalIteration == (fetchResult.count) {
                                    argsMap["args"] = allImages
                                    SwiftCustomImagePickerPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                }
                            })
                        }
                    }
                    break
                case "getAlbumList":
                    DispatchQueue.main.async {
                        var argsMap: [String: Any] = [:]
                        argsMap["id"] = currentListenerId
                        var album:[PhoneAlbum] = [PhoneAlbum]()
                        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                        userAlbums.enumerateObjects{ (collection, count: Int, stop: UnsafeMutablePointer) in
                            if collection is PHAssetCollection {
                                if (collection.hasAssets()) {
                                    let image = collection.getCoverImgWithSize(CGRect())
                                    if image != nil {
                                        var imageData: Data?
                                        if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                            
                                            imageData = image!.jpegData(compressionQuality: 0.8)
                                        }
                                        else {
                                            imageData = image!.pngData()
                                        }
                                        let guid = ProcessInfo.processInfo.globallyUniqueString;
                                        let tmpFile = String(format: "image_picker_%@.jpg", guid);
                                        let tmpDirectory = NSTemporaryDirectory();
                                        let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                                        if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                           

                                            album.append(PhoneAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "", coverUri: tmpPath, photosCount: collection.photosCount))
                                        }
                                        album.forEach { (phoneAlbum) in
                                           
                                            var string = "[ "
                                            album.forEach { (phoneAlbum) in
                                                string += phoneAlbum.toJson()
                                                if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
                                                    string += ", "
                                                }
                                            }
                                            string += "]"
                                            print("String is \(string)")
                                            argsMap["args"] = string
                                            SwiftCustomImagePickerPlugin.channel.invokeMethod("callListener", arguments: argsMap)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    break
                case "getPhotosOfAlbum":
                    DispatchQueue.main.async {
                        var argsToSend: [String: Any] = [:]
                        argsToSend["id"] = currentListenerId
                        let argsContent = argsMap["args"] as! [String:Any]
                        var album:[PhonePhoto] = [PhonePhoto]()
                        var assetCollection = PHAssetCollection()
                        var albumFound = Bool()

                        DispatchQueue.main.async {
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
                            fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", argsContent["albumID"] as! String)
                            let resultCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                            if let firstObject = resultCollections.firstObject{
                                //found the album
                                assetCollection = firstObject
                                albumFound = true
                            }   else { albumFound = false }
                            let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
                            photoAssets.enumerateObjects { (collection, _, __) in
                                if collection is PHAsset{
                                    let asset = collection as! PHAsset
                                    var imageData: Data?
                                    let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                                    let image = asset.getAssetThumbnail(size: imageSize)
                                    if let cgImage = image.cgImage, cgImage.renderingIntent == .defaultIntent {
                                                                      
                                        imageData = image.jpegData(compressionQuality: 0.8)
                                    }
                                    else {
                                        imageData = image.pngData()
                                    }
                                   

                                    let guid = ProcessInfo.processInfo.globallyUniqueString;
                                    let tmpFile = String(format: "image_picker_%@.jpg", guid);
                                    let tmpDirectory = NSTemporaryDirectory();
                                    let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                                    if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                        album.append(PhonePhoto(id: asset.localIdentifier, albumName: assetCollection.localizedTitle!, photoUri: tmpPath))
                                    
                                    }

                                }
                            }
                            album.forEach { (phonePhoto) in
                                var string = "[ "
                                album.forEach { (phonePhoto) in
                                    string += phonePhoto.toJson()
                                    if (album.firstIndex(where: {$0 === phonePhoto}) != album.count - 1) {
                                        string += ", "
                                    }
                                }
                                string += "]"
                                argsToSend["args"] = string
                                SwiftCustomImagePickerPlugin.channel.invokeMethod("callListener", arguments: argsToSend)
                            }
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        callbackById[currentListenerId] = fun
        fun()
    }
    
    
    private func mapToCall(result: FlutterResult, arguments: Any?) {
        let argsMap = arguments as! [String: Any]
        let args = argsMap["id"] as! Int
        switch args {
        case 0:
            startListening(args: argsMap, flutterResult: result, methodName: "getAllImages")
            break
        case 1:
            startListening(args: argsMap, flutterResult: result, methodName: "getAlbumList")
            break
        case 2:
            startListening(args: argsMap, flutterResult: result, methodName: "getPhotosOfAlbum")
            break
        default:
            break
        }
    }
    
//    private func cancelListening(args: Any, result: FlutterResult) {
//        // Get callback id
//        let currentListenerId = args as Int
//        // Remove callback
//        callbackById.remove(currentListenerId)
//        // Do additional stuff if required to cancel the listener
//        result.success(nil)
//    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("call method \(call.method)")
        if (call.method == "startListening") {
            mapToCall(result: result, arguments: call.arguments)
        } else if (call.method == "cancelListening") {
            
        }
    
        
        else if (call.method == "getAllImages") {

            DispatchQueue.main.async {

                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                var allImages = [String]()

                var totalIteration = 0
                print("fetchResult.count : \(fetchResult.count)")

                var savedLocalIdentifiers = [String]()

                for index in 0..<fetchResult.count
                {
                    let asset = fetchResult.object(at: index) as PHAsset
                    let localIdentifier = asset.localIdentifier
                    savedLocalIdentifiers.append(localIdentifier)

                    imgManager.requestImage(for: asset, targetSize: CGSize(width: 512.0, height: 512.0), contentMode: PHImageContentMode.aspectFit, options: PHImageRequestOptions(), resultHandler:{(image, info) in

                        if image != nil {
                            var imageData: Data?
                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                imageData = image!.jpegData(compressionQuality: 0.8)
                            }
                            else {
                                imageData = image!.pngData()
                            }
                            let guid = ProcessInfo.processInfo.globallyUniqueString;
                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
                            let tmpDirectory = NSTemporaryDirectory();
                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                allImages.append(tmpPath)
                            }
                        }
                        totalIteration += 1
                        if totalIteration == (fetchResult.count) {
                            result(allImages)
                        }
                    })
                }
            }
        } else if (call.method == "getAlbums") {
            DispatchQueue.main.async {
                var album:[PhoneAlbum] = [PhoneAlbum]()

                let phResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                print("albums counts \(phResult.count)")

                phResult.enumerateObjects({ (collection, _, _) in
                    
                    print("hasAssets \(collection.hasAssets())")
                    print("photos count \(collection.photosCount)")

                    if (collection.hasAssets()) {
                        let image = collection.getCoverImgWithSize(CGRect())
                        if image != nil {
                            var imageData: Data?
                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                imageData = image!.jpegData(compressionQuality: 0.8)
                            }
                            else {
                                imageData = image!.pngData()
                            }
                            let guid = ProcessInfo.processInfo.globallyUniqueString;
                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
                            let tmpDirectory = NSTemporaryDirectory();
                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                album.append(PhoneAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "", coverUri: tmpPath, photosCount: collection.photosCount))
                                
                            }
                        }
                    }
                })
                album.forEach { (phoneAlbum) in
                    var string = "[ "
                    album.forEach { (phoneAlbum) in
                        string += phoneAlbum.toJson()
                        if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
                            string += ", "
                        }
                    }
                    string += "]"
                    result(string)
                }
            }
        } else if (call.method == "getPhotosOfAlbum") {
//            DispatchQueue.main.async {
//                var album:[PhonePhoto] = [PhonePhoto]()
//
//                let phResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
//                print("albums counts \(phResult.count)")
//
//
//
//                DispatchQueue.main.async {
//                        let fetchOptions = PHFetchOptions()
//                        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
//                        self.photos = PHAsset.fetchAssets(with: fetchOptions)
//                            album.forEach { (phoneAlbum) in
//                                var string = "[ "
//                                album.forEach { (phoneAlbum) in
//                                    string += phoneAlbum.toJson()
//                                    if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
//                                        string += ", "
//                                    }
//                                }
//                                string += "]"
//                                result(string)
//                            }
//                        result(album)
//                 }
//
//
//                phResult.enumerateObjects({ (collection, _, _) in
//
//                    if (collection.hasAssets()) {
//                        let image = collection.getCoverImgWithSize(CGRect())
//                        if image != nil {
//                            var imageData: Data?
//                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
//                                imageData = image!.jpegData(compressionQuality: 0.8)
//                            }
//                            else {
//                                imageData = image!.pngData()
//                            }
//                            let guid = ProcessInfo.processInfo.globallyUniqueString;
//                            let tmpFile = String(format: "image_picker_%@.jpg", guid);
//                            let tmpDirectory = NSTemporaryDirectory();
//                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
//                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
//                                album.append(PhoneAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "", coverUri: tmpPath, photosCount: collection.photosCount))
//                            }
//                        }
//                    }
//                })
//                album.forEach { (phoneAlbum) in
//                    var string = "[ "
//                    album.forEach { (phoneAlbum) in
//                        string += phoneAlbum.toJson()
//                        if (album.firstIndex(where: {$0 === phoneAlbum}) != album.count - 1) {
//                            string += ", "
//                        }
//                    }
//                    string += "]"
//                    result(string)
//                }
//            }
        }
   }
    
    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
//        DispatchQueue.main.async {
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//            if let collection = collection {
//                self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
//            } else {
//                self.photos = PHAsset.fetchAssets(with: fetchOptions)
//            }
//            self.collectionView.reloadData()
//        }
    }
    
    
    
}

extension PHAsset {
    
    // MARK: - Public methods
    
    func getAssetThumbnail(size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImageData(for: self, options: option) { (data, string, orientation, anyHashable) in
            print("The string is \(string) and data is \(data)")
        }
        
        return thumbnail
    }
    
    func getOrginalImage(complition:@escaping (UIImage) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info)->Void in
            image = result!
            
            complition(image)
        })
    }
    
    func getImageFromPHAsset() -> UIImage {
        var image = UIImage()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        
        if (self.mediaType == PHAssetMediaType.image) {
            PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (pickedImage, info) in
                image = pickedImage!
            })
        }
        return image
    }
    
}

extension PHAssetCollection {
    
    // MARK: - Public methods
    
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    func getCoverImgWithSize(_ size: CGRect) -> UIImage! {
        let assets = PHAsset.fetchAssets(in: self, options: nil)
        let asset = assets.firstObject
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset!, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                thumbnail = result!
        })
        
        return thumbnail
    }
    
    func hasAssets() -> Bool {
        let assets = PHAsset.fetchAssets(in: self, options: nil)
        return assets.count > 0
    }
    
}

extension PHPhotoLibrary {
    
    // MARK: - Public methods
    
    static func checkAuthorizationStatus(completion: @escaping (_ status: Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
}
