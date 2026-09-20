//
//  BrowseScreen.swift
//  tides
//
//  Created by Zach Maillard on 9/20/26.
//
public enum Screen: Hashable, Identifiable, Codable {
    public var id: Self {self}
    
    case root
    case settings
}
