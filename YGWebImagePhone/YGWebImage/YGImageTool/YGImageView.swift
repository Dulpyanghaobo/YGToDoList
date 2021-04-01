//
//  YGImageView.swift
//  YGWebImage
//
//  Created by 杨皓博 on 2021/3/31.
//

import UIKit

fileprivate let _ygOperationQueue:OperationQueue = {
    let opQueue = OperationQueue.init()
    // 最大并行下载任务
    opQueue.maxConcurrentOperationCount = 5
    return opQueue
}()

fileprivate var __urlStr:String = "urlStr"

extension UIImageView
{
    var urlStr : String? {
        get {
            return objc_getAssociatedObject(self, &__urlStr) as? String
        } set {
            objc_setAssociatedObject(self, &__urlStr, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadImageWithURL(url:String) {
        // 负责执行图片下载任务
        // 缓存,bitmap在子线程操作;主线程加载图片
        self.urlStr = url
        
        let loadOperation = LoadImageOperation()
        loadOperation.imageView = self
        loadOperation.urlString = url
        
        _ygOperationQueue.addOperation(loadOperation)
        
    }
    
    /// 加载图片没有缓存
    /// - Parameter url: 图片下载路径
    func loadImageWithURLNoCache(url:String)
    {
        
    }
}
