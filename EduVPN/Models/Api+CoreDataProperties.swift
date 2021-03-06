//
//  Api+CoreDataProperties.swift
//  EduVPN
//
//  Created by Jeroen Leenarts on 04-02-18.
//  Copyright © 2018 SURFNet. All rights reserved.
//
//

import Foundation
import CoreData

import AppAuth
import KeychainSwift

extension Api {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Api> {
        return NSFetchRequest<Api>(entityName: "Api")
    }

    @NSManaged public var apiBaseUri: String?
    @NSManaged public var instance: Instance?
    @NSManaged public var profiles: Set<Profile>
    @NSManaged public var authServer: AuthServer?

    var authorizationEndpoint: String? {
        guard let authorizationType = instance?.group?.authorizationTypeEnum else { return authServer?.authorizationEndpoint }

        switch authorizationType {
        case .local:
            return authServer?.authorizationEndpoint
        case .federated:
            return instance?.authServer?.authorizationEndpoint
        case .distributed:
            return instance?.authServer?.authorizationEndpoint ?? authServer?.authorizationEndpoint
        }
    }

    var tokenEndpoint: String? {
        guard let authorizationType = instance?.group?.authorizationTypeEnum else { return authServer?.tokenEndpoint }

        switch authorizationType {
        case .local:
            return authServer?.tokenEndpoint
        case .federated:
            return instance?.authServer?.tokenEndpoint
        case .distributed:
            return instance?.authServer?.tokenEndpoint ?? authServer?.tokenEndpoint
        }
    }

    private var authStateKeychainKey: String {
        return "\(authorizationEndpoint!)|instance-info-authState"
    }

    var authState: OIDAuthState? {
        get {
            if let data = KeychainSwift().getData(authStateKeychainKey) {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
                KeychainSwift().set(data, forKey: authStateKeychainKey)
            } else {
                KeychainSwift().delete(authStateKeychainKey)
            }
        }
    }

    private var certificateKeychainKey: String {
        return "\(authorizationEndpoint!)|certificate"
    }

    var certificateModel: CertificateModel? {
        get {
            if let data = KeychainSwift().getData(certificateKeychainKey) {
                do {
                    return try JSONDecoder().decode(CertificateModel.self, from: data)
                } catch {
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    KeychainSwift().set(data, forKey: certificateKeychainKey)
                } catch {
                }
            } else {
                KeychainSwift().delete(certificateKeychainKey)
            }
        }
    }

}

// MARK: Generated accessors for profiles
extension Api {

    @objc(addProfilesObject:)
    @NSManaged public func addToProfiles(_ value: Profile)

    @objc(removeProfilesObject:)
    @NSManaged public func removeFromProfiles(_ value: Profile)

    @objc(addProfiles:)
    @NSManaged public func addToProfiles(_ values: NSSet)

    @objc(removeProfiles:)
    @NSManaged public func removeFromProfiles(_ values: NSSet)

}
