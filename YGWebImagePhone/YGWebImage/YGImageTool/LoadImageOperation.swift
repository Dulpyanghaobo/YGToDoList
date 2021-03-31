//
//  LoadImageOperation.swift
//  YGWebImage
//
//  Created by 杨皓博 on 2021/3/31.
//

import UIKit

class LoadImageOperation: Operation {
    fileprivate var __reTaskInfo = {
        return Dictionary<String, Array<UIImageView>>()
    }()
    
    weak var imageView : UIImageView?
    var urlString : String?
    let gyCache = YGImageCache()
    
    override func main() {
        print("开始执行任务")
        
        //        1 缓存查找 是否有图片
        if let cacheImage = gyCache.searchImage(imageKey: urlString) {
            //            1.1 如果图片已经存在，那么直接加载
            loadImageInMain(bitmap: cacheImage)
            return
        }
        
        
        //        上锁
        //        1.2 判断是否已经开启一个网络任务
        if var arry = self.__reTaskInfo[self.urlString ?? ""] {
            arry.append(self.imageView!)
            return
        } else {
            var arry = Array<UIImageView>()
            arry.append(self.imageView!)
            self.__reTaskInfo[self.urlString ?? ""] = arry
        }
        // 解锁
        
        // 2. 网络图片下载
        if let imageData = syncLoadImageNet() {
            if let bitmap = createBimmapImage(image: UIImage.init(data: imageData)) {
                
//                4.将图片放入缓存
                bitmap.saveImageToYGCache(fileName: urlString)
                
//                5.加载图片
                loadImageInMain(bitmap: bitmap)
                
//                6.去重
                reloadSameTask(bitmap: bitmap)
                
            }
        }
        
        
    }

    
    // 2.下载图片数据 同步操作
    /// 下载图片
    /// - Returns: ImageData
    func syncLoadImageNet() -> Data? {
        let url = URL.init(string: urlString ?? "")
        let urlSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        var imageData:Data?
        
        let netTask = urlSession.dataTask(with: url!) {
            (data,response,error) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 404 || error != nil {
                print("图片下载失败")
            } else {
                imageData = data
            }
            semaphore.signal()
        }
        
        netTask.resume()
        semaphore.wait()
        return imageData
        
    }
    
    /// 如果缓存当中有图片那么直接下载
    /// - Parameter bitmap: 从内存当中拿到图片
    func loadImageInMain(bitmap: UIImage) {
        DispatchQueue.main.async {
            
            if (self.imageView?.urlStr != self.urlString) {
                return
            }
            self.imageView?.image = bitmap
        }
    }
    
    // 3. bitmap
    func createBimmapImage(image:UIImage?) -> UIImage? {
        if image == nil {
            return nil
        }
        
        let imageRef = (image!.cgImage)!
        
        var colorSpace = imageRef.colorSpace
        if colorSpace == nil {
            colorSpace = CGColorSpaceCreateDeviceRGB()
        }
        // 1 准备好一个上下文。 创建了一个bitmapContext， Creates a bitmap graphics context
        let context =  CGContext.init(data: nil, width: imageRef.width, height: imageRef.height, bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: imageRef.bytesPerRow, space: colorSpace!, bitmapInfo: imageRef.bitmapInfo.rawValue)
        
        
        // 2 图片绘制到上下文中
        context?.draw(imageRef, in: CGRect.init(x: 0, y: 0, width: imageRef.width, height: imageRef.height))
        
        // 3 生成bitmap
        if let cgBitmapImage = context?.makeImage() {
            
            let bitmapImage = UIImage.init(cgImage: cgBitmapImage)

            return bitmapImage
        }
        
                return nil
 
    }
    
    func reloadSameTask(bitmap:UIImage)  {
        // 上锁
        if let arr = self.__reTaskInfo[self.urlString ?? ""] {
            
            for imageView in arr {
                
                if imageView == self.imageView{
                    continue
                }
                
                if imageView.urlStr == self.urlString{ // 当前的imageView是否切换任务了
                    
                    DispatchQueue.main.async {
                        imageView.image = bitmap
                    }
                }
            }
            
            self.__reTaskInfo[self.urlString!] = nil // 移除任务
        }
        
        //解锁代码自己写（防止数据脏的出现）
    }
    
}
