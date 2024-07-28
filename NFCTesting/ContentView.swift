//
//  ContentView.swift
//  Testing
//
//  Created by Jon Melitski on 3/18/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var tagManager = NFCTagManager()
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(tagManager.UID != nil ? tagManager.UID! : tagManager.readerState.description)
                .onTapGesture {
                    tagManager.activateTagReader()
                }
                .onChange(of: tagManager.payload) { _ in
                }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
