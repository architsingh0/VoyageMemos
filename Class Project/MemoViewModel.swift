//
//  MemoViewModel.swift
//  Class Project
//
//  Created by Archit Singh on 11/20/23.
//

import Foundation
import CoreData
import UIKit

class MemoViewModel: ObservableObject {
    @Published var memos: [Memo] = []
    
    private var managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        fetchMemos()
    }

    func fetchMemos() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()

        do {
            memos = try managedObjectContext.fetch(request)
        } catch {
            print("Error fetching memos: \(error)")
        }
    }

    func addMemo(title: String, text: String, images: [UIImage], forTrip trip: Trip) {
        let newMemo = Memo(context: managedObjectContext)
        newMemo.id = UUID()
        newMemo.title = title
        newMemo.text = text
        newMemo.trip = trip
        newMemo.images = images.map { convertImageToData(image: $0) } as NSObject
        memos.append(newMemo)
        saveContext()
    }

    func removeMemo(at offsets: IndexSet) {
        for index in offsets {
            let memo = memos[index]
            managedObjectContext.delete(memo)
        }
        memos.remove(atOffsets: offsets)
        saveContext()
    }

    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    private func convertImageToData(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 1.0) // Adjust compression quality as needed
    }

    private func convertDataToImage(data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

extension Memo {
    func imagesAsArray() -> [UIImage] {
        guard let imageDataArray = images as? [Data] else { return [] }
        return imageDataArray.compactMap { UIImage(data: $0) }
    }
}
