import UIKit

// MARK: - სექცია 1 - აქ ვიყენებ კლასებს, პროტოკოლებსა და ქლოჟერებს რომ გავწყვიტო ამ კლასებს შორის ციკლური რეფერენსები (Room-Hotel, Person-Room)
class Person {
    var name: String
    var room: Room? // Strong Reference
    
    init(name: String) {
        self.name = name
        print("🟢 \(name) ინიციალიზებულია 🟢")
    }
    
    deinit {
        print("🔴 \(name) დე-ინიციალიზებულია 🔴")
    }

}

class Room {
    var unit: String
    weak var tenant: Person?
    unowned var hotel: Hotel?
    
    init(unit: String, hotel: Hotel) {
        self.unit = unit
        self.hotel = hotel
        print("🟢 ოთახი \(unit) ინიციალიზებულია 🟢")
    }
    
    deinit {
        print("🔴 ოთახი \(unit) დე-ინიციალიზებულია 🔴")
    }
    
    lazy var releasePersonReference: (() -> Void)? = { [weak self] in
        self?.tenant = nil
    }
}

class Hotel {
    var address: String
    var rooms: [Room]
    
    init(address: String) {
        self.address = address
        self.rooms = []
        print("🟢 სასტუმრო მისამართზე \(address) ინიციალიზებულია 🟢")
    }
    
    deinit {
        print("🔴 სასტუმრო მისამართზე \(address) დე-ინიციალიზებულია 🔴")
    }
}


// MARK: - ვწყვიტავთ ციკლურ რეფერენსს - პროტოკოლის გამოყენებით - Hotel-სა და Room-ს შორის (Strong Ref - Unowned Ref)

/*
protocol OwnersProtocol: AnyObject {
    func detach()
}

extension Hotel: OwnersProtocol {
    func detach() {
        for room in rooms {
            room.hotel = nil
        }
        rooms.removeAll()
        owner = nil
    }
}

extension Room: OwnersProtocol {
    func detach() {
        hotel = nil
    }
}

var hotelObject: Hotel? = Hotel(address: "Chavchavadze Ave. 38")

hotelObject?.rooms = [
    Room(unit: "101", hotel: hotelObject!),
    Room(unit: "202", hotel: hotelObject!),
    Room(unit: "303", hotel: hotelObject!)
]

// Print the initial state
print("\nსასტუმროს ოთახები:")
for room in hotelObject!.rooms {
    print(room.unit)
}

hotelObject?.detach()
hotelObject = nil
*/

// MARK: - ვწყვიტავთ ციკლურ რეფერენსს - ქლოჟერის გამოყენებით - Person-სა და Room-ს შორის (Strong Ref - Weak Ref)

/*
 var luka: Person? = Person(name: "Luka")
 var firstHotel: Hotel? = Hotel(address: "Smth Ave.")
 var room: Room? = Room(unit: "4A", hotel: firstHotel!)
 
 luka?.room = room
 room?.tenant = luka
 
 // რეფერენს ციკლს ვწყვიტავ
 room?.releasePersonReference?()
 
 luka = nil
 room = nil
 */


//MARK: - Structs
/*
struct HotelEnvironment {
    var person: Person
    var room: Room
    var hotel: Hotel
    
    init(personName: String, roomUnit: String, hotelAddress: String) {
        // Initialize hotel first
        self.hotel = Hotel(address: hotelAddress)
        
        // Initialize other properties
        self.person = Person(name: personName)
        self.room = Room(unit: roomUnit, hotel: self.hotel)
        
        // Assigning references
        self.person.room = self.room
        self.room.tenant = self.person
        self.room.hotel = self.hotel
    }
}

var hotelEnvironment: HotelEnvironment? = HotelEnvironment(personName: "Luka", roomUnit: "101", hotelAddress: "Chavchavadze 39")

print(hotelEnvironment!.person.name)
print(hotelEnvironment!.room.unit)
print(hotelEnvironment!.hotel.address)

hotelEnvironment = nil
*/

//MARK: - Enums - ობიექტების შექმნა და დიინიციალიზაცია

indirect enum User {
    case follower(Following?)
    case post(String)
    
    mutating func removeFollowingReference() {
        guard case let .follower(following) = self else { return }
        var tempFollowing = following
        tempFollowing?.removeFollowerReference()
    }
}

indirect enum Following {
    case following(User?)
    case post(Int)
    
    mutating func removeFollowerReference() {
        guard case let .following(user) = self else { return }
        var tempUser = user
        tempUser?.removeFollowingReference()
    }
}

var shvashtangiri: User? = .follower(.following(nil))
var marexi: Following? = .following(.post("123"))

shvashtangiri?.removeFollowingReference()
marexi?.removeFollowerReference()

shvashtangiri = nil
marexi = nil



