//
//  LocationViewModel.swift
//  GPSBackupApp
//
//  Created by joe on 7/7/25.
//

import SwiftUI
import CoreLocation
import MapKit
import UniformTypeIdentifiers

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: Double = 37.7749
    @Published var longitude: Double = -122.4194
    @Published var timestamp: Date? = Date()
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var unlockPassword: String = ""
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var isRecording: Bool = false
    @Published var savedLocations: [LocationRecord] = []
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var exportedFileURL: URL? = nil
    
    private let locationManager = CLLocationManager()
    private var storedPassword: String?
    private var updateTimer: Timer?
    
    override init() {
        super.init()
        print("LocationViewModel initialized")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Add some sample data for demo purposes
        addDemoDataIfNeeded()
        
        // Start a timer to simulate location updates even in simulator
        startSimulatedLocationUpdates()
    }
    
    func addDemoDataIfNeeded() {
        // Only add demo data if we don't have any saved locations
        guard savedLocations.isEmpty else { return }
        
        // Add 20 sample locations from the past hour
        let now = Date()
        for i in 0..<20 {
            // Create locations moving in a small area
            let timeAgo = Double(i) * 180 // 3 minutes apart
            let timestamp = now.addingTimeInterval(-timeAgo)
            
            // Vary the coordinates slightly to simulate movement
            let latVariation = Double.random(in: -0.001...0.001)
            let lonVariation = Double.random(in: -0.001...0.001)
            
            let record = LocationRecord(
                latitude: 37.7749 + latVariation * Double(i),
                longitude: -122.4194 + lonVariation * Double(i),
                timestamp: timestamp,
                speed: Double.random(in: 0...5),
                altitude: Double.random(in: 10...20)
            )
            savedLocations.append(record)
        }
        
        // Sort by timestamp
        savedLocations.sort { $0.timestamp > $1.timestamp }
    }
    
    func startSimulatedLocationUpdates() {
        // Create a timer that simulates location updates every 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Only add simulated locations if we're recording
            if self.isRecording {
                // Get current location or use default
                let baseLat = self.latitude
                let baseLon = self.longitude
                
                // Add small random variations to simulate movement
                let latVariation = Double.random(in: -0.0002...0.0002)
                let lonVariation = Double.random(in: -0.0002...0.0002)
                
                let newLat = baseLat + latVariation
                let newLon = baseLon + lonVariation
                
                // Create a simulated location
                let location = CLLocation(
                    coordinate: CLLocationCoordinate2D(latitude: newLat, longitude: newLon),
                    altitude: Double.random(in: 10...20),
                    horizontalAccuracy: 10,
                    verticalAccuracy: 10,
                    timestamp: Date()
                )
                
                // Process this simulated location
                DispatchQueue.main.async {
                    self.locationManager(self.locationManager, didUpdateLocations: [location])
                }
                
                print("Simulated location: \(newLat), \(newLon)")
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.timestamp = location.timestamp
            
            // Update map region to follow user
            self.mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            // If recording, save location
            if self.isRecording {
                let newRecord = LocationRecord(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timestamp: location.timestamp,
                    speed: location.speed,
                    altitude: location.altitude
                )
                self.savedLocations.append(newRecord)
                
                // Save to persistent storage periodically
                if self.savedLocations.count % 5 == 0 {
                    self.saveLocations()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        DispatchQueue.main.async {
            self.statusMessage = "Location error: \(error.localizedDescription)"
            self.isError = true
        }
    }
    
    func toggleRecording() {
        if isRecording {
            // Stop recording - requires password
            if unlockPassword == storedPassword {
                isRecording = false
                locationManager.stopUpdatingLocation()
                saveLocations()
                statusMessage = "Recording stopped and data saved"
                isError = false
                unlockPassword = ""
            } else {
                statusMessage = "Incorrect password to stop recording"
                isError = true
            }
        } else {
            // Start recording - requires setting a password
            if password.isEmpty {
                statusMessage = "Please enter a password"
                isError = true
                return
            }
            
            if password != confirmPassword {
                statusMessage = "Passwords do not match"
                isError = true
                return
            }
            
            // Request when in use authorization first
            locationManager.requestWhenInUseAuthorization()
            
            // Store the password and start recording
            storedPassword = password
            isRecording = true
            locationManager.startUpdatingLocation()
            statusMessage = "Recording started"
            isError = false
            
            // Clear the password fields
            password = ""
            confirmPassword = ""
        }
    }
    
    func saveLocations() {
        // Simple file-based storage for demo purposes
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(savedLocations)
            let fileURL = documentsDirectory.appendingPathComponent("saved_locations.json")
            try data.write(to: fileURL)
            print("Saved locations to \(fileURL)")
        } catch {
            print("Failed to save locations: \(error)")
        }
    }
    
    func loadSavedLocations() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("saved_locations.json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            savedLocations = try decoder.decode([LocationRecord].self, from: data)
        } catch {
            print("Failed to load locations: \(error)")
        }
    }
    
    func getFilteredLocations(timeInterval: TimeInterval) -> [LocationRecord] {
        let now = Date()
        return savedLocations.filter { now.timeIntervalSince($0.timestamp) <= timeInterval }
    }
    
    func shareLocations(timeInterval: TimeInterval?) -> URL? {
        var locationsToShare = savedLocations
        
        if let interval = timeInterval {
            locationsToShare = getFilteredLocations(timeInterval: interval)
        }
        
        // Format locations as CSV
        var csvString = "Timestamp,Latitude,Longitude,Altitude,Speed\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for location in locationsToShare {
            let timestamp = dateFormatter.string(from: location.timestamp)
            csvString.append("\(timestamp),\(location.latitude),\(location.longitude),\(location.altitude),\(location.speed)\n")
        }
        
        // Save to a file for sharing
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Use timestamp in filename
            let currentTimestamp = dateFormatter.string(from: Date()).replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-")
            let filename = "gps_data_\(currentTimestamp).csv"
            let fileURL = dir.appendingPathComponent(filename)
            
            do {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                print("File saved at \(fileURL)")
                statusMessage = "Data exported to CSV file: \(filename)"
                isError = false
                
                // Save the URL for sharing
                exportedFileURL = fileURL
                return fileURL
            } catch {
                print("Failed to write file: \(error)")
                statusMessage = "Failed to export data: \(error.localizedDescription)"
                isError = true
            }
        }
        
        return nil
    }
    
    // Get a list of all exported CSV files
    func getExportedFiles() -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "csv" }
        } catch {
            print("Error listing directory: \(error)")
            return []
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// Model for location records

// MARK: - Map Controls & Route

extension LocationViewModel {
    // Reset zoom to default span
    func resetZoom() {
        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    // Recenter map to current location
    func recenterMap() {
        mapRegion.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    // Polyline route for Map
    var routeLine: [CLLocationCoordinate2D] {
        savedLocations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
}

struct LocationRecord: Codable, Identifiable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let speed: CLLocationSpeed
    let altitude: CLLocationDistance
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // CodingKeys to handle UUID encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, timestamp, speed, altitude
    }
    
    init(latitude: Double, longitude: Double, timestamp: Date, speed: CLLocationSpeed, altitude: CLLocationDistance) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.speed = speed
        self.altitude = altitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        speed = try container.decode(CLLocationSpeed.self, forKey: .speed)
        altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(speed, forKey: .speed)
        try container.encode(altitude, forKey: .altitude)
    }
}
