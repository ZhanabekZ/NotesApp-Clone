//
//  CoreDataManager.swift
//  MyNotes
//
//  Created by ZhZinekenov on 03.07.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager(modelName: "MyNotes")
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
                fatalError("\(error!.localizedDescription)")
            }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error has occured while saving: \(error.localizedDescription)")
            }
        }
    }
}

 // MARK:- Helper Functions

extension CoreDataManager {
    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.lastUpdated = Date()
        note.text = ""
        save()
        
        return note
    }
    
    func fetchNotes(filterText: String? = nil) -> [Note]? {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filterText = filterText {
            let predicate = NSPredicate(format: "text contains[cd] %@", filterText)
            request.predicate = predicate
        }
        
        do {
            return(try viewContext.fetch(request))
        } catch {
            print("An error has occured while fetching notes list: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        save()
    }
    
    func createNotesFetchedResultsController(filterText: String? = nil) -> NSFetchedResultsController<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filterText = filterText {
            let predicate = NSPredicate(format: "text contains[cd] %@", filterText)
            request.predicate = predicate
        }
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}
