//
//  Connectivity.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// https://stackoverflow.com/a/38785685/8798838

class Connectivity: NSObject, MCSessionDelegate {
    var serviceType = "trivia"

    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser? = nil

    var players: [Player] = []

    var delegate: ConnectivityDelegate?

    func setupPeerWithDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }

    func setupSession(){
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    func setupBrowser() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
    }

    func browseSelf(browse: Bool) {
        if browse {
            browser.startBrowsingForPeers()
        } else {
            browser.stopBrowsingForPeers()
        }
    }

    func advertiseSelf(advertise: Bool) {
        if advertise{
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
        } else {
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
        }
    }

    // to player nil sends to all
    func sendData(data: Data, to players: [Player]?) {
        var peers: [MCPeerID] = []
        if players == nil {
            peers = self.players.peerID()
        } else {
            peers = players!.peerID()
        }
        do {
            try self.session.send(data, toPeers: peers, with: .reliable)
        } catch {
            self.delegate?.error("Error: \(error)")
        }
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(peerID) changed state to \(state.rawValue)")
        players.removeAll()
        session.connectedPeers.forEach { peer in
            let player = Player(peerID: peer)
            players.append(player)
        }
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map { $0.displayName })
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieved data \(data)")
        self.delegate?.recieveMessage(type: .beginGame, data: "Test")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Recieved stream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Start receive resource \(resourceName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("End Recieve resouce \(resourceName)")
    }
}

extension Connectivity: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer \(peerID)")
        print("Invite peer \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer \(peerID)")
    }
}

extension Connectivity: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invite from peer \(peerID)")
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error advertsing \(error)")
    }
}
