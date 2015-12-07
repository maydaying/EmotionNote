//
//  ENService.swift
//  EmotionNote
//
//  Created by youxinyu on 15/12/7.
//  Copyright © 2015年 yogayu.github.io. All rights reserved.
//

import UIKit
import Alamofire

// TODO: Get Random number
func randomIn(min min: Int, max: Int) -> Int{
    return Int(arc4random()) % (max - min + 1) + min}
// TODO: Sort emotion. Well, just bubble sort
func bubbolSort(var array: [Double]) -> [Double] {
    for var i = array.count-1;i>1; i--
    {
        for var j = 0;j < i;j++
        {
            if array[j] > array[j + 1]
            {
                let temp = array[j]
                array[j] = array[j+1]
                array[j+1] = temp
            }
        }
    }
    return array
}

struct ENService {
    // MARK: Upload image
    static func loadImgInfo(uploadimage:UIImage,response:(JSON)->()){
        
        print("begin to upload image.")
        // init paramters Dictionary
        let parameters = [
            "entities" : "true",
            "faceRectangles": "true",
        ]
        let image = uploadimage
        let imageData = UIImagePNGRepresentation(image)
        
        // CREATE AND SEND REQUEST
        let urlRequest = urlRequestWithComponents("https://api.projectoxford.ai/emotion/v1.0/recognize", parameters: parameters, imageData: imageData!)
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                //print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON {(_, _, data) -> Void in
                let emotion = JSON(data.value ?? [])
                debugPrint(emotion)
                response(emotion)
        }
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    static func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        mutableURLRequest.setValue("6e231ef52099425b90918984897ce508", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        mutableURLRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        // add image
        uploadData.appendData(imageData)
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}