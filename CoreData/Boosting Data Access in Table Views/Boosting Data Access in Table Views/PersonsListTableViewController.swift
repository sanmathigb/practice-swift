//
//  PersonsListTableViewController.swift
//  Boosting Data Access in Table Views
//
//  Created by Domenico Solazzo on 17/05/15.
//  License MIT
//

import UIKit
import CoreData

class PersonsListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    struct TableConstants{
        static let cellIdentifier = "Cell"
    }
    //- MARK: ViewController
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        barButtonAddPerson = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Add,
            target: self,
            action: "addNewPerson:")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Persons"
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem = barButtonAddPerson
        
        // Create the fetch request
        var fetchRequest = NSFetchRequest(entityName: "Person")
        
        // Sort descriptor
        var ageDescriptor = NSSortDescriptor(key: "age", ascending: true)
        var firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        fetchRequest.sortDescriptors = [ageDescriptor, firstNameDescriptor]
        
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.frc.delegate = self
        
        var fetchError: NSError?
        if self.frc.performFetch(&fetchError){
            println("Success")
        }else{
            if let error = fetchError{
                println("Error: \(error)")
            }
        }
    }
    
    //- MARK: NSFetchedResultsControllerDelegate
    /*
        Gets called on the delegate to let it know that the context that is backing 
        the fetched results controller has changed and that 
        the fetched results controller is about to change its contents
    */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    /*
        Gets called on the delegate to inform the delegate of specific changes made 
        to an object on the context.
    */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if type == NSFetchedResultsChangeType.Delete{
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
        if type == NSFetchedResultsChangeType.Insert{
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    /*
        Gets called on the delegate to inform it that the fetched results controller 
        was refreshed and updated as a result of an update to a managed object context.
    */
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    //- MARK: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = frc.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableConstants.cellIdentifier,
            forIndexPath: indexPath) as! UITableViewCell
        
        let person = frc.objectAtIndexPath(indexPath) as! Person
        
        cell.textLabel!.text = person.firstName + " " + person.lastName
        cell.detailTextLabel!.text = "Age: \(person.age)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let personToDelete = self.frc.objectAtIndexPath(indexPath) as! Person
        
        managedObjectContext!.deleteObject(personToDelete)
        
        if personToDelete.deleted{
            var savingError: NSError?
            
            if managedObjectContext!.save(&savingError){
                println("Successfully deleted the object")
            } else {
                if let error = savingError{
                    println("Failed to save the context with error = \(error)")
                }
            }
        }
    }
    
    
    //- MARK: Private variables
    var barButtonAddPerson: UIBarButtonItem!
    var frc: NSFetchedResultsController!
    
    //- MARK: Computed variables
    var managedObjectContext: NSManagedObjectContext?{
        return (UIApplication.sharedApplication().delegate
            as! AppDelegate).managedObjectContext
    }
    
    //- MARK: UIBarButton
    func addNewPerson(sender: AnyObject){
        /* This is a custom segue identifier that we defined in our
        storyboard that simply does a "Show" segue from our view controller
        to the "Add New Person" view controller */
        performSegueWithIdentifier("addPerson", sender: nil)
    }
}
