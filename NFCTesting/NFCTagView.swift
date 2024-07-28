//
//  NFCTagView.swift
//  NFCTesting
//
//  Created by Jon Melitski on 3/18/24.
//

import UIKit
import SwiftUI

struct NFCTagView: UIViewControllerRepresentable {
    
    var manager: NFCTagManager
    
    init(tagManager: NFCTagManager = NFCTagManager()) {
        manager = tagManager
    }
    
    func makeUIViewController(context: Context) -> NFCTagManager {
        return manager
    }
    
    func updateUIViewController(_ uiViewController: NFCTagManager, context: Context) {
        
    }
    
    
    typealias UIViewControllerType = NFCTagManager
    
    
}
