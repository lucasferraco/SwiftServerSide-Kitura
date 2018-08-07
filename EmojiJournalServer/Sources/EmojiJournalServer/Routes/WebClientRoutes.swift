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

func initializeWebClientRoutes(app: App) {
    app.router.setDefault(templateEngine: StencilTemplateEngine())
    app.router.all(middleware: StaticFileServer(path: "./public"))
    app.router.get("/client", handler: showClient)
    
    Log.info("Web client routes created")
}

func showClient(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    var context = [String : Any]()
    context["title"] = "I'm a web developer now!"
    
    do {
        try response.render("home.stencil", context: context)
    } catch let error {
        response.status(.internalServerError).send(error.localizedDescription)
    }
}
