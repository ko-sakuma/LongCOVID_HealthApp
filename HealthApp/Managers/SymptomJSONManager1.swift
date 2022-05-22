//
//  SymptomJSONManager1.swift
//  HealthApp
//
//  Created by Ko Sakuma on 22/05/2022.
//

// NOTE: SymptomJSONManager class for managing read/write symtom & timestamp: within iPhone and Apple Watch

import Foundation
import WatchConnectivity

class SymptomJSONManager: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var symptomDataArray = [SymptomData]()
    @Published var refresh: Bool = false
    
    let session: WCSession = .default
    var transfer: WCSessionFileTransfer?
    
    // MARK: - Filtering
    
    func symptoms(forDay date: Date) -> [SymptomData] {
        let allSymptoms = symptomDataArray.reversed()
        let calendar = Calendar.current
        return allSymptoms.filter({ symptom in
            guard let symptomDate = symptom.date else { return false }
            return calendar.isDate(date, inSameDayAs: symptomDate)
        })
    }

// CONNECTIVITY
    
    // MARK: - Start the session for WatchConnectivity
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("received file", String(decoding: try! Data(contentsOf: file.fileURL), as: UTF8.self))
        
        mergeUserDataWithRecords(fromJSONAt: file.fileURL)
    }
    
    // MARK: - Merge the input data between iPhone and Apple Watch
    private func mergeUserDataWithRecords(fromJSONAt url: URL) {
        var existingSymptoms = symptomData(from: .healthDataFile)
        let newSymptoms = symptomData(from: url)
        
        for symptom in newSymptoms {
            // Merge by adding records that do not exist here while not deleting anything
            if !existingSymptoms.contains(symptom) {
                existingSymptoms.append(symptom)
            }
        }
        
        // Execute
        DispatchQueue.main.async {
//            print("Received symptoms: \(newSymptoms)")
//            print("Updated symptoms to: \(existingSymptoms)")
            self.symptomDataArray = existingSymptoms
            self.save(symptoms: self.symptomDataArray)
        }
    }
    
    
    // MARK: - Start syncing the file: if there's a file transfer in progress cancel that and start a new one
    func startSync() {
        if let transfer = transfer,
           transfer.isTransferring {
            transfer.cancel()
        }
        transfer =  session.transferFile(.healthDataFile, metadata: nil)
    }
    
    // MARK: - Present the UI on appear
    func onAppear() {
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Fetch the symptomData that has been read ( Used in mergeUserDataWithRecords() )
    private func symptomData(from url: URL) -> [SymptomData] {
        // Decode with .iso8601 strategy
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let readableJson = try String(contentsOf: url,
                                          encoding: .utf8)
            let data = Data(readableJson.utf8)
            
            let jsonData = try decoder.decode(UserInputs.self, from: data)
            return jsonData.symptomData
        } catch {
            return []
        }
    }
   
    
// ENCODING PART
    // MARK: - Convert NSObject into JSON data type (is triggered when the symptom button is clicked)
    func writeJSONToFileManager(_ symptom: String, andTimeStamp timeStamp: Date) {
        // Define the 2 variables
        var symptomData = SymptomData()
        symptomData.symptom = symptom
        symptomData.timestamp = convertToString(from: timeStamp)
        
        // Append symptomData to the symptomDataArray then refresh
        symptomDataArray = self.symptomData(from: .healthDataFile)
        symptomDataArray.append(symptomData)
        refresh.toggle()
        
        save(symptoms: symptomDataArray)
        
        // Start the sync of file between iphone and watch once encoding is successful
        startSync()
    }
    
    // MARK: - Save the inputted SymptomData ( Used in mergeUserDataWithRecords() )
    private func save(symptoms: [SymptomData]) {
        
        // Encode into JSON format
        let userInput = UserInputs(symptomData: symptoms)
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(userInput)
        encoder.dateEncodingStrategy = .iso8601
        
        // Ensure the encoded JSON format is in String data type
        let jsonString = String(data: jsonData, encoding: .utf8)!
//        print(jsonString)
        
        // Write jsonString into the FileManager
        do {
            try jsonString.write(to: .healthDataFile,
                                 atomically: true,
                                 encoding: .utf8)
        } catch {
//            print("error in save()")
        }
    }
    
    
    // MARK: - Convert Date to String (keeping in iso8601 format)
    private func convertToString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: date)
    }
    
    
// DECODING PART
    
    // MARK: - Locate the Json data from the file manager where my json data is actually stored
    private func locateJSONInFileManager() -> Data? {
            do {
                let readableJson = try String(contentsOf: .healthDataFile,
                                              encoding: .utf8)
                let data = Data(readableJson.utf8)
                return data
            } catch {
//                print("error in locateJSONInFileManager()")
                return nil
            }
    }
    
    
    // MARK: - Decode the json file
    func readUserDataFromJSON() {
        // Locate the json file
        guard let data = locateJSONInFileManager() else { return }
        
        // Decode with .iso8601 strategy
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let jsonData = try decoder.decode(UserInputs.self, from: data)
//            print(jsonData)
            self.symptomDataArray = jsonData.symptomData
        } catch {
//            print("error in readUserDataFromJSON()")
        }
    }
    
    
    // MARK: - Display the timestamp in the desired format (is triggered when symptom is displayed)
    func displayTimestamp(_ timeStamp: String) -> String {
        // Format timeStamp into string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        // Get the date in the desired format to be displayed
        if let date = dateFormatter.date(from: timeStamp) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy HH:mm"
            
            return formatter.string(from: date)
        } else {
            return ""
        }
    }
    
    
// DEBUGGER
    
        #if os(iOS)
        
        // MARK: - Debugger: prints when session is inactive: "error nil"
        func sessionDidBecomeInactive(_ session: WCSession) {
            print(#function)
        }
        
        // MARK: - Debugger: prints when session is deactivated: "state 2"
        func sessionDidDeactivate(_ session: WCSession) {
            print(#function)
        }
        #else
        
        #endif
        
        // MARK: - Debugger: sync the file
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            print("error", error)
            print("state", activationState.rawValue)
            
            #if  os(iOS)
            print("paired", session.isPaired)
            #endif
            print("supported", WCSession.isSupported())
            print("reachable", session.isReachable)
            
        }
}


extension URL {
    static var documentsDirectory: Self {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }
    static var sharedDirectory: Self {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.jsonexperiments.appgroup")!
    }
    static var healthDataFile: Self {
        documentsDirectory.appendingPathComponent("userData.json")
    }
}



// NOTE: Use this code if I want to activate the WCSession when its first needed. Currently we activate it as soon as the view first appears (as per Apple's recoomendation)
//    func activateSessionIfNeeded() {
//        guard session.activationState != .activated else {
//            return
//        }
//        session.activate()
//    }

