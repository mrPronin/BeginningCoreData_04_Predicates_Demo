/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class DevicesTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var devices = [Device]()
    
    var selectedPerson: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedPerson = selectedPerson {
            title = "\(selectedPerson.name)'s Devices"
        } else {
            title = "Devices"
            
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(DevicesTableViewController.addDevice(_:))),
                UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(DevicesTableViewController.selectFilter(_:)))
            ]
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    func reloadData(deviceTypeFilter: String? = nil) {
        if let selectedPerson = selectedPerson {
            if let personDevices = selectedPerson.devices.allObjects as? [Device] {
                devices = personDevices
            }
        } else {
            let fetchRequest = NSFetchRequest(entityName: "Device")
            
            if let deviceTypeFilter = deviceTypeFilter {
                let filterPredicate = NSPredicate(format: "deviceType =[c] %@", deviceTypeFilter)
                fetchRequest.predicate = filterPredicate
            }
            
            do {
                if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Device] {
                    devices = results
                }
            } catch {
                fatalError("There was an error fetching the list of devices!")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceCell", forIndexPath: indexPath)
        
        let device = devices[indexPath.row]
        
        cell.textLabel?.text = device.deviceDescription
        cell.detailTextLabel?.text = "(owner name goes here)"
        
        return cell
    }
    
    // MARK: - Actions & Segues
    
    func addDevice(sender: AnyObject?) {
        performSegueWithIdentifier("deviceDetail", sender: self)
    }
    
    func selectFilter(sender: AnyObject?) {
        let sheet = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
            })
        sheet.addAction(UIAlertAction(title: "Show All", style: .Default) { (action) in
            self.reloadData()
            })
        sheet.addAction(UIAlertAction(title: "Only Phones", style: .Default) { (action) in
            self.reloadData("iphone")
            })
        sheet.addAction(UIAlertAction(title: "Only Watches", style: .Default) { (action) in
            self.reloadData("watch")
            })
        
        presentViewController(sheet, animated: true, completion: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if selectedPerson != nil && identifier == "deviceDetail" {
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? DeviceDetailTableViewController {
            dest.managedObjectContext = managedObjectContext
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let device = devices[selectedIndexPath.row]
                dest.device = device
            }
        }
    }
    
}
