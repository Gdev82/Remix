//  Copyright © 2017 cutting.io. All rights reserved.

import Foundation
import Entity
import Services

class GroupSelectionInteractor {

    enum SelectionType {
        case leafGroup
        case parentGroup
        case notFound
    }

    let groupService: GroupService

    init(groupService: GroupService) {
        self.groupService = groupService
    }

    func findSelectionType(for groupID: GroupID, completion: @escaping (SelectionType) -> Void) {
        groupService.fetchGroup(for: groupID) { group in
            guard let group = group else {
                completion(.notFound)
                return
            }
            let type: SelectionType = group.children.isEmpty ? .leafGroup : .parentGroup
            completion(type)
        }
    }

    func fetchGroups(parentGroupID: GroupID?, completion: @escaping ([Group]) -> Void) {
        groupService.fetchGroups() { groups in
            let filteredGroups = self.filter(groups: groups, withParentGroupID: parentGroupID)
            completion(filteredGroups)
        }
    }

    private func filter(groups: [Group], withParentGroupID parentGroupID: GroupID?) -> [Group] {
        let filteredGroups = groups.filter { group in
            group.parent == parentGroupID
        }
        return filteredGroups
    }
}