//
//  NFCTagManager.swift
//  Testing
//
//  Created by Jon Melitski on 3/18/24.
//

import CoreNFC
import SwiftUI


class NFCTagManager: NSObject, NFCTagReaderSessionDelegate, ObservableObject {
    var session: NFCTagReaderSession?
    
    private var errorHandlers: [() -> Void] = []
    
    @Published var UID: String?
    @Published var payload: [NFCNDEFPayload]?
    @Published var readerState: ReaderState = .idle

    func activateTagReader(message: String = ReaderState.active.description) {
        resetTagReader()
        self.session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        self.session?.alertMessage = message
        self.session?.begin()
    }
    
    func resetTagReader() {
        self.session?.invalidate()
        updateUID(newUID: nil)
        updatePayload(newPayload: nil)
        updateReaderState(newState: .idle)
    }
    
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        updateReaderState(newState: .active)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        updateReaderState(newState: .error(e: error))
        
        //execute all error handlers
        errorHandlers.forEach { function in
            function()
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        updateReaderState(newState: .pending)
        if tags.count > 1 {
            session.invalidate(errorMessage: "More than one tag detected. Please try again.")
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if error != nil {
                session.invalidate(errorMessage: "Unable to connect to tag.")
            }
            
            if case let .miFare(sTag) = tag {
                sTag.readNDEF { msg, err in
                    if err != nil {
                        session.invalidate(errorMessage: err?.localizedDescription ?? "Error")
                    }
                    
                    self.updatePayload(newPayload: msg?.records ?? nil)
                    
                }
                
                
                self.updateUID(newUID: sTag.identifier.map{ String(format: "%.2hhx", $0)}.joined())
                self.updateReaderState(newState: .captured)
                session.invalidate()
            }
        }
    }
    
    func addErrorHandler(function: @escaping () -> Void) {
        errorHandlers.append(function)
    }
    
    func updateUID(newUID: String?) {
        DispatchQueue.main.async {
            self.UID = newUID
        }
    }
    
    func updatePayload(newPayload: [NFCNDEFPayload]?) {
        DispatchQueue.main.async {
            self.payload = newPayload
        }
    }
    func updateReaderState(newState: ReaderState) {
        DispatchQueue.main.async {
            self.readerState = newState
        }
    }
    
    enum ReaderState: Equatable {
        case active
        case idle
        case pending
        case captured
        case error(e: Error)
        
        var description: String {
            switch (self) {
            case .active:
                "Scan the NFC Tag."
            case .pending:
                "Processing tag."
            case .captured:
                "Tag data captured."
            case .idle:
                "Reader is inactive."
            case .error(e: let e):
                e.localizedDescription
            }
        }
        
        static func ==(lhs: ReaderState, rhs: ReaderState) -> Bool {
            switch (lhs, rhs) {
            case (let .error(err1), let .error(err2)):
                return err1.localizedDescription == err2.localizedDescription
            case (let lhs, let rhs):
                return lhs.description == rhs.description
            }
        }
    }
}
