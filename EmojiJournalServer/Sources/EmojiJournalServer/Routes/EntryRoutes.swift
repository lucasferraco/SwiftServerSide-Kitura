//
//  EntryRoutes.swift
//  EmojiJournalServer
//
//  Created by Lucas Ferraco on 03/08/18.
//

import Foundation
import LoggerAPI
import KituraContracts

private var dataStore = [String : JournalEntry]()

func initializeEntryRoutes(app: App) {
    app.router.get("/entries", handler: getAllEntries)
    app.router.post("/entries", handler: addEntry)
    app.router.delete("/entries", handler: deleteEntry)
    
    Log.info("Journal entry Routes Created")
}

func getAllEntries(_ completion: @escaping ([JournalEntry]?, RequestError?) -> Void) {
    var entries = dataStore.map { $0.value }
    entries.sort { (entry1, entry2) -> Bool in
        guard let idString1 = entry1.id, let idString2 = entry2.id else { return true }
        guard let id1 = Int(idString1), let id2 = Int(idString2) else { return true }
        return id1 < id2
    }
    
    completion(entries, nil)
}

func addEntry(entry: JournalEntry, _ completion: @escaping (JournalEntry?, RequestError?) -> Void) {
    var newEntry = entry
    newEntry.id = String(dataStore.count + 1)
    dataStore[newEntry.id!] = newEntry
    completion(newEntry, nil)
}

func deleteEntry(id: String, _ completion: @escaping (RequestError?) -> Void) {
    dataStore.removeValue(forKey: id)
    completion(nil)
}
