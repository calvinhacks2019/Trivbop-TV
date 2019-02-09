//
//  Connectivity.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Connectivity: NSObject, MCSessionDelegate {
    var serviceType = "trivia"

    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser? = nil

    var server: MCPeerID?

    var delegate: ConnectivityDelegate?

    func setupPeerWithDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }

    func setupSession(){
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    func advertiseSelf(advertise: Bool) {
        if advertise{
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
        }else{
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
        }
    }

    func sendData(data: Data) {
        guard let peer = server else { return }
        do {
            try self.session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            self.delegate?.error(message: "Error: \(error)")
        }
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(peerID) changed state to \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map { $0.displayName })
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieved data \(data)")
        do {
            let jsonDecoder = JSONDecoder()
            let sendable = try jsonDecoder.decode(MessageSendable.self, from: data)
            self.delegate?.recieveMessage(type: sendable.type, data: sendable.data)
        } catch {
            self.delegate?.error(message: "Error: \(error)")
        }
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

extension Connectivity: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invite from peer \(peerID)")
        invitationHandler(true, session)
        server = peerID
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error advertsing \(error)")
    }
}

