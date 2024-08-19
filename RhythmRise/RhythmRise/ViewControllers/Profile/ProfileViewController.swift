//
//  ProfileViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/25/24.
//

import UIKit
import SwiftUI
import Charts


// Define a new structure for play time data
struct PlayTimeDataStructure: Identifiable {
    var id: Int
    var timePlayed: Double
}

// ViewModel to handle dynamic data
class PlayTimeViewModel: ObservableObject {
    @Published var playTimeData: [PlayTimeDataStructure]
    
    init(playTime: [Double]) {
        self.playTimeData = playTime.enumerated().map { index, time in
            PlayTimeDataStructure(id: index, timePlayed: time)
        }
    }
}

// Update the ChartUIView to use the ViewModel
struct ChartUIView: View {
    @ObservedObject var viewModel: PlayTimeViewModel

    var body: some View {
        Chart {
            ForEach(viewModel.playTimeData) { playTime in
                LineMark(
                    x: .value("Day", playTime.id),
                    y: .value("Time Played", playTime.timePlayed)
                )
            }
        }
        .chartXAxis(.hidden) // Hides the X-axis labels
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
            }
        }
    }
}


// Usage example
struct ContentView: View {
    @State var playTime: [Double] = [0.0, 2.0, 4.5, 3.0, 5.0, 6.0, 7.0]
    
    var body: some View {
        ChartUIView(viewModel: PlayTimeViewModel(playTime: playTime))
    }
}

class ProfileViewController: UIViewController, DatabaseListener {
    
    var userDetails: User?
    var playTime: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var totalPlayTime: Double = 0
    
    @IBOutlet weak var PlayTimeLabel: UILabel!
    @IBOutlet weak var Chart: UIView!
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .user

    @IBOutlet var ProfileView: UIView!
    
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var FollowersCountLabel: UILabel!
    @IBOutlet weak var FollowingCountLabel: UILabel!
    @IBOutlet weak var BioLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        updatePlayTime()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    func onUserDetailsChange(change: DatabaseChange, user: User) {
        userDetails = user
        UsernameLabel.text = databaseController?.userDetails?.username
        FollowersCountLabel.text = String(userDetails?.followers.count ?? 0)
        FollowingCountLabel.text = String(userDetails?.following.count ?? 0)
        BioLabel.text = userDetails?.bio
        LocationLabel.text = userDetails?.location
        
        // Check if the user has a profile picture URL and it's not empty
        if let profilePicture = userDetails?.profilePicture, !profilePicture.isEmpty {
            // Attempt to create a URL object from the profile picture string
            if let url = URL(string: profilePicture) {
                // Create an asynchronous data task to fetch the image data
                URLSession.shared.dataTask(with: url) { data, response, error in
                    // Check if data was received successfully
                    if let data = data {
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            // Set the profile picture image with the received data
                            self.ProfilePicture.image = UIImage(data: data)
                        }
                    }
                }.resume() // Start the data task
            }
        } else {
            // Log a message if the profile picture URL is empty or nil
            print("Profile picture URL is empty or nil")
        }
    }
    
    func updateGraph() {
        // Create a ViewModel with the current playTime data
        let viewModel = PlayTimeViewModel(playTime: self.playTime)
        
        // Create a UIHostingController with the ChartUIView, passing the ViewModel
        let controller = UIHostingController(rootView: ChartUIView(viewModel: viewModel))
        
        // Ensure the controller's view is available
        guard let chartView = controller.view else {
            return
        }
        
        // Add the chartView as a subview to the Chart UIView
        Chart.addSubview(chartView)
        addChild(controller)
        
        // Set up constraints for the chartView
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: Chart.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: Chart.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: Chart.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: Chart.bottomAnchor)
        ])
        
        // Notify the controller that it has been moved to a parent view controller
        controller.didMove(toParent: self)
    }
    
    func onEquipmentsChange(change: DatabaseChange, equipments: [Equipment]) {
        // unused
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {
        updatePlayTime()
    }
    
    // converts seconds to xxh xxm xxs format
    func convertSecondsToString(seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let seconds = Int(seconds) % 60

        var timeString = ""

        if hours > 0 {
            timeString += "\(hours)h "
        }
        if minutes > 0 || hours > 0 {
            timeString += "\(minutes)m "
        }
        timeString += "\(seconds)s"

        return timeString
    }
    
    func updatePlayTime() {
        databaseController?.getActivitiesFromLast7Days{ (activities, error) in
            if let error = error {
                print("Error getting activities: \(error)")
            } else if let activities = activities {
                for activity in activities {
                    // calculate how many days ago this activity is
                    let activityDate = Date(timeIntervalSince1970: activity.timestamp!)
                    let calendar = Calendar.current
                    let now = Date()
                    let components = calendar.dateComponents([.day], from: activityDate, to: now)
                    let daysAgo = components.day!
                    
                    // the number of days corresponds to the index in playTime array
                    // add to the existing number
                    let tempPlayTime = self.playTime[daysAgo]
                    self.playTime[6-daysAgo] = tempPlayTime + activity.elapsed_time!
                    
                    self.totalPlayTime += activity.elapsed_time!
                    print(self.totalPlayTime)
                }
                self.PlayTimeLabel.text = self.convertSecondsToString(seconds: self.totalPlayTime)
                self.updateGraph()  //update graph after getting records
            }
        }
    }


    @IBAction func onPressEditProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditProfilePageSegue", sender: self)
    }
    
    
    @IBAction func onPressEquipment(_ sender: Any) {
        self.performSegue(withIdentifier: "showEquipmentPageSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfilePageSegue" {
            let destination = segue.destination as! EditProfileViewController
            destination.bio = userDetails?.bio
            destination.location = userDetails?.location
            destination.profilePictureURL = userDetails?.profilePicture
        }
    }
}
