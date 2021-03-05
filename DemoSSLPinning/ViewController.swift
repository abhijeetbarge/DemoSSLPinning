//
//  ViewController.swift
//  DemoSSLPinning
//
//  Created by Abhijeet Barge on 04/03/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testCertificatePinning()
    }
    
    func  testCertificatePinning() {
        if let url = NSURL(string: "https://www.google.co.uk") {

            let session = URLSession(
                    configuration: URLSessionConfiguration.ephemeral,
                    delegate: PublicKeyPinningDelegate(),
                    delegateQueue: nil)


            let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("error: \(error!.localizedDescription): \(error!)")
                } else if data != nil {
                    if let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                        print("Success **:\n")
                        //print("Received data:\n\(str)")
                    } else {
                        print("Unable to convert data to text")
                    }
                }
            })

            task.resume()
        } else {
            print("Unable to create NSURL")
        }
    }


}

