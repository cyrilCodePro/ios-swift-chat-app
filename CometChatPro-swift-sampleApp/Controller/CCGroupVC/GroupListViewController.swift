//
//  GroupListViewController.swift
//  CometChatUI
//
//  Created by pushpsen airekar on 18/11/18.
//  Copyright © 2018 Admin1. All rights reserved.
//

import UIKit
import CometChatPro


class GroupListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate{
    
    //Outlets Declarations
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    
    
    //Variable Declarations
    var joinedChatRoomList = [Group]()
    var othersChatRoomList = [Group]()
    var groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 10).build()
    var searchController:UISearchController!
    var refreshControl: UIRefreshControl!
    
    //This method is called when controller has loaded its view into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.createGroupObserver(notification:)), name: Notification.Name("com.newGroupData"), object: nil)
        
        //Function Calling
        self.fetchGroupList()
        groupTableView.reloadData()
        
        //Assigning Delegates
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        var isGroupLeave:String!
        if((UserDefaults.standard.value(forKey: "leaveGroupAction")) != nil){
            isGroupLeave = (UserDefaults.standard.value(forKey: "leaveGroupAction") as! String)
        }else{
            isGroupLeave = "0"
        }
        if(isGroupLeave == "1"){
            self.fetchGroupList()
            UserDefaults.standard.removeObject(forKey: "leaveGroupAction")
        }
        
        //Calling Function
        self.handleGroupListVCAppearance()
    }
    
    
    
    func fetchGroupList(){
        
        //This method fetches the grouplist from the server
        
        groupRequest.fetchNext(onSuccess: { (groupList) in
            
          if !groupList.isEmpty{
            for group in groupList {
                if(group.hasJoined == true){
                    self.joinedChatRoomList.append(group)
                    CometChatLog.print(items: "joinedChatRoomList is:",self.joinedChatRoomList)
                    
                }else{
                    self.othersChatRoomList.append(group)
                    CometChatLog.print(items:"othersChatRoomList is:",self.othersChatRoomList)
                }
            }
            DispatchQueue.main.async(execute: { self.groupTableView.reloadData()
            })
           }
        }) { (exception) in
            
            DispatchQueue.main.async(execute: {
                self.view.makeToast("\(String(describing: exception!.errorDescription))")
            })
            CometChatLog.print(items:exception?.errorDescription as Any)
        }
    }
    
    
    @objc func createGroupObserver(notification: Notification) {
        
        let newGroup:Group = notification.userInfo?["groupData"] as! Group
        
        CometChatLog.print(items:"new group is: \(newGroup.stringValue())")
        joinedChatRoomList.append(newGroup)
        DispatchQueue.main.async {self.groupTableView.reloadData()}
    }
    
    
    @objc func refresh(_ sender: Any) {
        
        if(joinedChatRoomList.isEmpty && othersChatRoomList.isEmpty){
            fetchGroupList()
        }
        refreshControl.endRefreshing()
    }
    
    
    //This method handles the UI customization for handleGroupListVC
    func  handleGroupListVCAppearance(){
        
        // ViewController Appearance
        view.backgroundColor = UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_COLOR)
        
        //Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            groupTableView.refreshControl = refreshControl
        } else {
            groupTableView.addSubview(refreshControl)
        }
        
        //TableView Appearance
        self.groupTableView.cornerRadius = CGFloat(UIAppearanceSize.CORNER_RADIUS)
        groupTableView.tableFooterView = UIView(frame: .zero)
        self.leftPadding.constant = CGFloat(UIAppearanceSize.Padding)
        self.rightPadding.constant = CGFloat(UIAppearanceSize.Padding)
        
        switch AppAppearance{
        case .AzureRadiance:self.groupTableView.separatorStyle = .none
        case .MountainMeadow:break
        case .PersianBlue:break
        case .Custom:break
        }
        
        // NavigationBar Appearance
        navigationItem.title = "Groups"
        let normalTitleforNavigationBar = [
            NSAttributedString.Key.foregroundColor: UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_TITLE_COLOR),
            NSAttributedString.Key.font: UIFont(name: SystemFont.regular.value, size: 21)!]
        navigationController?.navigationBar.titleTextAttributes = normalTitleforNavigationBar
        navigationController?.navigationBar.barTintColor = UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_COLOR)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            let letlargeTitleforNavigationBar = [
                NSAttributedString.Key.foregroundColor: UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_TITLE_COLOR),
                NSAttributedString.Key.font: UIFont(name: SystemFont.bold.value, size: 40)!]
            navigationController?.navigationBar.largeTitleTextAttributes = letlargeTitleforNavigationBar
        }
        
        // NavigationBar Buttons Appearance
        
        // notifyButton.setImage(UIImage(named: "bell.png"), for: .normal)
        createButton.setImage(UIImage(named: "new.png"), for: .normal)
        moreButton.setImage(UIImage(named: "more_vertical.png"), for: .normal)
        
        //notifyButton.tintColor = UIColor(hexFromString: UIAppearance.NAVIGATION_BAR_BUTTON_TINT_COLOR)
        createButton.tintColor = UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_BUTTON_TINT_COLOR)
        moreButton.tintColor = UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_BUTTON_TINT_COLOR)
        refreshControl.tintColor = UIColor(hexFromString: UIAppearanceColor.NAVIGATION_BAR_BUTTON_TINT_COLOR)
        
        // SearchBar Apperance
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.init(hexFromString: UIAppearanceColor.NAVIGATION_BAR_TITLE_COLOR)
        
        if(UIAppearanceColor.SEARCH_BAR_STYLE_LIGHT_CONTENT == true){
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(white: 1, alpha: 0.5)])
        }else{
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(white: 0, alpha: 0.5)])
        }
        
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        let SearchImageView = UIImageView.init()
        let SearchImage = UIImage(named: "icons8-search-30")!.withRenderingMode(.alwaysTemplate)
        SearchImageView.image = SearchImage
        SearchImageView.tintColor = UIColor.init(white: 1, alpha: 0.5)
        
        searchController.searchBar.setImage(SearchImageView.image, for: UISearchBarIcon.search, state: .normal)
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            if let backgroundview = textfield.subviews.first{
                
                // Background color
                backgroundview.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            
        }
        
    }
    
    //TableView Methods:
    
    //numberOfSections -->
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    //numberOfRowsInSection -->
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if joinedChatRoomList.isEmpty && othersChatRoomList.isEmpty{
            AMShimmer.start(for: groupTableView)
            return 15
        }else{
            AMShimmer.stop(for: groupTableView)
            if (section == 0) {
                return joinedChatRoomList.count
            } else {
                return othersChatRoomList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            if(joinedChatRoomList.count == 0)
            {
                return 0
            } else {
                return 40
            }
        } else {
            if(othersChatRoomList.count == 0)
            {
                return 0
            } else {
                return 40
            }
        }
    }
    
    //cellForRowAt indexPath -->
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "groupTableViewCell") as! GroupTableViewCell
        
   if !joinedChatRoomList.isEmpty  || !othersChatRoomList.isEmpty {
    
            var group:Group!
        
            if(indexPath.section == 0){
                group = joinedChatRoomList[indexPath.row]
            }else{
                group = othersChatRoomList[indexPath.row]
            }
            
            if(group.groupType == .password){
                cell.passwordProtected.isHidden = false
            }else{
                cell.passwordProtected.isHidden = true
            }
            cell.group = group
            cell.groupScope = group.scope.rawValue
            cell.groupName.text = group.name
            let groupIconURL = NSURL(string: group.icon ?? "")
            cell.groupAvtar.sd_setImage(with: groupIconURL as URL?, placeholderImage: #imageLiteral(resourceName: "default_user_icon"))
            cell.groupParticipants.text = group.groupDescription
            cell.UID = group.guid
            cell.groupType = group.groupType.rawValue
    
        }else{}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        groupTableView.deselectRow(at: indexPath, animated: true)
        let selectedCell:GroupTableViewCell = tableView.cellForRow(at: indexPath) as! GroupTableViewCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let oneOnOneChatViewController = storyboard.instantiateViewController(withIdentifier: "oneOnOneChatViewController") as! OneOnOneChatViewController
        oneOnOneChatViewController.buddyAvtar = selectedCell.groupAvtar.image
        oneOnOneChatViewController.buddyNameString = selectedCell.groupName.text
        oneOnOneChatViewController.buddyUID = selectedCell.UID!
        oneOnOneChatViewController.isGroup = "1"
        
        if let scope = selectedCell.groupScope {
            oneOnOneChatViewController.groupScope = scope
        }
        
        if(indexPath.section != 0){
            if(selectedCell.groupType == 2){
                let alertController = UIAlertController(title: "Enter Password", message: "Kindly, Enter the password to proceed.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "Enter Password"
                    textField.isSecureTextEntry = true
                }
                let saveAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default, handler: { alert -> Void in
                    let passwordTextfield = alertController.textFields![0] as UITextField
                    CometChat.joinGroup(GUID: selectedCell.UID, groupType: .password, password: passwordTextfield.text, onSuccess: { (success) in
    
                        DispatchQueue.main.async{
                           
                            self.view.makeToast("Group Joined Sucessfully.")
                            self.navigationController?.pushViewController(oneOnOneChatViewController, animated: true)
                            self.othersChatRoomList.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            self.joinedChatRoomList.append(selectedCell.group)
                            self.groupTableView.reloadData()
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            self.view.makeToast("Failed to join group")
                        }
                    }
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: {
                    (action : UIAlertAction!) -> Void in })
                
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                CometChat.joinGroup(GUID: selectedCell.UID, groupType: .public, password: nil, onSuccess: { (success) in

                      DispatchQueue.main.async{
                    self.view.makeToast("Group Joined Sucessfully.")
                        self.navigationController?.pushViewController(oneOnOneChatViewController, animated: true)
                        self.othersChatRoomList.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.joinedChatRoomList.append(selectedCell.group)
                        self.groupTableView.reloadData()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.view.makeToast("Failed to join group")
                    }
                }
            }
        }else{
            self.navigationController?.pushViewController(oneOnOneChatViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.row == (joinedChatRoomList.count + othersChatRoomList.count) - 1) {
            self.fetchGroupList()
        }
    }
    
    //titleForHeaderInSection indexPath -->
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if(section == 0) {
            return "Joined Groups"
        }
        else {
            return "Other Groups"
        }
    }
    
    //heightForRowAt indexPath -->
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    
    //trailingSwipeActionsConfigurationForRowAt indexPath -->
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedCell:GroupTableViewCell = tableView.cellForRow(at: indexPath) as! GroupTableViewCell
        
        let deleteAction =  UIContextualAction(style: .normal, title: "Files", handler: { (action,view,completionHandler ) in
            
            CometChat.deleteGroup(GUID: selectedCell.UID, onSuccess: { (sucess) in
                DispatchQueue.main.async {
                    self.view.makeToast("\(sucess)")
                    self.joinedChatRoomList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.groupTableView.reloadData()
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    self.view.makeToast("\(error.debugDescription)")
                }
            })
            completionHandler(true)
        })
        deleteAction.image = UIImage(named: "delete.png")
        deleteAction.backgroundColor = .red
        
        
        let leaveAction =  UIContextualAction(style: .normal, title: "Files1", handler: { (deleteAction,view,completionHandler ) in
            
            CometChat.leaveGroup(GUID: selectedCell.UID, onSuccess: { (sucess) in
                DispatchQueue.main.async {
                    self.view.makeToast("\(sucess)")
                    self.joinedChatRoomList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.othersChatRoomList.insert(selectedCell.group, at: 0)
                    self.groupTableView.reloadData()
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    self.view.makeToast("\(error.debugDescription)")
                }
            })
            
            
            completionHandler(true)
        })
        leaveAction.image = UIImage(named: "leaveGroup.png")
        leaveAction.backgroundColor = .orange
        
        var confrigation:UISwipeActionsConfiguration?
        if AMShimmer.isAnimating == false {
            if(indexPath.section == 0){
                if(selectedCell.groupScope == 0){
                    confrigation = UISwipeActionsConfiguration(actions: [deleteAction,leaveAction])
                }else{
                    confrigation = UISwipeActionsConfiguration(actions: [leaveAction])
                }
            }else{
                confrigation = UISwipeActionsConfiguration(actions: [])
            }
        }else{
            confrigation = UISwipeActionsConfiguration(actions: [])
            
        }
        return confrigation
    }
    
    //leadingSwipeActionsConfigurationForRowAt indexPath -->
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedCell:GroupTableViewCell = tableView.cellForRow(at: indexPath) as! GroupTableViewCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let CallingViewController = storyboard.instantiateViewController(withIdentifier: "callingViewController") as! CallingViewController
        
        let videoCall =  UIContextualAction(style: .normal, title: "Files", handler: { (action,view,completionHandler ) in
            completionHandler(true)
            CallingViewController.isAudioCall = "0"
            CallingViewController.isIncoming = false
            CallingViewController.userAvtarImage = selectedCell.groupAvtar.image
            CallingViewController.userNameString = selectedCell.groupName.text
            CallingViewController.callingString = "Calling ..."
            CallingViewController.callerUID = selectedCell.UID
            CallingViewController.isGroupCall = true
            self.present(CallingViewController, animated: true, completion: nil)
        })
        videoCall.image = UIImage(named: "video_call.png")
        videoCall.backgroundColor = .green
        
        
        let audioCall =  UIContextualAction(style: .normal, title: "Files1", handler: { (deleteAction,view,completionHandler ) in
            //do stuff
            completionHandler(true)
            CallingViewController.isAudioCall = "1"
            CallingViewController.isIncoming = false
            CallingViewController.userAvtarImage = selectedCell.groupAvtar.image
            CallingViewController.userNameString = selectedCell.groupName.text
            CallingViewController.callingString = "Calling ..."
            CallingViewController.callerUID = selectedCell.UID
            CallingViewController.isGroupCall = true
            self.present(CallingViewController, animated: true, completion: nil)
        })
        audioCall.image = UIImage(named: "audio_call.png")
        audioCall.backgroundColor = .blue
        
        var confrigation:UISwipeActionsConfiguration?
        if AMShimmer.isAnimating == false {
            if(indexPath.section == 0){
                confrigation = UISwipeActionsConfiguration(actions: [videoCall,audioCall])
            }
        }else{
            confrigation = UISwipeActionsConfiguration(actions: [])
        }
        return confrigation
    }
    
    //Announcement Button Pressed
    @IBAction func announcementPressed(_ sender: Any) {
        
        
        
    }
    
    //MoreSettinngs  Button Pressed
    @IBAction func morePressed(_ sender: UIView) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let CCWebviewController = storyboard.instantiateViewController(withIdentifier: "moreSettingsViewController") as! MoreSettingsViewController
        navigationController?.pushViewController(CCWebviewController, animated: true)
        CCWebviewController.title = "More"
        CCWebviewController.hidesBottomBarWhenPushed = true
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }
    
    //CreateGroup Button Pressed
    @IBAction func createGroupPressed(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let createGroupAction: UIAlertAction = UIAlertAction(title: "Create Group", style: .default) { action -> Void in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createGroupcontroller = storyboard.instantiateViewController(withIdentifier: "createGroupcontroller") as! CreateGroupcontroller
            self.navigationController?.pushViewController(createGroupcontroller, animated: false)
            createGroupcontroller.title = "Create Group"
            createGroupcontroller.hidesBottomBarWhenPushed = true
        }
        createGroupAction.setValue(UIImage(named: "createGroup.png"), forKey: "image")
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheetController.addAction(createGroupAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    
}
