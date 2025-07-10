//
//  ContentView.swift
//  GPSBackupApp
//
//  Created by joe on 7/7/25.
//


import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @State private var timeFilterIndex = 3 // Default to "Hour"
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?

    let timeFilters = ["Minute", "Hour", "Day", "Week", "All"]
    let timeIntervals: [TimeInterval] = [60, 3600, 86400, 604800, Double.infinity]

    var body: some View {
        TabView {
            // Main Recording Tab
            mainView
                .tabItem {
                    Label("Record", systemImage: "record.circle")
                }

            // Map Tab
            mapView
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            // History Tab
            historyView
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            // Export Files Tab
            exportFilesView
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
        }
        .onAppear {
            locationViewModel.requestLocation()
        }
        .sheet(isPresented: $showingExportSheet) {
            exportActivityView
        }
    }

    // Main tab for recording control
    var mainView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("GPS Backup App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Location:")
                        .font(.headline)

                    Text("Latitude: \(String(format: "%.6f", locationViewModel.latitude))")
                    Text("Longitude: \(String(format: "%.6f", locationViewModel.longitude))")

                    if let timestamp = locationViewModel.timestamp {
                        Text("Time: \(timestamp.formatted(date: .abbreviated, time: .standard))")
                    }

                    if locationViewModel.isRecording {
                        Text("Recording Status: ACTIVE")
                            .foregroundColor(.green)
                            .fontWeight(.bold)

                        Text("Locations Recorded: \(locationViewModel.savedLocations.count)")
                    } else {
                        Text("Recording Status: INACTIVE")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Show password fields if not recording
                if !locationViewModel.isRecording {
                    Text("Set password to begin recording")
                        .font(.headline)

                    SecureField("Password for recording", text: $locationViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    SecureField("Confirm password", text: $locationViewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                } else {
                    // Show unlock password if recording
                    Text("Enter password to stop recording")
                        .font(.headline)

                    SecureField("Password", text: $locationViewModel.unlockPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                Button(action: {
                    locationViewModel.toggleRecording()
                }) {
                    Text(locationViewModel.isRecording ? "Stop Recording" : "Start Recording")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(locationViewModel.isRecording ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if !locationViewModel.statusMessage.isEmpty {
                    Text(locationViewModel.statusMessage)
                        .foregroundColor(locationViewModel.isError ? .red : .green)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Divider()

                // Quick Export Section
                VStack(spacing: 15) {
                    Text("Quick Export")
                        .font(.headline)

                    Button(action: {
                        exportFileURL = locationViewModel.shareLocations(timeInterval: nil)
                        showingExportSheet = true
                    }) {
                        Label("Export All Data as CSV", systemImage: "arrow.up.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .disabled(locationViewModel.savedLocations.isEmpty)
                }
                .padding()
            }
            .padding()
        }
    }

    // Map view tab
    var mapView: some View {
        VStack {
            Text("GPS Tracking Map")
                .font(.headline)
                .padding(.top)

            // Map controls
            HStack(spacing: 20) {
                Button(action: {
                    locationViewModel.mapRegion.span.latitudeDelta /= 2
                    locationViewModel.mapRegion.span.longitudeDelta /= 2
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title2)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Button(action: {
                    locationViewModel.mapRegion.span.latitudeDelta *= 2
                    locationViewModel.mapRegion.span.longitudeDelta *= 2
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title2)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Button(action: {
                    locationViewModel.resetZoom()
                }) {
                    Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                        .font(.title2)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Button(action: {
                    locationViewModel.recenterMap()
                }) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 8)

            // SwiftUI Map for pan/zoom/markers
            Map(coordinateRegion: $locationViewModel.mapRegion,
                showsUserLocation: true,
                annotationItems: locationViewModel.savedLocations) { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            }
            .edgesIgnoringSafeArea(.all)
            .frame(height: 300)

            // Polyline overlay using UIKit MapKit
            MapPolylineView(route: locationViewModel.routeLine)
                .frame(height: 300)
        }
    }

    // History view tab
    var historyView: some View {
        VStack {
            Text("Location History")
                .font(.headline)
                .padding()

            Picker("Time Range", selection: $timeFilterIndex) {
                ForEach(0..<timeFilters.count, id: \.self) { index in
                    Text(timeFilters[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            List {
                ForEach(locationViewModel.getFilteredLocations(timeInterval: timeIntervals[timeFilterIndex])) { record in
                    VStack(alignment: .leading) {
                        Text("Time: \(record.timestamp.formatted(date: .abbreviated, time: .standard))")
                            .font(.subheadline)
                        Text("Lat: \(String(format: "%.6f", record.latitude)), Long: \(String(format: "%.6f", record.longitude))")
                        Text("Altitude: \(String(format: "%.1f", record.altitude)) m, Speed: \(String(format: "%.1f", record.speed)) m/s")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }

            Button(action: {
                exportFileURL = locationViewModel.shareLocations(timeInterval: timeIntervals[timeFilterIndex])
                showingExportSheet = true
            }) {
                Label("Export \(timeFilters[timeFilterIndex]) Data", systemImage: "square.and.arrow.up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .disabled(locationViewModel.savedLocations.isEmpty)
        }
    }

    // Export files tab
    var exportFilesView: some View {
        VStack {
            Text("Exported CSV Files")
                .font(.headline)
                .padding()

            List {
                ForEach(locationViewModel.getExportedFiles(), id: \.self) { url in
                    Button(action: {
                        exportFileURL = url
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text(url.lastPathComponent)
                            Spacer()
                        }
                    }
                }
            }

            Button(action: {
                exportFileURL = locationViewModel.shareLocations(timeInterval: nil)
                showingExportSheet = true
            }) {
                Text("Create & Export New CSV File")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(locationViewModel.savedLocations.isEmpty)

            // Info text
            Text("Files are saved to app's Documents directory")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
    }

    // Export activity view - in a real app, this would use UIActivityViewController
    var exportActivityView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)

            Text("CSV File Ready")
                .font(.title)
                .fontWeight(.bold)

            if let url = exportFileURL {
                Text("File saved to:")
                    .font(.headline)

                Text(url.lastPathComponent)
                    .padding()
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text("In a real app, this would open the iOS share sheet for saving to Files, email, messaging, etc.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {
                showingExportSheet = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - Map Polyline Overlay

import MapKit

struct MapPolylineView: UIViewRepresentable {
    var route: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        let polyline = MKPolyline(coordinates: route, count: route.count)
        uiView.addOverlay(polyline)
        // Optionally, update region here if you want auto-fit
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
