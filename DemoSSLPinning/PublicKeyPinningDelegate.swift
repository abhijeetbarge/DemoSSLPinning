//
//  PublicPinningDelegate.swift
//  DemoSSLPinning
//
//  Created by Abhijeet Barge on 04/03/21.
//

import Foundation
import Security

class PublicKeyPinningDelegate: NSObject {

    //static let  pinnedPublicKeyHash = "w7ML9y32Q724ETpipsaXQdGlw0+R2bcMHsaoodYvDMs="
    //let pinnedPublicKeyHash = "Gdbmf0GLeR880mGN9WSW1XOL6v7xsVmWO6ks0LxybzU="
    static let  pinnedPublicKeyHash = "MwCtPyljg2LOqMre3YL3U8qwvXT+QCxfCyOuiCY3bV8="

    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    private func sha256(data : Data) -> String {
           var keyWithHeader = Data(rsa2048Asn1Header)
           keyWithHeader.append(data)
           var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
           
           keyWithHeader.withUnsafeBytes {
               _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
           }
           return Data(hash).base64EncodedString()
       }
}



extension PublicKeyPinningDelegate: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            // Server public key
            let serverPublicKey = SecCertificateCopyKey(serverCertificate)
            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
            let data:Data = serverPublicKeyData as Data
            
            //let str = String(decoding: data, as: UTF8.self)
            //print("STR : \(str)")
            // Server Hash key
            let serverHashKey = sha256(data: data)
            // Local Hash Key
            //let publickKeyLocal = pinnedPublicKeyHash//type(of: self).publicKeyHash
            let publickKeyLocal = type(of: self).pinnedPublicKeyHash

            print("serverHashKey : \(serverHashKey)")
            if (serverHashKey == publickKeyLocal) {
                // Success! This is our server
                print("Public key pinning is successfully completed")
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
            }else{
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
}
