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
    }
    
    weak var imageView : UIImageView?
    var urlString : String?
    let gyCache = YGImageCache()
    
    override func main() {
        print("开始执行任务")
    }
    
    
    func loadImageInMain(bitmap: UIImage) {
        DispatchQueue.main.async {
            
            if (self.imageView?.urlStr != self.urlString) {
                return
            }
            self.imageView?.image = bitmap
        }
    }
    
    
}
