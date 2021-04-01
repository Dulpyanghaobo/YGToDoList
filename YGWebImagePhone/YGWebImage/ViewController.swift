//
//  ViewController.swift
//  YGWebImage
//
//  Created by 杨皓博 on 2021/3/31.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView = UIImageView()
    
    let imageString : String = "https://t7.baidu.com/it/u=4036010509,3445021118&fm=193&f=GIF"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.loadImageWithURL(url: imageString)
        imageView.frame = CGRect.init(origin: CGPoint.init(x: 20, y: 80), size: CGSize(width: 200, height: 300))
        view.addSubview(imageView)
    }

    
}

