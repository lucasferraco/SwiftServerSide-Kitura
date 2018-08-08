//
//  WebClientRoutes.swift
//  EmojiJournalServer
//
//  Created by Lucas Ferraco on 07/08/18.
//

import Foundation
import LoggerAPI
import KituraStencil
import Kitura
import CouchDB

private var database: Database?

func initializeWebClientRoutes(app: App) {
    app.router.setDefault(templateEngine: StencilTemplateEngine())
    app.router.all(middleware: StaticFileServer(path: "./public"))
    app.router.get("/client", handler: showClient)
    database = app.database
    
    Log.info("Web client routes created")
}

func showClient(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let database = database else {
        response.status(.serviceUnavailable).send(json: ["Message": "CouchDB Unavailable"])
        return
    }
    
    JournalEntry.Persistence.getAll(for: database) { (entries, error) in
        guard let entries = entries else {
            response.status(.serviceUnavailable).send(json: ["Message": error?.localizedDescription])
            return
        }
        
        let sortedEntries = entries.sorted(by: { (entry1, entry2) -> Bool in
            entry1.date.timeIntervalSince1970 > entry2.date.timeIntervalSince1970
        })
        
        var context = [String : Any]()
        var contextEntries = [[String : Any]]()
        for entry in sortedEntries {
            if let id = entry.id {
                let map = [
                    "emoji": entry.emoji,
                    "date": entry.date.displayDate,
                    "id": id,
                    "time": entry.date.displayTime,
                    "emojiBGColor": entry.backgroundColorCode
                ]
                
                contextEntries.append(map)
            }
        }
        
        context["entries"] = contextEntries
        do {
            try response.render("home.stencil", context: context)
        } catch let error {
            response.status(.internalServerError).send(error.localizedDescription)
        }
    }
}

fileprivate extension JournalEntry {
    var backgroundColorCode: String {
        guard let substring = id?.suffix(6).uppercased() else { return "000000" }
        return substring
    }
}
