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
        
        
        
        algoCases()
        // runUnitTests()
    }
    
    func algoCases() {
        
        // Example 1
        EntityCloner().computeResult(entities: [(1, "Entity 1"), (2, "Entity 2"), (3, "Entity 3"), (4, "Entity 4"), (5, "Entity5"), (6, "Entity6"), ],
                                     links: [(1, 2), (2,3), (2,4), (2,5), (5,6), (4,3), (6,2), (2,2), (6,6)],
                                     cloneEntityId: 2)
        
        
        // Example 2
        EntityCloner().computeResult(entities: [(1, "Entity 1"), (2, "Entity 2"), (3, "Entity 3"), (4, "Entity 4")],
                                     links: [],
                                     cloneEntityId: 2)
        
        
        // Example 3
        EntityCloner().computeResult(entities: [(1, "Entity 1")],
                                     links: [],
                                     cloneEntityId: 1)
        
        
        // Example 4
        EntityCloner().computeResult(entities: [(1, "Entity 1"), (2, "Entity 2"), (3, "Entity 3"), (4, "Entity 4")],
                                     links: [(1, 2), (1, 3), (2, 3), (3, 4)],
                                     cloneEntityId: 2)

    }
    
    func runUnitTests() {
        unitTest1()
        unitTest2()
        unitTest3()
    }
    func unitTest1() {
        let eCloner = EntityCloner()
        var idSet = Set<Int>()
        for _ in 0..<10000 {
            let temp = eCloner.createEntity(name: "Test name", description: "Test description")
            if idSet.contains(temp) {
                print("unitTest1 failed!!")
                return
            }
            idSet.insert(temp)
        }
        print("unitTest1 Succeeded - createEntity")
        return
    }
    func unitTest2() {
        let eCloner = EntityCloner()
        let id = eCloner.createEntity(name: "some name", description: "some Description")
        let newId = eCloner.cloneEntity(id: id)
        let oldEntity = eCloner.entityDictionary[id]
        let clonedEntity = eCloner.entityDictionary[newId]
        if (oldEntity?.name != clonedEntity?.name) || ((oldEntity?.description)! != (clonedEntity?.description)!) {
            print("unitTest2 failed!! - cloning")
            return
        }
        print("unitTest2 Succeeded - cloning entity")
        
        eCloner.createLink(id, newId)
        if (oldEntity?.outwardConnections.contains(newId))! && (clonedEntity?.inwardConnetions.contains(id))! {
            print("unitTest2 Succeeded - creating links")
        } else {
            print("unitTest2 Failed!! - creating links")
        }
    }
    
    func unitTest3() {
        let eCloner = EntityCloner()
        let id = eCloner.createEntity(name: "hello", description: "world")
        let newId = eCloner.createEntity(name: "hello2", description: "world2")
        eCloner.entityDictionary[id]?.outwardConnections.insert(newId)
        eCloner.entityDictionary[newId]?.inwardConnetions.insert(id)
        
        let tempId = eCloner.createEntity(name: "hello 33", description: "workdl 33")
        
        eCloner.copyInwardLinks(clonedId: tempId, origId: newId)
        
        if ((eCloner.entityDictionary[tempId]?.inwardConnetions.contains(id))! && (eCloner.entityDictionary[id]?.outwardConnections.contains(tempId))!) {
            print("unitTest3 Succeeded - inward links - Positive")
        } else {
            print("unitTest3 Failed!!! - Postive case")
        }
        
        if (eCloner.entityDictionary[tempId]?.inwardConnetions.contains(tempId))! {
            print("unitTest3 Failed!! - negative Test case")
        }
    }

}

class EntityCloner {
    
    var approxIdCounter = 0
    var entityDictionary = [Int: Entity]()
    
    // Generates a unique ID
    // Order - Best and average case = O(1)
    // Worst case - O(n) where n is the number of entities
    func generateUniqueId() -> Int {
        while entityDictionary[approxIdCounter] != nil {
            approxIdCounter += 1
        }
        return approxIdCounter
    }
    
    
    // Entity Class
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
    
    // creates the link by adding the relevant connections in the entities
    func createLink(_ from: Int, _ to: Int)  {
        let fromEntity = entityDictionary[from]
        let toEntity = entityDictionary[to]
        
        fromEntity?.outwardConnections.insert(to)
        toEntity?.inwardConnetions.insert(from)
    }
    
    // creates the graph and prints the result
    func computeResult(entities: [(Int, String)], links: [(Int, Int)], cloneEntityId: Int) {
        for each in entities {
            _ = createEntity(id: each.0, name: each.1, description: each.1)
        }
        
        for each in links {
            createLink(each.0, each.1)
        }
        
        deepClone(origId: cloneEntityId)
        printResult()
    }
    
    // Prints the result
    func printResult() {
        print("\n\n------Output------ \n")
        var entities = "Entities: "
        var links = "\nLinks: "
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
    
    // Handles the cloning process at a higher level
    func deepClone(origId: Int) {
        // create the primary clone
        let clonedId = cloneEntity(id: origId)
        
        // replicate the graph
        replicateGraph(origId: origId, clonedId: clonedId)
        
        // copy all incoming connections from the original to the first clone
        copyInwardLinks(clonedId: clonedId, origId: origId)
    }
    
    // used to copy the incoming links to the first node that is newly generated
    func copyInwardLinks(clonedId: Int, origId: Int) {
        let inwardSet = (entityDictionary[origId]?.inwardConnetions)!
        entityDictionary[clonedId]?.inwardConnetions = inwardSet
        
        for each in inwardSet {
            entityDictionary[each]?.outwardConnections.insert(clonedId)
        }
    }
    
    // Replicates the newly created graph
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
    
    // Makes a copy of the entity
    func cloneEntity(id: Int) -> Int {
        guard let origEntity = entityDictionary[id] else {
            print("invalid entity")
            return 0
        }
        return createEntity(name: origEntity.name, description: origEntity.description)
    }
    
    // Creates a new Entity based on the name and description parameters
    func createEntity(name: String, description: String) -> Int {
        let id = generateUniqueId()
        _ = createEntity(id: id, name: name, description: description)
        return id
    }
    
    // Returns an object of the item
    // input - ID, name , description
    // return - the reference to the generated Object
    // throws - in case it uses an existing ID
    // O(1)
    func createEntity(id: Int, name: String, description: String) -> Entity {
        let tempEntity = Entity(name: name, description: description)
        entityDictionary[id] = tempEntity
        approxIdCounter = (approxIdCounter<=id) ? (id + 1) : approxIdCounter
        return tempEntity
    }
}





