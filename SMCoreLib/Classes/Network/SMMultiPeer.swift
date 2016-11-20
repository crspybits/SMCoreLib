//
//  SMMultiPeer.swift
//
//  Modified from example by Ralf Ebert on 28/04/15.
//  https://www.ralfebert.de/tutorials/ios-swift-multipeer-connectivity/
//

import Foundation
import MultipeerConnectivity

public protocol SMMultiPeerDelegate : class {
    func didReceive(data data:NSData, fromPeer:String)
}

public class SMMultiPeer : NSObject {
    private let ServiceType = "SMMultiPeer"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    public weak var delegate:SMMultiPeerDelegate?
    
    public override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: self.ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.ServiceType)

        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    public lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()

    // returns true iff there was no error sending.
    public func sendData(data:NSData) -> Bool {
        var result:Bool = true
        
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                Log.error("\(error)")
                result = false
            }
        }
        else {
            result = false
        }
        
        return result
    }
    
    // returns true iff there was no error sending.
    public func sendString(string : String) -> Bool {
        return self.sendData(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
}

extension SMMultiPeer : MCNearbyServiceAdvertiserDelegate {
    
    public func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
didReceiveInvitationFromPeer peerID: MCPeerID, 
    withContext context: NSData?,
invitationHandler: (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension SMMultiPeer : MCNearbyServiceBrowserDelegate {
    
    public func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    public func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    public func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension SMMultiPeer : MCSessionDelegate {
    
    public func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    }
    
    public func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.length) bytes")
        //let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        self.delegate?.didReceive(data: data, fromPeer: peerID.displayName)
    }
    
    public func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    public func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    public func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}
