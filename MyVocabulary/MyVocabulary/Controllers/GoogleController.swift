//
//  GoogleController.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import CoreXLSX

class GoogleController: NSObject, GIDSignInDelegate, ObservableObject {

    /// Indicates the status of the google sign in process.
    /// - **.ok(signedIn: Bool)** ~ when `true`, the user has signed in succesfully.
    /// When `false`, the user has signed out successfully or never has signed in.
    /// - **error(description: String)** ~ error during sign in process, `description` gives information about the error.
    enum SignInStatus: Equatable {
        case ok(signedIn: Bool)
        case error(description: String)

        static func ==(lhs: SignInStatus, rhs: SignInStatus) -> Bool {
            switch (lhs, rhs) {
            case (.error(let lhsString), .error(let rhsString)):
                // If the error is different, the status is considered as changed.
                return lhsString == rhsString
            case (.ok(let lhsSignedIn), .ok(let rhsSignedIn)):
                return lhsSignedIn == rhsSignedIn
            default:
                return false
            }
        }
    }

    /// Status of the google authetication process, initially not signed in.
    @Published var signInStatus: SignInStatus = .ok(signedIn: false)
    /// Result that contains all the spreadsheets that the current user has in its Google Drive or an error if download failed.
    @Published var spreadsheetsResult: Result<[Spreadsheet], Error>?

    private var dispatchGroup = DispatchGroup()
    private var spreadsheets: [Spreadsheet] = []
    private var googleUser: GIDGoogleUser?
    private let googleDriveService = GTLRDriveService()

    // MARK: - GIDSignInDelegate methods

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            signInStatus = .error(description: error.localizedDescription)
        } else {
            signInStatus = .ok(signedIn: true)
            googleUser = user
            googleDriveService.authorizer = googleUser?.authentication.fetcherAuthorizer()
        }
    }

    // MARK: - Google drive

    /// Closes the Google session, the Google Drive spreadsheets stop being available.
    func signOut() {
        spreadsheets = []
        GIDSignIn.sharedInstance()?.signOut()
        signInStatus = .ok(signedIn: false)
        spreadsheetsResult = nil
    }


    /// Downloads all spreadsheets from the current user's Google Drive.
    /// - Parameter completion: Code that will run at the end of the operation, successful or not.
    func fetchAllSpreadsheets(completion: @escaping () -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "drive"
        query.corpora = "user"
        query.fields = "files(id,name)"
        query.q = "mimeType = 'application/vnd.google-apps.spreadsheet'"
        // This query fetches the names and IDs of the spreadsheets.
        googleDriveService.executeQuery(query) { [weak self] _, result, error in
            guard error == nil else {
                completion()
                return
            }
            for file in (result as? GTLRDrive_FileList)?.files ?? [] {
                if let id = file.identifier, let name = file.name {
                    self?.dispatchGroup.enter()
                    self?.fetchSpreadsheet(id: id, name: name)
                }
            }
            self?.dispatchGroup.notify(queue: .main) { [weak self] in
                self?.spreadsheetsResult = .success(self?.spreadsheets ?? [])
                completion()
            }
        }
    }
}

// MARK: - Private methods

private extension GoogleController {

    func spreadsheetUrl(id: String) -> URL? {
        let mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        return URL(
            string: String(
                format: "https://www.googleapis.com/drive/v3/files/%@/export?alt=media&mimeType=%@",
                id,
                mimeType
            )
        )
    }

    func fetchSpreadsheet(id: String, name: String) {
        guard let url = spreadsheetUrl(id: id) else {
            dispatchGroup.leave()
            return
        }
        // Fetches and parses the content of each spreadsheet, given its ID.
        googleDriveService.fetcherService.fetcher(with: url).beginFetch { [weak self] data, error in
            guard error == nil, let data = data else {
                self?.dispatchGroup.leave()
                return
            }
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.generateSpreadsheet(from: data, id: id, name: name)
                self?.dispatchGroup.leave()
            }
        }
    }

    func generateSpreadsheet(from data: Data, id: String, name: String) {
        guard let file = try? XLSXFile(data: data),
              let sharedStrings = try? file.parseSharedStrings(),
              let workbooks = try? file.parseWorkbooks() else {
            return
        }
        for workbook in workbooks {
            guard let pathsAndNames = try? file.parseWorksheetPathsAndNames(workbook: workbook) else { continue }
            for (_, path) in pathsAndNames {
                guard let worksheet = try? file.parseWorksheet(at: path) else { continue }
                let translations = worksheet.data?.rows
                    .compactMap({ Spreadsheet.Translation(row: $0, sharedStrings: sharedStrings) }) ?? []
                let spreadsheet = Spreadsheet(id: id, name: name, translations: translations)
                spreadsheets.append(spreadsheet)
            }
        }
    }
}
