//
//  ViewController.swift
//  EntityCloner
//
//  Created by Rahul Golwalkar on 13/06/18.
//  Copyright © 2018 Rahul Golwalkar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        do {
            _ = try EntityCloner().computeResult(entities: [(1, "Entity 1"), (2, "Entity 2"), (3, "Entity 3"), (4, "Entity 4")], links: [(1, 2), (1, 3), (2, 3), (3, 4)], cloneEntityId: 2)
        } catch {
            print (error)
        }
        
    }


}

class EntityCloner {
    // rrrr proper access modifiers
    // explain the code once..
    // proper comments
    // share the order of each function
    
    var approxIdCounter = 0
    var entityDictionary = [Int: Entity]()
    
    // Order - Best and average case = O(1)
    // Worst case - O(n) where n is the number of entities
    func generateUniqueId() -> Int {
        while entityDictionary[approxIdCounter] != nil {
            approxIdCounter += 1
        }
        return approxIdCounter
    }
    
    
    class Entity {
        var name = String()
        var description = String()
        var outwardConnections = Set<Int>()
        var inwardConnetions = Set<Int>()
        
        var connected = false
        
        init (name: String, description: String) {
            self.name = name
            self.description = description
        }
    }
    
    func createLink(_ from: Int, _ to: Int)  {
//        guard let fromEntity = entityDictionary[from], let toEntity = entityDictionary[to] else {
//            throw EntityClonerError.EntityDoesntExist
//        }
        
        let fromEntity = entityDictionary[from]
        let toEntity = entityDictionary[to]
        
        fromEntity?.outwardConnections.insert(to)
        toEntity?.inwardConnetions.insert(from)
    }
    
    
    
    // Time complexity O(n+l) where n is the number of Entity nodes and l is the number of links
    func computeResult(entities: [(Int, String)], links: [(Int, Int)], cloneEntityId: Int) throws -> [Int: Entity] {
        for each in entities {
            _ = try createEntity(id: each.0, name: each.1, description: each.1)
        }
        
        for each in links {
            try createLink(each.0, each.1)
        }
        
        deepClone(origId: cloneEntityId)
        
        let eee = entityDictionary
        
        printResult()
        
        
        return entityDictionary
    }
    
    func printResult() {
        var entities = "Entities: "
        var links = "Links: "
        for each in entityDictionary {
            entities += "{\(each.key), \"\(each.value.name)\"}, "
            for i in each.value.outwardConnections {
                links += "(\(each.key), \(i)), "
            }
        }
        
        entities.removeLast(2)
        links.removeLast(2)
        
        print(entities)
        print(links)
        
    }
    
    func deepClone(origId: Int) {
        // create the primary clone
        let clonedId = cloneEntity(id: origId)
        
        // copy all incoming connections from the original to the first clone
        copyInwardLinks(clonedId: clonedId, origId: origId)
        
        // replicate the graph
        replicateGraph(origId: origId, clonedId: clonedId)
        
    }
    
    func copyInwardLinks(clonedId: Int, origId: Int) {
        let inwardSet = (entityDictionary[origId]?.inwardConnetions)!
        entityDictionary[clonedId]?.inwardConnetions = inwardSet
        
        for each in inwardSet {
            entityDictionary[each]?.outwardConnections.insert(clonedId)
        }
    }
    
    func replicateGraph(origId: Int, clonedId: Int) {
        var clonedEntityMapping = [Int:Int]()
        clonedEntityMapping[origId] = clonedId
        
        var idStack = [Int]()
        idStack.append(origId)
        
        while idStack.count != 0 {
            let poppedItem = idStack.removeLast()
            
            if entityDictionary[poppedItem]?.connected == true {
                continue
            }
            
            for each in (entityDictionary[poppedItem]?.outwardConnections)! {
                var tempEntityId = Int()
                if clonedEntityMapping[each] != nil {
                    tempEntityId = clonedEntityMapping[each]!
                } else {
                    tempEntityId = cloneEntity(id: each)
                    idStack.append(each)
                    clonedEntityMapping[each] = tempEntityId
                }
                createLink(clonedEntityMapping[poppedItem]!, tempEntityId)
            }
            entityDictionary[poppedItem]?.connected = true
            
        }
    }
    
    func cloneEntity(id: Int) -> Int {
        guard let origEntity = entityDictionary[id] else {
            print("invalid entity")
            return 0
        }
        return createEntity(name: origEntity.name, description: origEntity.description)
    }
    
    func createEntity(name: String, description: String) -> Int {
        let id = generateUniqueId()
        do {
            _ = try createEntity(id: id, name: name, description: description)
        } catch {
            print("Some issue with unique ID generator - ", error)
        }
        return id
    }
    
    
    // O(1)
    // input - ID, name , description
    // return - the reference to the generated Object
    // throws - in case it uses an existing ID
    func createEntity(id: Int, name: String, description: String) throws -> Entity {
        if (entityDictionary[id] != nil) {
            throw EntityClonerError.NonUniqueId
        }
        
        let tempEntity = Entity(name: name, description: description)
        entityDictionary[id] = tempEntity
        approxIdCounter = (approxIdCounter<=id) ? (id + 1) : approxIdCounter
        return tempEntity
    }
    
    enum EntityClonerError: String, Error {
        case NonUniqueId = "Entity created is with a non-unique ID, i.e. ID already exists"
        case EntityDoesntExist = "Entity with the given ID does not exist"
    }
}





