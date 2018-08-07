//
//  EmojiClient.swift
//  EmojiJournalMobileApp
//
//  Created by Lucas Ferraco on 06/08/18.
//  Copyright © 2018 Razeware. All rights reserved.
//

import UIKit
import KituraKit

enum EmojiClientError: Error {
    case couldNotLoadEntries
    case couldNotAdd(JournalEntry)
    case couldNotDelete(JournalEntry)
    case couldNotCreateClient
}

extension UIApplication {
    var isDebugMode: Bool {
        let dictionary = ProcessInfo.processInfo.environment
        return dictionary["DEBUGMODE"] != nil
    }
}

class EmojiClient {
    private static var baseURL: String {
        if UIApplication.shared.isDebugMode {
            return "http://localhost:8080"
        } else {
            return "https://learningswiftserver-emojijournalserver.mybluemix.net"
        }
    }
    
    static func getAll(_ completion: @escaping (_ entries: [JournalEntry]?, _ error: EmojiClientError?) -> Void) {
        guard let client = KituraKit(baseURL: baseURL) else { return completion(nil, EmojiClientError.couldNotCreateClient) }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        client.get("/entries") { (entries: [JournalEntry]?, error: RequestError?) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let _ = error {
                    completion(nil, EmojiClientError.couldNotLoadEntries)
                } else {
                    completion(entries?.sorted(by: { $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970 }), nil)
                }
            }
        }
    }
    
    static func add(entry: JournalEntry, _ completion: @escaping (_ entries: JournalEntry?, _ error: EmojiClientError?) -> Void) {
        guard let client = KituraKit(baseURL: baseURL) else { return completion(nil, EmojiClientError.couldNotCreateClient) }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        client.post("/entries", data: entry) { (savedEntry: JournalEntry?, error: RequestError?) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let _ = error {
                    completion(nil, EmojiClientError.couldNotAdd(entry))
                } else {
                    completion(savedEntry, nil)
                }
            }
        }
    }
    
    static func delete(entry: JournalEntry, _ completion: @escaping (_ error: EmojiClientError?) -> Void) {
        guard let client = KituraKit(baseURL: baseURL), let id = entry.id else { return completion(EmojiClientError.couldNotCreateClient) }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        client.delete("/entries", identifier: id) { (error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let _ = error {
                    completion(EmojiClientError.couldNotDelete(entry))
                } else {
                    completion(nil)
                }
            }
        }
    }
}
