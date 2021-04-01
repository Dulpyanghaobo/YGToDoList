//
//  YGImageCache.swift
//  YGWebImage
//
//  Created by 杨皓博 on 2021/3/31.
//
import UIKit

class YGImageCache {
    let cachaeDocPath : String
    
    static var imageMemoryCache = {
        return NSCache<NSString,UIImage>()
    }()
    
    fileprivate static let ygImageCache:YGImageCache = {
        return YGImageCache.init()
    }()
    
    static func shareInstance() -> YGImageCache
    {
        return ygImageCache
    }
    
    init()
    {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as NSString
        cachaeDocPath = docPath.appendingPathComponent("YGImageCache")
        if (FileManager.default.fileExists(atPath: cachaeDocPath, isDirectory: nil) == false) {
            do {
                try FileManager.default.createDirectory(atPath: cachaeDocPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("缓存文件夹创建失败:", error)
            }
        }
    }
    // 1.查找
    func searchImage(imageKey:String?) -> UIImage? {
        
        if let imageName = imageKey {
            if let cacheImage = YGImageCache.imageMemoryCache.object(forKey: imageName.ygImageFileName() as NSString) {
                return cacheImage
            }
            
            let imagefilePath = cachaeDocPath.appending("/\(imageName.ygImageFileName())")
            return UIImage.init(contentsOfFile: imagefilePath)
        }
        return nil
    }
    
}

extension UIImage {
//    保存图片到缓存
    func saveImageToYGCache(fileName:String?) {
        if let imageData = self.pngData(),let filename = fileName {
            
            // 2.1 存 cache
            YGImageCache.imageMemoryCache.setObject(self, forKey: filename.ygImageFileName() as NSString)
            
            // 2.2 存本地文件
            var filePath = YGImageCache.shareInstance().cachaeDocPath as NSString
            filePath = filePath.appendingPathComponent(filename.ygImageFileName()) as NSString
            let url = URL.init(fileURLWithPath: filePath as String)
            
            do{
                
             try  imageData.write(to: url, options: .atomicWrite)
                
            }catch{
                
                print("写入失败")
            }
        }
    }
    
}


extension String {
    func ygImageFileName() -> String {
        
        if let tmpString = self as NSString? {
        
            return tmpString.replacingOccurrences(of: "/", with: "")

        } else {
            return ""
        }
    }
    
    func ygImageMD5Key() -> String? {
        return nil
    }
}


