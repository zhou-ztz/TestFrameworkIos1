//  This file was automatically generated and should not be edited.

import Apollo

public struct CustomStickerInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(customStickerId: GraphQLID, sequence: Swift.Optional<Int?> = nil) {
    graphQLMap = ["custom_sticker_id": customStickerId, "sequence": sequence]
  }

  public var customStickerId: GraphQLID {
    get {
      return graphQLMap["custom_sticker_id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "custom_sticker_id")
    }
  }

  public var sequence: Swift.Optional<Int?> {
    get {
      return graphQLMap["sequence"] as! Swift.Optional<Int?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sequence")
    }
  }
}

public struct StickerInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bundleId: GraphQLID, sequence: Swift.Optional<Int?> = nil) {
    graphQLMap = ["bundle_id": bundleId, "sequence": sequence]
  }

  public var bundleId: GraphQLID {
    get {
      return graphQLMap["bundle_id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bundle_id")
    }
  }

  public var sequence: Swift.Optional<Int?> {
    get {
      return graphQLMap["sequence"] as! Swift.Optional<Int?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sequence")
    }
  }
}

public final class GameBannersQuery: GraphQLQuery {
  public let operationDefinition =
    "query GameBanners {\n  gameBanners {\n    __typename\n    banner_id\n    banner_url\n    banner_sequence\n    banner_name\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("gameBanners", type: .nonNull(.list(.nonNull(.object(GameBanner.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(gameBanners: [GameBanner]) {
      self.init(unsafeResultMap: ["__typename": "Query", "gameBanners": gameBanners.map { (value: GameBanner) -> ResultMap in value.resultMap }])
    }

    public var gameBanners: [GameBanner] {
      get {
        return (resultMap["gameBanners"] as! [ResultMap]).map { (value: ResultMap) -> GameBanner in GameBanner(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: GameBanner) -> ResultMap in value.resultMap }, forKey: "gameBanners")
      }
    }

    public struct GameBanner: GraphQLSelectionSet {
      public static let possibleTypes = ["GameBanner"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("banner_id", type: .scalar(GraphQLID.self)),
        GraphQLField("banner_url", type: .scalar(String.self)),
        GraphQLField("banner_sequence", type: .scalar(Int.self)),
        GraphQLField("banner_name", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bannerId: GraphQLID? = nil, bannerUrl: String? = nil, bannerSequence: Int? = nil, bannerName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "GameBanner", "banner_id": bannerId, "banner_url": bannerUrl, "banner_sequence": bannerSequence, "banner_name": bannerName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bannerId: GraphQLID? {
        get {
          return resultMap["banner_id"] as? GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "banner_id")
        }
      }

      public var bannerUrl: String? {
        get {
          return resultMap["banner_url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "banner_url")
        }
      }

      public var bannerSequence: Int? {
        get {
          return resultMap["banner_sequence"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "banner_sequence")
        }
      }

      public var bannerName: String? {
        get {
          return resultMap["banner_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "banner_name")
        }
      }
    }
  }
}

public final class FaceUnityByCategoryQuery: GraphQLQuery {
  public let operationDefinition =
    "query FaceUnityByCategory($fu_categories_id: Int, $first: Int!, $after: String) {\n  faceUnityByCategory(fu_categories_id: $fu_categories_id, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      hasPreviousPage\n      startCursor\n      endCursor\n      total\n      count\n      currentPage\n      lastPage\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        fu_bundle_id\n        fu_categories_id\n        fu_bundle_icon\n        fu_bundle_name\n        fu_bundle_description\n        fu_bundle_sequence\n        fu_is_free\n        fu_is_show\n        fu_is_official\n        fu_is_delete\n        fu_download_count\n        fu_max_face\n        fu_face_description\n        FaceUnityBundleLists(device_type: 2) {\n          __typename\n          fu_item_path\n        }\n      }\n      cursor\n    }\n  }\n}"

  public var fu_categories_id: Int?
  public var first: Int
  public var after: String?

  public init(fu_categories_id: Int? = nil, first: Int, after: String? = nil) {
    self.fu_categories_id = fu_categories_id
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["fu_categories_id": fu_categories_id, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("faceUnityByCategory", arguments: ["fu_categories_id": GraphQLVariable("fu_categories_id"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(FaceUnityByCategory.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(faceUnityByCategory: FaceUnityByCategory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "faceUnityByCategory": faceUnityByCategory.flatMap { (value: FaceUnityByCategory) -> ResultMap in value.resultMap }])
    }

    public var faceUnityByCategory: FaceUnityByCategory? {
      get {
        return (resultMap["faceUnityByCategory"] as? ResultMap).flatMap { FaceUnityByCategory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "faceUnityByCategory")
      }
    }

    public struct FaceUnityByCategory: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnityConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnityConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("hasPreviousPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("count", type: .scalar(Int.self)),
          GraphQLField("currentPage", type: .scalar(Int.self)),
          GraphQLField("lastPage", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, hasPreviousPage: Bool, startCursor: String? = nil, endCursor: String? = nil, total: Int? = nil, count: Int? = nil, currentPage: Int? = nil, lastPage: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "hasPreviousPage": hasPreviousPage, "startCursor": startCursor, "endCursor": endCursor, "total": total, "count": count, "currentPage": currentPage, "lastPage": lastPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool {
          get {
            return resultMap["hasPreviousPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasPreviousPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Total number of node in connection.
        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }

        /// Current page of request.
        public var currentPage: Int? {
          get {
            return resultMap["currentPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "currentPage")
          }
        }

        /// Last page in connection.
        public var lastPage: Int? {
          get {
            return resultMap["lastPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "lastPage")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["FaceUnityEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "FaceUnityEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["FaceUnity"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("fu_bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("fu_categories_id", type: .scalar(Int.self)),
            GraphQLField("fu_bundle_icon", type: .scalar(String.self)),
            GraphQLField("fu_bundle_name", type: .scalar(String.self)),
            GraphQLField("fu_bundle_description", type: .scalar(String.self)),
            GraphQLField("fu_bundle_sequence", type: .scalar(Int.self)),
            GraphQLField("fu_is_free", type: .scalar(Int.self)),
            GraphQLField("fu_is_show", type: .scalar(Int.self)),
            GraphQLField("fu_is_official", type: .scalar(Int.self)),
            GraphQLField("fu_is_delete", type: .scalar(Int.self)),
            GraphQLField("fu_download_count", type: .scalar(Int.self)),
            GraphQLField("fu_max_face", type: .scalar(Int.self)),
            GraphQLField("fu_face_description", type: .scalar(String.self)),
            GraphQLField("FaceUnityBundleLists", arguments: ["device_type": 2], type: .nonNull(.list(.nonNull(.object(FaceUnityBundleList.selections))))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(fuBundleId: GraphQLID, fuCategoriesId: Int? = nil, fuBundleIcon: String? = nil, fuBundleName: String? = nil, fuBundleDescription: String? = nil, fuBundleSequence: Int? = nil, fuIsFree: Int? = nil, fuIsShow: Int? = nil, fuIsOfficial: Int? = nil, fuIsDelete: Int? = nil, fuDownloadCount: Int? = nil, fuMaxFace: Int? = nil, fuFaceDescription: String? = nil, faceUnityBundleLists: [FaceUnityBundleList]) {
            self.init(unsafeResultMap: ["__typename": "FaceUnity", "fu_bundle_id": fuBundleId, "fu_categories_id": fuCategoriesId, "fu_bundle_icon": fuBundleIcon, "fu_bundle_name": fuBundleName, "fu_bundle_description": fuBundleDescription, "fu_bundle_sequence": fuBundleSequence, "fu_is_free": fuIsFree, "fu_is_show": fuIsShow, "fu_is_official": fuIsOfficial, "fu_is_delete": fuIsDelete, "fu_download_count": fuDownloadCount, "fu_max_face": fuMaxFace, "fu_face_description": fuFaceDescription, "FaceUnityBundleLists": faceUnityBundleLists.map { (value: FaceUnityBundleList) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fuBundleId: GraphQLID {
            get {
              return resultMap["fu_bundle_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_id")
            }
          }

          public var fuCategoriesId: Int? {
            get {
              return resultMap["fu_categories_id"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_categories_id")
            }
          }

          public var fuBundleIcon: String? {
            get {
              return resultMap["fu_bundle_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_icon")
            }
          }

          public var fuBundleName: String? {
            get {
              return resultMap["fu_bundle_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_name")
            }
          }

          public var fuBundleDescription: String? {
            get {
              return resultMap["fu_bundle_description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_description")
            }
          }

          public var fuBundleSequence: Int? {
            get {
              return resultMap["fu_bundle_sequence"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_sequence")
            }
          }

          public var fuIsFree: Int? {
            get {
              return resultMap["fu_is_free"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_is_free")
            }
          }

          public var fuIsShow: Int? {
            get {
              return resultMap["fu_is_show"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_is_show")
            }
          }

          public var fuIsOfficial: Int? {
            get {
              return resultMap["fu_is_official"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_is_official")
            }
          }

          public var fuIsDelete: Int? {
            get {
              return resultMap["fu_is_delete"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_is_delete")
            }
          }

          public var fuDownloadCount: Int? {
            get {
              return resultMap["fu_download_count"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_download_count")
            }
          }

          public var fuMaxFace: Int? {
            get {
              return resultMap["fu_max_face"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_max_face")
            }
          }

          public var fuFaceDescription: String? {
            get {
              return resultMap["fu_face_description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_face_description")
            }
          }

          public var faceUnityBundleLists: [FaceUnityBundleList] {
            get {
              return (resultMap["FaceUnityBundleLists"] as! [ResultMap]).map { (value: ResultMap) -> FaceUnityBundleList in FaceUnityBundleList(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: FaceUnityBundleList) -> ResultMap in value.resultMap }, forKey: "FaceUnityBundleLists")
            }
          }

          public struct FaceUnityBundleList: GraphQLSelectionSet {
            public static let possibleTypes = ["FaceUnityBundleList"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("fu_item_path", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(fuItemPath: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "FaceUnityBundleList", "fu_item_path": fuItemPath])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fuItemPath: String? {
              get {
                return resultMap["fu_item_path"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "fu_item_path")
              }
            }
          }
        }
      }
    }
  }
}

public final class FaceUnityQuery: GraphQLQuery {
  public let operationDefinition =
    "query FaceUnity($fu_bundle_id: ID, $fu_categories_id: Int) {\n  faceUnity(fu_bundle_id: $fu_bundle_id, fu_categories_id: $fu_categories_id) {\n    __typename\n    fu_bundle_id\n    fu_categories_id\n    fu_bundle_icon\n    fu_bundle_name\n    fu_bundle_description\n    fu_bundle_sequence\n    fu_is_free\n    fu_is_show\n    fu_is_official\n    fu_is_delete\n    fu_download_count\n    fu_max_face\n    fu_face_description\n  }\n}"

  public var fu_bundle_id: GraphQLID?
  public var fu_categories_id: Int?

  public init(fu_bundle_id: GraphQLID? = nil, fu_categories_id: Int? = nil) {
    self.fu_bundle_id = fu_bundle_id
    self.fu_categories_id = fu_categories_id
  }

  public var variables: GraphQLMap? {
    return ["fu_bundle_id": fu_bundle_id, "fu_categories_id": fu_categories_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("faceUnity", arguments: ["fu_bundle_id": GraphQLVariable("fu_bundle_id"), "fu_categories_id": GraphQLVariable("fu_categories_id")], type: .nonNull(.object(FaceUnity.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(faceUnity: FaceUnity) {
      self.init(unsafeResultMap: ["__typename": "Query", "faceUnity": faceUnity.resultMap])
    }

    public var faceUnity: FaceUnity {
      get {
        return FaceUnity(unsafeResultMap: resultMap["faceUnity"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "faceUnity")
      }
    }

    public struct FaceUnity: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnity"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fu_bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("fu_categories_id", type: .scalar(Int.self)),
        GraphQLField("fu_bundle_icon", type: .scalar(String.self)),
        GraphQLField("fu_bundle_name", type: .scalar(String.self)),
        GraphQLField("fu_bundle_description", type: .scalar(String.self)),
        GraphQLField("fu_bundle_sequence", type: .scalar(Int.self)),
        GraphQLField("fu_is_free", type: .scalar(Int.self)),
        GraphQLField("fu_is_show", type: .scalar(Int.self)),
        GraphQLField("fu_is_official", type: .scalar(Int.self)),
        GraphQLField("fu_is_delete", type: .scalar(Int.self)),
        GraphQLField("fu_download_count", type: .scalar(Int.self)),
        GraphQLField("fu_max_face", type: .scalar(Int.self)),
        GraphQLField("fu_face_description", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fuBundleId: GraphQLID, fuCategoriesId: Int? = nil, fuBundleIcon: String? = nil, fuBundleName: String? = nil, fuBundleDescription: String? = nil, fuBundleSequence: Int? = nil, fuIsFree: Int? = nil, fuIsShow: Int? = nil, fuIsOfficial: Int? = nil, fuIsDelete: Int? = nil, fuDownloadCount: Int? = nil, fuMaxFace: Int? = nil, fuFaceDescription: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnity", "fu_bundle_id": fuBundleId, "fu_categories_id": fuCategoriesId, "fu_bundle_icon": fuBundleIcon, "fu_bundle_name": fuBundleName, "fu_bundle_description": fuBundleDescription, "fu_bundle_sequence": fuBundleSequence, "fu_is_free": fuIsFree, "fu_is_show": fuIsShow, "fu_is_official": fuIsOfficial, "fu_is_delete": fuIsDelete, "fu_download_count": fuDownloadCount, "fu_max_face": fuMaxFace, "fu_face_description": fuFaceDescription])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fuBundleId: GraphQLID {
        get {
          return resultMap["fu_bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_id")
        }
      }

      public var fuCategoriesId: Int? {
        get {
          return resultMap["fu_categories_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_categories_id")
        }
      }

      public var fuBundleIcon: String? {
        get {
          return resultMap["fu_bundle_icon"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_icon")
        }
      }

      public var fuBundleName: String? {
        get {
          return resultMap["fu_bundle_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_name")
        }
      }

      public var fuBundleDescription: String? {
        get {
          return resultMap["fu_bundle_description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_description")
        }
      }

      public var fuBundleSequence: Int? {
        get {
          return resultMap["fu_bundle_sequence"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_sequence")
        }
      }

      public var fuIsFree: Int? {
        get {
          return resultMap["fu_is_free"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_free")
        }
      }

      public var fuIsShow: Int? {
        get {
          return resultMap["fu_is_show"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_show")
        }
      }

      public var fuIsOfficial: Int? {
        get {
          return resultMap["fu_is_official"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_official")
        }
      }

      public var fuIsDelete: Int? {
        get {
          return resultMap["fu_is_delete"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_delete")
        }
      }

      public var fuDownloadCount: Int? {
        get {
          return resultMap["fu_download_count"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_download_count")
        }
      }

      public var fuMaxFace: Int? {
        get {
          return resultMap["fu_max_face"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_max_face")
        }
      }

      public var fuFaceDescription: String? {
        get {
          return resultMap["fu_face_description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_face_description")
        }
      }
    }
  }
}

public final class FaceUnityCategoriesQuery: GraphQLQuery {
  public let operationDefinition =
    "query FaceUnityCategories($first: Int!, $after: String) {\n  FaceUnityCategories(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      hasPreviousPage\n      startCursor\n      endCursor\n      total\n      count\n      currentPage\n      lastPage\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        fu_categories_id\n        fu_categories_name\n        fu_folder_name\n        fu_is_show\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("FaceUnityCategories", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(FaceUnityCategory.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(faceUnityCategories: FaceUnityCategory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "FaceUnityCategories": faceUnityCategories.flatMap { (value: FaceUnityCategory) -> ResultMap in value.resultMap }])
    }

    public var faceUnityCategories: FaceUnityCategory? {
      get {
        return (resultMap["FaceUnityCategories"] as? ResultMap).flatMap { FaceUnityCategory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "FaceUnityCategories")
      }
    }

    public struct FaceUnityCategory: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnityCategoryConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnityCategoryConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("hasPreviousPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("count", type: .scalar(Int.self)),
          GraphQLField("currentPage", type: .scalar(Int.self)),
          GraphQLField("lastPage", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, hasPreviousPage: Bool, startCursor: String? = nil, endCursor: String? = nil, total: Int? = nil, count: Int? = nil, currentPage: Int? = nil, lastPage: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "hasPreviousPage": hasPreviousPage, "startCursor": startCursor, "endCursor": endCursor, "total": total, "count": count, "currentPage": currentPage, "lastPage": lastPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool {
          get {
            return resultMap["hasPreviousPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasPreviousPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Total number of node in connection.
        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }

        /// Current page of request.
        public var currentPage: Int? {
          get {
            return resultMap["currentPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "currentPage")
          }
        }

        /// Last page in connection.
        public var lastPage: Int? {
          get {
            return resultMap["lastPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "lastPage")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["FaceUnityCategoryEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "FaceUnityCategoryEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["FaceUnityCategory"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("fu_categories_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("fu_categories_name", type: .scalar(String.self)),
            GraphQLField("fu_folder_name", type: .scalar(String.self)),
            GraphQLField("fu_is_show", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(fuCategoriesId: GraphQLID, fuCategoriesName: String? = nil, fuFolderName: String? = nil, fuIsShow: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "FaceUnityCategory", "fu_categories_id": fuCategoriesId, "fu_categories_name": fuCategoriesName, "fu_folder_name": fuFolderName, "fu_is_show": fuIsShow])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fuCategoriesId: GraphQLID {
            get {
              return resultMap["fu_categories_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_categories_id")
            }
          }

          public var fuCategoriesName: String? {
            get {
              return resultMap["fu_categories_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_categories_name")
            }
          }

          public var fuFolderName: String? {
            get {
              return resultMap["fu_folder_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_folder_name")
            }
          }

          public var fuIsShow: Int? {
            get {
              return resultMap["fu_is_show"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_is_show")
            }
          }
        }
      }
    }
  }
}

public final class FaceUnityBundleListsQuery: GraphQLQuery {
  public let operationDefinition =
    "query FaceUnityBundleLists($first: Int!, $after: String) {\n  faceUnityBundleLists(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      hasPreviousPage\n      startCursor\n      endCursor\n      total\n      count\n      currentPage\n      lastPage\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        fu_bundle_id\n        fu_device_type\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("faceUnityBundleLists", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(FaceUnityBundleList.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(faceUnityBundleLists: FaceUnityBundleList? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "faceUnityBundleLists": faceUnityBundleLists.flatMap { (value: FaceUnityBundleList) -> ResultMap in value.resultMap }])
    }

    public var faceUnityBundleLists: FaceUnityBundleList? {
      get {
        return (resultMap["faceUnityBundleLists"] as? ResultMap).flatMap { FaceUnityBundleList(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "faceUnityBundleLists")
      }
    }

    public struct FaceUnityBundleList: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnityBundleListConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnityBundleListConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("hasPreviousPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("count", type: .scalar(Int.self)),
          GraphQLField("currentPage", type: .scalar(Int.self)),
          GraphQLField("lastPage", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, hasPreviousPage: Bool, startCursor: String? = nil, endCursor: String? = nil, total: Int? = nil, count: Int? = nil, currentPage: Int? = nil, lastPage: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "hasPreviousPage": hasPreviousPage, "startCursor": startCursor, "endCursor": endCursor, "total": total, "count": count, "currentPage": currentPage, "lastPage": lastPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool {
          get {
            return resultMap["hasPreviousPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasPreviousPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Total number of node in connection.
        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }

        /// Current page of request.
        public var currentPage: Int? {
          get {
            return resultMap["currentPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "currentPage")
          }
        }

        /// Last page in connection.
        public var lastPage: Int? {
          get {
            return resultMap["lastPage"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "lastPage")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["FaceUnityBundleListEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "FaceUnityBundleListEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["FaceUnityBundleList"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("fu_bundle_id", type: .scalar(Int.self)),
            GraphQLField("fu_device_type", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(fuBundleId: Int? = nil, fuDeviceType: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "FaceUnityBundleList", "fu_bundle_id": fuBundleId, "fu_device_type": fuDeviceType])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fuBundleId: Int? {
            get {
              return resultMap["fu_bundle_id"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_bundle_id")
            }
          }

          public var fuDeviceType: Int? {
            get {
              return resultMap["fu_device_type"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "fu_device_type")
            }
          }
        }
      }
    }
  }
}

public final class FaceUnityBundleListQuery: GraphQLQuery {
  public let operationDefinition =
    "query FaceUnityBundleList($fu_bundle_id: ID, $fu_device_type: Int) {\n  faceUnityBundleList(fu_bundle_id: $fu_bundle_id, fu_device_type: $fu_device_type) {\n    __typename\n    fu_id\n    fu_bundle_id\n    is_show\n    fu_name\n    fu_item_path\n    fu_device_type\n    fu_file_type\n    faceUnity {\n      __typename\n      fu_bundle_id\n      fu_categories_id\n      fu_bundle_icon\n      fu_bundle_name\n      fu_bundle_description\n      fu_bundle_sequence\n      fu_is_free\n      fu_is_show\n      fu_is_official\n      fu_is_delete\n      fu_download_count\n      fu_max_face\n      fu_face_description\n    }\n  }\n}"

  public var fu_bundle_id: GraphQLID?
  public var fu_device_type: Int?

  public init(fu_bundle_id: GraphQLID? = nil, fu_device_type: Int? = nil) {
    self.fu_bundle_id = fu_bundle_id
    self.fu_device_type = fu_device_type
  }

  public var variables: GraphQLMap? {
    return ["fu_bundle_id": fu_bundle_id, "fu_device_type": fu_device_type]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("faceUnityBundleList", arguments: ["fu_bundle_id": GraphQLVariable("fu_bundle_id"), "fu_device_type": GraphQLVariable("fu_device_type")], type: .object(FaceUnityBundleList.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(faceUnityBundleList: FaceUnityBundleList? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "faceUnityBundleList": faceUnityBundleList.flatMap { (value: FaceUnityBundleList) -> ResultMap in value.resultMap }])
    }

    public var faceUnityBundleList: FaceUnityBundleList? {
      get {
        return (resultMap["faceUnityBundleList"] as? ResultMap).flatMap { FaceUnityBundleList(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "faceUnityBundleList")
      }
    }

    public struct FaceUnityBundleList: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnityBundleList"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fu_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("fu_bundle_id", type: .scalar(Int.self)),
        GraphQLField("is_show", type: .scalar(Int.self)),
        GraphQLField("fu_name", type: .scalar(String.self)),
        GraphQLField("fu_item_path", type: .scalar(String.self)),
        GraphQLField("fu_device_type", type: .scalar(Int.self)),
        GraphQLField("fu_file_type", type: .scalar(String.self)),
        GraphQLField("faceUnity", type: .object(FaceUnity.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fuId: GraphQLID, fuBundleId: Int? = nil, isShow: Int? = nil, fuName: String? = nil, fuItemPath: String? = nil, fuDeviceType: Int? = nil, fuFileType: String? = nil, faceUnity: FaceUnity? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnityBundleList", "fu_id": fuId, "fu_bundle_id": fuBundleId, "is_show": isShow, "fu_name": fuName, "fu_item_path": fuItemPath, "fu_device_type": fuDeviceType, "fu_file_type": fuFileType, "faceUnity": faceUnity.flatMap { (value: FaceUnity) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fuId: GraphQLID {
        get {
          return resultMap["fu_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_id")
        }
      }

      public var fuBundleId: Int? {
        get {
          return resultMap["fu_bundle_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_id")
        }
      }

      public var isShow: Int? {
        get {
          return resultMap["is_show"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_show")
        }
      }

      public var fuName: String? {
        get {
          return resultMap["fu_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_name")
        }
      }

      public var fuItemPath: String? {
        get {
          return resultMap["fu_item_path"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_item_path")
        }
      }

      public var fuDeviceType: Int? {
        get {
          return resultMap["fu_device_type"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_device_type")
        }
      }

      public var fuFileType: String? {
        get {
          return resultMap["fu_file_type"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_file_type")
        }
      }

      public var faceUnity: FaceUnity? {
        get {
          return (resultMap["faceUnity"] as? ResultMap).flatMap { FaceUnity(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "faceUnity")
        }
      }

      public struct FaceUnity: GraphQLSelectionSet {
        public static let possibleTypes = ["FaceUnity"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fu_bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fu_categories_id", type: .scalar(Int.self)),
          GraphQLField("fu_bundle_icon", type: .scalar(String.self)),
          GraphQLField("fu_bundle_name", type: .scalar(String.self)),
          GraphQLField("fu_bundle_description", type: .scalar(String.self)),
          GraphQLField("fu_bundle_sequence", type: .scalar(Int.self)),
          GraphQLField("fu_is_free", type: .scalar(Int.self)),
          GraphQLField("fu_is_show", type: .scalar(Int.self)),
          GraphQLField("fu_is_official", type: .scalar(Int.self)),
          GraphQLField("fu_is_delete", type: .scalar(Int.self)),
          GraphQLField("fu_download_count", type: .scalar(Int.self)),
          GraphQLField("fu_max_face", type: .scalar(Int.self)),
          GraphQLField("fu_face_description", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(fuBundleId: GraphQLID, fuCategoriesId: Int? = nil, fuBundleIcon: String? = nil, fuBundleName: String? = nil, fuBundleDescription: String? = nil, fuBundleSequence: Int? = nil, fuIsFree: Int? = nil, fuIsShow: Int? = nil, fuIsOfficial: Int? = nil, fuIsDelete: Int? = nil, fuDownloadCount: Int? = nil, fuMaxFace: Int? = nil, fuFaceDescription: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "FaceUnity", "fu_bundle_id": fuBundleId, "fu_categories_id": fuCategoriesId, "fu_bundle_icon": fuBundleIcon, "fu_bundle_name": fuBundleName, "fu_bundle_description": fuBundleDescription, "fu_bundle_sequence": fuBundleSequence, "fu_is_free": fuIsFree, "fu_is_show": fuIsShow, "fu_is_official": fuIsOfficial, "fu_is_delete": fuIsDelete, "fu_download_count": fuDownloadCount, "fu_max_face": fuMaxFace, "fu_face_description": fuFaceDescription])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fuBundleId: GraphQLID {
          get {
            return resultMap["fu_bundle_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_id")
          }
        }

        public var fuCategoriesId: Int? {
          get {
            return resultMap["fu_categories_id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_categories_id")
          }
        }

        public var fuBundleIcon: String? {
          get {
            return resultMap["fu_bundle_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_icon")
          }
        }

        public var fuBundleName: String? {
          get {
            return resultMap["fu_bundle_name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_name")
          }
        }

        public var fuBundleDescription: String? {
          get {
            return resultMap["fu_bundle_description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_description")
          }
        }

        public var fuBundleSequence: Int? {
          get {
            return resultMap["fu_bundle_sequence"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_sequence")
          }
        }

        public var fuIsFree: Int? {
          get {
            return resultMap["fu_is_free"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_free")
          }
        }

        public var fuIsShow: Int? {
          get {
            return resultMap["fu_is_show"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_show")
          }
        }

        public var fuIsOfficial: Int? {
          get {
            return resultMap["fu_is_official"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_official")
          }
        }

        public var fuIsDelete: Int? {
          get {
            return resultMap["fu_is_delete"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_delete")
          }
        }

        public var fuDownloadCount: Int? {
          get {
            return resultMap["fu_download_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_download_count")
          }
        }

        public var fuMaxFace: Int? {
          get {
            return resultMap["fu_max_face"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_max_face")
          }
        }

        public var fuFaceDescription: String? {
          get {
            return resultMap["fu_face_description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_face_description")
          }
        }
      }
    }
  }
}

public final class GamesQuery: GraphQLQuery {
  public let operationDefinition =
    "query Games($ios_status: Int, $first: Int!, $after: String) {\n  games(ios_status: $ios_status, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        game_url\n        game_icon\n        game_name\n        game_id\n        description\n        isOfficial\n        game_sequence\n      }\n      cursor\n    }\n  }\n}"

  public var ios_status: Int?
  public var first: Int
  public var after: String?

  public init(ios_status: Int? = nil, first: Int, after: String? = nil) {
    self.ios_status = ios_status
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["ios_status": ios_status, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("games", arguments: ["ios_status": GraphQLVariable("ios_status"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(Game.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(games: Game? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "games": games.flatMap { (value: Game) -> ResultMap in value.resultMap }])
    }

    public var games: Game? {
      get {
        return (resultMap["games"] as? ResultMap).flatMap { Game(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "games")
      }
    }

    public struct Game: GraphQLSelectionSet {
      public static let possibleTypes = ["GameConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "GameConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["GameEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "GameEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Game"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("game_url", type: .scalar(String.self)),
            GraphQLField("game_icon", type: .scalar(String.self)),
            GraphQLField("game_name", type: .scalar(String.self)),
            GraphQLField("game_id", type: .scalar(GraphQLID.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("isOfficial", type: .scalar(Int.self)),
            GraphQLField("game_sequence", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(gameUrl: String? = nil, gameIcon: String? = nil, gameName: String? = nil, gameId: GraphQLID? = nil, description: String? = nil, isOfficial: Int? = nil, gameSequence: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Game", "game_url": gameUrl, "game_icon": gameIcon, "game_name": gameName, "game_id": gameId, "description": description, "isOfficial": isOfficial, "game_sequence": gameSequence])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var gameUrl: String? {
            get {
              return resultMap["game_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "game_url")
            }
          }

          public var gameIcon: String? {
            get {
              return resultMap["game_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "game_icon")
            }
          }

          public var gameName: String? {
            get {
              return resultMap["game_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "game_name")
            }
          }

          public var gameId: GraphQLID? {
            get {
              return resultMap["game_id"] as? GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "game_id")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var isOfficial: Int? {
            get {
              return resultMap["isOfficial"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isOfficial")
            }
          }

          public var gameSequence: Int? {
            get {
              return resultMap["game_sequence"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "game_sequence")
            }
          }
        }
      }
    }
  }
}

public final class UsersQuery: GraphQLQuery {
  public let operationDefinition =
    "query Users {\n  user {\n    __typename\n    id\n    username\n    sex\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("user", type: .object(User.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(user: User? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
    }

    public var user: User? {
      get {
        return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "user")
      }
    }

    public struct User: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .scalar(String.self)),
        GraphQLField("sex", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, username: String? = nil, sex: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "username": username, "sex": sex])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String? {
        get {
          return resultMap["username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "username")
        }
      }

      public var sex: Int? {
        get {
          return resultMap["sex"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "sex")
        }
      }
    }
  }
}

public final class StickerQuery: GraphQLQuery {
  public let operationDefinition =
    "query Sticker($bundle_id: ID) {\n  sticker(bundle_id: $bundle_id) {\n    __typename\n    ...BundleInfo\n    artist {\n      __typename\n      ...ArtistInfo\n      user {\n        __typename\n        id\n        username\n      }\n    }\n    artist_id\n    stickerLists {\n      __typename\n      sticker_id\n      sticker_icon\n      sitcker_name\n    }\n    contest {\n      __typename\n      page_icon\n      page_url\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(BundleInfo.fragmentDefinition).appending(ArtistInfo.fragmentDefinition) }

  public var bundle_id: GraphQLID?

  public init(bundle_id: GraphQLID? = nil) {
    self.bundle_id = bundle_id
  }

  public var variables: GraphQLMap? {
    return ["bundle_id": bundle_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sticker", arguments: ["bundle_id": GraphQLVariable("bundle_id")], type: .object(Sticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sticker: Sticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "sticker": sticker.flatMap { (value: Sticker) -> ResultMap in value.resultMap }])
    }

    public var sticker: Sticker? {
      get {
        return (resultMap["sticker"] as? ResultMap).flatMap { Sticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "sticker")
      }
    }

    public struct Sticker: GraphQLSelectionSet {
      public static let possibleTypes = ["Sticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(BundleInfo.self),
        GraphQLField("artist", type: .object(Artist.selections)),
        GraphQLField("artist_id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("stickerLists", type: .list(.object(StickerList.selections))),
        GraphQLField("contest", type: .object(Contest.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var artist: Artist? {
        get {
          return (resultMap["artist"] as? ResultMap).flatMap { Artist(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "artist")
        }
      }

      public var artistId: Int {
        get {
          return resultMap["artist_id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "artist_id")
        }
      }

      public var stickerLists: [StickerList?]? {
        get {
          return (resultMap["stickerLists"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [StickerList?] in value.map { (value: ResultMap?) -> StickerList? in value.flatMap { (value: ResultMap) -> StickerList in StickerList(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [StickerList?]) -> [ResultMap?] in value.map { (value: StickerList?) -> ResultMap? in value.flatMap { (value: StickerList) -> ResultMap in value.resultMap } } }, forKey: "stickerLists")
        }
      }

      public var contest: Contest? {
        get {
          return (resultMap["contest"] as? ResultMap).flatMap { Contest(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "contest")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var bundleInfo: BundleInfo {
          get {
            return BundleInfo(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Artist: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerArtist"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(ArtistInfo.self),
          GraphQLField("user", type: .object(User.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var user: User? {
          get {
            return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "user")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var artistInfo: ArtistInfo {
            get {
              return ArtistInfo(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct User: GraphQLSelectionSet {
          public static let possibleTypes = ["User"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("username", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, username: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "User", "id": id, "username": username])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var username: String? {
            get {
              return resultMap["username"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "username")
            }
          }
        }
      }

      public struct StickerList: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerList"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("sticker_id", type: .scalar(GraphQLID.self)),
          GraphQLField("sticker_icon", type: .scalar(String.self)),
          GraphQLField("sitcker_name", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(stickerId: GraphQLID? = nil, stickerIcon: String? = nil, sitckerName: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "StickerList", "sticker_id": stickerId, "sticker_icon": stickerIcon, "sitcker_name": sitckerName])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var stickerId: GraphQLID? {
          get {
            return resultMap["sticker_id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "sticker_id")
          }
        }

        public var stickerIcon: String? {
          get {
            return resultMap["sticker_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sticker_icon")
          }
        }

        public var sitckerName: String? {
          get {
            return resultMap["sitcker_name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sitcker_name")
          }
        }
      }

      public struct Contest: GraphQLSelectionSet {
        public static let possibleTypes = ["Contest"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("page_icon", type: .scalar(String.self)),
          GraphQLField("page_url", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pageIcon: String? = nil, pageUrl: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Contest", "page_icon": pageIcon, "page_url": pageUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var pageIcon: String? {
          get {
            return resultMap["page_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "page_icon")
          }
        }

        public var pageUrl: String? {
          get {
            return resultMap["page_url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "page_url")
          }
        }
      }
    }
  }
}

public final class StickerArtistQuery: GraphQLQuery {
  public let operationDefinition =
    "query StickerArtist($artist_id: ID!, $count: Int!, $page: Int!) {\n  StickerArtist(artist_id: $artist_id) {\n    __typename\n    artist_id\n    artist_name\n    description\n    icon\n    banner\n    uid\n    hide_view_moment\n    stickers(count: $count, page: $page) {\n      __typename\n      paginatorInfo {\n        __typename\n        total\n        currentPage\n        hasMorePages\n        perPage\n      }\n      data {\n        __typename\n        bundle_id\n        bundle_icon\n        bundle_name\n        description\n        banner_url\n        isGif\n        isOfficial\n        status\n        download_count\n        artist_id\n        artist {\n          __typename\n          artist_name\n          artist_id\n          description\n          icon\n          banner\n        }\n      }\n    }\n  }\n}"

  public var artist_id: GraphQLID
  public var count: Int
  public var page: Int

  public init(artist_id: GraphQLID, count: Int, page: Int) {
    self.artist_id = artist_id
    self.count = count
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["artist_id": artist_id, "count": count, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("StickerArtist", arguments: ["artist_id": GraphQLVariable("artist_id")], type: .object(StickerArtist.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(stickerArtist: StickerArtist? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "StickerArtist": stickerArtist.flatMap { (value: StickerArtist) -> ResultMap in value.resultMap }])
    }

    public var stickerArtist: StickerArtist? {
      get {
        return (resultMap["StickerArtist"] as? ResultMap).flatMap { StickerArtist(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "StickerArtist")
      }
    }

    public struct StickerArtist: GraphQLSelectionSet {
      public static let possibleTypes = ["StickerArtist"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("icon", type: .scalar(String.self)),
        GraphQLField("banner", type: .scalar(String.self)),
        GraphQLField("uid", type: .scalar(Int.self)),
        GraphQLField("hide_view_moment", type: .scalar(Bool.self)),
        GraphQLField("stickers", arguments: ["count": GraphQLVariable("count"), "page": GraphQLVariable("page")], type: .object(Sticker.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(artistId: GraphQLID, artistName: String, description: String? = nil, icon: String? = nil, banner: String? = nil, uid: Int? = nil, hideViewMoment: Bool? = nil, stickers: Sticker? = nil) {
        self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_id": artistId, "artist_name": artistName, "description": description, "icon": icon, "banner": banner, "uid": uid, "hide_view_moment": hideViewMoment, "stickers": stickers.flatMap { (value: Sticker) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var artistId: GraphQLID {
        get {
          return resultMap["artist_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "artist_id")
        }
      }

      public var artistName: String {
        get {
          return resultMap["artist_name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "artist_name")
        }
      }

      public var description: String? {
        get {
          return resultMap["description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "description")
        }
      }

      public var icon: String? {
        get {
          return resultMap["icon"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "icon")
        }
      }

      public var banner: String? {
        get {
          return resultMap["banner"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "banner")
        }
      }

      public var uid: Int? {
        get {
          return resultMap["uid"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "uid")
        }
      }

      public var hideViewMoment: Bool? {
        get {
          return resultMap["hide_view_moment"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "hide_view_moment")
        }
      }

      public var stickers: Sticker? {
        get {
          return (resultMap["stickers"] as? ResultMap).flatMap { Sticker(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "stickers")
        }
      }

      public struct Sticker: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerPaginator"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("paginatorInfo", type: .nonNull(.object(PaginatorInfo.selections))),
          GraphQLField("data", type: .nonNull(.list(.nonNull(.object(Datum.selections))))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(paginatorInfo: PaginatorInfo, data: [Datum]) {
          self.init(unsafeResultMap: ["__typename": "StickerPaginator", "paginatorInfo": paginatorInfo.resultMap, "data": data.map { (value: Datum) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var paginatorInfo: PaginatorInfo {
          get {
            return PaginatorInfo(unsafeResultMap: resultMap["paginatorInfo"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "paginatorInfo")
          }
        }

        public var data: [Datum] {
          get {
            return (resultMap["data"] as! [ResultMap]).map { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Datum) -> ResultMap in value.resultMap }, forKey: "data")
          }
        }

        public struct PaginatorInfo: GraphQLSelectionSet {
          public static let possibleTypes = ["PaginatorInfo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("total", type: .nonNull(.scalar(Int.self))),
            GraphQLField("currentPage", type: .nonNull(.scalar(Int.self))),
            GraphQLField("hasMorePages", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("perPage", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(total: Int, currentPage: Int, hasMorePages: Bool, perPage: Int) {
            self.init(unsafeResultMap: ["__typename": "PaginatorInfo", "total": total, "currentPage": currentPage, "hasMorePages": hasMorePages, "perPage": perPage])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Total items available in the collection.
          public var total: Int {
            get {
              return resultMap["total"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "total")
            }
          }

          /// Current pagination page.
          public var currentPage: Int {
            get {
              return resultMap["currentPage"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "currentPage")
            }
          }

          /// If collection has more pages.
          public var hasMorePages: Bool {
            get {
              return resultMap["hasMorePages"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasMorePages")
            }
          }

          /// Number of items per page in the collection.
          public var perPage: Int {
            get {
              return resultMap["perPage"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "perPage")
            }
          }
        }

        public struct Datum: GraphQLSelectionSet {
          public static let possibleTypes = ["Sticker"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("bundle_icon", type: .scalar(String.self)),
            GraphQLField("bundle_name", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("banner_url", type: .scalar(String.self)),
            GraphQLField("isGif", type: .scalar(Int.self)),
            GraphQLField("isOfficial", type: .scalar(Int.self)),
            GraphQLField("status", type: .scalar(Int.self)),
            GraphQLField("download_count", type: .scalar(Int.self)),
            GraphQLField("artist_id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("artist", type: .object(Artist.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil, description: String? = nil, bannerUrl: String? = nil, isGif: Int? = nil, isOfficial: Int? = nil, status: Int? = nil, downloadCount: Int? = nil, artistId: Int, artist: Artist? = nil) {
            self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName, "description": description, "banner_url": bannerUrl, "isGif": isGif, "isOfficial": isOfficial, "status": status, "download_count": downloadCount, "artist_id": artistId, "artist": artist.flatMap { (value: Artist) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var bundleId: GraphQLID {
            get {
              return resultMap["bundle_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_id")
            }
          }

          public var bundleIcon: String? {
            get {
              return resultMap["bundle_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_icon")
            }
          }

          public var bundleName: String? {
            get {
              return resultMap["bundle_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_name")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var bannerUrl: String? {
            get {
              return resultMap["banner_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "banner_url")
            }
          }

          public var isGif: Int? {
            get {
              return resultMap["isGif"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isGif")
            }
          }

          public var isOfficial: Int? {
            get {
              return resultMap["isOfficial"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isOfficial")
            }
          }

          public var status: Int? {
            get {
              return resultMap["status"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }

          public var downloadCount: Int? {
            get {
              return resultMap["download_count"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "download_count")
            }
          }

          public var artistId: Int {
            get {
              return resultMap["artist_id"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "artist_id")
            }
          }

          public var artist: Artist? {
            get {
              return (resultMap["artist"] as? ResultMap).flatMap { Artist(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "artist")
            }
          }

          public struct Artist: GraphQLSelectionSet {
            public static let possibleTypes = ["StickerArtist"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("icon", type: .scalar(String.self)),
              GraphQLField("banner", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(artistName: String, artistId: GraphQLID, description: String? = nil, icon: String? = nil, banner: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_name": artistName, "artist_id": artistId, "description": description, "icon": icon, "banner": banner])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var artistName: String {
              get {
                return resultMap["artist_name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_name")
              }
            }

            public var artistId: GraphQLID {
              get {
                return resultMap["artist_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_id")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }

            public var icon: String? {
              get {
                return resultMap["icon"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "icon")
              }
            }

            public var banner: String? {
              get {
                return resultMap["banner"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "banner")
              }
            }
          }
        }
      }
    }
  }
}

public final class StickersQuery: GraphQLQuery {
  public let operationDefinition =
    "query Stickers($filter_type: String, $first: Int!, $after: String) {\n  stickers(filter_type: $filter_type, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        bundle_id\n        bundle_icon\n        bundle_name\n        description\n        banner_url\n        isGif\n        isOfficial\n        status\n        download_count\n        artist_id\n        artist {\n          __typename\n          artist_name\n          artist_id\n          description\n          icon\n          banner\n        }\n      }\n      cursor\n    }\n  }\n}"

  public var filter_type: String?
  public var first: Int
  public var after: String?

  public init(filter_type: String? = nil, first: Int, after: String? = nil) {
    self.filter_type = filter_type
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["filter_type": filter_type, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("stickers", arguments: ["filter_type": GraphQLVariable("filter_type"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(Sticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(stickers: Sticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "stickers": stickers.flatMap { (value: Sticker) -> ResultMap in value.resultMap }])
    }

    public var stickers: Sticker? {
      get {
        return (resultMap["stickers"] as? ResultMap).flatMap { Sticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "stickers")
      }
    }

    public struct Sticker: GraphQLSelectionSet {
      public static let possibleTypes = ["StickerConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StickerConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "StickerEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Sticker"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("bundle_icon", type: .scalar(String.self)),
            GraphQLField("bundle_name", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("banner_url", type: .scalar(String.self)),
            GraphQLField("isGif", type: .scalar(Int.self)),
            GraphQLField("isOfficial", type: .scalar(Int.self)),
            GraphQLField("status", type: .scalar(Int.self)),
            GraphQLField("download_count", type: .scalar(Int.self)),
            GraphQLField("artist_id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("artist", type: .object(Artist.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil, description: String? = nil, bannerUrl: String? = nil, isGif: Int? = nil, isOfficial: Int? = nil, status: Int? = nil, downloadCount: Int? = nil, artistId: Int, artist: Artist? = nil) {
            self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName, "description": description, "banner_url": bannerUrl, "isGif": isGif, "isOfficial": isOfficial, "status": status, "download_count": downloadCount, "artist_id": artistId, "artist": artist.flatMap { (value: Artist) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var bundleId: GraphQLID {
            get {
              return resultMap["bundle_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_id")
            }
          }

          public var bundleIcon: String? {
            get {
              return resultMap["bundle_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_icon")
            }
          }

          public var bundleName: String? {
            get {
              return resultMap["bundle_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_name")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var bannerUrl: String? {
            get {
              return resultMap["banner_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "banner_url")
            }
          }

          public var isGif: Int? {
            get {
              return resultMap["isGif"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isGif")
            }
          }

          public var isOfficial: Int? {
            get {
              return resultMap["isOfficial"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isOfficial")
            }
          }

          public var status: Int? {
            get {
              return resultMap["status"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }

          public var downloadCount: Int? {
            get {
              return resultMap["download_count"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "download_count")
            }
          }

          public var artistId: Int {
            get {
              return resultMap["artist_id"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "artist_id")
            }
          }

          public var artist: Artist? {
            get {
              return (resultMap["artist"] as? ResultMap).flatMap { Artist(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "artist")
            }
          }

          public struct Artist: GraphQLSelectionSet {
            public static let possibleTypes = ["StickerArtist"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("icon", type: .scalar(String.self)),
              GraphQLField("banner", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(artistName: String, artistId: GraphQLID, description: String? = nil, icon: String? = nil, banner: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_name": artistName, "artist_id": artistId, "description": description, "icon": icon, "banner": banner])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var artistName: String {
              get {
                return resultMap["artist_name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_name")
              }
            }

            public var artistId: GraphQLID {
              get {
                return resultMap["artist_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_id")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }

            public var icon: String? {
              get {
                return resultMap["icon"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "icon")
              }
            }

            public var banner: String? {
              get {
                return resultMap["banner"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "banner")
              }
            }
          }
        }
      }
    }
  }
}

public final class StickerSearchQuery: GraphQLQuery {
  public let operationDefinition =
    "query StickerSearch($bundle_name: String, $first: Int!, $after: String) {\n  stickerSearch(bundle_name: $bundle_name, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      endCursor\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        bundle_id\n        bundle_icon\n        bundle_name\n        description\n        banner_url\n        isGif\n        isOfficial\n        status\n        download_count\n        artist_id\n        artist {\n          __typename\n          artist_name\n          artist_id\n          description\n          icon\n          banner\n        }\n      }\n    }\n  }\n}"

  public var bundle_name: String?
  public var first: Int
  public var after: String?

  public init(bundle_name: String? = nil, first: Int, after: String? = nil) {
    self.bundle_name = bundle_name
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["bundle_name": bundle_name, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("stickerSearch", arguments: ["bundle_name": GraphQLVariable("bundle_name"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(StickerSearch.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(stickerSearch: StickerSearch? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "stickerSearch": stickerSearch.flatMap { (value: StickerSearch) -> ResultMap in value.resultMap }])
    }

    public var stickerSearch: StickerSearch? {
      get {
        return (resultMap["stickerSearch"] as? ResultMap).flatMap { StickerSearch(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "stickerSearch")
      }
    }

    public struct StickerSearch: GraphQLSelectionSet {
      public static let possibleTypes = ["StickerConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StickerConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("endCursor", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, endCursor: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "endCursor": endCursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil) {
          self.init(unsafeResultMap: ["__typename": "StickerEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Sticker"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("bundle_icon", type: .scalar(String.self)),
            GraphQLField("bundle_name", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("banner_url", type: .scalar(String.self)),
            GraphQLField("isGif", type: .scalar(Int.self)),
            GraphQLField("isOfficial", type: .scalar(Int.self)),
            GraphQLField("status", type: .scalar(Int.self)),
            GraphQLField("download_count", type: .scalar(Int.self)),
            GraphQLField("artist_id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("artist", type: .object(Artist.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil, description: String? = nil, bannerUrl: String? = nil, isGif: Int? = nil, isOfficial: Int? = nil, status: Int? = nil, downloadCount: Int? = nil, artistId: Int, artist: Artist? = nil) {
            self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName, "description": description, "banner_url": bannerUrl, "isGif": isGif, "isOfficial": isOfficial, "status": status, "download_count": downloadCount, "artist_id": artistId, "artist": artist.flatMap { (value: Artist) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var bundleId: GraphQLID {
            get {
              return resultMap["bundle_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_id")
            }
          }

          public var bundleIcon: String? {
            get {
              return resultMap["bundle_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_icon")
            }
          }

          public var bundleName: String? {
            get {
              return resultMap["bundle_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_name")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var bannerUrl: String? {
            get {
              return resultMap["banner_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "banner_url")
            }
          }

          public var isGif: Int? {
            get {
              return resultMap["isGif"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isGif")
            }
          }

          public var isOfficial: Int? {
            get {
              return resultMap["isOfficial"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "isOfficial")
            }
          }

          public var status: Int? {
            get {
              return resultMap["status"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }

          public var downloadCount: Int? {
            get {
              return resultMap["download_count"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "download_count")
            }
          }

          public var artistId: Int {
            get {
              return resultMap["artist_id"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "artist_id")
            }
          }

          public var artist: Artist? {
            get {
              return (resultMap["artist"] as? ResultMap).flatMap { Artist(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "artist")
            }
          }

          public struct Artist: GraphQLSelectionSet {
            public static let possibleTypes = ["StickerArtist"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
              GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("icon", type: .scalar(String.self)),
              GraphQLField("banner", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(artistName: String, artistId: GraphQLID, description: String? = nil, icon: String? = nil, banner: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_name": artistName, "artist_id": artistId, "description": description, "icon": icon, "banner": banner])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var artistName: String {
              get {
                return resultMap["artist_name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_name")
              }
            }

            public var artistId: GraphQLID {
              get {
                return resultMap["artist_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_id")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }

            public var icon: String? {
              get {
                return resultMap["icon"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "icon")
              }
            }

            public var banner: String? {
              get {
                return resultMap["banner"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "banner")
              }
            }
          }
        }
      }
    }
  }
}

public final class ArtistSearchQuery: GraphQLQuery {
  public let operationDefinition =
    "query ArtistSearch($artist_name: String, $first: Int!, $after: String) {\n  artistSearch(artist_name: $artist_name, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      endCursor\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        artist_id\n        artist_name\n        description\n        icon\n        banner\n        uid\n        hide_view_moment\n        sticker_set\n        user {\n          __typename\n          id\n          username\n          name\n          phone\n          email\n        }\n      }\n    }\n  }\n}"

  public var artist_name: String?
  public var first: Int
  public var after: String?

  public init(artist_name: String? = nil, first: Int, after: String? = nil) {
    self.artist_name = artist_name
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["artist_name": artist_name, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("artistSearch", arguments: ["artist_name": GraphQLVariable("artist_name"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(ArtistSearch.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(artistSearch: ArtistSearch? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "artistSearch": artistSearch.flatMap { (value: ArtistSearch) -> ResultMap in value.resultMap }])
    }

    public var artistSearch: ArtistSearch? {
      get {
        return (resultMap["artistSearch"] as? ResultMap).flatMap { ArtistSearch(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "artistSearch")
      }
    }

    public struct ArtistSearch: GraphQLSelectionSet {
      public static let possibleTypes = ["StickerArtistConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StickerArtistConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("endCursor", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, endCursor: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "endCursor": endCursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerArtistEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil) {
          self.init(unsafeResultMap: ["__typename": "StickerArtistEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["StickerArtist"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("icon", type: .scalar(String.self)),
            GraphQLField("banner", type: .scalar(String.self)),
            GraphQLField("uid", type: .scalar(Int.self)),
            GraphQLField("hide_view_moment", type: .scalar(Bool.self)),
            GraphQLField("sticker_set", type: .nonNull(.scalar(Int.self))),
            GraphQLField("user", type: .object(User.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(artistId: GraphQLID, artistName: String, description: String? = nil, icon: String? = nil, banner: String? = nil, uid: Int? = nil, hideViewMoment: Bool? = nil, stickerSet: Int, user: User? = nil) {
            self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_id": artistId, "artist_name": artistName, "description": description, "icon": icon, "banner": banner, "uid": uid, "hide_view_moment": hideViewMoment, "sticker_set": stickerSet, "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var artistId: GraphQLID {
            get {
              return resultMap["artist_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "artist_id")
            }
          }

          public var artistName: String {
            get {
              return resultMap["artist_name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "artist_name")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var icon: String? {
            get {
              return resultMap["icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "icon")
            }
          }

          public var banner: String? {
            get {
              return resultMap["banner"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "banner")
            }
          }

          public var uid: Int? {
            get {
              return resultMap["uid"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "uid")
            }
          }

          public var hideViewMoment: Bool? {
            get {
              return resultMap["hide_view_moment"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hide_view_moment")
            }
          }

          public var stickerSet: Int {
            get {
              return resultMap["sticker_set"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "sticker_set")
            }
          }

          public var user: User? {
            get {
              return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "user")
            }
          }

          public struct User: GraphQLSelectionSet {
            public static let possibleTypes = ["User"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("username", type: .scalar(String.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("phone", type: .scalar(String.self)),
              GraphQLField("email", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, username: String? = nil, name: String? = nil, phone: String? = nil, email: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "User", "id": id, "username": username, "name": name, "phone": phone, "email": email])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var username: String? {
              get {
                return resultMap["username"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "username")
              }
            }

            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var phone: String? {
              get {
                return resultMap["phone"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "phone")
              }
            }

            public var email: String? {
              get {
                return resultMap["email"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "email")
              }
            }
          }
        }
      }
    }
  }
}

public final class StickerListsQuery: GraphQLQuery {
  public let operationDefinition =
    "query StickerLists($first: Int!, $after: String) {\n  stickerLists(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        sticker_id\n        bundle_id\n        sticker_icon\n        sitcker_name\n        sticker {\n          __typename\n          description\n          banner_url\n          isGif\n          isOfficial\n          status\n          download_count\n          bundle_id\n          bundle_icon\n          artist {\n            __typename\n            artist_name\n            artist_id\n            description\n            icon\n            banner\n          }\n          artist_id\n        }\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("stickerLists", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(StickerList.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(stickerLists: StickerList? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "stickerLists": stickerLists.flatMap { (value: StickerList) -> ResultMap in value.resultMap }])
    }

    public var stickerLists: StickerList? {
      get {
        return (resultMap["stickerLists"] as? ResultMap).flatMap { StickerList(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "stickerLists")
      }
    }

    public struct StickerList: GraphQLSelectionSet {
      public static let possibleTypes = ["StickerListConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "StickerListConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerListEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "StickerListEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["StickerList"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("sticker_id", type: .scalar(GraphQLID.self)),
            GraphQLField("bundle_id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("sticker_icon", type: .scalar(String.self)),
            GraphQLField("sitcker_name", type: .scalar(String.self)),
            GraphQLField("sticker", type: .object(Sticker.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(stickerId: GraphQLID? = nil, bundleId: Int, stickerIcon: String? = nil, sitckerName: String? = nil, sticker: Sticker? = nil) {
            self.init(unsafeResultMap: ["__typename": "StickerList", "sticker_id": stickerId, "bundle_id": bundleId, "sticker_icon": stickerIcon, "sitcker_name": sitckerName, "sticker": sticker.flatMap { (value: Sticker) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var stickerId: GraphQLID? {
            get {
              return resultMap["sticker_id"] as? GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "sticker_id")
            }
          }

          public var bundleId: Int {
            get {
              return resultMap["bundle_id"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "bundle_id")
            }
          }

          public var stickerIcon: String? {
            get {
              return resultMap["sticker_icon"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "sticker_icon")
            }
          }

          public var sitckerName: String? {
            get {
              return resultMap["sitcker_name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "sitcker_name")
            }
          }

          public var sticker: Sticker? {
            get {
              return (resultMap["sticker"] as? ResultMap).flatMap { Sticker(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "sticker")
            }
          }

          public struct Sticker: GraphQLSelectionSet {
            public static let possibleTypes = ["Sticker"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("banner_url", type: .scalar(String.self)),
              GraphQLField("isGif", type: .scalar(Int.self)),
              GraphQLField("isOfficial", type: .scalar(Int.self)),
              GraphQLField("status", type: .scalar(Int.self)),
              GraphQLField("download_count", type: .scalar(Int.self)),
              GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("bundle_icon", type: .scalar(String.self)),
              GraphQLField("artist", type: .object(Artist.selections)),
              GraphQLField("artist_id", type: .nonNull(.scalar(Int.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(description: String? = nil, bannerUrl: String? = nil, isGif: Int? = nil, isOfficial: Int? = nil, status: Int? = nil, downloadCount: Int? = nil, bundleId: GraphQLID, bundleIcon: String? = nil, artist: Artist? = nil, artistId: Int) {
              self.init(unsafeResultMap: ["__typename": "Sticker", "description": description, "banner_url": bannerUrl, "isGif": isGif, "isOfficial": isOfficial, "status": status, "download_count": downloadCount, "bundle_id": bundleId, "bundle_icon": bundleIcon, "artist": artist.flatMap { (value: Artist) -> ResultMap in value.resultMap }, "artist_id": artistId])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var description: String? {
              get {
                return resultMap["description"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "description")
              }
            }

            public var bannerUrl: String? {
              get {
                return resultMap["banner_url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "banner_url")
              }
            }

            public var isGif: Int? {
              get {
                return resultMap["isGif"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "isGif")
              }
            }

            public var isOfficial: Int? {
              get {
                return resultMap["isOfficial"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "isOfficial")
              }
            }

            public var status: Int? {
              get {
                return resultMap["status"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "status")
              }
            }

            public var downloadCount: Int? {
              get {
                return resultMap["download_count"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "download_count")
              }
            }

            public var bundleId: GraphQLID {
              get {
                return resultMap["bundle_id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "bundle_id")
              }
            }

            public var bundleIcon: String? {
              get {
                return resultMap["bundle_icon"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "bundle_icon")
              }
            }

            public var artist: Artist? {
              get {
                return (resultMap["artist"] as? ResultMap).flatMap { Artist(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "artist")
              }
            }

            public var artistId: Int {
              get {
                return resultMap["artist_id"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "artist_id")
              }
            }

            public struct Artist: GraphQLSelectionSet {
              public static let possibleTypes = ["StickerArtist"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
                GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("description", type: .scalar(String.self)),
                GraphQLField("icon", type: .scalar(String.self)),
                GraphQLField("banner", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(artistName: String, artistId: GraphQLID, description: String? = nil, icon: String? = nil, banner: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_name": artistName, "artist_id": artistId, "description": description, "icon": icon, "banner": banner])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var artistName: String {
                get {
                  return resultMap["artist_name"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "artist_name")
                }
              }

              public var artistId: GraphQLID {
                get {
                  return resultMap["artist_id"]! as! GraphQLID
                }
                set {
                  resultMap.updateValue(newValue, forKey: "artist_id")
                }
              }

              public var description: String? {
                get {
                  return resultMap["description"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "description")
                }
              }

              public var icon: String? {
                get {
                  return resultMap["icon"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "icon")
                }
              }

              public var banner: String? {
                get {
                  return resultMap["banner"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "banner")
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class MyStickersQuery: GraphQLQuery {
  public let operationDefinition =
    "query MyStickers {\n  user {\n    __typename\n    id\n    username\n    phone\n    email\n    bio\n    avatar\n    sex\n    stickers(orderBy: [{field: \"updated_at\", order: DESC}]) {\n      __typename\n      bundle_id\n      bundle_icon\n      bundle_name\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("user", type: .object(User.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(user: User? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
    }

    public var user: User? {
      get {
        return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "user")
      }
    }

    public struct User: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .scalar(String.self)),
        GraphQLField("phone", type: .scalar(String.self)),
        GraphQLField("email", type: .scalar(String.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("avatar", type: .scalar(String.self)),
        GraphQLField("sex", type: .scalar(Int.self)),
        GraphQLField("stickers", arguments: ["orderBy": [["field": "updated_at", "order": "DESC"]]], type: .nonNull(.list(.nonNull(.object(Sticker.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, username: String? = nil, phone: String? = nil, email: String? = nil, bio: String? = nil, avatar: String? = nil, sex: Int? = nil, stickers: [Sticker]) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "username": username, "phone": phone, "email": email, "bio": bio, "avatar": avatar, "sex": sex, "stickers": stickers.map { (value: Sticker) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String? {
        get {
          return resultMap["username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "username")
        }
      }

      public var phone: String? {
        get {
          return resultMap["phone"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "phone")
        }
      }

      public var email: String? {
        get {
          return resultMap["email"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "email")
        }
      }

      public var bio: String? {
        get {
          return resultMap["bio"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bio")
        }
      }

      public var avatar: String? {
        get {
          return resultMap["avatar"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "avatar")
        }
      }

      public var sex: Int? {
        get {
          return resultMap["sex"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "sex")
        }
      }

      public var stickers: [Sticker] {
        get {
          return (resultMap["stickers"] as! [ResultMap]).map { (value: ResultMap) -> Sticker in Sticker(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Sticker) -> ResultMap in value.resultMap }, forKey: "stickers")
        }
      }

      public struct Sticker: GraphQLSelectionSet {
        public static let possibleTypes = ["Sticker"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("bundle_icon", type: .scalar(String.self)),
          GraphQLField("bundle_name", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bundleId: GraphQLID {
          get {
            return resultMap["bundle_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "bundle_id")
          }
        }

        public var bundleIcon: String? {
          get {
            return resultMap["bundle_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bundle_icon")
          }
        }

        public var bundleName: String? {
          get {
            return resultMap["bundle_name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bundle_name")
          }
        }
      }
    }
  }
}

public final class DownloadStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation DownloadSticker($bundleId: ID!) {\n  downloadSticker(bundle_id: $bundleId) {\n    __typename\n    bundle_id\n    bundle_icon\n    bundle_name\n    stickerLists {\n      __typename\n      bundle_id\n      sticker_icon\n      sitcker_name\n      sticker_id\n    }\n  }\n}"

  public var bundleId: GraphQLID

  public init(bundleId: GraphQLID) {
    self.bundleId = bundleId
  }

  public var variables: GraphQLMap? {
    return ["bundleId": bundleId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("downloadSticker", arguments: ["bundle_id": GraphQLVariable("bundleId")], type: .object(DownloadSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(downloadSticker: DownloadSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "downloadSticker": downloadSticker.flatMap { (value: DownloadSticker) -> ResultMap in value.resultMap }])
    }

    public var downloadSticker: DownloadSticker? {
      get {
        return (resultMap["downloadSticker"] as? ResultMap).flatMap { DownloadSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "downloadSticker")
      }
    }

    public struct DownloadSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["Sticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("bundle_icon", type: .scalar(String.self)),
        GraphQLField("bundle_name", type: .scalar(String.self)),
        GraphQLField("stickerLists", type: .list(.object(StickerList.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil, stickerLists: [StickerList?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName, "stickerLists": stickerLists.flatMap { (value: [StickerList?]) -> [ResultMap?] in value.map { (value: StickerList?) -> ResultMap? in value.flatMap { (value: StickerList) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bundleId: GraphQLID {
        get {
          return resultMap["bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_id")
        }
      }

      public var bundleIcon: String? {
        get {
          return resultMap["bundle_icon"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_icon")
        }
      }

      public var bundleName: String? {
        get {
          return resultMap["bundle_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_name")
        }
      }

      public var stickerLists: [StickerList?]? {
        get {
          return (resultMap["stickerLists"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [StickerList?] in value.map { (value: ResultMap?) -> StickerList? in value.flatMap { (value: ResultMap) -> StickerList in StickerList(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [StickerList?]) -> [ResultMap?] in value.map { (value: StickerList?) -> ResultMap? in value.flatMap { (value: StickerList) -> ResultMap in value.resultMap } } }, forKey: "stickerLists")
        }
      }

      public struct StickerList: GraphQLSelectionSet {
        public static let possibleTypes = ["StickerList"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bundle_id", type: .nonNull(.scalar(Int.self))),
          GraphQLField("sticker_icon", type: .scalar(String.self)),
          GraphQLField("sitcker_name", type: .scalar(String.self)),
          GraphQLField("sticker_id", type: .scalar(GraphQLID.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(bundleId: Int, stickerIcon: String? = nil, sitckerName: String? = nil, stickerId: GraphQLID? = nil) {
          self.init(unsafeResultMap: ["__typename": "StickerList", "bundle_id": bundleId, "sticker_icon": stickerIcon, "sitcker_name": sitckerName, "sticker_id": stickerId])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bundleId: Int {
          get {
            return resultMap["bundle_id"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bundle_id")
          }
        }

        public var stickerIcon: String? {
          get {
            return resultMap["sticker_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sticker_icon")
          }
        }

        public var sitckerName: String? {
          get {
            return resultMap["sitcker_name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "sitcker_name")
          }
        }

        public var stickerId: GraphQLID? {
          get {
            return resultMap["sticker_id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "sticker_id")
          }
        }
      }
    }
  }
}

public final class RemoveStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveSticker($bundleId: ID!) {\n  removeSticker(bundle_id: $bundleId) {\n    __typename\n    bundle_id\n  }\n}"

  public var bundleId: GraphQLID

  public init(bundleId: GraphQLID) {
    self.bundleId = bundleId
  }

  public var variables: GraphQLMap? {
    return ["bundleId": bundleId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeSticker", arguments: ["bundle_id": GraphQLVariable("bundleId")], type: .object(RemoveSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeSticker: RemoveSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeSticker": removeSticker.flatMap { (value: RemoveSticker) -> ResultMap in value.resultMap }])
    }

    public var removeSticker: RemoveSticker? {
      get {
        return (resultMap["removeSticker"] as? ResultMap).flatMap { RemoveSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "removeSticker")
      }
    }

    public struct RemoveSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["Sticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bundleId: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bundleId: GraphQLID {
        get {
          return resultMap["bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_id")
        }
      }
    }
  }
}

public final class DownloadFaceUnityMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation DownloadFaceUnity($fu_bundle_Id: ID!) {\n  downloadFaceUnity(fu_bundle_id: $fu_bundle_Id) {\n    __typename\n    fu_id\n    fu_bundle_id\n    is_show\n    fu_name\n    fu_item_path\n    fu_device_type\n    fu_file_type\n    faceUnity {\n      __typename\n      fu_bundle_id\n      fu_categories_id\n      fu_bundle_icon\n      fu_bundle_name\n      fu_bundle_description\n      fu_bundle_sequence\n      fu_is_free\n      fu_is_show\n      fu_is_official\n      fu_is_delete\n      fu_download_count\n      fu_max_face\n      fu_face_description\n    }\n  }\n}"

  public var fu_bundle_Id: GraphQLID

  public init(fu_bundle_Id: GraphQLID) {
    self.fu_bundle_Id = fu_bundle_Id
  }

  public var variables: GraphQLMap? {
    return ["fu_bundle_Id": fu_bundle_Id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("downloadFaceUnity", arguments: ["fu_bundle_id": GraphQLVariable("fu_bundle_Id")], type: .object(DownloadFaceUnity.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(downloadFaceUnity: DownloadFaceUnity? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "downloadFaceUnity": downloadFaceUnity.flatMap { (value: DownloadFaceUnity) -> ResultMap in value.resultMap }])
    }

    public var downloadFaceUnity: DownloadFaceUnity? {
      get {
        return (resultMap["downloadFaceUnity"] as? ResultMap).flatMap { DownloadFaceUnity(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "downloadFaceUnity")
      }
    }

    public struct DownloadFaceUnity: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnityBundleList"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fu_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("fu_bundle_id", type: .scalar(Int.self)),
        GraphQLField("is_show", type: .scalar(Int.self)),
        GraphQLField("fu_name", type: .scalar(String.self)),
        GraphQLField("fu_item_path", type: .scalar(String.self)),
        GraphQLField("fu_device_type", type: .scalar(Int.self)),
        GraphQLField("fu_file_type", type: .scalar(String.self)),
        GraphQLField("faceUnity", type: .object(FaceUnity.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fuId: GraphQLID, fuBundleId: Int? = nil, isShow: Int? = nil, fuName: String? = nil, fuItemPath: String? = nil, fuDeviceType: Int? = nil, fuFileType: String? = nil, faceUnity: FaceUnity? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnityBundleList", "fu_id": fuId, "fu_bundle_id": fuBundleId, "is_show": isShow, "fu_name": fuName, "fu_item_path": fuItemPath, "fu_device_type": fuDeviceType, "fu_file_type": fuFileType, "faceUnity": faceUnity.flatMap { (value: FaceUnity) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fuId: GraphQLID {
        get {
          return resultMap["fu_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_id")
        }
      }

      public var fuBundleId: Int? {
        get {
          return resultMap["fu_bundle_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_id")
        }
      }

      public var isShow: Int? {
        get {
          return resultMap["is_show"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "is_show")
        }
      }

      public var fuName: String? {
        get {
          return resultMap["fu_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_name")
        }
      }

      public var fuItemPath: String? {
        get {
          return resultMap["fu_item_path"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_item_path")
        }
      }

      public var fuDeviceType: Int? {
        get {
          return resultMap["fu_device_type"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_device_type")
        }
      }

      public var fuFileType: String? {
        get {
          return resultMap["fu_file_type"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_file_type")
        }
      }

      public var faceUnity: FaceUnity? {
        get {
          return (resultMap["faceUnity"] as? ResultMap).flatMap { FaceUnity(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "faceUnity")
        }
      }

      public struct FaceUnity: GraphQLSelectionSet {
        public static let possibleTypes = ["FaceUnity"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fu_bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fu_categories_id", type: .scalar(Int.self)),
          GraphQLField("fu_bundle_icon", type: .scalar(String.self)),
          GraphQLField("fu_bundle_name", type: .scalar(String.self)),
          GraphQLField("fu_bundle_description", type: .scalar(String.self)),
          GraphQLField("fu_bundle_sequence", type: .scalar(Int.self)),
          GraphQLField("fu_is_free", type: .scalar(Int.self)),
          GraphQLField("fu_is_show", type: .scalar(Int.self)),
          GraphQLField("fu_is_official", type: .scalar(Int.self)),
          GraphQLField("fu_is_delete", type: .scalar(Int.self)),
          GraphQLField("fu_download_count", type: .scalar(Int.self)),
          GraphQLField("fu_max_face", type: .scalar(Int.self)),
          GraphQLField("fu_face_description", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(fuBundleId: GraphQLID, fuCategoriesId: Int? = nil, fuBundleIcon: String? = nil, fuBundleName: String? = nil, fuBundleDescription: String? = nil, fuBundleSequence: Int? = nil, fuIsFree: Int? = nil, fuIsShow: Int? = nil, fuIsOfficial: Int? = nil, fuIsDelete: Int? = nil, fuDownloadCount: Int? = nil, fuMaxFace: Int? = nil, fuFaceDescription: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "FaceUnity", "fu_bundle_id": fuBundleId, "fu_categories_id": fuCategoriesId, "fu_bundle_icon": fuBundleIcon, "fu_bundle_name": fuBundleName, "fu_bundle_description": fuBundleDescription, "fu_bundle_sequence": fuBundleSequence, "fu_is_free": fuIsFree, "fu_is_show": fuIsShow, "fu_is_official": fuIsOfficial, "fu_is_delete": fuIsDelete, "fu_download_count": fuDownloadCount, "fu_max_face": fuMaxFace, "fu_face_description": fuFaceDescription])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fuBundleId: GraphQLID {
          get {
            return resultMap["fu_bundle_id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_id")
          }
        }

        public var fuCategoriesId: Int? {
          get {
            return resultMap["fu_categories_id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_categories_id")
          }
        }

        public var fuBundleIcon: String? {
          get {
            return resultMap["fu_bundle_icon"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_icon")
          }
        }

        public var fuBundleName: String? {
          get {
            return resultMap["fu_bundle_name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_name")
          }
        }

        public var fuBundleDescription: String? {
          get {
            return resultMap["fu_bundle_description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_description")
          }
        }

        public var fuBundleSequence: Int? {
          get {
            return resultMap["fu_bundle_sequence"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_bundle_sequence")
          }
        }

        public var fuIsFree: Int? {
          get {
            return resultMap["fu_is_free"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_free")
          }
        }

        public var fuIsShow: Int? {
          get {
            return resultMap["fu_is_show"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_show")
          }
        }

        public var fuIsOfficial: Int? {
          get {
            return resultMap["fu_is_official"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_official")
          }
        }

        public var fuIsDelete: Int? {
          get {
            return resultMap["fu_is_delete"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_is_delete")
          }
        }

        public var fuDownloadCount: Int? {
          get {
            return resultMap["fu_download_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_download_count")
          }
        }

        public var fuMaxFace: Int? {
          get {
            return resultMap["fu_max_face"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_max_face")
          }
        }

        public var fuFaceDescription: String? {
          get {
            return resultMap["fu_face_description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "fu_face_description")
          }
        }
      }
    }
  }
}

public final class RemoveFaceUnityMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveFaceUnity($fu_bundle_Id: ID!) {\n  removeFaceUnity(fu_bundle_id: $fu_bundle_Id) {\n    __typename\n    fu_bundle_id\n    fu_categories_id\n    fu_bundle_icon\n    fu_bundle_name\n    fu_bundle_description\n    fu_bundle_sequence\n    fu_is_free\n    fu_is_show\n    fu_is_official\n    fu_is_delete\n    fu_download_count\n    fu_max_face\n    fu_face_description\n  }\n}"

  public var fu_bundle_Id: GraphQLID

  public init(fu_bundle_Id: GraphQLID) {
    self.fu_bundle_Id = fu_bundle_Id
  }

  public var variables: GraphQLMap? {
    return ["fu_bundle_Id": fu_bundle_Id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeFaceUnity", arguments: ["fu_bundle_id": GraphQLVariable("fu_bundle_Id")], type: .object(RemoveFaceUnity.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeFaceUnity: RemoveFaceUnity? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeFaceUnity": removeFaceUnity.flatMap { (value: RemoveFaceUnity) -> ResultMap in value.resultMap }])
    }

    public var removeFaceUnity: RemoveFaceUnity? {
      get {
        return (resultMap["removeFaceUnity"] as? ResultMap).flatMap { RemoveFaceUnity(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "removeFaceUnity")
      }
    }

    public struct RemoveFaceUnity: GraphQLSelectionSet {
      public static let possibleTypes = ["FaceUnity"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fu_bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("fu_categories_id", type: .scalar(Int.self)),
        GraphQLField("fu_bundle_icon", type: .scalar(String.self)),
        GraphQLField("fu_bundle_name", type: .scalar(String.self)),
        GraphQLField("fu_bundle_description", type: .scalar(String.self)),
        GraphQLField("fu_bundle_sequence", type: .scalar(Int.self)),
        GraphQLField("fu_is_free", type: .scalar(Int.self)),
        GraphQLField("fu_is_show", type: .scalar(Int.self)),
        GraphQLField("fu_is_official", type: .scalar(Int.self)),
        GraphQLField("fu_is_delete", type: .scalar(Int.self)),
        GraphQLField("fu_download_count", type: .scalar(Int.self)),
        GraphQLField("fu_max_face", type: .scalar(Int.self)),
        GraphQLField("fu_face_description", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fuBundleId: GraphQLID, fuCategoriesId: Int? = nil, fuBundleIcon: String? = nil, fuBundleName: String? = nil, fuBundleDescription: String? = nil, fuBundleSequence: Int? = nil, fuIsFree: Int? = nil, fuIsShow: Int? = nil, fuIsOfficial: Int? = nil, fuIsDelete: Int? = nil, fuDownloadCount: Int? = nil, fuMaxFace: Int? = nil, fuFaceDescription: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "FaceUnity", "fu_bundle_id": fuBundleId, "fu_categories_id": fuCategoriesId, "fu_bundle_icon": fuBundleIcon, "fu_bundle_name": fuBundleName, "fu_bundle_description": fuBundleDescription, "fu_bundle_sequence": fuBundleSequence, "fu_is_free": fuIsFree, "fu_is_show": fuIsShow, "fu_is_official": fuIsOfficial, "fu_is_delete": fuIsDelete, "fu_download_count": fuDownloadCount, "fu_max_face": fuMaxFace, "fu_face_description": fuFaceDescription])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fuBundleId: GraphQLID {
        get {
          return resultMap["fu_bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_id")
        }
      }

      public var fuCategoriesId: Int? {
        get {
          return resultMap["fu_categories_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_categories_id")
        }
      }

      public var fuBundleIcon: String? {
        get {
          return resultMap["fu_bundle_icon"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_icon")
        }
      }

      public var fuBundleName: String? {
        get {
          return resultMap["fu_bundle_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_name")
        }
      }

      public var fuBundleDescription: String? {
        get {
          return resultMap["fu_bundle_description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_description")
        }
      }

      public var fuBundleSequence: Int? {
        get {
          return resultMap["fu_bundle_sequence"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_bundle_sequence")
        }
      }

      public var fuIsFree: Int? {
        get {
          return resultMap["fu_is_free"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_free")
        }
      }

      public var fuIsShow: Int? {
        get {
          return resultMap["fu_is_show"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_show")
        }
      }

      public var fuIsOfficial: Int? {
        get {
          return resultMap["fu_is_official"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_official")
        }
      }

      public var fuIsDelete: Int? {
        get {
          return resultMap["fu_is_delete"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_is_delete")
        }
      }

      public var fuDownloadCount: Int? {
        get {
          return resultMap["fu_download_count"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_download_count")
        }
      }

      public var fuMaxFace: Int? {
        get {
          return resultMap["fu_max_face"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_max_face")
        }
      }

      public var fuFaceDescription: String? {
        get {
          return resultMap["fu_face_description"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "fu_face_description")
        }
      }
    }
  }
}

public final class FetchRemarksQuery: GraphQLQuery {
  public let operationDefinition =
    "query FetchRemarks($owner_id: Int!) {\n  fetchRemarks(owner_id: $owner_id) {\n    __typename\n    target_id\n    target_username\n    remark_name\n  }\n}"

  public var owner_id: Int

  public init(owner_id: Int) {
    self.owner_id = owner_id
  }

  public var variables: GraphQLMap? {
    return ["owner_id": owner_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("fetchRemarks", arguments: ["owner_id": GraphQLVariable("owner_id")], type: .nonNull(.list(.nonNull(.object(FetchRemark.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(fetchRemarks: [FetchRemark]) {
      self.init(unsafeResultMap: ["__typename": "Query", "fetchRemarks": fetchRemarks.map { (value: FetchRemark) -> ResultMap in value.resultMap }])
    }

    public var fetchRemarks: [FetchRemark] {
      get {
        return (resultMap["fetchRemarks"] as! [ResultMap]).map { (value: ResultMap) -> FetchRemark in FetchRemark(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: FetchRemark) -> ResultMap in value.resultMap }, forKey: "fetchRemarks")
      }
    }

    public struct FetchRemark: GraphQLSelectionSet {
      public static let possibleTypes = ["UserRemark"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("target_id", type: .scalar(Int.self)),
        GraphQLField("target_username", type: .scalar(String.self)),
        GraphQLField("remark_name", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(targetId: Int? = nil, targetUsername: String? = nil, remarkName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "UserRemark", "target_id": targetId, "target_username": targetUsername, "remark_name": remarkName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var targetId: Int? {
        get {
          return resultMap["target_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_id")
        }
      }

      public var targetUsername: String? {
        get {
          return resultMap["target_username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_username")
        }
      }

      public var remarkName: String? {
        get {
          return resultMap["remark_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "remark_name")
        }
      }
    }
  }
}

public final class InsertUpdateUserRemarkMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation InsertUpdateUserRemark($target_id: Int!, $target_username: String!, $remark_name: String!) {\n  insertUpdateUserRemark(target_id: $target_id, target_username: $target_username, remark_name: $remark_name) {\n    __typename\n    owner_id\n    target_id\n    target_username\n    remark_name\n  }\n}"

  public var target_id: Int
  public var target_username: String
  public var remark_name: String

  public init(target_id: Int, target_username: String, remark_name: String) {
    self.target_id = target_id
    self.target_username = target_username
    self.remark_name = remark_name
  }

  public var variables: GraphQLMap? {
    return ["target_id": target_id, "target_username": target_username, "remark_name": remark_name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("insertUpdateUserRemark", arguments: ["target_id": GraphQLVariable("target_id"), "target_username": GraphQLVariable("target_username"), "remark_name": GraphQLVariable("remark_name")], type: .object(InsertUpdateUserRemark.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(insertUpdateUserRemark: InsertUpdateUserRemark? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "insertUpdateUserRemark": insertUpdateUserRemark.flatMap { (value: InsertUpdateUserRemark) -> ResultMap in value.resultMap }])
    }

    public var insertUpdateUserRemark: InsertUpdateUserRemark? {
      get {
        return (resultMap["insertUpdateUserRemark"] as? ResultMap).flatMap { InsertUpdateUserRemark(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "insertUpdateUserRemark")
      }
    }

    public struct InsertUpdateUserRemark: GraphQLSelectionSet {
      public static let possibleTypes = ["UserRemark"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner_id", type: .scalar(Int.self)),
        GraphQLField("target_id", type: .scalar(Int.self)),
        GraphQLField("target_username", type: .scalar(String.self)),
        GraphQLField("remark_name", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(ownerId: Int? = nil, targetId: Int? = nil, targetUsername: String? = nil, remarkName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "UserRemark", "owner_id": ownerId, "target_id": targetId, "target_username": targetUsername, "remark_name": remarkName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var ownerId: Int? {
        get {
          return resultMap["owner_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "owner_id")
        }
      }

      public var targetId: Int? {
        get {
          return resultMap["target_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_id")
        }
      }

      public var targetUsername: String? {
        get {
          return resultMap["target_username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_username")
        }
      }

      public var remarkName: String? {
        get {
          return resultMap["remark_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "remark_name")
        }
      }
    }
  }
}

public final class RemoveUserRemarkMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveUserRemark($target_id: Int!) {\n  removeRemark(target_id: $target_id) {\n    __typename\n    owner_id\n    target_id\n    target_username\n    remark_name\n  }\n}"

  public var target_id: Int

  public init(target_id: Int) {
    self.target_id = target_id
  }

  public var variables: GraphQLMap? {
    return ["target_id": target_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeRemark", arguments: ["target_id": GraphQLVariable("target_id")], type: .object(RemoveRemark.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeRemark: RemoveRemark? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeRemark": removeRemark.flatMap { (value: RemoveRemark) -> ResultMap in value.resultMap }])
    }

    public var removeRemark: RemoveRemark? {
      get {
        return (resultMap["removeRemark"] as? ResultMap).flatMap { RemoveRemark(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "removeRemark")
      }
    }

    public struct RemoveRemark: GraphQLSelectionSet {
      public static let possibleTypes = ["UserRemark"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner_id", type: .scalar(Int.self)),
        GraphQLField("target_id", type: .scalar(Int.self)),
        GraphQLField("target_username", type: .scalar(String.self)),
        GraphQLField("remark_name", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(ownerId: Int? = nil, targetId: Int? = nil, targetUsername: String? = nil, remarkName: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "UserRemark", "owner_id": ownerId, "target_id": targetId, "target_username": targetUsername, "remark_name": remarkName])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var ownerId: Int? {
        get {
          return resultMap["owner_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "owner_id")
        }
      }

      public var targetId: Int? {
        get {
          return resultMap["target_id"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_id")
        }
      }

      public var targetUsername: String? {
        get {
          return resultMap["target_username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "target_username")
        }
      }

      public var remarkName: String? {
        get {
          return resultMap["remark_name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "remark_name")
        }
      }
    }
  }
}

public final class BytedEffectSoundQuery: GraphQLQuery {
  public let operationDefinition =
    "query BytedEffectSound($first: Int!, $after: String) {\n  bytedEffectSound(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        id\n        name\n        file_url\n        cover_url\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("bytedEffectSound", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(BytedEffectSound.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bytedEffectSound: BytedEffectSound? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "bytedEffectSound": bytedEffectSound.flatMap { (value: BytedEffectSound) -> ResultMap in value.resultMap }])
    }

    public var bytedEffectSound: BytedEffectSound? {
      get {
        return (resultMap["bytedEffectSound"] as? ResultMap).flatMap { BytedEffectSound(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "bytedEffectSound")
      }
    }

    public struct BytedEffectSound: GraphQLSelectionSet {
      public static let possibleTypes = ["BytedEffectSoundConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "BytedEffectSoundConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["BytedEffectSoundEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "BytedEffectSoundEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["BytedEffectSound"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("file_url", type: .scalar(String.self)),
            GraphQLField("cover_url", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: String? = nil, fileUrl: String? = nil, coverUrl: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "BytedEffectSound", "id": id, "name": name, "file_url": fileUrl, "cover_url": coverUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var fileUrl: String? {
            get {
              return resultMap["file_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "file_url")
            }
          }

          public var coverUrl: String? {
            get {
              return resultMap["cover_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "cover_url")
            }
          }
        }
      }
    }
  }
}

public final class BytedEffectCategoriesQuery: GraphQLQuery {
  public let operationDefinition =
    "query BytedEffectCategories($first: Int!, $after: String) {\n  bytedEffectCategories(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        id\n        sequence\n        translation_key\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("bytedEffectCategories", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(BytedEffectCategory.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bytedEffectCategories: BytedEffectCategory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "bytedEffectCategories": bytedEffectCategories.flatMap { (value: BytedEffectCategory) -> ResultMap in value.resultMap }])
    }

    public var bytedEffectCategories: BytedEffectCategory? {
      get {
        return (resultMap["bytedEffectCategories"] as? ResultMap).flatMap { BytedEffectCategory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "bytedEffectCategories")
      }
    }

    public struct BytedEffectCategory: GraphQLSelectionSet {
      public static let possibleTypes = ["BytedEffectCategoryConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "BytedEffectCategoryConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["BytedEffectCategoryEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "BytedEffectCategoryEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["BytedEffectCategory"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("sequence", type: .scalar(Int.self)),
            GraphQLField("translation_key", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, sequence: Int? = nil, translationKey: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "BytedEffectCategory", "id": id, "sequence": sequence, "translation_key": translationKey])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var sequence: Int? {
            get {
              return resultMap["sequence"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "sequence")
            }
          }

          public var translationKey: String? {
            get {
              return resultMap["translation_key"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "translation_key")
            }
          }
        }
      }
    }
  }
}

public final class BytedEffectByCategoryQuery: GraphQLQuery {
  public let operationDefinition =
    "query BytedEffectByCategory($category_id: Int!, $first: Int!, $after: String) {\n  bytedEffectByCategory(category_id: $category_id, first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n      startCursor\n      endCursor\n      count\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        id\n        name\n        icon_url\n        sequence\n        category_id\n        bundle(device_type: 2) {\n          __typename\n          id\n          bundle_id\n          name\n          bundle_url\n        }\n      }\n      cursor\n    }\n  }\n}"

  public var category_id: Int
  public var first: Int
  public var after: String?

  public init(category_id: Int, first: Int, after: String? = nil) {
    self.category_id = category_id
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["category_id": category_id, "first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("bytedEffectByCategory", arguments: ["category_id": GraphQLVariable("category_id"), "first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(BytedEffectByCategory.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bytedEffectByCategory: BytedEffectByCategory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "bytedEffectByCategory": bytedEffectByCategory.flatMap { (value: BytedEffectByCategory) -> ResultMap in value.resultMap }])
    }

    public var bytedEffectByCategory: BytedEffectByCategory? {
      get {
        return (resultMap["bytedEffectByCategory"] as? ResultMap).flatMap { BytedEffectByCategory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "bytedEffectByCategory")
      }
    }

    public struct BytedEffectByCategory: GraphQLSelectionSet {
      public static let possibleTypes = ["BytedEffectConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "BytedEffectConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("startCursor", type: .scalar(String.self)),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("count", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool, startCursor: String? = nil, endCursor: String? = nil, count: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "startCursor": startCursor, "endCursor": endCursor, "count": count])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }

        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? {
          get {
            return resultMap["startCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startCursor")
          }
        }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        /// Count of nodes in current request.
        public var count: Int? {
          get {
            return resultMap["count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "count")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["BytedEffectEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "BytedEffectEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["BytedEffect"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("icon_url", type: .scalar(String.self)),
            GraphQLField("sequence", type: .scalar(Int.self)),
            GraphQLField("category_id", type: .scalar(Int.self)),
            GraphQLField("bundle", arguments: ["device_type": 2], type: .nonNull(.list(.nonNull(.object(Bundle.selections))))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: String? = nil, iconUrl: String? = nil, sequence: Int? = nil, categoryId: Int? = nil, bundle: [Bundle]) {
            self.init(unsafeResultMap: ["__typename": "BytedEffect", "id": id, "name": name, "icon_url": iconUrl, "sequence": sequence, "category_id": categoryId, "bundle": bundle.map { (value: Bundle) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var iconUrl: String? {
            get {
              return resultMap["icon_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "icon_url")
            }
          }

          public var sequence: Int? {
            get {
              return resultMap["sequence"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "sequence")
            }
          }

          public var categoryId: Int? {
            get {
              return resultMap["category_id"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "category_id")
            }
          }

          public var bundle: [Bundle] {
            get {
              return (resultMap["bundle"] as! [ResultMap]).map { (value: ResultMap) -> Bundle in Bundle(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Bundle) -> ResultMap in value.resultMap }, forKey: "bundle")
            }
          }

          public struct Bundle: GraphQLSelectionSet {
            public static let possibleTypes = ["BytedEffectBundleList"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("bundle_id", type: .scalar(Int.self)),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("bundle_url", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, bundleId: Int? = nil, name: String? = nil, bundleUrl: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "BytedEffectBundleList", "id": id, "bundle_id": bundleId, "name": name, "bundle_url": bundleUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var bundleId: Int? {
              get {
                return resultMap["bundle_id"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "bundle_id")
              }
            }

            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var bundleUrl: String? {
              get {
                return resultMap["bundle_url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "bundle_url")
              }
            }
          }
        }
      }
    }
  }
}

public final class FetchCustomStickersQuery: GraphQLQuery {
  public let operationDefinition =
    "query FetchCustomStickers($first: Int!, $after: String) {\n  fetchCustomStickers(first: $first, after: $after) {\n    __typename\n    pageInfo {\n      __typename\n      hasNextPage\n    }\n    edges {\n      __typename\n      node {\n        __typename\n        custom_sticker_id\n        sticker_url\n      }\n      cursor\n    }\n  }\n}"

  public var first: Int
  public var after: String?

  public init(first: Int, after: String? = nil) {
    self.first = first
    self.after = after
  }

  public var variables: GraphQLMap? {
    return ["first": first, "after": after]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("fetchCustomStickers", arguments: ["first": GraphQLVariable("first"), "after": GraphQLVariable("after")], type: .object(FetchCustomSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(fetchCustomStickers: FetchCustomSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "fetchCustomStickers": fetchCustomStickers.flatMap { (value: FetchCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var fetchCustomStickers: FetchCustomSticker? {
      get {
        return (resultMap["fetchCustomStickers"] as? ResultMap).flatMap { FetchCustomSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "fetchCustomStickers")
      }
    }

    public struct FetchCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomStickerConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomStickerConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(hasNextPage: Bool) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["CustomStickerEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node? = nil, cursor: String) {
          self.init(unsafeResultMap: ["__typename": "CustomStickerEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }, "cursor": cursor])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["CustomSticker"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("sticker_url", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(customStickerId: GraphQLID, stickerUrl: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId, "sticker_url": stickerUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var customStickerId: GraphQLID {
            get {
              return resultMap["custom_sticker_id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "custom_sticker_id")
            }
          }

          public var stickerUrl: String? {
            get {
              return resultMap["sticker_url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "sticker_url")
            }
          }
        }
      }
    }
  }
}

public final class DownloadCustomStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation DownloadCustomSticker($custom_sticker_id: ID!) {\n  downloadCustomSticker(custom_sticker_id: $custom_sticker_id) {\n    __typename\n    custom_sticker_id\n    sticker_url\n  }\n}"

  public var custom_sticker_id: GraphQLID

  public init(custom_sticker_id: GraphQLID) {
    self.custom_sticker_id = custom_sticker_id
  }

  public var variables: GraphQLMap? {
    return ["custom_sticker_id": custom_sticker_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("downloadCustomSticker", arguments: ["custom_sticker_id": GraphQLVariable("custom_sticker_id")], type: .object(DownloadCustomSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(downloadCustomSticker: DownloadCustomSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "downloadCustomSticker": downloadCustomSticker.flatMap { (value: DownloadCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var downloadCustomSticker: DownloadCustomSticker? {
      get {
        return (resultMap["downloadCustomSticker"] as? ResultMap).flatMap { DownloadCustomSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "downloadCustomSticker")
      }
    }

    public struct DownloadCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomSticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sticker_url", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customStickerId: GraphQLID, stickerUrl: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId, "sticker_url": stickerUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customStickerId: GraphQLID {
        get {
          return resultMap["custom_sticker_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "custom_sticker_id")
        }
      }

      public var stickerUrl: String? {
        get {
          return resultMap["sticker_url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "sticker_url")
        }
      }
    }
  }
}

public final class RemoveCustomStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveCustomSticker($custom_sticker_id: ID!) {\n  removeCustomSticker(custom_sticker_id: $custom_sticker_id) {\n    __typename\n    custom_sticker_id\n    sticker_url\n  }\n}"

  public var custom_sticker_id: GraphQLID

  public init(custom_sticker_id: GraphQLID) {
    self.custom_sticker_id = custom_sticker_id
  }

  public var variables: GraphQLMap? {
    return ["custom_sticker_id": custom_sticker_id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeCustomSticker", arguments: ["custom_sticker_id": GraphQLVariable("custom_sticker_id")], type: .object(RemoveCustomSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeCustomSticker: RemoveCustomSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeCustomSticker": removeCustomSticker.flatMap { (value: RemoveCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var removeCustomSticker: RemoveCustomSticker? {
      get {
        return (resultMap["removeCustomSticker"] as? ResultMap).flatMap { RemoveCustomSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "removeCustomSticker")
      }
    }

    public struct RemoveCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomSticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sticker_url", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customStickerId: GraphQLID, stickerUrl: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId, "sticker_url": stickerUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customStickerId: GraphQLID {
        get {
          return resultMap["custom_sticker_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "custom_sticker_id")
        }
      }

      public var stickerUrl: String? {
        get {
          return resultMap["sticker_url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "sticker_url")
        }
      }
    }
  }
}

public final class UploadCustomStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation UploadCustomSticker($file: Upload!) {\n  uploadCustomSticker(file: $file) {\n    __typename\n    custom_sticker_id\n    sticker_url\n  }\n}"

  public var file: String

  public init(file: String) {
    self.file = file
  }

  public var variables: GraphQLMap? {
    return ["file": file]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadCustomSticker", arguments: ["file": GraphQLVariable("file")], type: .object(UploadCustomSticker.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(uploadCustomSticker: UploadCustomSticker? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "uploadCustomSticker": uploadCustomSticker.flatMap { (value: UploadCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var uploadCustomSticker: UploadCustomSticker? {
      get {
        return (resultMap["uploadCustomSticker"] as? ResultMap).flatMap { UploadCustomSticker(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "uploadCustomSticker")
      }
    }

    public struct UploadCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomSticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sticker_url", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customStickerId: GraphQLID, stickerUrl: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId, "sticker_url": stickerUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customStickerId: GraphQLID {
        get {
          return resultMap["custom_sticker_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "custom_sticker_id")
        }
      }

      public var stickerUrl: String? {
        get {
          return resultMap["sticker_url"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "sticker_url")
        }
      }
    }
  }
}

public final class RemoveCustomStickersMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveCustomStickers($custom_sticker_ids: [ID!]) {\n  removeCustomStickers(custom_sticker_ids: $custom_sticker_ids) {\n    __typename\n    custom_sticker_id\n  }\n}"

  public var custom_sticker_ids: [GraphQLID]?

  public init(custom_sticker_ids: [GraphQLID]?) {
    self.custom_sticker_ids = custom_sticker_ids
  }

  public var variables: GraphQLMap? {
    return ["custom_sticker_ids": custom_sticker_ids]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeCustomStickers", arguments: ["custom_sticker_ids": GraphQLVariable("custom_sticker_ids")], type: .nonNull(.list(.nonNull(.object(RemoveCustomSticker.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeCustomStickers: [RemoveCustomSticker]) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeCustomStickers": removeCustomStickers.map { (value: RemoveCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var removeCustomStickers: [RemoveCustomSticker] {
      get {
        return (resultMap["removeCustomStickers"] as! [ResultMap]).map { (value: ResultMap) -> RemoveCustomSticker in RemoveCustomSticker(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: RemoveCustomSticker) -> ResultMap in value.resultMap }, forKey: "removeCustomStickers")
      }
    }

    public struct RemoveCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomSticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customStickerId: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customStickerId: GraphQLID {
        get {
          return resultMap["custom_sticker_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "custom_sticker_id")
        }
      }
    }
  }
}

public final class RemoveStickersMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation RemoveStickers($bundle_ids: [ID!]) {\n  removeStickers(bundle_ids: $bundle_ids) {\n    __typename\n    bundle_id\n  }\n}"

  public var bundle_ids: [GraphQLID]?

  public init(bundle_ids: [GraphQLID]?) {
    self.bundle_ids = bundle_ids
  }

  public var variables: GraphQLMap? {
    return ["bundle_ids": bundle_ids]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeStickers", arguments: ["bundle_ids": GraphQLVariable("bundle_ids")], type: .nonNull(.list(.nonNull(.object(RemoveSticker.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removeStickers: [RemoveSticker]) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removeStickers": removeStickers.map { (value: RemoveSticker) -> ResultMap in value.resultMap }])
    }

    public var removeStickers: [RemoveSticker] {
      get {
        return (resultMap["removeStickers"] as! [ResultMap]).map { (value: ResultMap) -> RemoveSticker in RemoveSticker(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: RemoveSticker) -> ResultMap in value.resultMap }, forKey: "removeStickers")
      }
    }

    public struct RemoveSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["Sticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bundleId: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bundleId: GraphQLID {
        get {
          return resultMap["bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_id")
        }
      }
    }
  }
}

public final class SortCustomStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation SortCustomSticker($custom_stickers: [CustomStickerInput!]) {\n  sortCustomSticker(custom_stickers: $custom_stickers) {\n    __typename\n    custom_sticker_id\n    pivot {\n      __typename\n      sequence\n    }\n  }\n}"

  public var custom_stickers: [CustomStickerInput]?

  public init(custom_stickers: [CustomStickerInput]?) {
    self.custom_stickers = custom_stickers
  }

  public var variables: GraphQLMap? {
    return ["custom_stickers": custom_stickers]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sortCustomSticker", arguments: ["custom_stickers": GraphQLVariable("custom_stickers")], type: .nonNull(.list(.nonNull(.object(SortCustomSticker.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sortCustomSticker: [SortCustomSticker]) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sortCustomSticker": sortCustomSticker.map { (value: SortCustomSticker) -> ResultMap in value.resultMap }])
    }

    public var sortCustomSticker: [SortCustomSticker] {
      get {
        return (resultMap["sortCustomSticker"] as! [ResultMap]).map { (value: ResultMap) -> SortCustomSticker in SortCustomSticker(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: SortCustomSticker) -> ResultMap in value.resultMap }, forKey: "sortCustomSticker")
      }
    }

    public struct SortCustomSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["CustomSticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("custom_sticker_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("pivot", type: .object(Pivot.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customStickerId: GraphQLID, pivot: Pivot? = nil) {
        self.init(unsafeResultMap: ["__typename": "CustomSticker", "custom_sticker_id": customStickerId, "pivot": pivot.flatMap { (value: Pivot) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customStickerId: GraphQLID {
        get {
          return resultMap["custom_sticker_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "custom_sticker_id")
        }
      }

      public var pivot: Pivot? {
        get {
          return (resultMap["pivot"] as? ResultMap).flatMap { Pivot(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "pivot")
        }
      }

      public struct Pivot: GraphQLSelectionSet {
        public static let possibleTypes = ["UserCustomStickerPivot"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("sequence", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(sequence: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "UserCustomStickerPivot", "sequence": sequence])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var sequence: Int? {
          get {
            return resultMap["sequence"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "sequence")
          }
        }
      }
    }
  }
}

public final class SortStickerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation SortSticker($stickers: [StickerInput!]) {\n  sortSticker(stickers: $stickers) {\n    __typename\n    bundle_id\n    pivot {\n      __typename\n      sequence\n    }\n  }\n}"

  public var stickers: [StickerInput]?

  public init(stickers: [StickerInput]?) {
    self.stickers = stickers
  }

  public var variables: GraphQLMap? {
    return ["stickers": stickers]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sortSticker", arguments: ["stickers": GraphQLVariable("stickers")], type: .nonNull(.list(.nonNull(.object(SortSticker.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sortSticker: [SortSticker]) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sortSticker": sortSticker.map { (value: SortSticker) -> ResultMap in value.resultMap }])
    }

    public var sortSticker: [SortSticker] {
      get {
        return (resultMap["sortSticker"] as! [ResultMap]).map { (value: ResultMap) -> SortSticker in SortSticker(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: SortSticker) -> ResultMap in value.resultMap }, forKey: "sortSticker")
      }
    }

    public struct SortSticker: GraphQLSelectionSet {
      public static let possibleTypes = ["Sticker"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("pivot", type: .object(Pivot.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(bundleId: GraphQLID, pivot: Pivot? = nil) {
        self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "pivot": pivot.flatMap { (value: Pivot) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bundleId: GraphQLID {
        get {
          return resultMap["bundle_id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "bundle_id")
        }
      }

      public var pivot: Pivot? {
        get {
          return (resultMap["pivot"] as? ResultMap).flatMap { Pivot(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "pivot")
        }
      }

      public struct Pivot: GraphQLSelectionSet {
        public static let possibleTypes = ["UserStickerPivot"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("sequence", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(sequence: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "UserStickerPivot", "sequence": sequence])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var sequence: Int? {
          get {
            return resultMap["sequence"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "sequence")
          }
        }
      }
    }
  }
}

public struct BundleInfo: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment BundleInfo on Sticker {\n  __typename\n  bundle_id\n  bundle_icon\n  bundle_name\n  banner_url\n  description\n  isGif\n}"

  public static let possibleTypes = ["Sticker"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("bundle_id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("bundle_icon", type: .scalar(String.self)),
    GraphQLField("bundle_name", type: .scalar(String.self)),
    GraphQLField("banner_url", type: .scalar(String.self)),
    GraphQLField("description", type: .scalar(String.self)),
    GraphQLField("isGif", type: .scalar(Int.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(bundleId: GraphQLID, bundleIcon: String? = nil, bundleName: String? = nil, bannerUrl: String? = nil, description: String? = nil, isGif: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "Sticker", "bundle_id": bundleId, "bundle_icon": bundleIcon, "bundle_name": bundleName, "banner_url": bannerUrl, "description": description, "isGif": isGif])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var bundleId: GraphQLID {
    get {
      return resultMap["bundle_id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "bundle_id")
    }
  }

  public var bundleIcon: String? {
    get {
      return resultMap["bundle_icon"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "bundle_icon")
    }
  }

  public var bundleName: String? {
    get {
      return resultMap["bundle_name"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "bundle_name")
    }
  }

  public var bannerUrl: String? {
    get {
      return resultMap["banner_url"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "banner_url")
    }
  }

  public var description: String? {
    get {
      return resultMap["description"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  public var isGif: Int? {
    get {
      return resultMap["isGif"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "isGif")
    }
  }
}

public struct ArtistInfo: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment ArtistInfo on StickerArtist {\n  __typename\n  artist_id\n  artist_name\n  description\n  icon\n  banner\n  uid\n}"

  public static let possibleTypes = ["StickerArtist"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("artist_id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("artist_name", type: .nonNull(.scalar(String.self))),
    GraphQLField("description", type: .scalar(String.self)),
    GraphQLField("icon", type: .scalar(String.self)),
    GraphQLField("banner", type: .scalar(String.self)),
    GraphQLField("uid", type: .scalar(Int.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(artistId: GraphQLID, artistName: String, description: String? = nil, icon: String? = nil, banner: String? = nil, uid: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "StickerArtist", "artist_id": artistId, "artist_name": artistName, "description": description, "icon": icon, "banner": banner, "uid": uid])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var artistId: GraphQLID {
    get {
      return resultMap["artist_id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "artist_id")
    }
  }

  public var artistName: String {
    get {
      return resultMap["artist_name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "artist_name")
    }
  }

  public var description: String? {
    get {
      return resultMap["description"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  public var icon: String? {
    get {
      return resultMap["icon"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "icon")
    }
  }

  public var banner: String? {
    get {
      return resultMap["banner"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "banner")
    }
  }

  public var uid: Int? {
    get {
      return resultMap["uid"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "uid")
    }
  }
}
