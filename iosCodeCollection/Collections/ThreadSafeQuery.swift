//
//  ThreadSafeQuery.swift
//  iosCodeCollection
//
//  Created by Herman Volzhsky on 30.11.24.
//

import Foundation

struct Adverb {
    
}

func getAdverb(id: String, completion: @escaping (Adverb) -> Void) {}

//with dictionary
func getAdverbsDictionary(ids: [String], completion: @escaping ([Adverb]) -> Void) {
    let group = DispatchGroup()
    let lock = NSLock()

    // Use a dictionary to store the results with indices as keys
    var dict: [Int: Adverb] = [:]

    ids.enumerated().forEach { index, id in
        group.enter()
        getAdverb(id: id) { adverb in
            lock.lock()
            dict[index] = adverb // Store the result with its index
            lock.unlock()
            group.leave()
        }
    }

    group.notify(queue: .main) {
        // Sort the dictionary by keys (indices), extract values, and pass them to the completion
        let sortedAdverbs = dict
            .sorted(by: { $0.key < $1.key }) // Sort by index
            .map { $0.value }               // Extract values in sorted order
        completion(sortedAdverbs)
    }
}


//with array
func getAdverbsArray(ids: [String], completion: @escaping ([Adverb]) -> Void) {
    let group = DispatchGroup()
    let lock = NSLock()
    
    // Initialize an array with `nil` placeholders
    var results: [Adverb?] = Array(repeating: nil, count: ids.count)
    
    // Iterate over `ids` with their indices
    ids.enumerated().forEach { index, id in
        group.enter()
        getAdverb(id: id) { adverb in
            lock.lock()
            results[index] = adverb // Place the result at the correct index
            lock.unlock()
            group.leave()
        }
    }
    
    // Notify when all tasks are complete
    group.notify(queue: .main) {
        // Force unwrap `results` because we know all `nil` values have been replaced
        completion(results.compactMap { $0 })
    }
}
