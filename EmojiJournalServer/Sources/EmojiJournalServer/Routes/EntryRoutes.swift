//
//  EntryRoutes.swift
//  EmojiJournalServer
//
//  Created by Lucas Ferraco on 03/08/18.
//

import Foundation
import LoggerAPI
import KituraContracts
import CouchDB

private var database: Database?

func initializeEntryRoutes(app: App) {
    app.router.get("/entries", handler: getAllEntries)
    app.router.post("/entries", handler: addEntry)
    app.router.delete("/entries", handler: deleteEntry)
    
    database = app.database
    
    Log.info("Journal entry Routes Created")
}

func getAllEntries(_ completion: @escaping ([JournalEntry]?, RequestError?) -> Void) {
    guard let database = database else {
        completion(nil, .internalServerError)
        return
    }
    
    JournalEntry.Persistence.getAll(for: database) { (entries, error) in
        completion(entries, error as? RequestError)
    }
}

func addEntry(entry: JournalEntry, _ completion: @escaping (JournalEntry?, RequestError?) -> Void) {
    guard let database = database else {
        completion(nil, .internalServerError)
        return
    }
    
    JournalEntry.Persistence.save(entry: entry, to: database) { (id, error) in
        guard let id = id else {
            completion(nil, .notAcceptable)
            return
        }
        
        JournalEntry.Persistence.get(from: database, with: id, callback: { (entry, error) in
            completion(entry, error as? RequestError)
            return
        })
    }
}

func deleteEntry(id: String, _ completion: @escaping (RequestError?) -> Void) {
    guard let database = database else {
        completion(.internalServerError)
        return
    }
    
    JournalEntry.Persistence.delete(entryWith: id, from: database) { (error) in
        completion(error as? RequestError)
        return
    }
}
