//
//  EntryPersistence.swift
//  EmojiJournalServer
//
//  Created by Lucas Ferraco on 06/08/18.
//

import Foundation
import CouchDB
import SwiftyJSON

extension JournalEntry {
    class Persistence {
        static func getAll(for database: Database, callback: @escaping (_ entries: [JournalEntry]?, _ error: NSError?) -> Void) {
            database.retrieveAll(includeDocuments: true) { (documents, error) in
                guard let docs = documents else {
                    callback(nil, error)
                    return
                }
                
                var entries = [JournalEntry]()
                for doc in docs["rows"].arrayValue {
                    let id = doc["id"].stringValue
                    let emoji = doc["doc"]["emoji"].stringValue
                    
                    guard let date = doc["doc"]["date"].dateTime else { continue }
                    if let entry = JournalEntry(id: id, emoji: emoji, date: date) {
                        entries.append(entry)
                    }
                }
                
                callback(entries, nil)
            }
        }
        
        static func save(entry: JournalEntry, to database: Database, callback: @escaping (_ entryID: String?, _ error: NSError?) -> Void) {
            getAll(for: database) { (entries, error) in
                guard let entries = entries else {
                    callback(nil, error)
                    return
                }
                
                for newEntry in entries where entry == newEntry {
                    callback(nil, NSError(domain: "EmojiJournal", code: 400, userInfo: ["localizedDescription" : "Duplicate Entry"]))
                }
                
                let body = JSON(["emoji": entry.emoji, "date": entry.date.iso8601])
                database.create(body, callback: { (id, _, _, error) in
                    callback(id, error)
                })
            }
        }
        
        static func get(from database: Database, with entryID: String, callback: @escaping (_ entry: JournalEntry?, _ error: NSError?) -> Void) {
            database.retrieve(entryID) { (document, error) in
                guard let doc = document else {
                    callback(nil, error)
                    return
                }
                
                guard let date = doc["date"].dateTime else {
                    callback(nil, error)
                    return
                }
                
                guard let entry = JournalEntry(id: doc["_id"].stringValue, emoji: doc["emoji"].stringValue, date: date) else {
                    callback(nil, error)
                    return
                }
                
                callback(entry, nil)
            }
        }
        
        static func delete(entryWith id: String, from database: Database, callback: @escaping (_ error: NSError?) -> Void) {
            database.retrieve(id) { (document, error) in
                guard let doc = document else {
                    callback(error)
                    return
                }
                
                let id = doc["_id"].stringValue
                let revision = doc["_rev"].stringValue
                
                database.delete(id, rev: revision, callback: callback)
            }
        }
    }
}
