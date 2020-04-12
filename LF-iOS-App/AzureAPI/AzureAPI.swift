//
//  AzureAPI.swift
//  ServiceQueue
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import CryptoSwift
import Alamofire

// FIXME: Error handlig code should be implemented better
enum GetError: Error {
    case getFailed(error: Error?)
    case getFailed(errorString: String)
    case failedResponse(response: HTTPURLResponse)
    case unknownFail
}

class AzureAPI {
    
    // MARK: - GET Methods

    /*
     * Get API method to get data for multiple beacons.
     * Arguments:
     *  - parameters: [String : AnyObject] as assembled by ParametrizeForAPI.getBeaconsData(...)
     * Completition:
     *  - beaconsData: Optional array [BeaconData]?
     *  - getError: GetError?
     */
    class func getBeaconsData(parameters params: [String : AnyObject], initalSetOfBeacons: Set<String>, _ completion:@escaping (_ beaconsData: [DataForBeacon]?, _ getError: GetError?) -> Void) {

        AzureAPI.post(endPoint: APIEndPoints.getBeaconInfo, parameters: params) {
            (didSucceed: Bool, aFResponse: DefaultDataResponse) in

            print(" -> Calling API: getBeaconsData \(Date())")

            if !didSucceed {
                completion(nil, nil)
                return
            }

            guard
                let respData = aFResponse.data,
                let json = try? JSONSerialization.jsonObject(with: respData, options: []) as! [Any]
                else {
                    print("getBeaconData(...): Failed to get JSON serialized")
                    completion(nil, nil)
                    return
            }

            let decoder = JSONDecoder()
            var dataForBeacons = [DataForBeacon]()
            var majMinResultant = Set<String>()

            for value in json {

                guard
                    let singleJSON = try? JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted),
                    let dataForBeacon = try? decoder.decode(DataForBeacon.self, from: singleJSON)
                else {
                        continue
                }

                print("----- From API ------")
                print("name: \(String(describing: dataForBeacon.mainName))")
                print("didPerformActionA: \(dataForBeacon.didPerformActionA)")
                print("---------------------")

                // Append to list of beacons
                dataForBeacons.append(dataForBeacon)
                // Insert to set of major-minor key of this returned beacon
                majMinResultant.insert(
                    ParametrizeForAPI.majMinKey(major: dataForBeacon.major, minor: dataForBeacon.minor)
                )

            }

            // Compare initalSetOfBeacons to majMinResultant. Any key missing from
            // initalSetOfBeacons when compared to will be blacklisted
            let diff = initalSetOfBeacons.subtracting(majMinResultant)
            ParametrizeForAPI.blacklistedBeacons.formUnion(diff)
            if !diff.isEmpty {
                print("--- Beacons being blacklisted ---")
                for item in diff {
                    print(item)
                }
                print("---------------------------------")
            }

            if dataForBeacons.count != 0 {
                completion(dataForBeacons, nil)
            }
            else {
                completion(nil, nil)
            }

            return

        }
    }

    /*
     * Get API method for data being shown in SecondMainView.
     * Arguments:
     *  - parameters: [String : AnyObject] as assembled by ParametrizeForAPI.forSecondMainView()
     * Completition:
     *  - dataForBeacons: Optional array [DataForBeacon]?
     *  - getError: GetError?
     */
    class func forSecondMainView(parameters params: [String: AnyObject], _ completion:@escaping (_ dataForBeacons: [DataForBeacon]?, _ getError: GetError?) -> Void) {

        AzureAPI.post(endPoint: APIEndPoints.forSecondMainView, parameters: params) {
            (didSucceed: Bool, aFResponse: DefaultDataResponse) in

            if !didSucceed {
                completion(nil, nil)
                return
            }

            // FIXME: Create a codable list class to automatically handle a list of DataForBeacon

            // At the moment, the data that comes in (aFResponse.data) is an array of JSON objects
            // (which can be thought of as a nested JSON). First, that data object is broken down
            // into an array of Any objects. Then, each Any object is mapped to JSON form. With that
            // JSON form, we can map (using codable objects) them into out Swift objects.

            guard
                let respData = aFResponse.data,
                let json = try? JSONSerialization.jsonObject(with: respData, options: []) as! [Any]
            else {
                    print("forSecondMainView(...): Failed to get JSON serialized")
                    completion(nil, nil)
                    return
            }

            let decoder = JSONDecoder()
            var dataForBeacons = [DataForBeacon]()

            for value in json {

                guard
                    let singleJSON = try? JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted),
                    let dataForBeacon = try? decoder.decode(DataForBeacon.self, from: singleJSON)
                else {
                    continue
                }

                dataForBeacons.append(dataForBeacon)

            }

            if dataForBeacons.count != 0 {
                completion(dataForBeacons, nil)
            }
            else {
                completion(nil, nil)
            }

            return

        }

    }

    /*
     Post method for registering User
     @param:
     @completion: verificationString: String?, will return nil if the function failed to get a
        usable verfication code, else it will return a verfication code as a String
     */
    class func postRegister(parameters params: [String: AnyObject], _ completion:@escaping (_ verificationString: String?) -> Void) {
        self.post(endPoint: APIEndPoints.register, parameters: params) { (didSucceed, aFResponse) in

            guard let json = try? JSONSerialization.jsonObject(with: aFResponse.data!, options: []) as? [String] else {
                completion(nil)
                return
            }

            print("json: \(String(describing: json))")

            if
                json != nil,
                !(json!.isEmpty)
            {
                let verificationString: String = json![0]

                print("Verification string: \(json![0])")

                completion(verificationString)
            }
            else {
                print("Failed to get verification string for registration.")
                completion(nil)
            }

        }
    }

    /*
     Post method for verification during the registration process
     */
    class func postRegistrationVerify(parameters params: [String: AnyObject], _ completion:@escaping (_ didSucceed: Bool) -> Void) {
        self.post(endPoint: APIEndPoints.verify, parameters: params) { (didSucceed, aFResponse) in

            guard let json = try? JSONSerialization.jsonObject(with: aFResponse.data!, options: []) as? [String] else {
                completion(false)
                return
            }

            print("json: \(String(describing: json))")

            if json != nil, !(json!.isEmpty) {
                let mU = MainUser()

                print("User GUIID: \(json![0])")

                mU.set(gUIID: json![0])
                completion(true)
            }
            else {
                print("Failed registration.")
                completion(false)
            }

        }
    }
    
    /*
     * Calling "Action A" web API
     */
    class func performActionA(parameters params: [String: AnyObject], _ completion:@escaping (_ didSucceed: Bool) -> Void) {
        self.post(endPoint: APIEndPoints.actionA, parameters: params) { (didSucceed: Bool, aFResponse :DefaultDataResponse) in
            completion(didSucceed)
        }
    }

    /*
     * Post method for cancelling Action A by User
     */
    class func postCancelActionA(parameters params: [String: AnyObject], _ completion:@escaping (_ didSucceed: Bool) -> Void) {
        self.post(endPoint: APIEndPoints.cancelActionA, parameters: params) { (didSucceed: Bool, aFResponse :DefaultDataResponse) in
            completion(didSucceed)
        }
    }


    // MARK: - Private POST/GET

    /**
     Private class for posting to Azure's API APIEndPoints.

     Post is done through secure hashing.

     - parameter endPoint: The API endpoint (e.g.: "api/SomeEndPoint")
     - parameter parameters: [String: AnyObject], holds the data that will be passed in POST method
     - parameter completion: bool, completes true if POST method completed succesfully, else completes false.
     */
    private class func post(endPoint eP: String, parameters params: [String: AnyObject], completion: @escaping (_ didSucceed: Bool, _ aFResponse: DefaultDataResponse) -> Void) {

        let requestTimeStamp = String(Int(NSDate().timeIntervalSince1970))
        
        let postUrl = AzureAPIKeys.baseUrl + eP
        
        let requestURI: String = (postUrl).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.lowercased()
        let nonce: String = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        let signatureRawData: String = AzureAPIKeys.APPId + "POST" + requestURI + requestTimeStamp + nonce

        let sRDB: Array<UInt8> = signatureRawData.bytes

        let key: Array<UInt8> = AzureAPIKeys.APIKey.bytes

        let g = try! HMAC(key: key, variant: .sha256).authenticate(sRDB)
        let requestSignatureBase64String: String = g.toBase64()!

        let authHead = "amx " + AzureAPIKeys.APPId + ":" + requestSignatureBase64String + ":" + nonce + ":" + requestTimeStamp

        let headers: HTTPHeaders = [
            "Authorization": authHead,
            "Accept": "application/json"
        ]

        Alamofire.request(postUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (response: DefaultDataResponse) in

//            print("========================================")
//            print("Response")
//            debugPrint(response.response as Any)
//            print("Request")
//            debugPrint(response.request as Any)
//            debugPrint("allHTTPHeaderFields: ", response.request?.allHTTPHeaderFields as Any)
//            debugPrint("httpBody data: ", String(data: (response.request?.httpBody!)!, encoding: String.Encoding.utf8 ) as Any)
//            print("----------------------------------------")
//            print("Constructed params:")
//            print(params)
//            print("----------------------------------------")

            if response.error != nil {
                print("Post error.")
                completion(false, response)
                return
            }

            if
                let statCode = response.response?.statusCode,
                statCode < 200 || statCode >= 300
            {
                print("Post sever error or failure, with status code: ", statCode)
                completion(false, response)
                return
            }
            
            completion(true, response)
            return
            
        }
        
    }

}

