//
//  UIImage+.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/10/30.
//

import UIKit

extension UIImage {
    func resizeImage(width: Double, height: Double) -> UIImage {
        let targetSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

}
