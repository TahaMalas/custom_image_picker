import Flutter
import UIKit
import Photos

public class SwiftCustomImagePickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "custom_image_picker", binaryMessenger: registrar.messenger())
    let instance = SwiftCustomImagePickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
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
            DispatchQueue.main.async {
                var album:[PhonePhoto] = [PhonePhoto]()

                let phResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                print("albums counts \(phResult.count)")
                
                
                
                DispatchQueue.main.async {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                        if let collection = collection {
                            self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                        } else {
                            self.photos = PHAsset.fetchAssets(with: fetchOptions)
                        }
                        self.collectionView.reloadData()
                 }
                
                
                phResult.enumerateObjects({ (collection, _, _) in
                    
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
