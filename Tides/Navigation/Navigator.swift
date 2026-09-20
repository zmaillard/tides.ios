//
//  Navigation.swift
//  tides
//
//  Created by Zach Maillard on 9/20/26.
//
import Foundation

@Observable
final class Navigator {
    var path: [Screen] = []
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func handleDeepLink(_ url: URL) {
        guard let screens = parseUrl(url) else { return }
        
        path = screens
    }
    
    private func parseUrl(_ url: URL) -> [Screen]? {
        guard url.scheme == "tides" else {
            return nil
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid Url")
            return nil
        }
        
        
        var items: [Screen] = [.root]
        if let action = components.host, action == "settings" {
            items.append(.settings)
        }
        
        print(items)
        
        return items
    }
}
