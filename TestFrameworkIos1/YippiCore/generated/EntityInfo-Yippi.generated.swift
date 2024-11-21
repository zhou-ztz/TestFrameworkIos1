// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


extension CountryEntity: ObjectBox.__EntityRelatable {
    internal typealias EntityType = CountryEntity

    internal var _id: EntityId<CountryEntity> {
        return EntityId<CountryEntity>(self.id.value)
    }
}

extension CountryEntity: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = CountryEntityBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "CountryEntity", id: 24)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: CountryEntity.self, id: 24, uid: 4487558620356764160)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 7077889924746723840)
        try entityBuilder.addProperty(name: "code", type: PropertyType.string, id: 2, uid: 8301639631822351360)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 3, uid: 4941442191265326592)

        try entityBuilder.lastProperty(id: 3, uid: 4941442191265326592)
    }
}

extension CountryEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CountryEntity.id == myId }
    internal static var id: Property<CountryEntity, Id, Id> { return Property<CountryEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CountryEntity.code.startsWith("X") }
    internal static var code: Property<CountryEntity, String, Void> { return Property<CountryEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CountryEntity.name.startsWith("X") }
    internal static var name: Property<CountryEntity, String, Void> { return Property<CountryEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == CountryEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<CountryEntity, Id, Id> { return Property<CountryEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .code.startsWith("X") }

    internal static var code: Property<CountryEntity, String, Void> { return Property<CountryEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<CountryEntity, String, Void> { return Property<CountryEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `CountryEntity.EntityBindingType`.
internal class CountryEntityBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = CountryEntity
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_code = propertyCollector.prepare(string: entity.code)
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_code, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 3)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = CountryEntity()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.code = entityReader.read(at: 2 + 2 * 2)
        entity.name = entityReader.read(at: 2 + 2 * 3)

        return entity
    }
}



extension EventEntity: ObjectBox.__EntityRelatable {
    internal typealias EntityType = EventEntity

    internal var _id: EntityId<EventEntity> {
        return EntityId<EventEntity>(self.id.value)
    }
}

extension EventEntity: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = EventEntityBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "EventEntity", id: 23)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: EventEntity.self, id: 23, uid: 4494622889153640960)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 5284771444462599680)
        try entityBuilder.addProperty(name: "itemId", type: PropertyType.string, id: 2, uid: 8226392785309593600)
        try entityBuilder.addProperty(name: "itemType", type: PropertyType.string, id: 3, uid: 1685554581512293120)
        try entityBuilder.addProperty(name: "bhvType", type: PropertyType.string, id: 4, uid: 7426219900064899840)
        try entityBuilder.addProperty(name: "traceId", type: PropertyType.string, id: 5, uid: 3851727721966118656)
        try entityBuilder.addProperty(name: "traceInfo", type: PropertyType.string, id: 6, uid: 5591965990571875840)
        try entityBuilder.addProperty(name: "sceneId", type: PropertyType.string, id: 7, uid: 1610995658511610112)
        try entityBuilder.addProperty(name: "bhvTime", type: PropertyType.string, id: 8, uid: 4764500269203235072)
        try entityBuilder.addProperty(name: "bhvValue", type: PropertyType.string, id: 9, uid: 5235895467321703168)
        try entityBuilder.addProperty(name: "userId", type: PropertyType.string, id: 10, uid: 1106378575285961216)
        try entityBuilder.addProperty(name: "platform", type: PropertyType.string, id: 11, uid: 2828628351877124864)
        try entityBuilder.addProperty(name: "imei", type: PropertyType.string, id: 12, uid: 6620866299898544896)
        try entityBuilder.addProperty(name: "appVersion", type: PropertyType.string, id: 13, uid: 8392972739322677248)
        try entityBuilder.addProperty(name: "netType", type: PropertyType.string, id: 14, uid: 8352621810059484672)
        try entityBuilder.addProperty(name: "ip", type: PropertyType.string, id: 15, uid: 7977035441793815040)
        try entityBuilder.addProperty(name: "login", type: PropertyType.string, id: 16, uid: 6161658180692166912)
        try entityBuilder.addProperty(name: "reportSrc", type: PropertyType.string, id: 17, uid: 7338027680868673024)
        try entityBuilder.addProperty(name: "deviceModel", type: PropertyType.string, id: 18, uid: 8742345720030209280)
        try entityBuilder.addProperty(name: "longitude", type: PropertyType.string, id: 19, uid: 7730346858840214272)
        try entityBuilder.addProperty(name: "latitude", type: PropertyType.string, id: 20, uid: 633698647485149184)
        try entityBuilder.addProperty(name: "moduleId", type: PropertyType.string, id: 21, uid: 5280268198585038080)
        try entityBuilder.addProperty(name: "pageId", type: PropertyType.string, id: 22, uid: 2946098669010340608)
        try entityBuilder.addProperty(name: "position", type: PropertyType.string, id: 23, uid: 6014526704615363072)
        try entityBuilder.addProperty(name: "messageId", type: PropertyType.string, id: 24, uid: 8985494355146791936)
        try entityBuilder.addProperty(name: "appName", type: PropertyType.string, id: 25, uid: 3780702733524021504)
        try entityBuilder.addProperty(name: "partitionDate", type: PropertyType.string, id: 26, uid: 8075023364712773376)
        try entityBuilder.addProperty(name: "fetchOrigin", type: PropertyType.string, id: 27, uid: 7871859084299845120)

        try entityBuilder.lastProperty(id: 27, uid: 7871859084299845120)
    }
}

extension EventEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.id == myId }
    internal static var id: Property<EventEntity, Id, Id> { return Property<EventEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.itemId.startsWith("X") }
    internal static var itemId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.itemType.startsWith("X") }
    internal static var itemType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.bhvType.startsWith("X") }
    internal static var bhvType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.traceId.startsWith("X") }
    internal static var traceId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.traceInfo.startsWith("X") }
    internal static var traceInfo: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.sceneId.startsWith("X") }
    internal static var sceneId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.bhvTime.startsWith("X") }
    internal static var bhvTime: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.bhvValue.startsWith("X") }
    internal static var bhvValue: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.userId.startsWith("X") }
    internal static var userId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.platform.startsWith("X") }
    internal static var platform: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.imei.startsWith("X") }
    internal static var imei: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.appVersion.startsWith("X") }
    internal static var appVersion: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.netType.startsWith("X") }
    internal static var netType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.ip.startsWith("X") }
    internal static var ip: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.login.startsWith("X") }
    internal static var login: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.reportSrc.startsWith("X") }
    internal static var reportSrc: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.deviceModel.startsWith("X") }
    internal static var deviceModel: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.longitude.startsWith("X") }
    internal static var longitude: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.latitude.startsWith("X") }
    internal static var latitude: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.moduleId.startsWith("X") }
    internal static var moduleId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.pageId.startsWith("X") }
    internal static var pageId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.position.startsWith("X") }
    internal static var position: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.messageId.startsWith("X") }
    internal static var messageId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.appName.startsWith("X") }
    internal static var appName: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.partitionDate.startsWith("X") }
    internal static var partitionDate: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 26, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { EventEntity.fetchOrigin.startsWith("X") }
    internal static var fetchOrigin: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 27, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == EventEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<EventEntity, Id, Id> { return Property<EventEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .itemId.startsWith("X") }

    internal static var itemId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .itemType.startsWith("X") }

    internal static var itemType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bhvType.startsWith("X") }

    internal static var bhvType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .traceId.startsWith("X") }

    internal static var traceId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .traceInfo.startsWith("X") }

    internal static var traceInfo: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .sceneId.startsWith("X") }

    internal static var sceneId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bhvTime.startsWith("X") }

    internal static var bhvTime: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bhvValue.startsWith("X") }

    internal static var bhvValue: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .userId.startsWith("X") }

    internal static var userId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .platform.startsWith("X") }

    internal static var platform: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .imei.startsWith("X") }

    internal static var imei: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .appVersion.startsWith("X") }

    internal static var appVersion: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .netType.startsWith("X") }

    internal static var netType: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .ip.startsWith("X") }

    internal static var ip: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .login.startsWith("X") }

    internal static var login: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .reportSrc.startsWith("X") }

    internal static var reportSrc: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .deviceModel.startsWith("X") }

    internal static var deviceModel: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .longitude.startsWith("X") }

    internal static var longitude: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .latitude.startsWith("X") }

    internal static var latitude: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .moduleId.startsWith("X") }

    internal static var moduleId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .pageId.startsWith("X") }

    internal static var pageId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .position.startsWith("X") }

    internal static var position: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .messageId.startsWith("X") }

    internal static var messageId: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .appName.startsWith("X") }

    internal static var appName: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .partitionDate.startsWith("X") }

    internal static var partitionDate: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 26, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .fetchOrigin.startsWith("X") }

    internal static var fetchOrigin: Property<EventEntity, String, Void> { return Property<EventEntity, String, Void>(propertyId: 27, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `EventEntity.EntityBindingType`.
internal class EventEntityBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = EventEntity
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_itemId = propertyCollector.prepare(string: entity.itemId)
        let propertyOffset_itemType = propertyCollector.prepare(string: entity.itemType)
        let propertyOffset_bhvType = propertyCollector.prepare(string: entity.bhvType)
        let propertyOffset_traceId = propertyCollector.prepare(string: entity.traceId)
        let propertyOffset_traceInfo = propertyCollector.prepare(string: entity.traceInfo)
        let propertyOffset_sceneId = propertyCollector.prepare(string: entity.sceneId)
        let propertyOffset_bhvTime = propertyCollector.prepare(string: entity.bhvTime)
        let propertyOffset_bhvValue = propertyCollector.prepare(string: entity.bhvValue)
        let propertyOffset_userId = propertyCollector.prepare(string: entity.userId)
        let propertyOffset_platform = propertyCollector.prepare(string: entity.platform)
        let propertyOffset_imei = propertyCollector.prepare(string: entity.imei)
        let propertyOffset_appVersion = propertyCollector.prepare(string: entity.appVersion)
        let propertyOffset_netType = propertyCollector.prepare(string: entity.netType)
        let propertyOffset_ip = propertyCollector.prepare(string: entity.ip)
        let propertyOffset_login = propertyCollector.prepare(string: entity.login)
        let propertyOffset_reportSrc = propertyCollector.prepare(string: entity.reportSrc)
        let propertyOffset_deviceModel = propertyCollector.prepare(string: entity.deviceModel)
        let propertyOffset_longitude = propertyCollector.prepare(string: entity.longitude)
        let propertyOffset_latitude = propertyCollector.prepare(string: entity.latitude)
        let propertyOffset_moduleId = propertyCollector.prepare(string: entity.moduleId)
        let propertyOffset_pageId = propertyCollector.prepare(string: entity.pageId)
        let propertyOffset_position = propertyCollector.prepare(string: entity.position)
        let propertyOffset_messageId = propertyCollector.prepare(string: entity.messageId)
        let propertyOffset_appName = propertyCollector.prepare(string: entity.appName)
        let propertyOffset_partitionDate = propertyCollector.prepare(string: entity.partitionDate)
        let propertyOffset_fetchOrigin = propertyCollector.prepare(string: entity.fetchOrigin)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_itemId, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_itemType, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_bhvType, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_traceId, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_traceInfo, at: 2 + 2 * 6)
        propertyCollector.collect(dataOffset: propertyOffset_sceneId, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_bhvTime, at: 2 + 2 * 8)
        propertyCollector.collect(dataOffset: propertyOffset_bhvValue, at: 2 + 2 * 9)
        propertyCollector.collect(dataOffset: propertyOffset_userId, at: 2 + 2 * 10)
        propertyCollector.collect(dataOffset: propertyOffset_platform, at: 2 + 2 * 11)
        propertyCollector.collect(dataOffset: propertyOffset_imei, at: 2 + 2 * 12)
        propertyCollector.collect(dataOffset: propertyOffset_appVersion, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_netType, at: 2 + 2 * 14)
        propertyCollector.collect(dataOffset: propertyOffset_ip, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_login, at: 2 + 2 * 16)
        propertyCollector.collect(dataOffset: propertyOffset_reportSrc, at: 2 + 2 * 17)
        propertyCollector.collect(dataOffset: propertyOffset_deviceModel, at: 2 + 2 * 18)
        propertyCollector.collect(dataOffset: propertyOffset_longitude, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_latitude, at: 2 + 2 * 20)
        propertyCollector.collect(dataOffset: propertyOffset_moduleId, at: 2 + 2 * 21)
        propertyCollector.collect(dataOffset: propertyOffset_pageId, at: 2 + 2 * 22)
        propertyCollector.collect(dataOffset: propertyOffset_position, at: 2 + 2 * 23)
        propertyCollector.collect(dataOffset: propertyOffset_messageId, at: 2 + 2 * 24)
        propertyCollector.collect(dataOffset: propertyOffset_appName, at: 2 + 2 * 25)
        propertyCollector.collect(dataOffset: propertyOffset_partitionDate, at: 2 + 2 * 26)
        propertyCollector.collect(dataOffset: propertyOffset_fetchOrigin, at: 2 + 2 * 27)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = EventEntity()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.itemId = entityReader.read(at: 2 + 2 * 2)
        entity.itemType = entityReader.read(at: 2 + 2 * 3)
        entity.bhvType = entityReader.read(at: 2 + 2 * 4)
        entity.traceId = entityReader.read(at: 2 + 2 * 5)
        entity.traceInfo = entityReader.read(at: 2 + 2 * 6)
        entity.sceneId = entityReader.read(at: 2 + 2 * 7)
        entity.bhvTime = entityReader.read(at: 2 + 2 * 8)
        entity.bhvValue = entityReader.read(at: 2 + 2 * 9)
        entity.userId = entityReader.read(at: 2 + 2 * 10)
        entity.platform = entityReader.read(at: 2 + 2 * 11)
        entity.imei = entityReader.read(at: 2 + 2 * 12)
        entity.appVersion = entityReader.read(at: 2 + 2 * 13)
        entity.netType = entityReader.read(at: 2 + 2 * 14)
        entity.ip = entityReader.read(at: 2 + 2 * 15)
        entity.login = entityReader.read(at: 2 + 2 * 16)
        entity.reportSrc = entityReader.read(at: 2 + 2 * 17)
        entity.deviceModel = entityReader.read(at: 2 + 2 * 18)
        entity.longitude = entityReader.read(at: 2 + 2 * 19)
        entity.latitude = entityReader.read(at: 2 + 2 * 20)
        entity.moduleId = entityReader.read(at: 2 + 2 * 21)
        entity.pageId = entityReader.read(at: 2 + 2 * 22)
        entity.position = entityReader.read(at: 2 + 2 * 23)
        entity.messageId = entityReader.read(at: 2 + 2 * 24)
        entity.appName = entityReader.read(at: 2 + 2 * 25)
        entity.partitionDate = entityReader.read(at: 2 + 2 * 26)
        entity.fetchOrigin = entityReader.read(at: 2 + 2 * 27)

        return entity
    }
}



extension FeedListModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = FeedListModel

    internal var _id: EntityId<FeedListModel> {
        return EntityId<FeedListModel>(self.feedId.value)
    }
}

extension FeedListModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = FeedListModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "FeedListModel", id: 7)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: FeedListModel.self, id: 7, uid: 5837724723651889664)
        try entityBuilder.addProperty(name: "feedId", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 1019146961543622912)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, id: 2, uid: 1413653545838604800)
        try entityBuilder.addProperty(name: "index", type: PropertyType.long, id: 3, uid: 8984458139442052352)
        try entityBuilder.addProperty(name: "userId", type: PropertyType.long, id: 4, uid: 669014988713836288)
        try entityBuilder.addProperty(name: "content", type: PropertyType.string, id: 5, uid: 5255479193342077440)
        try entityBuilder.addProperty(name: "from", type: PropertyType.long, id: 6, uid: 642430504840339456)
        try entityBuilder.addProperty(name: "likeCount", type: PropertyType.long, id: 7, uid: 5088076410596847872)
        try entityBuilder.addProperty(name: "viewCount", type: PropertyType.long, id: 8, uid: 8128288746350766848)
        try entityBuilder.addProperty(name: "commentCount", type: PropertyType.long, id: 9, uid: 7140870674536267776)
        try entityBuilder.addProperty(name: "rewardCount", type: PropertyType.long, id: 10, uid: 7069569646675657216)
        try entityBuilder.addProperty(name: "latitude", type: PropertyType.string, id: 11, uid: 6481845336709053952)
        try entityBuilder.addProperty(name: "longtitude", type: PropertyType.string, id: 12, uid: 7558485602569196032)
        try entityBuilder.addProperty(name: "geo", type: PropertyType.string, id: 13, uid: 4653764247225120000)
        try entityBuilder.addProperty(name: "feedMark", type: PropertyType.long, id: 14, uid: 3277413880401456128)
        try entityBuilder.addProperty(name: "pinned", type: PropertyType.long, id: 15, uid: 8149603405070192896)
        try entityBuilder.addProperty(name: "create", type: PropertyType.date, id: 16, uid: 2002392084078417920)
        try entityBuilder.addProperty(name: "delete", type: PropertyType.date, id: 17, uid: 2649478506162976256)
        try entityBuilder.addProperty(name: "hasCollect", type: PropertyType.bool, id: 18, uid: 302660218176682496)
        try entityBuilder.addProperty(name: "hasLike", type: PropertyType.bool, id: 19, uid: 2764203368876659712)
        try entityBuilder.addProperty(name: "repostType", type: PropertyType.string, id: 20, uid: 6341543693582419456)
        try entityBuilder.addProperty(name: "repostId", type: PropertyType.long, id: 21, uid: 3917854076662905344)
        try entityBuilder.addProperty(name: "hot", type: PropertyType.long, id: 22, uid: 8243487722905811712)
        try entityBuilder.addProperty(name: "hasReward", type: PropertyType.bool, id: 23, uid: 825275905895931904)
        try entityBuilder.addProperty(name: "hasDisabled", type: PropertyType.bool, id: 24, uid: 4747894739535378944)
        try entityBuilder.addProperty(name: "privacy", type: PropertyType.string, id: 25, uid: 712086577305953280)
        try entityBuilder.addProperty(name: "editedAt", type: PropertyType.string, id: 26, uid: 8158483469636579584)
        try entityBuilder.addProperty(name: "topReactions", type: PropertyType.string, id: 27, uid: 5782672877589588736)
        try entityBuilder.addProperty(name: "reactType", type: PropertyType.string, id: 28, uid: 8594940564205551616)
        try entityBuilder.addProperty(name: "isSponsored", type: PropertyType.bool, id: 29, uid: 5346682534091522304)
        try entityBuilder.addProperty(name: "feedType", type: PropertyType.string, id: 30, uid: 6364015798347757824)
        try entityBuilder.addProperty(name: "images", type: PropertyType.string, id: 31, uid: 5625880502079732736)
        try entityBuilder.addProperty(name: "feedVideo", type: PropertyType.string, id: 32, uid: 2458574517360954624)
        try entityBuilder.addProperty(name: "sharedModel", type: PropertyType.string, id: 33, uid: 1727396091355540992)
        try entityBuilder.addProperty(name: "location", type: PropertyType.string, id: 34, uid: 5945153529966974976)
        try entityBuilder.addProperty(name: "topics", type: PropertyType.string, id: 35, uid: 7908588905082604032)
        try entityBuilder.addProperty(name: "comments", type: PropertyType.string, id: 36, uid: 4442575556605726720)
        try entityBuilder.addProperty(name: "liveModel", type: PropertyType.string, id: 37, uid: 853005446502890240)
        try entityBuilder.addProperty(name: "rewardsMerchantUsers", type: PropertyType.string, id: 39, uid: 2702444766303750656)
        try entityBuilder.addProperty(name: "tagUsers", type: PropertyType.string, id: 43, uid: 4422032733432129792)
        try entityBuilder.addProperty(name: "rewardsLinkMerchantUsers", type: PropertyType.string, id: 44, uid: 9010752739702208256)
        try entityBuilder.addProperty(name: "feedForwardCount", type: PropertyType.long, id: 40, uid: 2769847051002190848)
        try entityBuilder.addProperty(name: "afterTime", type: PropertyType.string, id: 41, uid: 7549196780559016960)
        try entityBuilder.addProperty(name: "isPinned", type: PropertyType.bool, id: 42, uid: 8928810757289476352)
        try entityBuilder.addProperty(name: "tagVoucher", type: PropertyType.string, id: 45, uid: 470114365747547648)

        try entityBuilder.lastProperty(id: 45, uid: 470114365747547648)
    }
}

extension FeedListModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.feedId == myId }
    internal static var feedId: Property<FeedListModel, Id, Id> { return Property<FeedListModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.id > 1234 }
    internal static var id: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.index > 1234 }
    internal static var index: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.userId > 1234 }
    internal static var userId: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.content.startsWith("X") }
    internal static var content: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.from > 1234 }
    internal static var from: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.likeCount > 1234 }
    internal static var likeCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.viewCount > 1234 }
    internal static var viewCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.commentCount > 1234 }
    internal static var commentCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.rewardCount > 1234 }
    internal static var rewardCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.latitude.startsWith("X") }
    internal static var latitude: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.longtitude.startsWith("X") }
    internal static var longtitude: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.geo.startsWith("X") }
    internal static var geo: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.feedMark > 1234 }
    internal static var feedMark: Property<FeedListModel, Int64, Void> { return Property<FeedListModel, Int64, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.pinned > 1234 }
    internal static var pinned: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.create > 1234 }
    internal static var create: Property<FeedListModel, Date, Void> { return Property<FeedListModel, Date, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.delete > 1234 }
    internal static var delete: Property<FeedListModel, Date, Void> { return Property<FeedListModel, Date, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.hasCollect == true }
    internal static var hasCollect: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.hasLike == true }
    internal static var hasLike: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.repostType.startsWith("X") }
    internal static var repostType: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.repostId > 1234 }
    internal static var repostId: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.hot > 1234 }
    internal static var hot: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.hasReward == true }
    internal static var hasReward: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.hasDisabled == true }
    internal static var hasDisabled: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.privacy.startsWith("X") }
    internal static var privacy: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.editedAt.startsWith("X") }
    internal static var editedAt: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 26, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.topReactions.startsWith("X") }
    internal static var topReactions: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 27, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.reactType.startsWith("X") }
    internal static var reactType: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 28, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.isSponsored == true }
    internal static var isSponsored: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 29, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.feedType.startsWith("X") }
    internal static var feedType: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 30, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.images.startsWith("X") }
    internal static var images: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 31, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.feedVideo.startsWith("X") }
    internal static var feedVideo: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 32, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.sharedModel.startsWith("X") }
    internal static var sharedModel: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 33, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.location.startsWith("X") }
    internal static var location: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 34, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.topics.startsWith("X") }
    internal static var topics: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 35, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.comments.startsWith("X") }
    internal static var comments: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 36, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.liveModel.startsWith("X") }
    internal static var liveModel: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 37, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.rewardsMerchantUsers.startsWith("X") }
    internal static var rewardsMerchantUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 39, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.tagUsers.startsWith("X") }
    internal static var tagUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 43, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.rewardsLinkMerchantUsers.startsWith("X") }
    internal static var rewardsLinkMerchantUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 44, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.feedForwardCount > 1234 }
    internal static var feedForwardCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 40, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.afterTime.startsWith("X") }
    internal static var afterTime: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 41, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.isPinned == true }
    internal static var isPinned: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 42, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedListModel.tagVoucher.startsWith("X") }
    internal static var tagVoucher: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 45, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.feedId = Id(identifier)
    }
}

extension ObjectBox.Property where E == FeedListModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedId == myId }

    internal static var feedId: Property<FeedListModel, Id, Id> { return Property<FeedListModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id > 1234 }

    internal static var id: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .index > 1234 }

    internal static var index: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .userId > 1234 }

    internal static var userId: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .content.startsWith("X") }

    internal static var content: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .from > 1234 }

    internal static var from: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .likeCount > 1234 }

    internal static var likeCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .viewCount > 1234 }

    internal static var viewCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .commentCount > 1234 }

    internal static var commentCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rewardCount > 1234 }

    internal static var rewardCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .latitude.startsWith("X") }

    internal static var latitude: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .longtitude.startsWith("X") }

    internal static var longtitude: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .geo.startsWith("X") }

    internal static var geo: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedMark > 1234 }

    internal static var feedMark: Property<FeedListModel, Int64, Void> { return Property<FeedListModel, Int64, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .pinned > 1234 }

    internal static var pinned: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .create > 1234 }

    internal static var create: Property<FeedListModel, Date, Void> { return Property<FeedListModel, Date, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .delete > 1234 }

    internal static var delete: Property<FeedListModel, Date, Void> { return Property<FeedListModel, Date, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hasCollect == true }

    internal static var hasCollect: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hasLike == true }

    internal static var hasLike: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .repostType.startsWith("X") }

    internal static var repostType: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .repostId > 1234 }

    internal static var repostId: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hot > 1234 }

    internal static var hot: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hasReward == true }

    internal static var hasReward: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hasDisabled == true }

    internal static var hasDisabled: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .privacy.startsWith("X") }

    internal static var privacy: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .editedAt.startsWith("X") }

    internal static var editedAt: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 26, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .topReactions.startsWith("X") }

    internal static var topReactions: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 27, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .reactType.startsWith("X") }

    internal static var reactType: Property<FeedListModel, String?, Void> { return Property<FeedListModel, String?, Void>(propertyId: 28, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isSponsored == true }

    internal static var isSponsored: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 29, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedType.startsWith("X") }

    internal static var feedType: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 30, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .images.startsWith("X") }

    internal static var images: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 31, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedVideo.startsWith("X") }

    internal static var feedVideo: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 32, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .sharedModel.startsWith("X") }

    internal static var sharedModel: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 33, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .location.startsWith("X") }

    internal static var location: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 34, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .topics.startsWith("X") }

    internal static var topics: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 35, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .comments.startsWith("X") }

    internal static var comments: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 36, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .liveModel.startsWith("X") }

    internal static var liveModel: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 37, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rewardsMerchantUsers.startsWith("X") }

    internal static var rewardsMerchantUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 39, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .tagUsers.startsWith("X") }

    internal static var tagUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 43, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rewardsLinkMerchantUsers.startsWith("X") }

    internal static var rewardsLinkMerchantUsers: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 44, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedForwardCount > 1234 }

    internal static var feedForwardCount: Property<FeedListModel, Int, Void> { return Property<FeedListModel, Int, Void>(propertyId: 40, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .afterTime.startsWith("X") }

    internal static var afterTime: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 41, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isPinned == true }

    internal static var isPinned: Property<FeedListModel, Bool, Void> { return Property<FeedListModel, Bool, Void>(propertyId: 42, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .tagVoucher.startsWith("X") }

    internal static var tagVoucher: Property<FeedListModel, String, Void> { return Property<FeedListModel, String, Void>(propertyId: 45, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `FeedListModel.EntityBindingType`.
internal class FeedListModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = FeedListModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.feedId.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_content = propertyCollector.prepare(string: entity.content)
        let propertyOffset_latitude = propertyCollector.prepare(string: entity.latitude)
        let propertyOffset_longtitude = propertyCollector.prepare(string: entity.longtitude)
        let propertyOffset_geo = propertyCollector.prepare(string: entity.geo)
        let propertyOffset_repostType = propertyCollector.prepare(string: entity.repostType)
        let propertyOffset_privacy = propertyCollector.prepare(string: entity.privacy)
        let propertyOffset_editedAt = propertyCollector.prepare(string: entity.editedAt)
        let propertyOffset_topReactions = propertyCollector.prepare(string: entity.topReactions)
        let propertyOffset_reactType = propertyCollector.prepare(string: entity.reactType)
        let propertyOffset_feedType = propertyCollector.prepare(string: entity.feedType)
        let propertyOffset_images = propertyCollector.prepare(string: FeedImageModel.convert(entity.images))
        let propertyOffset_feedVideo = propertyCollector.prepare(string: FeedVideoModel.convert(entity.feedVideo))
        let propertyOffset_sharedModel = propertyCollector.prepare(string: SharedViewModel.convert(entity.sharedModel))
        let propertyOffset_location = propertyCollector.prepare(string: TSPostLocationModel.convert(entity.location))
        let propertyOffset_topics = propertyCollector.prepare(string: TopicListModel.convert(entity.topics))
        let propertyOffset_comments = propertyCollector.prepare(string: FeedListCommentModel.convert(entity.comments))
        let propertyOffset_liveModel = propertyCollector.prepare(string: LiveEntityModel.convert(entity.liveModel))
        let propertyOffset_rewardsMerchantUsers = propertyCollector.prepare(string: TSRewardsLinkMerchantUserModel.convert(entity.rewardsMerchantUsers))
        let propertyOffset_tagUsers = propertyCollector.prepare(string: UserInfoModel.convert(entity.tagUsers))
        let propertyOffset_rewardsLinkMerchantUsers = propertyCollector.prepare(string: UserInfoModel.convert(entity.rewardsLinkMerchantUsers))
        let propertyOffset_afterTime = propertyCollector.prepare(string: entity.afterTime)
        let propertyOffset_tagVoucher = propertyCollector.prepare(string: TagVoucherModel.convert(entity.tagVoucher))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.id, at: 2 + 2 * 2)
        propertyCollector.collect(entity.index, at: 2 + 2 * 3)
        propertyCollector.collect(entity.userId, at: 2 + 2 * 4)
        propertyCollector.collect(entity.from, at: 2 + 2 * 6)
        propertyCollector.collect(entity.likeCount, at: 2 + 2 * 7)
        propertyCollector.collect(entity.viewCount, at: 2 + 2 * 8)
        propertyCollector.collect(entity.commentCount, at: 2 + 2 * 9)
        propertyCollector.collect(entity.rewardCount, at: 2 + 2 * 10)
        propertyCollector.collect(entity.feedMark, at: 2 + 2 * 14)
        propertyCollector.collect(entity.pinned, at: 2 + 2 * 15)
        propertyCollector.collect(entity.create, at: 2 + 2 * 16)
        propertyCollector.collect(entity.delete, at: 2 + 2 * 17)
        propertyCollector.collect(entity.hasCollect, at: 2 + 2 * 18)
        propertyCollector.collect(entity.hasLike, at: 2 + 2 * 19)
        propertyCollector.collect(entity.repostId, at: 2 + 2 * 21)
        propertyCollector.collect(entity.hot, at: 2 + 2 * 22)
        propertyCollector.collect(entity.hasReward, at: 2 + 2 * 23)
        propertyCollector.collect(entity.hasDisabled, at: 2 + 2 * 24)
        propertyCollector.collect(entity.isSponsored, at: 2 + 2 * 29)
        propertyCollector.collect(entity.feedForwardCount, at: 2 + 2 * 40)
        propertyCollector.collect(entity.isPinned, at: 2 + 2 * 42)
        propertyCollector.collect(dataOffset: propertyOffset_content, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_latitude, at: 2 + 2 * 11)
        propertyCollector.collect(dataOffset: propertyOffset_longtitude, at: 2 + 2 * 12)
        propertyCollector.collect(dataOffset: propertyOffset_geo, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_repostType, at: 2 + 2 * 20)
        propertyCollector.collect(dataOffset: propertyOffset_privacy, at: 2 + 2 * 25)
        propertyCollector.collect(dataOffset: propertyOffset_editedAt, at: 2 + 2 * 26)
        propertyCollector.collect(dataOffset: propertyOffset_topReactions, at: 2 + 2 * 27)
        propertyCollector.collect(dataOffset: propertyOffset_reactType, at: 2 + 2 * 28)
        propertyCollector.collect(dataOffset: propertyOffset_feedType, at: 2 + 2 * 30)
        propertyCollector.collect(dataOffset: propertyOffset_images, at: 2 + 2 * 31)
        propertyCollector.collect(dataOffset: propertyOffset_feedVideo, at: 2 + 2 * 32)
        propertyCollector.collect(dataOffset: propertyOffset_sharedModel, at: 2 + 2 * 33)
        propertyCollector.collect(dataOffset: propertyOffset_location, at: 2 + 2 * 34)
        propertyCollector.collect(dataOffset: propertyOffset_topics, at: 2 + 2 * 35)
        propertyCollector.collect(dataOffset: propertyOffset_comments, at: 2 + 2 * 36)
        propertyCollector.collect(dataOffset: propertyOffset_liveModel, at: 2 + 2 * 37)
        propertyCollector.collect(dataOffset: propertyOffset_rewardsMerchantUsers, at: 2 + 2 * 39)
        propertyCollector.collect(dataOffset: propertyOffset_tagUsers, at: 2 + 2 * 43)
        propertyCollector.collect(dataOffset: propertyOffset_rewardsLinkMerchantUsers, at: 2 + 2 * 44)
        propertyCollector.collect(dataOffset: propertyOffset_afterTime, at: 2 + 2 * 41)
        propertyCollector.collect(dataOffset: propertyOffset_tagVoucher, at: 2 + 2 * 45)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = FeedListModel()

        entity.feedId = entityReader.read(at: 2 + 2 * 1)
        entity.id = entityReader.read(at: 2 + 2 * 2)
        entity.index = entityReader.read(at: 2 + 2 * 3)
        entity.userId = entityReader.read(at: 2 + 2 * 4)
        entity.content = entityReader.read(at: 2 + 2 * 5)
        entity.from = entityReader.read(at: 2 + 2 * 6)
        entity.likeCount = entityReader.read(at: 2 + 2 * 7)
        entity.viewCount = entityReader.read(at: 2 + 2 * 8)
        entity.commentCount = entityReader.read(at: 2 + 2 * 9)
        entity.rewardCount = entityReader.read(at: 2 + 2 * 10)
        entity.latitude = entityReader.read(at: 2 + 2 * 11)
        entity.longtitude = entityReader.read(at: 2 + 2 * 12)
        entity.geo = entityReader.read(at: 2 + 2 * 13)
        entity.feedMark = entityReader.read(at: 2 + 2 * 14)
        entity.pinned = entityReader.read(at: 2 + 2 * 15)
        entity.create = entityReader.read(at: 2 + 2 * 16)
        entity.delete = entityReader.read(at: 2 + 2 * 17)
        entity.hasCollect = entityReader.read(at: 2 + 2 * 18)
        entity.hasLike = entityReader.read(at: 2 + 2 * 19)
        entity.repostType = entityReader.read(at: 2 + 2 * 20)
        entity.repostId = entityReader.read(at: 2 + 2 * 21)
        entity.hot = entityReader.read(at: 2 + 2 * 22)
        entity.hasReward = entityReader.read(at: 2 + 2 * 23)
        entity.hasDisabled = entityReader.read(at: 2 + 2 * 24)
        entity.privacy = entityReader.read(at: 2 + 2 * 25)
        entity.editedAt = entityReader.read(at: 2 + 2 * 26)
        entity.topReactions = entityReader.read(at: 2 + 2 * 27)
        entity.reactType = entityReader.read(at: 2 + 2 * 28)
        entity.isSponsored = entityReader.read(at: 2 + 2 * 29)
        entity.feedType = entityReader.read(at: 2 + 2 * 30)
        entity.images = FeedImageModel.convert(entityReader.read(at: 2 + 2 * 31))
        entity.feedVideo = FeedVideoModel.convert(entityReader.read(at: 2 + 2 * 32))
        entity.sharedModel = SharedViewModel.convert(entityReader.read(at: 2 + 2 * 33))
        entity.location = TSPostLocationModel.convert(entityReader.read(at: 2 + 2 * 34))
        entity.topics = TopicListModel.convert(entityReader.read(at: 2 + 2 * 35))
        entity.comments = FeedListCommentModel.convert(entityReader.read(at: 2 + 2 * 36))
        entity.liveModel = LiveEntityModel.convert(entityReader.read(at: 2 + 2 * 37))
        entity.rewardsMerchantUsers = TSRewardsLinkMerchantUserModel.convert(entityReader.read(at: 2 + 2 * 39))
        entity.tagUsers = UserInfoModel.convert(entityReader.read(at: 2 + 2 * 43))
        entity.rewardsLinkMerchantUsers = UserInfoModel.convert(entityReader.read(at: 2 + 2 * 44))
        entity.feedForwardCount = entityReader.read(at: 2 + 2 * 40)
        entity.afterTime = entityReader.read(at: 2 + 2 * 41)
        entity.isPinned = entityReader.read(at: 2 + 2 * 42)
        entity.tagVoucher = TagVoucherModel.convert(entityReader.read(at: 2 + 2 * 45))

        return entity
    }
}



extension FeedStoreModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = FeedStoreModel

    internal var _id: EntityId<FeedStoreModel> {
        return EntityId<FeedStoreModel>(self.feedId.value)
    }
}

extension FeedStoreModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = FeedStoreModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "FeedStoreModel", id: 11)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: FeedStoreModel.self, id: 11, uid: 3712742101132059136)
        try entityBuilder.addProperty(name: "feedId", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 2989843273031015936)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, id: 2, uid: 3322593231683911936)
        try entityBuilder.addProperty(name: "images", type: PropertyType.string, id: 3, uid: 6365954310138603776)
        try entityBuilder.addProperty(name: "feedVideo", type: PropertyType.string, id: 4, uid: 7291195539339711744)

        try entityBuilder.lastProperty(id: 4, uid: 7291195539339711744)
    }
}

extension FeedStoreModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedStoreModel.feedId == myId }
    internal static var feedId: Property<FeedStoreModel, Id, Id> { return Property<FeedStoreModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedStoreModel.id > 1234 }
    internal static var id: Property<FeedStoreModel, Int, Void> { return Property<FeedStoreModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedStoreModel.images.startsWith("X") }
    internal static var images: Property<FeedStoreModel, String, Void> { return Property<FeedStoreModel, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { FeedStoreModel.feedVideo.startsWith("X") }
    internal static var feedVideo: Property<FeedStoreModel, String, Void> { return Property<FeedStoreModel, String, Void>(propertyId: 4, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.feedId = Id(identifier)
    }
}

extension ObjectBox.Property where E == FeedStoreModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedId == myId }

    internal static var feedId: Property<FeedStoreModel, Id, Id> { return Property<FeedStoreModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id > 1234 }

    internal static var id: Property<FeedStoreModel, Int, Void> { return Property<FeedStoreModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .images.startsWith("X") }

    internal static var images: Property<FeedStoreModel, String, Void> { return Property<FeedStoreModel, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedVideo.startsWith("X") }

    internal static var feedVideo: Property<FeedStoreModel, String, Void> { return Property<FeedStoreModel, String, Void>(propertyId: 4, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `FeedStoreModel.EntityBindingType`.
internal class FeedStoreModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = FeedStoreModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.feedId.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_images = propertyCollector.prepare(string: FeedImageModel.convert(entity.images))
        let propertyOffset_feedVideo = propertyCollector.prepare(string: FeedVideoModel.convert(entity.feedVideo))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.id, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_images, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_feedVideo, at: 2 + 2 * 4)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = FeedStoreModel()

        entity.feedId = entityReader.read(at: 2 + 2 * 1)
        entity.id = entityReader.read(at: 2 + 2 * 2)
        entity.images = FeedImageModel.convert(entityReader.read(at: 2 + 2 * 3))
        entity.feedVideo = FeedVideoModel.convert(entityReader.read(at: 2 + 2 * 4))

        return entity
    }
}



extension HashtagModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = HashtagModel

    internal var _id: EntityId<HashtagModel> {
        return EntityId<HashtagModel>(self.entityId.value)
    }
}

extension HashtagModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = HashtagModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "HashtagModel", id: 8)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: HashtagModel.self, id: 8, uid: 997180440747651840)
        try entityBuilder.addProperty(name: "entityId", type: PropertyType.long, flags: [.id], id: 1, uid: 3826351019259441152)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, id: 2, uid: 2254343218857779968)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 3, uid: 7953526327378736384)
        try entityBuilder.addProperty(name: "hashtagId", type: PropertyType.long, id: 4, uid: 2376010505951601152)

        try entityBuilder.lastProperty(id: 4, uid: 2376010505951601152)
    }
}

extension HashtagModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { HashtagModel.entityId == myId }
    internal static var entityId: Property<HashtagModel, Id, Id> { return Property<HashtagModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { HashtagModel.id > 1234 }
    internal static var id: Property<HashtagModel, Int, Void> { return Property<HashtagModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { HashtagModel.name.startsWith("X") }
    internal static var name: Property<HashtagModel, String?, Void> { return Property<HashtagModel, String?, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { HashtagModel.hashtagId > 1234 }
    internal static var hashtagId: Property<HashtagModel, Int?, Void> { return Property<HashtagModel, Int?, Void>(propertyId: 4, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.entityId = Id(identifier)
    }
}

extension ObjectBox.Property where E == HashtagModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .entityId == myId }

    internal static var entityId: Property<HashtagModel, Id, Id> { return Property<HashtagModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id > 1234 }

    internal static var id: Property<HashtagModel, Int, Void> { return Property<HashtagModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<HashtagModel, String?, Void> { return Property<HashtagModel, String?, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hashtagId > 1234 }

    internal static var hashtagId: Property<HashtagModel, Int?, Void> { return Property<HashtagModel, Int?, Void>(propertyId: 4, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `HashtagModel.EntityBindingType`.
internal class HashtagModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = HashtagModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.entityId.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.id, at: 2 + 2 * 2)
        propertyCollector.collect(entity.hashtagId, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 3)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = HashtagModel()

        entity.entityId = entityReader.read(at: 2 + 2 * 1)
        entity.id = entityReader.read(at: 2 + 2 * 2)
        entity.name = entityReader.read(at: 2 + 2 * 3)
        entity.hashtagId = entityReader.read(at: 2 + 2 * 4)

        return entity
    }
}



extension LanguageEntity: ObjectBox.__EntityRelatable {
    internal typealias EntityType = LanguageEntity

    internal var _id: EntityId<LanguageEntity> {
        return EntityId<LanguageEntity>(self.id.value)
    }
}

extension LanguageEntity: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = LanguageEntityBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "LanguageEntity", id: 25)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: LanguageEntity.self, id: 25, uid: 1776807730205528832)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 2110383209573876224)
        try entityBuilder.addProperty(name: "code", type: PropertyType.string, id: 2, uid: 8103525167182148096)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 3, uid: 3960816398159464704)

        try entityBuilder.lastProperty(id: 3, uid: 3960816398159464704)
    }
}

extension LanguageEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LanguageEntity.id == myId }
    internal static var id: Property<LanguageEntity, Id, Id> { return Property<LanguageEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LanguageEntity.code.startsWith("X") }
    internal static var code: Property<LanguageEntity, String, Void> { return Property<LanguageEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LanguageEntity.name.startsWith("X") }
    internal static var name: Property<LanguageEntity, String, Void> { return Property<LanguageEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == LanguageEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<LanguageEntity, Id, Id> { return Property<LanguageEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .code.startsWith("X") }

    internal static var code: Property<LanguageEntity, String, Void> { return Property<LanguageEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<LanguageEntity, String, Void> { return Property<LanguageEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `LanguageEntity.EntityBindingType`.
internal class LanguageEntityBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = LanguageEntity
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_code = propertyCollector.prepare(string: entity.code)
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_code, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 3)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = LanguageEntity()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.code = entityReader.read(at: 2 + 2 * 2)
        entity.name = entityReader.read(at: 2 + 2 * 3)

        return entity
    }
}



extension LiveEntityModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = LiveEntityModel

    internal var _id: EntityId<LiveEntityModel> {
        return EntityId<LiveEntityModel>(self.feedId.value)
    }
}

extension LiveEntityModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = LiveEntityModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "LiveEntityModel", id: 3)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: LiveEntityModel.self, id: 3, uid: 545962726661651200)
        try entityBuilder.addProperty(name: "feedId", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 1644436036358302976)
        try entityBuilder.addProperty(name: "streamName", type: PropertyType.string, id: 2, uid: 2924956857950340096)
        try entityBuilder.addProperty(name: "liveDescription", type: PropertyType.string, id: 3, uid: 1731249023386396416)
        try entityBuilder.addProperty(name: "pushUrl", type: PropertyType.string, id: 4, uid: 5107365443859157248)
        try entityBuilder.addProperty(name: "rtmp", type: PropertyType.string, id: 5, uid: 9066661765055561472)
        try entityBuilder.addProperty(name: "status", type: PropertyType.long, id: 6, uid: 9051169846252243968)
        try entityBuilder.addProperty(name: "roomId", type: PropertyType.string, id: 7, uid: 8271154096262254592)
        try entityBuilder.addProperty(name: "rtmpSD", type: PropertyType.string, id: 9, uid: 5454407572880317696)
        try entityBuilder.addProperty(name: "rtmpLD", type: PropertyType.string, id: 10, uid: 429235892584544512)
        try entityBuilder.addProperty(name: "rtmpHD", type: PropertyType.string, id: 11, uid: 757693172518881024)
        try entityBuilder.addProperty(name: "flvSD", type: PropertyType.string, id: 12, uid: 5960930694272101888)
        try entityBuilder.addProperty(name: "flvLD", type: PropertyType.string, id: 13, uid: 292973221798451200)
        try entityBuilder.addProperty(name: "flvHD", type: PropertyType.string, id: 14, uid: 4568220600774160128)
        try entityBuilder.addProperty(name: "frameIcon", type: PropertyType.string, id: 15, uid: 228321969605136384)
        try entityBuilder.addProperty(name: "frameTint", type: PropertyType.string, id: 16, uid: 6491219742482286848)
        try entityBuilder.addProperty(name: "sorting", type: PropertyType.long, id: 17, uid: 3399980500585825024)
        try entityBuilder.addProperty(name: "rtmpHost", type: PropertyType.string, id: 18, uid: 1798861927912795136)
        try entityBuilder.addProperty(name: "rtmpAuth", type: PropertyType.string, id: 19, uid: 47187931677011712)
        try entityBuilder.addProperty(name: "host", type: PropertyType.string, id: 20, uid: 4440012806983731712)
        try entityBuilder.addProperty(name: "hostName", type: PropertyType.string, id: 22, uid: 9070344165410957056)
        try entityBuilder.addProperty(name: "hostIconUrl", type: PropertyType.string, id: 21, uid: 2515534959518852864)
        try entityBuilder.addProperty(name: "hostUsername", type: PropertyType.string, id: 23, uid: 6577381738975855616)
        try entityBuilder.addProperty(name: "hostAvatarUrl", type: PropertyType.string, id: 24, uid: 8037510471514288896)
        try entityBuilder.addProperty(name: "profileFrameIcon", type: PropertyType.string, id: 25, uid: 8688795077726438912)
        try entityBuilder.addProperty(name: "profileFrameTint", type: PropertyType.string, id: 26, uid: 7880161208206810624)

        try entityBuilder.lastProperty(id: 26, uid: 7880161208206810624)
    }
}

extension LiveEntityModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.feedId == myId }
    internal static var feedId: Property<LiveEntityModel, Id, Id> { return Property<LiveEntityModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.streamName.startsWith("X") }
    internal static var streamName: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.liveDescription.startsWith("X") }
    internal static var liveDescription: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.pushUrl.startsWith("X") }
    internal static var pushUrl: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmp.startsWith("X") }
    internal static var rtmp: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.status > 1234 }
    internal static var status: Property<LiveEntityModel, Int, Void> { return Property<LiveEntityModel, Int, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.roomId.startsWith("X") }
    internal static var roomId: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmpSD.startsWith("X") }
    internal static var rtmpSD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmpLD.startsWith("X") }
    internal static var rtmpLD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmpHD.startsWith("X") }
    internal static var rtmpHD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.flvSD.startsWith("X") }
    internal static var flvSD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.flvLD.startsWith("X") }
    internal static var flvLD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.flvHD.startsWith("X") }
    internal static var flvHD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.frameIcon.startsWith("X") }
    internal static var frameIcon: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.frameTint.startsWith("X") }
    internal static var frameTint: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.sorting > 1234 }
    internal static var sorting: Property<LiveEntityModel, Int, Void> { return Property<LiveEntityModel, Int, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmpHost.startsWith("X") }
    internal static var rtmpHost: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.rtmpAuth.startsWith("X") }
    internal static var rtmpAuth: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.host.startsWith("X") }
    internal static var host: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.hostName.startsWith("X") }
    internal static var hostName: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.hostIconUrl.startsWith("X") }
    internal static var hostIconUrl: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.hostUsername.startsWith("X") }
    internal static var hostUsername: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.hostAvatarUrl.startsWith("X") }
    internal static var hostAvatarUrl: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.profileFrameIcon.startsWith("X") }
    internal static var profileFrameIcon: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { LiveEntityModel.profileFrameTint.startsWith("X") }
    internal static var profileFrameTint: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 26, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.feedId = Id(identifier)
    }
}

extension ObjectBox.Property where E == LiveEntityModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedId == myId }

    internal static var feedId: Property<LiveEntityModel, Id, Id> { return Property<LiveEntityModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .streamName.startsWith("X") }

    internal static var streamName: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .liveDescription.startsWith("X") }

    internal static var liveDescription: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .pushUrl.startsWith("X") }

    internal static var pushUrl: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmp.startsWith("X") }

    internal static var rtmp: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .status > 1234 }

    internal static var status: Property<LiveEntityModel, Int, Void> { return Property<LiveEntityModel, Int, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .roomId.startsWith("X") }

    internal static var roomId: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmpSD.startsWith("X") }

    internal static var rtmpSD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmpLD.startsWith("X") }

    internal static var rtmpLD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmpHD.startsWith("X") }

    internal static var rtmpHD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flvSD.startsWith("X") }

    internal static var flvSD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flvLD.startsWith("X") }

    internal static var flvLD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flvHD.startsWith("X") }

    internal static var flvHD: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .frameIcon.startsWith("X") }

    internal static var frameIcon: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .frameTint.startsWith("X") }

    internal static var frameTint: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .sorting > 1234 }

    internal static var sorting: Property<LiveEntityModel, Int, Void> { return Property<LiveEntityModel, Int, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmpHost.startsWith("X") }

    internal static var rtmpHost: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rtmpAuth.startsWith("X") }

    internal static var rtmpAuth: Property<LiveEntityModel, String, Void> { return Property<LiveEntityModel, String, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .host.startsWith("X") }

    internal static var host: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hostName.startsWith("X") }

    internal static var hostName: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hostIconUrl.startsWith("X") }

    internal static var hostIconUrl: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hostUsername.startsWith("X") }

    internal static var hostUsername: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hostAvatarUrl.startsWith("X") }

    internal static var hostAvatarUrl: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameIcon.startsWith("X") }

    internal static var profileFrameIcon: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameTint.startsWith("X") }

    internal static var profileFrameTint: Property<LiveEntityModel, String?, Void> { return Property<LiveEntityModel, String?, Void>(propertyId: 26, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `LiveEntityModel.EntityBindingType`.
internal class LiveEntityModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = LiveEntityModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.feedId.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_streamName = propertyCollector.prepare(string: entity.streamName)
        let propertyOffset_liveDescription = propertyCollector.prepare(string: entity.liveDescription)
        let propertyOffset_pushUrl = propertyCollector.prepare(string: entity.pushUrl)
        let propertyOffset_rtmp = propertyCollector.prepare(string: entity.rtmp)
        let propertyOffset_roomId = propertyCollector.prepare(string: entity.roomId)
        let propertyOffset_rtmpSD = propertyCollector.prepare(string: entity.rtmpSD)
        let propertyOffset_rtmpLD = propertyCollector.prepare(string: entity.rtmpLD)
        let propertyOffset_rtmpHD = propertyCollector.prepare(string: entity.rtmpHD)
        let propertyOffset_flvSD = propertyCollector.prepare(string: entity.flvSD)
        let propertyOffset_flvLD = propertyCollector.prepare(string: entity.flvLD)
        let propertyOffset_flvHD = propertyCollector.prepare(string: entity.flvHD)
        let propertyOffset_frameIcon = propertyCollector.prepare(string: entity.frameIcon)
        let propertyOffset_frameTint = propertyCollector.prepare(string: entity.frameTint)
        let propertyOffset_rtmpHost = propertyCollector.prepare(string: entity.rtmpHost)
        let propertyOffset_rtmpAuth = propertyCollector.prepare(string: entity.rtmpAuth)
        let propertyOffset_host = propertyCollector.prepare(string: entity.host)
        let propertyOffset_hostName = propertyCollector.prepare(string: entity.hostName)
        let propertyOffset_hostIconUrl = propertyCollector.prepare(string: entity.hostIconUrl)
        let propertyOffset_hostUsername = propertyCollector.prepare(string: entity.hostUsername)
        let propertyOffset_hostAvatarUrl = propertyCollector.prepare(string: entity.hostAvatarUrl)
        let propertyOffset_profileFrameIcon = propertyCollector.prepare(string: entity.profileFrameIcon)
        let propertyOffset_profileFrameTint = propertyCollector.prepare(string: entity.profileFrameTint)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.status, at: 2 + 2 * 6)
        propertyCollector.collect(entity.sorting, at: 2 + 2 * 17)
        propertyCollector.collect(dataOffset: propertyOffset_streamName, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_liveDescription, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_pushUrl, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_rtmp, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_roomId, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_rtmpSD, at: 2 + 2 * 9)
        propertyCollector.collect(dataOffset: propertyOffset_rtmpLD, at: 2 + 2 * 10)
        propertyCollector.collect(dataOffset: propertyOffset_rtmpHD, at: 2 + 2 * 11)
        propertyCollector.collect(dataOffset: propertyOffset_flvSD, at: 2 + 2 * 12)
        propertyCollector.collect(dataOffset: propertyOffset_flvLD, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_flvHD, at: 2 + 2 * 14)
        propertyCollector.collect(dataOffset: propertyOffset_frameIcon, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_frameTint, at: 2 + 2 * 16)
        propertyCollector.collect(dataOffset: propertyOffset_rtmpHost, at: 2 + 2 * 18)
        propertyCollector.collect(dataOffset: propertyOffset_rtmpAuth, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_host, at: 2 + 2 * 20)
        propertyCollector.collect(dataOffset: propertyOffset_hostName, at: 2 + 2 * 22)
        propertyCollector.collect(dataOffset: propertyOffset_hostIconUrl, at: 2 + 2 * 21)
        propertyCollector.collect(dataOffset: propertyOffset_hostUsername, at: 2 + 2 * 23)
        propertyCollector.collect(dataOffset: propertyOffset_hostAvatarUrl, at: 2 + 2 * 24)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameIcon, at: 2 + 2 * 25)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameTint, at: 2 + 2 * 26)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = LiveEntityModel()

        entity.feedId = entityReader.read(at: 2 + 2 * 1)
        entity.streamName = entityReader.read(at: 2 + 2 * 2)
        entity.liveDescription = entityReader.read(at: 2 + 2 * 3)
        entity.pushUrl = entityReader.read(at: 2 + 2 * 4)
        entity.rtmp = entityReader.read(at: 2 + 2 * 5)
        entity.status = entityReader.read(at: 2 + 2 * 6)
        entity.roomId = entityReader.read(at: 2 + 2 * 7)
        entity.rtmpSD = entityReader.read(at: 2 + 2 * 9)
        entity.rtmpLD = entityReader.read(at: 2 + 2 * 10)
        entity.rtmpHD = entityReader.read(at: 2 + 2 * 11)
        entity.flvSD = entityReader.read(at: 2 + 2 * 12)
        entity.flvLD = entityReader.read(at: 2 + 2 * 13)
        entity.flvHD = entityReader.read(at: 2 + 2 * 14)
        entity.frameIcon = entityReader.read(at: 2 + 2 * 15)
        entity.frameTint = entityReader.read(at: 2 + 2 * 16)
        entity.sorting = entityReader.read(at: 2 + 2 * 17)
        entity.rtmpHost = entityReader.read(at: 2 + 2 * 18)
        entity.rtmpAuth = entityReader.read(at: 2 + 2 * 19)
        entity.host = entityReader.read(at: 2 + 2 * 20)
        entity.hostName = entityReader.read(at: 2 + 2 * 22)
        entity.hostIconUrl = entityReader.read(at: 2 + 2 * 21)
        entity.hostUsername = entityReader.read(at: 2 + 2 * 23)
        entity.hostAvatarUrl = entityReader.read(at: 2 + 2 * 24)
        entity.profileFrameIcon = entityReader.read(at: 2 + 2 * 25)
        entity.profileFrameTint = entityReader.read(at: 2 + 2 * 26)

        return entity
    }
}



//extension LiveSubCategoryList: ObjectBox.__EntityRelatable {
//    internal typealias EntityType = LiveSubCategoryList
//
//    internal var _id: EntityId<LiveSubCategoryList> {
//        return EntityId<LiveSubCategoryList>(self.id.value)
//    }
//}
//
//extension LiveSubCategoryList: ObjectBox.EntityInspectable {
//    internal typealias EntityBindingType = LiveSubCategoryListBinding
//
//    /// Generated metadata used by ObjectBox to persist the entity.
//    internal static var entityInfo = ObjectBox.EntityInfo(name: "LiveSubCategoryList", id: 20)
//
//    internal static var entityBinding = EntityBindingType()
//
//    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
//        let entityBuilder = try modelBuilder.entityBuilder(for: LiveSubCategoryList.self, id: 20, uid: 2353907672281020416)
//        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 4476770734643890176)
//        try entityBuilder.addProperty(name: "code", type: PropertyType.long, id: 2, uid: 5960178660414081536)
//        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 3, uid: 5428508758837406976)
//
//        try entityBuilder.lastProperty(id: 3, uid: 5428508758837406976)
//    }
//}
//
//extension LiveSubCategoryList {
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { LiveSubCategoryList.id == myId }
//    internal static var id: Property<LiveSubCategoryList, Id, Id> { return Property<LiveSubCategoryList, Id, Id>(propertyId: 1, isPrimaryKey: true) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { LiveSubCategoryList.code > 1234 }
//    internal static var code: Property<LiveSubCategoryList, Int, Void> { return Property<LiveSubCategoryList, Int, Void>(propertyId: 2, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { LiveSubCategoryList.name.startsWith("X") }
//    internal static var name: Property<LiveSubCategoryList, String, Void> { return Property<LiveSubCategoryList, String, Void>(propertyId: 3, isPrimaryKey: false) }
//
//    fileprivate func __setId(identifier: ObjectBox.Id) {
//        self.id = Id(identifier)
//    }
//}
//
//extension ObjectBox.Property where E == LiveSubCategoryList {
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .id == myId }
//
//    internal static var id: Property<LiveSubCategoryList, Id, Id> { return Property<LiveSubCategoryList, Id, Id>(propertyId: 1, isPrimaryKey: true) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .code > 1234 }
//
//    internal static var code: Property<LiveSubCategoryList, Int, Void> { return Property<LiveSubCategoryList, Int, Void>(propertyId: 2, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .name.startsWith("X") }
//
//    internal static var name: Property<LiveSubCategoryList, String, Void> { return Property<LiveSubCategoryList, String, Void>(propertyId: 3, isPrimaryKey: false) }
//
//}
//
//
///// Generated service type to handle persisting and reading entity data. Exposed through `LiveSubCategoryList.EntityBindingType`.
//internal class LiveSubCategoryListBinding: ObjectBox.EntityBinding {
//    internal typealias EntityType = LiveSubCategoryList
//    internal typealias IdType = Id
//
//    internal required init() {}
//
//    internal func generatorBindingVersion() -> Int { 1 }
//
//    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
//        entity.__setId(identifier: entityId)
//    }
//
//    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
//        return entity.id.value
//    }
//
//    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
//                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
//        let propertyOffset_name = propertyCollector.prepare(string: entity.name)
//
//        propertyCollector.collect(id, at: 2 + 2 * 1)
//        propertyCollector.collect(entity.code, at: 2 + 2 * 2)
//        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 3)
//    }
//
//    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
//        let entity = LiveSubCategoryList()
//
//        entity.id = entityReader.read(at: 2 + 2 * 1)
//        entity.code = entityReader.read(at: 2 + 2 * 2)
//        entity.name = entityReader.read(at: 2 + 2 * 3)
//
//        return entity
//    }
//}
//


extension TrendingPhotoModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = TrendingPhotoModel

    internal var _id: EntityId<TrendingPhotoModel> {
        return EntityId<TrendingPhotoModel>(self.id.value)
    }
}

extension TrendingPhotoModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = TrendingPhotoModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "TrendingPhotoModel", id: 9)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: TrendingPhotoModel.self, id: 9, uid: 7773583535735728384)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 6028754118538869248)
        try entityBuilder.addProperty(name: "feedId", type: PropertyType.long, id: 2, uid: 459567548952419328)
        try entityBuilder.addProperty(name: "imageId", type: PropertyType.long, id: 3, uid: 7312426006296417536)
        try entityBuilder.addProperty(name: "isVideo", type: PropertyType.bool, id: 4, uid: 3104161895251547136)
        try entityBuilder.addProperty(name: "type", type: PropertyType.string, id: 5, uid: 7910629193873342208)

        try entityBuilder.lastProperty(id: 5, uid: 7910629193873342208)
    }
}

extension TrendingPhotoModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TrendingPhotoModel.id == myId }
    internal static var id: Property<TrendingPhotoModel, Id, Id> { return Property<TrendingPhotoModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TrendingPhotoModel.feedId > 1234 }
    internal static var feedId: Property<TrendingPhotoModel, Int, Void> { return Property<TrendingPhotoModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TrendingPhotoModel.imageId > 1234 }
    internal static var imageId: Property<TrendingPhotoModel, Int, Void> { return Property<TrendingPhotoModel, Int, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TrendingPhotoModel.isVideo == true }
    internal static var isVideo: Property<TrendingPhotoModel, Bool, Void> { return Property<TrendingPhotoModel, Bool, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TrendingPhotoModel.type.startsWith("X") }
    internal static var type: Property<TrendingPhotoModel, String, Void> { return Property<TrendingPhotoModel, String, Void>(propertyId: 5, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == TrendingPhotoModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<TrendingPhotoModel, Id, Id> { return Property<TrendingPhotoModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedId > 1234 }

    internal static var feedId: Property<TrendingPhotoModel, Int, Void> { return Property<TrendingPhotoModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .imageId > 1234 }

    internal static var imageId: Property<TrendingPhotoModel, Int, Void> { return Property<TrendingPhotoModel, Int, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isVideo == true }

    internal static var isVideo: Property<TrendingPhotoModel, Bool, Void> { return Property<TrendingPhotoModel, Bool, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .type.startsWith("X") }

    internal static var type: Property<TrendingPhotoModel, String, Void> { return Property<TrendingPhotoModel, String, Void>(propertyId: 5, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `TrendingPhotoModel.EntityBindingType`.
internal class TrendingPhotoModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = TrendingPhotoModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_type = propertyCollector.prepare(string: TrendingPhotoType.convert(entity.type))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.feedId, at: 2 + 2 * 2)
        propertyCollector.collect(entity.imageId, at: 2 + 2 * 3)
        propertyCollector.collect(entity.isVideo, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_type, at: 2 + 2 * 5)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = TrendingPhotoModel()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.feedId = entityReader.read(at: 2 + 2 * 2)
        entity.imageId = entityReader.read(at: 2 + 2 * 3)
        entity.isVideo = entityReader.read(at: 2 + 2 * 4)
        entity.type = TrendingPhotoType.convert(entityReader.read(at: 2 + 2 * 5))

        return entity
    }
}



extension UserInfoModel: ObjectBox.__EntityRelatable {
    internal typealias EntityType = UserInfoModel

    internal var _id: EntityId<UserInfoModel> {
        return EntityId<UserInfoModel>(self.id.value)
    }
}

extension UserInfoModel: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = UserInfoModelBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "UserInfoModel", id: 5)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: UserInfoModel.self, id: 5, uid: 4929645511121151232)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 586348107477747968)
        try entityBuilder.addProperty(name: "userIdentity", type: PropertyType.long, id: 2, uid: 4229072801588696832)
        try entityBuilder.addProperty(name: "displayName", type: PropertyType.string, id: 3, uid: 8806347007523767808)
        try entityBuilder.addProperty(name: "username", type: PropertyType.string, id: 4, uid: 5787245753385918464)
        try entityBuilder.addProperty(name: "phone", type: PropertyType.string, id: 5, uid: 2104793288444748288)
        try entityBuilder.addProperty(name: "mobi", type: PropertyType.string, id: 6, uid: 121872105800150528)
        try entityBuilder.addProperty(name: "email", type: PropertyType.string, id: 7, uid: 7001764653639052544)
        try entityBuilder.addProperty(name: "sex", type: PropertyType.long, id: 8, uid: 4614569531834103808)
        try entityBuilder.addProperty(name: "bio", type: PropertyType.string, id: 9, uid: 2309731212052035328)
        try entityBuilder.addProperty(name: "location", type: PropertyType.string, id: 10, uid: 4209109407654613248)
        try entityBuilder.addProperty(name: "createDate", type: PropertyType.date, id: 11, uid: 5820558736295946752)
        try entityBuilder.addProperty(name: "updateDate", type: PropertyType.date, id: 12, uid: 6548239605531221248)
        try entityBuilder.addProperty(name: "avatarUrl", type: PropertyType.string, id: 13, uid: 6473876588094495744)
        try entityBuilder.addProperty(name: "avatarMime", type: PropertyType.string, id: 14, uid: 6806586607972328704)
        try entityBuilder.addProperty(name: "coverUrl", type: PropertyType.string, id: 15, uid: 6750692776588365568)
        try entityBuilder.addProperty(name: "coverMime", type: PropertyType.string, id: 16, uid: 4330999835255900672)
        try entityBuilder.addProperty(name: "following", type: PropertyType.bool, id: 17, uid: 3392093408830828288)
        try entityBuilder.addProperty(name: "follower", type: PropertyType.bool, id: 18, uid: 8364287401986617344)
        try entityBuilder.addProperty(name: "friendsCount", type: PropertyType.long, id: 19, uid: 501350743242794752)
        try entityBuilder.addProperty(name: "otpDevice", type: PropertyType.bool, id: 67, uid: 1071353611054709248)
        try entityBuilder.addProperty(name: "verificationIcon", type: PropertyType.string, id: 20, uid: 7814479104472228352)
        try entityBuilder.addProperty(name: "verificationType", type: PropertyType.string, id: 21, uid: 2241649482491098368)
        try entityBuilder.addProperty(name: "likesCount", type: PropertyType.long, id: 22, uid: 4326589721373131008)
        try entityBuilder.addProperty(name: "commentsCount", type: PropertyType.long, id: 23, uid: 8878005012122613760)
        try entityBuilder.addProperty(name: "followersCount", type: PropertyType.long, id: 24, uid: 7588635115401464320)
        try entityBuilder.addProperty(name: "followingsCount", type: PropertyType.long, id: 25, uid: 2622535656628028160)
        try entityBuilder.addProperty(name: "feedCount", type: PropertyType.long, id: 26, uid: 4369573193852428544)
        try entityBuilder.addProperty(name: "checkInCount", type: PropertyType.long, id: 27, uid: 377635664438736128)
        try entityBuilder.addProperty(name: "canSubscribe", type: PropertyType.bool, id: 48, uid: 8782886375103942912)
        try entityBuilder.addProperty(name: "isRewardAcceptEnabled", type: PropertyType.bool, id: 28, uid: 421099267676698624)
        try entityBuilder.addProperty(name: "activitiesCount", type: PropertyType.long, id: 30, uid: 3470246186222442496)
        try entityBuilder.addProperty(name: "isBlacked", type: PropertyType.bool, id: 31, uid: 7917614213882211328)
        try entityBuilder.addProperty(name: "deleteDate", type: PropertyType.string, id: 32, uid: 7313224954102455552)
        try entityBuilder.addProperty(name: "whiteListType", type: PropertyType.string, id: 33, uid: 166846790223922944)
        try entityBuilder.addProperty(name: "stickerArtistId", type: PropertyType.long, id: 34, uid: 6976781449923071232)
        try entityBuilder.addProperty(name: "stickerArtistName", type: PropertyType.string, id: 35, uid: 8200838570039615488)
        try entityBuilder.addProperty(name: "enableExternalRtmp", type: PropertyType.bool, id: 36, uid: 2572287371689683968)
        try entityBuilder.addProperty(name: "badgeCount", type: PropertyType.long, id: 37, uid: 5593126980003664384)
        try entityBuilder.addProperty(name: "latestBadges", type: PropertyType.string, id: 38, uid: 2545499133795937280)
        try entityBuilder.addProperty(name: "country", type: PropertyType.string, id: 39, uid: 1764049040241806080)
        try entityBuilder.addProperty(name: "subscribing", type: PropertyType.bool, id: 42, uid: 5781376429440706048)
        try entityBuilder.addProperty(name: "subsInfluenceScore", type: PropertyType.string, id: 43, uid: 6746527828189446912)
        try entityBuilder.addProperty(name: "rankingInfluenceScore", type: PropertyType.string, id: 44, uid: 7805502092279610112)
        try entityBuilder.addProperty(name: "miniProgramShopUrl", type: PropertyType.string, id: 45, uid: 8189632395992845056)
        try entityBuilder.addProperty(name: "miniProgramShopId", type: PropertyType.long, id: 50, uid: 1954115900950405632)
        try entityBuilder.addProperty(name: "birthdate", type: PropertyType.string, id: 47, uid: 7830881610736857856)
        try entityBuilder.addProperty(name: "monthlyLiveScore", type: PropertyType.string, id: 49, uid: 5438222990542380032)
        try entityBuilder.addProperty(name: "profileFrameIcon", type: PropertyType.string, id: 51, uid: 3346604852947322112)
        try entityBuilder.addProperty(name: "profileFrameColorHex", type: PropertyType.string, id: 52, uid: 6144287544219262464)
        try entityBuilder.addProperty(name: "liveFeedId", type: PropertyType.long, id: 53, uid: 5698833544422799616)
        try entityBuilder.addProperty(name: "subscriptionEnable", type: PropertyType.long, id: 54, uid: 877383105568782592)
        try entityBuilder.addProperty(name: "subscriptionDisabledMsg", type: PropertyType.string, id: 55, uid: 4763176315920727040)
        try entityBuilder.addProperty(name: "website", type: PropertyType.string, id: 56, uid: 1515355857621174784)
        try entityBuilder.addProperty(name: "workIndustryID", type: PropertyType.long, id: 57, uid: 5414074044058200064)
        try entityBuilder.addProperty(name: "workIndustryName", type: PropertyType.string, id: 58, uid: 6966412218753411840)
        try entityBuilder.addProperty(name: "workIndustryKey", type: PropertyType.string, id: 59, uid: 2492043702700866048)
        try entityBuilder.addProperty(name: "relationshipID", type: PropertyType.long, id: 60, uid: 4835675973285415936)
        try entityBuilder.addProperty(name: "relationshipName", type: PropertyType.string, id: 61, uid: 7673411034279386624)
        try entityBuilder.addProperty(name: "relationshipKey", type: PropertyType.string, id: 62, uid: 7524046218853691392)
        try entityBuilder.addProperty(name: "countryKey", type: PropertyType.string, id: 63, uid: 2716979733169081600)
        try entityBuilder.addProperty(name: "countryID", type: PropertyType.long, id: 64, uid: 2439391679055028992)
        try entityBuilder.addProperty(name: "cityKey", type: PropertyType.string, id: 65, uid: 2034977489781722624)
        try entityBuilder.addProperty(name: "cityID", type: PropertyType.long, id: 66, uid: 4523289180093014272)
        try entityBuilder.addProperty(name: "miniProgramShow", type: PropertyType.bool, id: 68, uid: 7760351142792951552)
        try entityBuilder.addProperty(name: "merchantId", type: PropertyType.long, id: 69, uid: 5885416540525483776)
        try entityBuilder.addProperty(name: "merchantRoute", type: PropertyType.string, id: 70, uid: 5244531120629497344)
        try entityBuilder.addProperty(name: "checkinStatus", type: PropertyType.bool, id: 72, uid: 6072381675711586560)
        try entityBuilder.addProperty(name: "checkinShowPoint", type: PropertyType.bool, id: 73, uid: 7289157537388155136)

        try entityBuilder.lastProperty(id: 73, uid: 7289157537388155136)
    }
}

extension UserInfoModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.id == myId }
    internal static var id: Property<UserInfoModel, Id, Id> { return Property<UserInfoModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.userIdentity > 1234 }
    internal static var userIdentity: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.displayName.startsWith("X") }
    internal static var displayName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.username.startsWith("X") }
    internal static var username: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.phone.startsWith("X") }
    internal static var phone: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.mobi.startsWith("X") }
    internal static var mobi: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.email.startsWith("X") }
    internal static var email: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.sex > 1234 }
    internal static var sex: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.bio.startsWith("X") }
    internal static var bio: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.location.startsWith("X") }
    internal static var location: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.createDate > 1234 }
    internal static var createDate: Property<UserInfoModel, Date?, Void> { return Property<UserInfoModel, Date?, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.updateDate > 1234 }
    internal static var updateDate: Property<UserInfoModel, Date?, Void> { return Property<UserInfoModel, Date?, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.avatarUrl.startsWith("X") }
    internal static var avatarUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.avatarMime.startsWith("X") }
    internal static var avatarMime: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.coverUrl.startsWith("X") }
    internal static var coverUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.coverMime.startsWith("X") }
    internal static var coverMime: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.following == true }
    internal static var following: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.follower == true }
    internal static var follower: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.friendsCount > 1234 }
    internal static var friendsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.otpDevice == true }
    internal static var otpDevice: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 67, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.verificationIcon.startsWith("X") }
    internal static var verificationIcon: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.verificationType.startsWith("X") }
    internal static var verificationType: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.likesCount > 1234 }
    internal static var likesCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.commentsCount > 1234 }
    internal static var commentsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.followersCount > 1234 }
    internal static var followersCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.followingsCount > 1234 }
    internal static var followingsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.feedCount > 1234 }
    internal static var feedCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 26, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.checkInCount > 1234 }
    internal static var checkInCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 27, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.canSubscribe == true }
    internal static var canSubscribe: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 48, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.isRewardAcceptEnabled == true }
    internal static var isRewardAcceptEnabled: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 28, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.activitiesCount > 1234 }
    internal static var activitiesCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 30, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.isBlacked == true }
    internal static var isBlacked: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 31, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.deleteDate.startsWith("X") }
    internal static var deleteDate: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 32, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.whiteListType.startsWith("X") }
    internal static var whiteListType: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 33, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.stickerArtistId > 1234 }
    internal static var stickerArtistId: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 34, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.stickerArtistName.startsWith("X") }
    internal static var stickerArtistName: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 35, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.enableExternalRtmp == true }
    internal static var enableExternalRtmp: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 36, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.badgeCount > 1234 }
    internal static var badgeCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 37, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.latestBadges.startsWith("X") }
    internal static var latestBadges: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 38, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.country.startsWith("X") }
    internal static var country: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 39, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.subscribing == true }
    internal static var subscribing: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 42, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.subsInfluenceScore.startsWith("X") }
    internal static var subsInfluenceScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 43, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.rankingInfluenceScore.startsWith("X") }
    internal static var rankingInfluenceScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 44, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.miniProgramShopUrl.startsWith("X") }
    internal static var miniProgramShopUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 45, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.miniProgramShopId > 1234 }
    internal static var miniProgramShopId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 50, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.birthdate.startsWith("X") }
    internal static var birthdate: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 47, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.monthlyLiveScore.startsWith("X") }
    internal static var monthlyLiveScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 49, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.profileFrameIcon.startsWith("X") }
    internal static var profileFrameIcon: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 51, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.profileFrameColorHex.startsWith("X") }
    internal static var profileFrameColorHex: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 52, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.liveFeedId > 1234 }
    internal static var liveFeedId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 53, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.subscriptionEnable > 1234 }
    internal static var subscriptionEnable: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 54, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.subscriptionDisabledMsg.startsWith("X") }
    internal static var subscriptionDisabledMsg: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 55, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.website.startsWith("X") }
    internal static var website: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 56, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.workIndustryID > 1234 }
    internal static var workIndustryID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 57, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.workIndustryName.startsWith("X") }
    internal static var workIndustryName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 58, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.workIndustryKey.startsWith("X") }
    internal static var workIndustryKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 59, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.relationshipID > 1234 }
    internal static var relationshipID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 60, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.relationshipName.startsWith("X") }
    internal static var relationshipName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 61, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.relationshipKey.startsWith("X") }
    internal static var relationshipKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 62, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.countryKey.startsWith("X") }
    internal static var countryKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 63, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.countryID > 1234 }
    internal static var countryID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 64, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.cityKey.startsWith("X") }
    internal static var cityKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 65, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.cityID > 1234 }
    internal static var cityID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 66, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.miniProgramShow == true }
    internal static var miniProgramShow: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 68, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.merchantId > 1234 }
    internal static var merchantId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 69, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.merchantRoute.startsWith("X") }
    internal static var merchantRoute: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 70, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.checkinStatus == true }
    internal static var checkinStatus: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 72, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserInfoModel.checkinShowPoint == true }
    internal static var checkinShowPoint: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 73, isPrimaryKey: false) }

    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == UserInfoModel {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<UserInfoModel, Id, Id> { return Property<UserInfoModel, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .userIdentity > 1234 }

    internal static var userIdentity: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .displayName.startsWith("X") }

    internal static var displayName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .username.startsWith("X") }

    internal static var username: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .phone.startsWith("X") }

    internal static var phone: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .mobi.startsWith("X") }

    internal static var mobi: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .email.startsWith("X") }

    internal static var email: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .sex > 1234 }

    internal static var sex: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bio.startsWith("X") }

    internal static var bio: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .location.startsWith("X") }

    internal static var location: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .createDate > 1234 }

    internal static var createDate: Property<UserInfoModel, Date?, Void> { return Property<UserInfoModel, Date?, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .updateDate > 1234 }

    internal static var updateDate: Property<UserInfoModel, Date?, Void> { return Property<UserInfoModel, Date?, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .avatarUrl.startsWith("X") }

    internal static var avatarUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .avatarMime.startsWith("X") }

    internal static var avatarMime: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coverUrl.startsWith("X") }

    internal static var coverUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coverMime.startsWith("X") }

    internal static var coverMime: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .following == true }

    internal static var following: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .follower == true }

    internal static var follower: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .friendsCount > 1234 }

    internal static var friendsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .otpDevice == true }

    internal static var otpDevice: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 67, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .verificationIcon.startsWith("X") }

    internal static var verificationIcon: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .verificationType.startsWith("X") }

    internal static var verificationType: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .likesCount > 1234 }

    internal static var likesCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .commentsCount > 1234 }

    internal static var commentsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .followersCount > 1234 }

    internal static var followersCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .followingsCount > 1234 }

    internal static var followingsCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedCount > 1234 }

    internal static var feedCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 26, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkInCount > 1234 }

    internal static var checkInCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 27, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .canSubscribe == true }

    internal static var canSubscribe: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 48, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isRewardAcceptEnabled == true }

    internal static var isRewardAcceptEnabled: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 28, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .activitiesCount > 1234 }

    internal static var activitiesCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 30, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isBlacked == true }

    internal static var isBlacked: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 31, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .deleteDate.startsWith("X") }

    internal static var deleteDate: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 32, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .whiteListType.startsWith("X") }

    internal static var whiteListType: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 33, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .stickerArtistId > 1234 }

    internal static var stickerArtistId: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 34, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .stickerArtistName.startsWith("X") }

    internal static var stickerArtistName: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 35, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .enableExternalRtmp == true }

    internal static var enableExternalRtmp: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 36, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .badgeCount > 1234 }

    internal static var badgeCount: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 37, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .latestBadges.startsWith("X") }

    internal static var latestBadges: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 38, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .country.startsWith("X") }

    internal static var country: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 39, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .subscribing == true }

    internal static var subscribing: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 42, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .subsInfluenceScore.startsWith("X") }

    internal static var subsInfluenceScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 43, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rankingInfluenceScore.startsWith("X") }

    internal static var rankingInfluenceScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 44, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .miniProgramShopUrl.startsWith("X") }

    internal static var miniProgramShopUrl: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 45, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .miniProgramShopId > 1234 }

    internal static var miniProgramShopId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 50, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .birthdate.startsWith("X") }

    internal static var birthdate: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 47, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .monthlyLiveScore.startsWith("X") }

    internal static var monthlyLiveScore: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 49, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameIcon.startsWith("X") }

    internal static var profileFrameIcon: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 51, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameColorHex.startsWith("X") }

    internal static var profileFrameColorHex: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 52, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .liveFeedId > 1234 }

    internal static var liveFeedId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 53, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .subscriptionEnable > 1234 }

    internal static var subscriptionEnable: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 54, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .subscriptionDisabledMsg.startsWith("X") }

    internal static var subscriptionDisabledMsg: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 55, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .website.startsWith("X") }

    internal static var website: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 56, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryID > 1234 }

    internal static var workIndustryID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 57, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryName.startsWith("X") }

    internal static var workIndustryName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 58, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryKey.startsWith("X") }

    internal static var workIndustryKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 59, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipID > 1234 }

    internal static var relationshipID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 60, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipName.startsWith("X") }

    internal static var relationshipName: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 61, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipKey.startsWith("X") }

    internal static var relationshipKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 62, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .countryKey.startsWith("X") }

    internal static var countryKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 63, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .countryID > 1234 }

    internal static var countryID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 64, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .cityKey.startsWith("X") }

    internal static var cityKey: Property<UserInfoModel, String, Void> { return Property<UserInfoModel, String, Void>(propertyId: 65, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .cityID > 1234 }

    internal static var cityID: Property<UserInfoModel, Int, Void> { return Property<UserInfoModel, Int, Void>(propertyId: 66, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .miniProgramShow == true }

    internal static var miniProgramShow: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 68, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .merchantId > 1234 }

    internal static var merchantId: Property<UserInfoModel, Int?, Void> { return Property<UserInfoModel, Int?, Void>(propertyId: 69, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .merchantRoute.startsWith("X") }

    internal static var merchantRoute: Property<UserInfoModel, String?, Void> { return Property<UserInfoModel, String?, Void>(propertyId: 70, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkinStatus == true }

    internal static var checkinStatus: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 72, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkinShowPoint == true }

    internal static var checkinShowPoint: Property<UserInfoModel, Bool, Void> { return Property<UserInfoModel, Bool, Void>(propertyId: 73, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `UserInfoModel.EntityBindingType`.
internal class UserInfoModelBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = UserInfoModel
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_displayName = propertyCollector.prepare(string: entity.displayName)
        let propertyOffset_username = propertyCollector.prepare(string: entity.username)
        let propertyOffset_phone = propertyCollector.prepare(string: entity.phone)
        let propertyOffset_mobi = propertyCollector.prepare(string: entity.mobi)
        let propertyOffset_email = propertyCollector.prepare(string: entity.email)
        let propertyOffset_bio = propertyCollector.prepare(string: entity.bio)
        let propertyOffset_location = propertyCollector.prepare(string: entity.location)
        let propertyOffset_avatarUrl = propertyCollector.prepare(string: entity.avatarUrl)
        let propertyOffset_avatarMime = propertyCollector.prepare(string: entity.avatarMime)
        let propertyOffset_coverUrl = propertyCollector.prepare(string: entity.coverUrl)
        let propertyOffset_coverMime = propertyCollector.prepare(string: entity.coverMime)
        let propertyOffset_verificationIcon = propertyCollector.prepare(string: entity.verificationIcon)
        let propertyOffset_verificationType = propertyCollector.prepare(string: entity.verificationType)
        let propertyOffset_deleteDate = propertyCollector.prepare(string: entity.deleteDate)
        let propertyOffset_whiteListType = propertyCollector.prepare(string: entity.whiteListType)
        let propertyOffset_stickerArtistName = propertyCollector.prepare(string: entity.stickerArtistName)
        let propertyOffset_latestBadges = propertyCollector.prepare(string: entity.latestBadges)
        let propertyOffset_country = propertyCollector.prepare(string: entity.country)
        let propertyOffset_subsInfluenceScore = propertyCollector.prepare(string: entity.subsInfluenceScore)
        let propertyOffset_rankingInfluenceScore = propertyCollector.prepare(string: entity.rankingInfluenceScore)
        let propertyOffset_miniProgramShopUrl = propertyCollector.prepare(string: entity.miniProgramShopUrl)
        let propertyOffset_birthdate = propertyCollector.prepare(string: entity.birthdate)
        let propertyOffset_monthlyLiveScore = propertyCollector.prepare(string: entity.monthlyLiveScore)
        let propertyOffset_profileFrameIcon = propertyCollector.prepare(string: entity.profileFrameIcon)
        let propertyOffset_profileFrameColorHex = propertyCollector.prepare(string: entity.profileFrameColorHex)
        let propertyOffset_subscriptionDisabledMsg = propertyCollector.prepare(string: entity.subscriptionDisabledMsg)
        let propertyOffset_website = propertyCollector.prepare(string: entity.website)
        let propertyOffset_workIndustryName = propertyCollector.prepare(string: entity.workIndustryName)
        let propertyOffset_workIndustryKey = propertyCollector.prepare(string: entity.workIndustryKey)
        let propertyOffset_relationshipName = propertyCollector.prepare(string: entity.relationshipName)
        let propertyOffset_relationshipKey = propertyCollector.prepare(string: entity.relationshipKey)
        let propertyOffset_countryKey = propertyCollector.prepare(string: entity.countryKey)
        let propertyOffset_cityKey = propertyCollector.prepare(string: entity.cityKey)
        let propertyOffset_merchantRoute = propertyCollector.prepare(string: entity.merchantRoute)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.userIdentity, at: 2 + 2 * 2)
        propertyCollector.collect(entity.sex, at: 2 + 2 * 8)
        propertyCollector.collect(entity.createDate, at: 2 + 2 * 11)
        propertyCollector.collect(entity.updateDate, at: 2 + 2 * 12)
        propertyCollector.collect(entity.following, at: 2 + 2 * 17)
        propertyCollector.collect(entity.follower, at: 2 + 2 * 18)
        propertyCollector.collect(entity.friendsCount, at: 2 + 2 * 19)
        propertyCollector.collect(entity.otpDevice, at: 2 + 2 * 67)
        propertyCollector.collect(entity.likesCount, at: 2 + 2 * 22)
        propertyCollector.collect(entity.commentsCount, at: 2 + 2 * 23)
        propertyCollector.collect(entity.followersCount, at: 2 + 2 * 24)
        propertyCollector.collect(entity.followingsCount, at: 2 + 2 * 25)
        propertyCollector.collect(entity.feedCount, at: 2 + 2 * 26)
        propertyCollector.collect(entity.checkInCount, at: 2 + 2 * 27)
        propertyCollector.collect(entity.canSubscribe, at: 2 + 2 * 48)
        propertyCollector.collect(entity.isRewardAcceptEnabled, at: 2 + 2 * 28)
        propertyCollector.collect(entity.activitiesCount, at: 2 + 2 * 30)
        propertyCollector.collect(entity.isBlacked, at: 2 + 2 * 31)
        propertyCollector.collect(entity.stickerArtistId, at: 2 + 2 * 34)
        propertyCollector.collect(entity.enableExternalRtmp, at: 2 + 2 * 36)
        propertyCollector.collect(entity.badgeCount, at: 2 + 2 * 37)
        propertyCollector.collect(entity.subscribing, at: 2 + 2 * 42)
        propertyCollector.collect(entity.miniProgramShopId, at: 2 + 2 * 50)
        propertyCollector.collect(entity.liveFeedId, at: 2 + 2 * 53)
        propertyCollector.collect(entity.subscriptionEnable, at: 2 + 2 * 54)
        propertyCollector.collect(entity.workIndustryID, at: 2 + 2 * 57)
        propertyCollector.collect(entity.relationshipID, at: 2 + 2 * 60)
        propertyCollector.collect(entity.countryID, at: 2 + 2 * 64)
        propertyCollector.collect(entity.cityID, at: 2 + 2 * 66)
        propertyCollector.collect(entity.miniProgramShow, at: 2 + 2 * 68)
        propertyCollector.collect(entity.merchantId, at: 2 + 2 * 69)
        propertyCollector.collect(entity.checkinStatus, at: 2 + 2 * 72)
        propertyCollector.collect(entity.checkinShowPoint, at: 2 + 2 * 73)
        propertyCollector.collect(dataOffset: propertyOffset_displayName, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_username, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_phone, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_mobi, at: 2 + 2 * 6)
        propertyCollector.collect(dataOffset: propertyOffset_email, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_bio, at: 2 + 2 * 9)
        propertyCollector.collect(dataOffset: propertyOffset_location, at: 2 + 2 * 10)
        propertyCollector.collect(dataOffset: propertyOffset_avatarUrl, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_avatarMime, at: 2 + 2 * 14)
        propertyCollector.collect(dataOffset: propertyOffset_coverUrl, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_coverMime, at: 2 + 2 * 16)
        propertyCollector.collect(dataOffset: propertyOffset_verificationIcon, at: 2 + 2 * 20)
        propertyCollector.collect(dataOffset: propertyOffset_verificationType, at: 2 + 2 * 21)
        propertyCollector.collect(dataOffset: propertyOffset_deleteDate, at: 2 + 2 * 32)
        propertyCollector.collect(dataOffset: propertyOffset_whiteListType, at: 2 + 2 * 33)
        propertyCollector.collect(dataOffset: propertyOffset_stickerArtistName, at: 2 + 2 * 35)
        propertyCollector.collect(dataOffset: propertyOffset_latestBadges, at: 2 + 2 * 38)
        propertyCollector.collect(dataOffset: propertyOffset_country, at: 2 + 2 * 39)
        propertyCollector.collect(dataOffset: propertyOffset_subsInfluenceScore, at: 2 + 2 * 43)
        propertyCollector.collect(dataOffset: propertyOffset_rankingInfluenceScore, at: 2 + 2 * 44)
        propertyCollector.collect(dataOffset: propertyOffset_miniProgramShopUrl, at: 2 + 2 * 45)
        propertyCollector.collect(dataOffset: propertyOffset_birthdate, at: 2 + 2 * 47)
        propertyCollector.collect(dataOffset: propertyOffset_monthlyLiveScore, at: 2 + 2 * 49)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameIcon, at: 2 + 2 * 51)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameColorHex, at: 2 + 2 * 52)
        propertyCollector.collect(dataOffset: propertyOffset_subscriptionDisabledMsg, at: 2 + 2 * 55)
        propertyCollector.collect(dataOffset: propertyOffset_website, at: 2 + 2 * 56)
        propertyCollector.collect(dataOffset: propertyOffset_workIndustryName, at: 2 + 2 * 58)
        propertyCollector.collect(dataOffset: propertyOffset_workIndustryKey, at: 2 + 2 * 59)
        propertyCollector.collect(dataOffset: propertyOffset_relationshipName, at: 2 + 2 * 61)
        propertyCollector.collect(dataOffset: propertyOffset_relationshipKey, at: 2 + 2 * 62)
        propertyCollector.collect(dataOffset: propertyOffset_countryKey, at: 2 + 2 * 63)
        propertyCollector.collect(dataOffset: propertyOffset_cityKey, at: 2 + 2 * 65)
        propertyCollector.collect(dataOffset: propertyOffset_merchantRoute, at: 2 + 2 * 70)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: Id = entityReader.read(at: 2 + 2 * 1)
        let entity = UserInfoModel(
            id: entityId, 
            userIdentity: entityReader.read(at: 2 + 2 * 2), 
            displayName: entityReader.read(at: 2 + 2 * 3), 
            username: entityReader.read(at: 2 + 2 * 4), 
            phone: entityReader.read(at: 2 + 2 * 5), 
            mobi: entityReader.read(at: 2 + 2 * 6), 
            email: entityReader.read(at: 2 + 2 * 7), 
            sex: entityReader.read(at: 2 + 2 * 8), 
            bio: entityReader.read(at: 2 + 2 * 9), 
            location: entityReader.read(at: 2 + 2 * 10), 
            createDate: entityReader.read(at: 2 + 2 * 11), 
            updateDate: entityReader.read(at: 2 + 2 * 12), 
            avatarUrl: entityReader.read(at: 2 + 2 * 13), 
            avatarMime: entityReader.read(at: 2 + 2 * 14), 
            coverUrl: entityReader.read(at: 2 + 2 * 15), 
            coverMime: entityReader.read(at: 2 + 2 * 16), 
            following: entityReader.read(at: 2 + 2 * 17), 
            follower: entityReader.read(at: 2 + 2 * 18), 
            friendsCount: entityReader.read(at: 2 + 2 * 19), 
            otpDevice: entityReader.read(at: 2 + 2 * 67), 
            verificationIcon: entityReader.read(at: 2 + 2 * 20), 
            verificationType: entityReader.read(at: 2 + 2 * 21), 
            likesCount: entityReader.read(at: 2 + 2 * 22), 
            commentsCount: entityReader.read(at: 2 + 2 * 23), 
            followersCount: entityReader.read(at: 2 + 2 * 24), 
            followingsCount: entityReader.read(at: 2 + 2 * 25), 
            feedCount: entityReader.read(at: 2 + 2 * 26), 
            checkInCount: entityReader.read(at: 2 + 2 * 27), 
            canSubscribe: entityReader.read(at: 2 + 2 * 48), 
            isRewardAcceptEnabled: entityReader.read(at: 2 + 2 * 28), 
            activitiesCount: entityReader.read(at: 2 + 2 * 30), 
            isBlacked: entityReader.read(at: 2 + 2 * 31), 
            deleteDate: entityReader.read(at: 2 + 2 * 32), 
            whiteListType: entityReader.read(at: 2 + 2 * 33), 
            stickerArtistId: entityReader.read(at: 2 + 2 * 34), 
            stickerArtistName: entityReader.read(at: 2 + 2 * 35), 
            enableExternalRtmp: entityReader.read(at: 2 + 2 * 36), 
            badgeCount: entityReader.read(at: 2 + 2 * 37), 
            latestBadges: entityReader.read(at: 2 + 2 * 38), 
            country: entityReader.read(at: 2 + 2 * 39), 
            subscribing: entityReader.read(at: 2 + 2 * 42), 
            subsInfluenceScore: entityReader.read(at: 2 + 2 * 43), 
            rankingInfluenceScore: entityReader.read(at: 2 + 2 * 44), 
            miniProgramShopUrl: entityReader.read(at: 2 + 2 * 45), 
            miniProgramShopId: entityReader.read(at: 2 + 2 * 50), 
            birthdate: entityReader.read(at: 2 + 2 * 47), 
            monthlyLiveScore: entityReader.read(at: 2 + 2 * 49), 
            profileFrameIcon: entityReader.read(at: 2 + 2 * 51), 
            profileFrameColorHex: entityReader.read(at: 2 + 2 * 52), 
            liveFeedId: entityReader.read(at: 2 + 2 * 53), 
            subscriptionEnable: entityReader.read(at: 2 + 2 * 54), 
            subscriptionDisabledMsg: entityReader.read(at: 2 + 2 * 55), 
            website: entityReader.read(at: 2 + 2 * 56), 
            workIndustryID: entityReader.read(at: 2 + 2 * 57), 
            workIndustryName: entityReader.read(at: 2 + 2 * 58), 
            workIndustryKey: entityReader.read(at: 2 + 2 * 59), 
            relationshipID: entityReader.read(at: 2 + 2 * 60), 
            relationshipName: entityReader.read(at: 2 + 2 * 61), 
            relationshipKey: entityReader.read(at: 2 + 2 * 62), 
            countryKey: entityReader.read(at: 2 + 2 * 63), 
            countryID: entityReader.read(at: 2 + 2 * 64), 
            cityKey: entityReader.read(at: 2 + 2 * 65), 
            cityID: entityReader.read(at: 2 + 2 * 66), 
            miniProgramShow: entityReader.read(at: 2 + 2 * 68), 
            merchantId: entityReader.read(at: 2 + 2 * 69), 
            merchantRoute: entityReader.read(at: 2 + 2 * 70), 
            checkinStatus: entityReader.read(at: 2 + 2 * 72), 
            checkinShowPoint: entityReader.read(at: 2 + 2 * 73)
        )
        return entity
    }
}

extension ObjectBox.Box where E == UserInfoModel {

    /// Puts the UserInfoModel in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: UserInfoModel) throws -> UserInfoModel {
        let entityId: UserInfoModel.EntityBindingType.IdType = try self.put(entity)

        return UserInfoModel(
            id: entityId, 
            userIdentity: entity.userIdentity, 
            displayName: entity.displayName, 
            username: entity.username, 
            phone: entity.phone, 
            mobi: entity.mobi, 
            email: entity.email, 
            sex: entity.sex, 
            bio: entity.bio, 
            location: entity.location, 
            createDate: entity.createDate, 
            updateDate: entity.updateDate, 
            avatarUrl: entity.avatarUrl, 
            avatarMime: entity.avatarMime, 
            coverUrl: entity.coverUrl, 
            coverMime: entity.coverMime, 
            following: entity.following, 
            follower: entity.follower, 
            friendsCount: entity.friendsCount, 
            otpDevice: entity.otpDevice, 
            verificationIcon: entity.verificationIcon, 
            verificationType: entity.verificationType, 
            likesCount: entity.likesCount, 
            commentsCount: entity.commentsCount, 
            followersCount: entity.followersCount, 
            followingsCount: entity.followingsCount, 
            feedCount: entity.feedCount, 
            checkInCount: entity.checkInCount, 
            canSubscribe: entity.canSubscribe, 
            isRewardAcceptEnabled: entity.isRewardAcceptEnabled, 
            activitiesCount: entity.activitiesCount, 
            isBlacked: entity.isBlacked, 
            deleteDate: entity.deleteDate, 
            whiteListType: entity.whiteListType, 
            stickerArtistId: entity.stickerArtistId, 
            stickerArtistName: entity.stickerArtistName, 
            enableExternalRtmp: entity.enableExternalRtmp, 
            badgeCount: entity.badgeCount, 
            latestBadges: entity.latestBadges, 
            country: entity.country, 
            subscribing: entity.subscribing, 
            subsInfluenceScore: entity.subsInfluenceScore, 
            rankingInfluenceScore: entity.rankingInfluenceScore, 
            miniProgramShopUrl: entity.miniProgramShopUrl, 
            miniProgramShopId: entity.miniProgramShopId, 
            birthdate: entity.birthdate, 
            monthlyLiveScore: entity.monthlyLiveScore, 
            profileFrameIcon: entity.profileFrameIcon, 
            profileFrameColorHex: entity.profileFrameColorHex, 
            liveFeedId: entity.liveFeedId, 
            subscriptionEnable: entity.subscriptionEnable, 
            subscriptionDisabledMsg: entity.subscriptionDisabledMsg, 
            website: entity.website, 
            workIndustryID: entity.workIndustryID, 
            workIndustryName: entity.workIndustryName, 
            workIndustryKey: entity.workIndustryKey, 
            relationshipID: entity.relationshipID, 
            relationshipName: entity.relationshipName, 
            relationshipKey: entity.relationshipKey, 
            countryKey: entity.countryKey, 
            countryID: entity.countryID, 
            cityKey: entity.cityKey, 
            cityID: entity.cityID, 
            miniProgramShow: entity.miniProgramShow, 
            merchantId: entity.merchantId, 
            merchantRoute: entity.merchantRoute, 
            checkinStatus: entity.checkinStatus, 
            checkinShowPoint: entity.checkinShowPoint
        )
    }

    /// Puts the UserInfoModels in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [UserInfoModel]) throws -> [UserInfoModel] {
        let entityIds: [UserInfoModel.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [UserInfoModel]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(UserInfoModel(
                id: entityId, 
                userIdentity: entity.userIdentity, 
                displayName: entity.displayName, 
                username: entity.username, 
                phone: entity.phone, 
                mobi: entity.mobi, 
                email: entity.email, 
                sex: entity.sex, 
                bio: entity.bio, 
                location: entity.location, 
                createDate: entity.createDate, 
                updateDate: entity.updateDate, 
                avatarUrl: entity.avatarUrl, 
                avatarMime: entity.avatarMime, 
                coverUrl: entity.coverUrl, 
                coverMime: entity.coverMime, 
                following: entity.following, 
                follower: entity.follower, 
                friendsCount: entity.friendsCount, 
                otpDevice: entity.otpDevice, 
                verificationIcon: entity.verificationIcon, 
                verificationType: entity.verificationType, 
                likesCount: entity.likesCount, 
                commentsCount: entity.commentsCount, 
                followersCount: entity.followersCount, 
                followingsCount: entity.followingsCount, 
                feedCount: entity.feedCount, 
                checkInCount: entity.checkInCount, 
                canSubscribe: entity.canSubscribe, 
                isRewardAcceptEnabled: entity.isRewardAcceptEnabled, 
                activitiesCount: entity.activitiesCount, 
                isBlacked: entity.isBlacked, 
                deleteDate: entity.deleteDate, 
                whiteListType: entity.whiteListType, 
                stickerArtistId: entity.stickerArtistId, 
                stickerArtistName: entity.stickerArtistName, 
                enableExternalRtmp: entity.enableExternalRtmp, 
                badgeCount: entity.badgeCount, 
                latestBadges: entity.latestBadges, 
                country: entity.country, 
                subscribing: entity.subscribing, 
                subsInfluenceScore: entity.subsInfluenceScore, 
                rankingInfluenceScore: entity.rankingInfluenceScore, 
                miniProgramShopUrl: entity.miniProgramShopUrl, 
                miniProgramShopId: entity.miniProgramShopId, 
                birthdate: entity.birthdate, 
                monthlyLiveScore: entity.monthlyLiveScore, 
                profileFrameIcon: entity.profileFrameIcon, 
                profileFrameColorHex: entity.profileFrameColorHex, 
                liveFeedId: entity.liveFeedId, 
                subscriptionEnable: entity.subscriptionEnable, 
                subscriptionDisabledMsg: entity.subscriptionDisabledMsg, 
                website: entity.website, 
                workIndustryID: entity.workIndustryID, 
                workIndustryName: entity.workIndustryName, 
                workIndustryKey: entity.workIndustryKey, 
                relationshipID: entity.relationshipID, 
                relationshipName: entity.relationshipName, 
                relationshipKey: entity.relationshipKey, 
                countryKey: entity.countryKey, 
                countryID: entity.countryID, 
                cityKey: entity.cityKey, 
                cityID: entity.cityID, 
                miniProgramShow: entity.miniProgramShow, 
                merchantId: entity.merchantId, 
                merchantRoute: entity.merchantRoute, 
                checkinStatus: entity.checkinStatus, 
                checkinShowPoint: entity.checkinShowPoint
            ))
        }

        return newEntities
    }
}


extension UserSessionInfo: ObjectBox.__EntityRelatable {
    internal typealias EntityType = UserSessionInfo

    internal var _id: EntityId<UserSessionInfo> {
        return EntityId<UserSessionInfo>(self.id.value)
    }
}

extension UserSessionInfo: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = UserSessionInfoBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "UserSessionInfo", id: 4)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: UserSessionInfo.self, id: 4, uid: 7103594958438401792)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 2560198813693385472)
        try entityBuilder.addProperty(name: "userIdentity", type: PropertyType.long, id: 2, uid: 937522128286801408)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 3, uid: 3950789627257883648)
        try entityBuilder.addProperty(name: "phone", type: PropertyType.string, id: 4, uid: 3596040650697118464)
        try entityBuilder.addProperty(name: "email", type: PropertyType.string, id: 5, uid: 395917784831551744)
        try entityBuilder.addProperty(name: "sex", type: PropertyType.long, id: 6, uid: 6927379152850022912)
        try entityBuilder.addProperty(name: "bio", type: PropertyType.string, id: 7, uid: 1303050463470516480)
        try entityBuilder.addProperty(name: "location", type: PropertyType.string, id: 8, uid: 8285540792052764928)
        try entityBuilder.addProperty(name: "createDate", type: PropertyType.date, id: 9, uid: 7953866581422149632)
        try entityBuilder.addProperty(name: "updateDate", type: PropertyType.date, id: 10, uid: 7650062978062618624)
        try entityBuilder.addProperty(name: "avatarUrl", type: PropertyType.string, id: 11, uid: 4960088819503801088)
        try entityBuilder.addProperty(name: "avatarMime", type: PropertyType.string, id: 12, uid: 804950039490284288)
        try entityBuilder.addProperty(name: "coverUrl", type: PropertyType.string, id: 13, uid: 4471466419040725248)
        try entityBuilder.addProperty(name: "coverMime", type: PropertyType.string, id: 14, uid: 8198687025536417792)
        try entityBuilder.addProperty(name: "following", type: PropertyType.bool, id: 15, uid: 8737167477568959232)
        try entityBuilder.addProperty(name: "follower", type: PropertyType.bool, id: 16, uid: 7333403488991935488)
        try entityBuilder.addProperty(name: "friendsCount", type: PropertyType.long, id: 17, uid: 8907740718979648256)
        try entityBuilder.addProperty(name: "otpDevice", type: PropertyType.bool, id: 63, uid: 7081026509952747776)
        try entityBuilder.addProperty(name: "certificationStatus", type: PropertyType.long, id: 42, uid: 363068368471417856)
        try entityBuilder.addProperty(name: "verificationIcon", type: PropertyType.string, id: 18, uid: 8599406822681246208)
        try entityBuilder.addProperty(name: "verificationType", type: PropertyType.string, id: 19, uid: 3528899991200822528)
        try entityBuilder.addProperty(name: "likesCount", type: PropertyType.long, id: 20, uid: 1539164095718707200)
        try entityBuilder.addProperty(name: "commentsCount", type: PropertyType.long, id: 21, uid: 1105406664480873984)
        try entityBuilder.addProperty(name: "followersCount", type: PropertyType.long, id: 22, uid: 8004674703760242688)
        try entityBuilder.addProperty(name: "followingsCount", type: PropertyType.long, id: 23, uid: 8297568970357019904)
        try entityBuilder.addProperty(name: "feedCount", type: PropertyType.long, id: 24, uid: 8840237417536367360)
        try entityBuilder.addProperty(name: "checkInCount", type: PropertyType.long, id: 25, uid: 8335180957547431424)
        try entityBuilder.addProperty(name: "isRewardAcceptEnabled", type: PropertyType.bool, id: 26, uid: 4730226898861426688)
        try entityBuilder.addProperty(name: "canSubscribe", type: PropertyType.bool, id: 43, uid: 845545900133359872)
        try entityBuilder.addProperty(name: "activitiesCount", type: PropertyType.long, id: 28, uid: 1156997928879568896)
        try entityBuilder.addProperty(name: "yippsTotal", type: PropertyType.double, id: 29, uid: 2436353526270278400)
        try entityBuilder.addProperty(name: "rewardsTotal", type: PropertyType.double, id: 30, uid: 1639190907591705088)
        try entityBuilder.addProperty(name: "rebates", type: PropertyType.double, id: 41, uid: 7667617750880327424)
        try entityBuilder.addProperty(name: "whiteListType", type: PropertyType.string, id: 31, uid: 9116384596989245440)
        try entityBuilder.addProperty(name: "country", type: PropertyType.string, id: 32, uid: 3319167167226344448)
        try entityBuilder.addProperty(name: "freeHotPost", type: PropertyType.long, id: 33, uid: 361891519407564288)
        try entityBuilder.addProperty(name: "isLiveEnabled", type: PropertyType.bool, id: 34, uid: 6993124263662723584)
        try entityBuilder.addProperty(name: "isMiniVideoEnabled", type: PropertyType.bool, id: 35, uid: 5834412251181715200)
        try entityBuilder.addProperty(name: "enableExternalRTMP", type: PropertyType.bool, id: 36, uid: 4185160711402824704)
        try entityBuilder.addProperty(name: "hasPin", type: PropertyType.bool, id: 37, uid: 1506003754219437568)
        try entityBuilder.addProperty(name: "birthdate", type: PropertyType.string, id: 38, uid: 8112893082683221248)
        try entityBuilder.addProperty(name: "username", type: PropertyType.string, id: 39, uid: 1920474541464486912)
        try entityBuilder.addProperty(name: "haslevelUpgraded", type: PropertyType.bool, id: 40, uid: 4144006352723723008)
        try entityBuilder.addProperty(name: "subscribingBadge", type: PropertyType.string, id: 44, uid: 7913450077902649856)
        try entityBuilder.addProperty(name: "profileFrameIcon", type: PropertyType.string, id: 45, uid: 7014280177347479040)
        try entityBuilder.addProperty(name: "profileFrameColorHex", type: PropertyType.string, id: 46, uid: 3966374675740896256)
        try entityBuilder.addProperty(name: "liveFeedId", type: PropertyType.long, id: 47, uid: 6105049847183175424)
        try entityBuilder.addProperty(name: "website", type: PropertyType.string, id: 48, uid: 6203170710400726272)
        try entityBuilder.addProperty(name: "workIndustryID", type: PropertyType.long, id: 49, uid: 4034039811943060480)
        try entityBuilder.addProperty(name: "workIndustryName", type: PropertyType.string, id: 50, uid: 4765507154140765696)
        try entityBuilder.addProperty(name: "workIndustryKey", type: PropertyType.string, id: 51, uid: 4011384290996769792)
        try entityBuilder.addProperty(name: "relationshipID", type: PropertyType.long, id: 52, uid: 1844837166976063232)
        try entityBuilder.addProperty(name: "relationshipName", type: PropertyType.string, id: 53, uid: 5510776139215630336)
        try entityBuilder.addProperty(name: "relationshipKey", type: PropertyType.string, id: 54, uid: 8100666138734264064)
        try entityBuilder.addProperty(name: "countryKey", type: PropertyType.string, id: 55, uid: 1734638980957326592)
        try entityBuilder.addProperty(name: "countryID", type: PropertyType.long, id: 56, uid: 5379226706926582784)
        try entityBuilder.addProperty(name: "countryHasChild", type: PropertyType.bool, id: 57, uid: 132936183399456000)
        try entityBuilder.addProperty(name: "provinceKey", type: PropertyType.string, id: 58, uid: 3950365427107107072)
        try entityBuilder.addProperty(name: "provinceID", type: PropertyType.long, id: 59, uid: 7194971055723219456)
        try entityBuilder.addProperty(name: "provinceHasChild", type: PropertyType.bool, id: 60, uid: 4945375286178102784)
        try entityBuilder.addProperty(name: "cityKey", type: PropertyType.string, id: 61, uid: 1483763437137572352)
        try entityBuilder.addProperty(name: "cityID", type: PropertyType.long, id: 62, uid: 7697878098155149824)
        try entityBuilder.addProperty(name: "checkinStatus", type: PropertyType.bool, id: 64, uid: 1287201179525317632)
        try entityBuilder.addProperty(name: "checkinShowPoint", type: PropertyType.bool, id: 65, uid: 4881328791647209728)

        try entityBuilder.lastProperty(id: 65, uid: 4881328791647209728)
    }
}

extension UserSessionInfo {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.id == myId }
    internal static var id: Property<UserSessionInfo, Id, Id> { return Property<UserSessionInfo, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.userIdentity > 1234 }
    internal static var userIdentity: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.name.startsWith("X") }
    internal static var name: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.phone.startsWith("X") }
    internal static var phone: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.email.startsWith("X") }
    internal static var email: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.sex > 1234 }
    internal static var sex: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.bio.startsWith("X") }
    internal static var bio: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.location.startsWith("X") }
    internal static var location: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.createDate > 1234 }
    internal static var createDate: Property<UserSessionInfo, Date?, Void> { return Property<UserSessionInfo, Date?, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.updateDate > 1234 }
    internal static var updateDate: Property<UserSessionInfo, Date?, Void> { return Property<UserSessionInfo, Date?, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.avatarUrl.startsWith("X") }
    internal static var avatarUrl: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.avatarMime.startsWith("X") }
    internal static var avatarMime: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.coverUrl.startsWith("X") }
    internal static var coverUrl: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.coverMime.startsWith("X") }
    internal static var coverMime: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.following == true }
    internal static var following: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.follower == true }
    internal static var follower: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.friendsCount > 1234 }
    internal static var friendsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.otpDevice == true }
    internal static var otpDevice: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 63, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.certificationStatus > 1234 }
    internal static var certificationStatus: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 42, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.verificationIcon.startsWith("X") }
    internal static var verificationIcon: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.verificationType.startsWith("X") }
    internal static var verificationType: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.likesCount > 1234 }
    internal static var likesCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.commentsCount > 1234 }
    internal static var commentsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.followersCount > 1234 }
    internal static var followersCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.followingsCount > 1234 }
    internal static var followingsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.feedCount > 1234 }
    internal static var feedCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.checkInCount > 1234 }
    internal static var checkInCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.isRewardAcceptEnabled == true }
    internal static var isRewardAcceptEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 26, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.canSubscribe == true }
    internal static var canSubscribe: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 43, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.activitiesCount > 1234 }
    internal static var activitiesCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 28, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.yippsTotal > 1234 }
    internal static var yippsTotal: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 29, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.rewardsTotal > 1234 }
    internal static var rewardsTotal: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 30, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.rebates > 1234 }
    internal static var rebates: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 41, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.whiteListType.startsWith("X") }
    internal static var whiteListType: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 31, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.country.startsWith("X") }
    internal static var country: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 32, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.freeHotPost > 1234 }
    internal static var freeHotPost: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 33, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.isLiveEnabled == true }
    internal static var isLiveEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 34, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.isMiniVideoEnabled == true }
    internal static var isMiniVideoEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 35, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.enableExternalRTMP == true }
    internal static var enableExternalRTMP: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 36, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.hasPin == true }
    internal static var hasPin: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 37, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.birthdate.startsWith("X") }
    internal static var birthdate: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 38, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.username.startsWith("X") }
    internal static var username: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 39, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.haslevelUpgraded == true }
    internal static var haslevelUpgraded: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 40, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.subscribingBadge.startsWith("X") }
    internal static var subscribingBadge: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 44, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.profileFrameIcon.startsWith("X") }
    internal static var profileFrameIcon: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 45, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.profileFrameColorHex.startsWith("X") }
    internal static var profileFrameColorHex: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 46, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.liveFeedId > 1234 }
    internal static var liveFeedId: Property<UserSessionInfo, Int?, Void> { return Property<UserSessionInfo, Int?, Void>(propertyId: 47, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.website.startsWith("X") }
    internal static var website: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 48, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.workIndustryID > 1234 }
    internal static var workIndustryID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 49, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.workIndustryName.startsWith("X") }
    internal static var workIndustryName: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 50, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.workIndustryKey.startsWith("X") }
    internal static var workIndustryKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 51, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.relationshipID > 1234 }
    internal static var relationshipID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 52, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.relationshipName.startsWith("X") }
    internal static var relationshipName: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 53, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.relationshipKey.startsWith("X") }
    internal static var relationshipKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 54, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.countryKey.startsWith("X") }
    internal static var countryKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 55, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.countryID > 1234 }
    internal static var countryID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 56, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.countryHasChild == true }
    internal static var countryHasChild: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 57, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.provinceKey.startsWith("X") }
    internal static var provinceKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 58, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.provinceID > 1234 }
    internal static var provinceID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 59, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.provinceHasChild == true }
    internal static var provinceHasChild: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 60, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.cityKey.startsWith("X") }
    internal static var cityKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 61, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.cityID > 1234 }
    internal static var cityID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 62, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.checkinStatus == true }
    internal static var checkinStatus: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 64, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UserSessionInfo.checkinShowPoint == true }
    internal static var checkinShowPoint: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 65, isPrimaryKey: false) }

    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == UserSessionInfo {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<UserSessionInfo, Id, Id> { return Property<UserSessionInfo, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .userIdentity > 1234 }

    internal static var userIdentity: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .phone.startsWith("X") }

    internal static var phone: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .email.startsWith("X") }

    internal static var email: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .sex > 1234 }

    internal static var sex: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bio.startsWith("X") }

    internal static var bio: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .location.startsWith("X") }

    internal static var location: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .createDate > 1234 }

    internal static var createDate: Property<UserSessionInfo, Date?, Void> { return Property<UserSessionInfo, Date?, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .updateDate > 1234 }

    internal static var updateDate: Property<UserSessionInfo, Date?, Void> { return Property<UserSessionInfo, Date?, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .avatarUrl.startsWith("X") }

    internal static var avatarUrl: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .avatarMime.startsWith("X") }

    internal static var avatarMime: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coverUrl.startsWith("X") }

    internal static var coverUrl: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coverMime.startsWith("X") }

    internal static var coverMime: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .following == true }

    internal static var following: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .follower == true }

    internal static var follower: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .friendsCount > 1234 }

    internal static var friendsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .otpDevice == true }

    internal static var otpDevice: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 63, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .certificationStatus > 1234 }

    internal static var certificationStatus: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 42, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .verificationIcon.startsWith("X") }

    internal static var verificationIcon: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .verificationType.startsWith("X") }

    internal static var verificationType: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .likesCount > 1234 }

    internal static var likesCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .commentsCount > 1234 }

    internal static var commentsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .followersCount > 1234 }

    internal static var followersCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .followingsCount > 1234 }

    internal static var followingsCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .feedCount > 1234 }

    internal static var feedCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkInCount > 1234 }

    internal static var checkInCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isRewardAcceptEnabled == true }

    internal static var isRewardAcceptEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 26, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .canSubscribe == true }

    internal static var canSubscribe: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 43, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .activitiesCount > 1234 }

    internal static var activitiesCount: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 28, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .yippsTotal > 1234 }

    internal static var yippsTotal: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 29, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rewardsTotal > 1234 }

    internal static var rewardsTotal: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 30, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .rebates > 1234 }

    internal static var rebates: Property<UserSessionInfo, Double, Void> { return Property<UserSessionInfo, Double, Void>(propertyId: 41, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .whiteListType.startsWith("X") }

    internal static var whiteListType: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 31, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .country.startsWith("X") }

    internal static var country: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 32, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .freeHotPost > 1234 }

    internal static var freeHotPost: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 33, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isLiveEnabled == true }

    internal static var isLiveEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 34, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .isMiniVideoEnabled == true }

    internal static var isMiniVideoEnabled: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 35, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .enableExternalRTMP == true }

    internal static var enableExternalRTMP: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 36, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .hasPin == true }

    internal static var hasPin: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 37, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .birthdate.startsWith("X") }

    internal static var birthdate: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 38, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .username.startsWith("X") }

    internal static var username: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 39, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .haslevelUpgraded == true }

    internal static var haslevelUpgraded: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 40, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .subscribingBadge.startsWith("X") }

    internal static var subscribingBadge: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 44, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameIcon.startsWith("X") }

    internal static var profileFrameIcon: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 45, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .profileFrameColorHex.startsWith("X") }

    internal static var profileFrameColorHex: Property<UserSessionInfo, String?, Void> { return Property<UserSessionInfo, String?, Void>(propertyId: 46, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .liveFeedId > 1234 }

    internal static var liveFeedId: Property<UserSessionInfo, Int?, Void> { return Property<UserSessionInfo, Int?, Void>(propertyId: 47, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .website.startsWith("X") }

    internal static var website: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 48, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryID > 1234 }

    internal static var workIndustryID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 49, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryName.startsWith("X") }

    internal static var workIndustryName: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 50, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .workIndustryKey.startsWith("X") }

    internal static var workIndustryKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 51, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipID > 1234 }

    internal static var relationshipID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 52, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipName.startsWith("X") }

    internal static var relationshipName: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 53, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .relationshipKey.startsWith("X") }

    internal static var relationshipKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 54, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .countryKey.startsWith("X") }

    internal static var countryKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 55, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .countryID > 1234 }

    internal static var countryID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 56, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .countryHasChild == true }

    internal static var countryHasChild: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 57, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .provinceKey.startsWith("X") }

    internal static var provinceKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 58, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .provinceID > 1234 }

    internal static var provinceID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 59, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .provinceHasChild == true }

    internal static var provinceHasChild: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 60, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .cityKey.startsWith("X") }

    internal static var cityKey: Property<UserSessionInfo, String, Void> { return Property<UserSessionInfo, String, Void>(propertyId: 61, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .cityID > 1234 }

    internal static var cityID: Property<UserSessionInfo, Int, Void> { return Property<UserSessionInfo, Int, Void>(propertyId: 62, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkinStatus == true }

    internal static var checkinStatus: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 64, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .checkinShowPoint == true }

    internal static var checkinShowPoint: Property<UserSessionInfo, Bool, Void> { return Property<UserSessionInfo, Bool, Void>(propertyId: 65, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `UserSessionInfo.EntityBindingType`.
internal class UserSessionInfoBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = UserSessionInfo
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)
        let propertyOffset_phone = propertyCollector.prepare(string: entity.phone)
        let propertyOffset_email = propertyCollector.prepare(string: entity.email)
        let propertyOffset_bio = propertyCollector.prepare(string: entity.bio)
        let propertyOffset_location = propertyCollector.prepare(string: entity.location)
        let propertyOffset_avatarUrl = propertyCollector.prepare(string: entity.avatarUrl)
        let propertyOffset_avatarMime = propertyCollector.prepare(string: entity.avatarMime)
        let propertyOffset_coverUrl = propertyCollector.prepare(string: entity.coverUrl)
        let propertyOffset_coverMime = propertyCollector.prepare(string: entity.coverMime)
        let propertyOffset_verificationIcon = propertyCollector.prepare(string: entity.verificationIcon)
        let propertyOffset_verificationType = propertyCollector.prepare(string: entity.verificationType)
        let propertyOffset_whiteListType = propertyCollector.prepare(string: entity.whiteListType)
        let propertyOffset_country = propertyCollector.prepare(string: entity.country)
        let propertyOffset_birthdate = propertyCollector.prepare(string: entity.birthdate)
        let propertyOffset_username = propertyCollector.prepare(string: entity.username)
        let propertyOffset_subscribingBadge = propertyCollector.prepare(string: entity.subscribingBadge)
        let propertyOffset_profileFrameIcon = propertyCollector.prepare(string: entity.profileFrameIcon)
        let propertyOffset_profileFrameColorHex = propertyCollector.prepare(string: entity.profileFrameColorHex)
        let propertyOffset_website = propertyCollector.prepare(string: entity.website)
        let propertyOffset_workIndustryName = propertyCollector.prepare(string: entity.workIndustryName)
        let propertyOffset_workIndustryKey = propertyCollector.prepare(string: entity.workIndustryKey)
        let propertyOffset_relationshipName = propertyCollector.prepare(string: entity.relationshipName)
        let propertyOffset_relationshipKey = propertyCollector.prepare(string: entity.relationshipKey)
        let propertyOffset_countryKey = propertyCollector.prepare(string: entity.countryKey)
        let propertyOffset_provinceKey = propertyCollector.prepare(string: entity.provinceKey)
        let propertyOffset_cityKey = propertyCollector.prepare(string: entity.cityKey)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.userIdentity, at: 2 + 2 * 2)
        propertyCollector.collect(entity.sex, at: 2 + 2 * 6)
        propertyCollector.collect(entity.createDate, at: 2 + 2 * 9)
        propertyCollector.collect(entity.updateDate, at: 2 + 2 * 10)
        propertyCollector.collect(entity.following, at: 2 + 2 * 15)
        propertyCollector.collect(entity.follower, at: 2 + 2 * 16)
        propertyCollector.collect(entity.friendsCount, at: 2 + 2 * 17)
        propertyCollector.collect(entity.otpDevice, at: 2 + 2 * 63)
        propertyCollector.collect(entity.certificationStatus, at: 2 + 2 * 42)
        propertyCollector.collect(entity.likesCount, at: 2 + 2 * 20)
        propertyCollector.collect(entity.commentsCount, at: 2 + 2 * 21)
        propertyCollector.collect(entity.followersCount, at: 2 + 2 * 22)
        propertyCollector.collect(entity.followingsCount, at: 2 + 2 * 23)
        propertyCollector.collect(entity.feedCount, at: 2 + 2 * 24)
        propertyCollector.collect(entity.checkInCount, at: 2 + 2 * 25)
        propertyCollector.collect(entity.isRewardAcceptEnabled, at: 2 + 2 * 26)
        propertyCollector.collect(entity.canSubscribe, at: 2 + 2 * 43)
        propertyCollector.collect(entity.activitiesCount, at: 2 + 2 * 28)
        propertyCollector.collect(entity.yippsTotal, at: 2 + 2 * 29)
        propertyCollector.collect(entity.rewardsTotal, at: 2 + 2 * 30)
        propertyCollector.collect(entity.rebates, at: 2 + 2 * 41)
        propertyCollector.collect(entity.freeHotPost, at: 2 + 2 * 33)
        propertyCollector.collect(entity.isLiveEnabled, at: 2 + 2 * 34)
        propertyCollector.collect(entity.isMiniVideoEnabled, at: 2 + 2 * 35)
        propertyCollector.collect(entity.enableExternalRTMP, at: 2 + 2 * 36)
        propertyCollector.collect(entity.hasPin, at: 2 + 2 * 37)
        propertyCollector.collect(entity.haslevelUpgraded, at: 2 + 2 * 40)
        propertyCollector.collect(entity.liveFeedId, at: 2 + 2 * 47)
        propertyCollector.collect(entity.workIndustryID, at: 2 + 2 * 49)
        propertyCollector.collect(entity.relationshipID, at: 2 + 2 * 52)
        propertyCollector.collect(entity.countryID, at: 2 + 2 * 56)
        propertyCollector.collect(entity.countryHasChild, at: 2 + 2 * 57)
        propertyCollector.collect(entity.provinceID, at: 2 + 2 * 59)
        propertyCollector.collect(entity.provinceHasChild, at: 2 + 2 * 60)
        propertyCollector.collect(entity.cityID, at: 2 + 2 * 62)
        propertyCollector.collect(entity.checkinStatus, at: 2 + 2 * 64)
        propertyCollector.collect(entity.checkinShowPoint, at: 2 + 2 * 65)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_phone, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_email, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_bio, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_location, at: 2 + 2 * 8)
        propertyCollector.collect(dataOffset: propertyOffset_avatarUrl, at: 2 + 2 * 11)
        propertyCollector.collect(dataOffset: propertyOffset_avatarMime, at: 2 + 2 * 12)
        propertyCollector.collect(dataOffset: propertyOffset_coverUrl, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_coverMime, at: 2 + 2 * 14)
        propertyCollector.collect(dataOffset: propertyOffset_verificationIcon, at: 2 + 2 * 18)
        propertyCollector.collect(dataOffset: propertyOffset_verificationType, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_whiteListType, at: 2 + 2 * 31)
        propertyCollector.collect(dataOffset: propertyOffset_country, at: 2 + 2 * 32)
        propertyCollector.collect(dataOffset: propertyOffset_birthdate, at: 2 + 2 * 38)
        propertyCollector.collect(dataOffset: propertyOffset_username, at: 2 + 2 * 39)
        propertyCollector.collect(dataOffset: propertyOffset_subscribingBadge, at: 2 + 2 * 44)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameIcon, at: 2 + 2 * 45)
        propertyCollector.collect(dataOffset: propertyOffset_profileFrameColorHex, at: 2 + 2 * 46)
        propertyCollector.collect(dataOffset: propertyOffset_website, at: 2 + 2 * 48)
        propertyCollector.collect(dataOffset: propertyOffset_workIndustryName, at: 2 + 2 * 50)
        propertyCollector.collect(dataOffset: propertyOffset_workIndustryKey, at: 2 + 2 * 51)
        propertyCollector.collect(dataOffset: propertyOffset_relationshipName, at: 2 + 2 * 53)
        propertyCollector.collect(dataOffset: propertyOffset_relationshipKey, at: 2 + 2 * 54)
        propertyCollector.collect(dataOffset: propertyOffset_countryKey, at: 2 + 2 * 55)
        propertyCollector.collect(dataOffset: propertyOffset_provinceKey, at: 2 + 2 * 58)
        propertyCollector.collect(dataOffset: propertyOffset_cityKey, at: 2 + 2 * 61)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: Id = entityReader.read(at: 2 + 2 * 1)
        let entity = UserSessionInfo(
            id: entityId, 
            userIdentity: entityReader.read(at: 2 + 2 * 2), 
            name: entityReader.read(at: 2 + 2 * 3), 
            phone: entityReader.read(at: 2 + 2 * 4), 
            email: entityReader.read(at: 2 + 2 * 5), 
            sex: entityReader.read(at: 2 + 2 * 6), 
            bio: entityReader.read(at: 2 + 2 * 7), 
            location: entityReader.read(at: 2 + 2 * 8), 
            createDate: entityReader.read(at: 2 + 2 * 9), 
            updateDate: entityReader.read(at: 2 + 2 * 10), 
            avatarUrl: entityReader.read(at: 2 + 2 * 11), 
            avatarMime: entityReader.read(at: 2 + 2 * 12), 
            coverUrl: entityReader.read(at: 2 + 2 * 13), 
            coverMime: entityReader.read(at: 2 + 2 * 14), 
            following: entityReader.read(at: 2 + 2 * 15), 
            follower: entityReader.read(at: 2 + 2 * 16), 
            friendsCount: entityReader.read(at: 2 + 2 * 17), 
            otpDevice: entityReader.read(at: 2 + 2 * 63), 
            certificationStatus: entityReader.read(at: 2 + 2 * 42), 
            verificationIcon: entityReader.read(at: 2 + 2 * 18), 
            verificationType: entityReader.read(at: 2 + 2 * 19), 
            likesCount: entityReader.read(at: 2 + 2 * 20), 
            commentsCount: entityReader.read(at: 2 + 2 * 21), 
            followersCount: entityReader.read(at: 2 + 2 * 22), 
            followingsCount: entityReader.read(at: 2 + 2 * 23), 
            feedCount: entityReader.read(at: 2 + 2 * 24), 
            checkInCount: entityReader.read(at: 2 + 2 * 25), 
            isRewardAcceptEnabled: entityReader.read(at: 2 + 2 * 26), 
            canSubscribe: entityReader.read(at: 2 + 2 * 43), 
            activitiesCount: entityReader.read(at: 2 + 2 * 28), 
            yippsTotal: entityReader.read(at: 2 + 2 * 29), 
            rewardsTotal: entityReader.read(at: 2 + 2 * 30), 
            rebates: entityReader.read(at: 2 + 2 * 41), 
            whiteListType: entityReader.read(at: 2 + 2 * 31), 
            country: entityReader.read(at: 2 + 2 * 32), 
            freeHotPost: entityReader.read(at: 2 + 2 * 33), 
            isLiveEnabled: entityReader.read(at: 2 + 2 * 34), 
            isMiniVideoEnabled: entityReader.read(at: 2 + 2 * 35), 
            enableExternalRTMP: entityReader.read(at: 2 + 2 * 36), 
            hasPin: entityReader.read(at: 2 + 2 * 37), 
            birthdate: entityReader.read(at: 2 + 2 * 38), 
            username: entityReader.read(at: 2 + 2 * 39), 
            haslevelUpgraded: entityReader.read(at: 2 + 2 * 40), 
            subscribingBadge: entityReader.read(at: 2 + 2 * 44), 
            profileFrameIcon: entityReader.read(at: 2 + 2 * 45), 
            profileFrameColorHex: entityReader.read(at: 2 + 2 * 46), 
            liveFeedId: entityReader.read(at: 2 + 2 * 47), 
            website: entityReader.read(at: 2 + 2 * 48), 
            workIndustryID: entityReader.read(at: 2 + 2 * 49), 
            workIndustryName: entityReader.read(at: 2 + 2 * 50), 
            workIndustryKey: entityReader.read(at: 2 + 2 * 51), 
            relationshipID: entityReader.read(at: 2 + 2 * 52), 
            relationshipName: entityReader.read(at: 2 + 2 * 53), 
            relationshipKey: entityReader.read(at: 2 + 2 * 54), 
            countryKey: entityReader.read(at: 2 + 2 * 55), 
            countryID: entityReader.read(at: 2 + 2 * 56), 
            countryHasChild: entityReader.read(at: 2 + 2 * 57), 
            provinceKey: entityReader.read(at: 2 + 2 * 58), 
            provinceID: entityReader.read(at: 2 + 2 * 59), 
            provinceHasChild: entityReader.read(at: 2 + 2 * 60), 
            cityKey: entityReader.read(at: 2 + 2 * 61), 
            cityID: entityReader.read(at: 2 + 2 * 62), 
            checkinStatus: entityReader.read(at: 2 + 2 * 64), 
            checkinShowPoint: entityReader.read(at: 2 + 2 * 65)
        )
        return entity
    }
}

extension ObjectBox.Box where E == UserSessionInfo {

    /// Puts the UserSessionInfo in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: UserSessionInfo) throws -> UserSessionInfo {
        let entityId: UserSessionInfo.EntityBindingType.IdType = try self.put(entity)

        return UserSessionInfo(
            id: entityId, 
            userIdentity: entity.userIdentity, 
            name: entity.name, 
            phone: entity.phone, 
            email: entity.email, 
            sex: entity.sex, 
            bio: entity.bio, 
            location: entity.location, 
            createDate: entity.createDate, 
            updateDate: entity.updateDate, 
            avatarUrl: entity.avatarUrl, 
            avatarMime: entity.avatarMime, 
            coverUrl: entity.coverUrl, 
            coverMime: entity.coverMime, 
            following: entity.following, 
            follower: entity.follower, 
            friendsCount: entity.friendsCount, 
            otpDevice: entity.otpDevice, 
            certificationStatus: entity.certificationStatus, 
            verificationIcon: entity.verificationIcon, 
            verificationType: entity.verificationType, 
            likesCount: entity.likesCount, 
            commentsCount: entity.commentsCount, 
            followersCount: entity.followersCount, 
            followingsCount: entity.followingsCount, 
            feedCount: entity.feedCount, 
            checkInCount: entity.checkInCount, 
            isRewardAcceptEnabled: entity.isRewardAcceptEnabled, 
            canSubscribe: entity.canSubscribe, 
            activitiesCount: entity.activitiesCount, 
            yippsTotal: entity.yippsTotal, 
            rewardsTotal: entity.rewardsTotal, 
            rebates: entity.rebates, 
            whiteListType: entity.whiteListType, 
            country: entity.country, 
            freeHotPost: entity.freeHotPost, 
            isLiveEnabled: entity.isLiveEnabled, 
            isMiniVideoEnabled: entity.isMiniVideoEnabled, 
            enableExternalRTMP: entity.enableExternalRTMP, 
            hasPin: entity.hasPin, 
            birthdate: entity.birthdate, 
            username: entity.username, 
            haslevelUpgraded: entity.haslevelUpgraded, 
            subscribingBadge: entity.subscribingBadge, 
            profileFrameIcon: entity.profileFrameIcon, 
            profileFrameColorHex: entity.profileFrameColorHex, 
            liveFeedId: entity.liveFeedId, 
            website: entity.website, 
            workIndustryID: entity.workIndustryID, 
            workIndustryName: entity.workIndustryName, 
            workIndustryKey: entity.workIndustryKey, 
            relationshipID: entity.relationshipID, 
            relationshipName: entity.relationshipName, 
            relationshipKey: entity.relationshipKey, 
            countryKey: entity.countryKey, 
            countryID: entity.countryID, 
            countryHasChild: entity.countryHasChild, 
            provinceKey: entity.provinceKey, 
            provinceID: entity.provinceID, 
            provinceHasChild: entity.provinceHasChild, 
            cityKey: entity.cityKey, 
            cityID: entity.cityID, 
            checkinStatus: entity.checkinStatus, 
            checkinShowPoint: entity.checkinShowPoint
        )
    }

    /// Puts the UserSessionInfos in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [UserSessionInfo]) throws -> [UserSessionInfo] {
        let entityIds: [UserSessionInfo.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [UserSessionInfo]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(UserSessionInfo(
                id: entityId, 
                userIdentity: entity.userIdentity, 
                name: entity.name, 
                phone: entity.phone, 
                email: entity.email, 
                sex: entity.sex, 
                bio: entity.bio, 
                location: entity.location, 
                createDate: entity.createDate, 
                updateDate: entity.updateDate, 
                avatarUrl: entity.avatarUrl, 
                avatarMime: entity.avatarMime, 
                coverUrl: entity.coverUrl, 
                coverMime: entity.coverMime, 
                following: entity.following, 
                follower: entity.follower, 
                friendsCount: entity.friendsCount, 
                otpDevice: entity.otpDevice, 
                certificationStatus: entity.certificationStatus, 
                verificationIcon: entity.verificationIcon, 
                verificationType: entity.verificationType, 
                likesCount: entity.likesCount, 
                commentsCount: entity.commentsCount, 
                followersCount: entity.followersCount, 
                followingsCount: entity.followingsCount, 
                feedCount: entity.feedCount, 
                checkInCount: entity.checkInCount, 
                isRewardAcceptEnabled: entity.isRewardAcceptEnabled, 
                canSubscribe: entity.canSubscribe, 
                activitiesCount: entity.activitiesCount, 
                yippsTotal: entity.yippsTotal, 
                rewardsTotal: entity.rewardsTotal, 
                rebates: entity.rebates, 
                whiteListType: entity.whiteListType, 
                country: entity.country, 
                freeHotPost: entity.freeHotPost, 
                isLiveEnabled: entity.isLiveEnabled, 
                isMiniVideoEnabled: entity.isMiniVideoEnabled, 
                enableExternalRTMP: entity.enableExternalRTMP, 
                hasPin: entity.hasPin, 
                birthdate: entity.birthdate, 
                username: entity.username, 
                haslevelUpgraded: entity.haslevelUpgraded, 
                subscribingBadge: entity.subscribingBadge, 
                profileFrameIcon: entity.profileFrameIcon, 
                profileFrameColorHex: entity.profileFrameColorHex, 
                liveFeedId: entity.liveFeedId, 
                website: entity.website, 
                workIndustryID: entity.workIndustryID, 
                workIndustryName: entity.workIndustryName, 
                workIndustryKey: entity.workIndustryKey, 
                relationshipID: entity.relationshipID, 
                relationshipName: entity.relationshipName, 
                relationshipKey: entity.relationshipKey, 
                countryKey: entity.countryKey, 
                countryID: entity.countryID, 
                countryHasChild: entity.countryHasChild, 
                provinceKey: entity.provinceKey, 
                provinceID: entity.provinceID, 
                provinceHasChild: entity.provinceHasChild, 
                cityKey: entity.cityKey, 
                cityID: entity.cityID, 
                checkinStatus: entity.checkinStatus, 
                checkinShowPoint: entity.checkinShowPoint
            ))
        }

        return newEntities
    }
}


//extension YippsWantedService: ObjectBox.__EntityRelatable {
//    internal typealias EntityType = YippsWantedService
//
//    internal var _id: EntityId<YippsWantedService> {
//        return EntityId<YippsWantedService>(self.id.value)
//    }
//}
//
//extension YippsWantedService: ObjectBox.EntityInspectable {
//    internal typealias EntityBindingType = YippsWantedServiceBinding
//
//    /// Generated metadata used by ObjectBox to persist the entity.
//    internal static var entityInfo = ObjectBox.EntityInfo(name: "YippsWantedService", id: 6)
//
//    internal static var entityBinding = EntityBindingType()
//
//    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
//        let entityBuilder = try modelBuilder.entityBuilder(for: YippsWantedService.self, id: 6, uid: 8189445334808857856)
//        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id, .idSelfAssignable], id: 1, uid: 6543299063112804864)
//        try entityBuilder.addProperty(name: "module", type: PropertyType.string, id: 3, uid: 561646250383391488)
//        try entityBuilder.addProperty(name: "status", type: PropertyType.bool, id: 4, uid: 7953627886920071424)
//        try entityBuilder.addProperty(name: "slug", type: PropertyType.string, id: 5, uid: 8481128069931209984)
//        try entityBuilder.addProperty(name: "imageURL", type: PropertyType.string, id: 6, uid: 3416704040956456192)
//        try entityBuilder.addProperty(name: "actionType", type: PropertyType.string, id: 9, uid: 8480080742486813440)
//        try entityBuilder.addProperty(name: "actionExtra", type: PropertyType.string, id: 10, uid: 7418798056533105152)
//        try entityBuilder.addProperty(name: "translationKey", type: PropertyType.string, id: 11, uid: 4010744587415712768)
//
//        try entityBuilder.lastProperty(id: 11, uid: 4010744587415712768)
//    }
//}

//extension YippsWantedService {
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.id == myId }
//    internal static var id: Property<YippsWantedService, Id, Id> { return Property<YippsWantedService, Id, Id>(propertyId: 1, isPrimaryKey: true) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.module.startsWith("X") }
//    internal static var module: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 3, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.status > 1234 }
//    internal static var status: Property<YippsWantedService, Bool?, Void> { return Property<YippsWantedService, Bool?, Void>(propertyId: 4, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.slug.startsWith("X") }
//    internal static var slug: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 5, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.imageURL.startsWith("X") }
//    internal static var imageURL: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 6, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.actionType.startsWith("X") }
//    internal static var actionType: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 9, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.actionExtra.startsWith("X") }
//    internal static var actionExtra: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 10, isPrimaryKey: false) }
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { YippsWantedService.translationKey.startsWith("X") }
//    internal static var translationKey: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 11, isPrimaryKey: false) }
//
//    fileprivate func __setId(identifier: ObjectBox.Id) {
//        self.id = Id(identifier)
//    }
//}
//
//extension ObjectBox.Property where E == YippsWantedService {
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .id == myId }
//
//    internal static var id: Property<YippsWantedService, Id, Id> { return Property<YippsWantedService, Id, Id>(propertyId: 1, isPrimaryKey: true) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .module.startsWith("X") }
//
//    internal static var module: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 3, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .status > 1234 }
//
//    internal static var status: Property<YippsWantedService, Bool?, Void> { return Property<YippsWantedService, Bool?, Void>(propertyId: 4, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .slug.startsWith("X") }
//
//    internal static var slug: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 5, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .imageURL.startsWith("X") }
//
//    internal static var imageURL: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 6, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .actionType.startsWith("X") }
//
//    internal static var actionType: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 9, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .actionExtra.startsWith("X") }
//
//    internal static var actionExtra: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 10, isPrimaryKey: false) }
//
//    /// Generated entity property information.
//    ///
//    /// You may want to use this in queries to specify fetch conditions, for example:
//    ///
//    ///     box.query { .translationKey.startsWith("X") }
//
//    internal static var translationKey: Property<YippsWantedService, String?, Void> { return Property<YippsWantedService, String?, Void>(propertyId: 11, isPrimaryKey: false) }
//
//}
//
//
///// Generated service type to handle persisting and reading entity data. Exposed through `YippsWantedService.EntityBindingType`.
//internal class YippsWantedServiceBinding: ObjectBox.EntityBinding {
//    internal typealias EntityType = YippsWantedService
//    internal typealias IdType = Id
//
//    internal required init() {}
//
//    internal func generatorBindingVersion() -> Int { 1 }
//
//    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
//        entity.__setId(identifier: entityId)
//    }
//
//    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
//        return entity.id.value
//    }
//
//    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
//                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
//        let propertyOffset_module = propertyCollector.prepare(string: entity.module)
//        let propertyOffset_slug = propertyCollector.prepare(string: entity.slug)
//        let propertyOffset_imageURL = propertyCollector.prepare(string: entity.imageURL)
//        let propertyOffset_actionType = propertyCollector.prepare(string: entity.actionType)
//        let propertyOffset_actionExtra = propertyCollector.prepare(string: entity.actionExtra)
//        let propertyOffset_translationKey = propertyCollector.prepare(string: entity.translationKey)
//
//        propertyCollector.collect(id, at: 2 + 2 * 1)
//        propertyCollector.collect(entity.status, at: 2 + 2 * 4)
//        propertyCollector.collect(dataOffset: propertyOffset_module, at: 2 + 2 * 3)
//        propertyCollector.collect(dataOffset: propertyOffset_slug, at: 2 + 2 * 5)
//        propertyCollector.collect(dataOffset: propertyOffset_imageURL, at: 2 + 2 * 6)
//        propertyCollector.collect(dataOffset: propertyOffset_actionType, at: 2 + 2 * 9)
//        propertyCollector.collect(dataOffset: propertyOffset_actionExtra, at: 2 + 2 * 10)
//        propertyCollector.collect(dataOffset: propertyOffset_translationKey, at: 2 + 2 * 11)
//    }
//
//    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
//        let entity = YippsWantedService()
//
//        entity.id = entityReader.read(at: 2 + 2 * 1)
//        entity.module = entityReader.read(at: 2 + 2 * 3)
//        entity.status = entityReader.read(at: 2 + 2 * 4)
//        entity.slug = entityReader.read(at: 2 + 2 * 5)
//        entity.imageURL = entityReader.read(at: 2 + 2 * 6)
//        entity.actionType = entityReader.read(at: 2 + 2 * 9)
//        entity.actionExtra = entityReader.read(at: 2 + 2 * 10)
//        entity.translationKey = entityReader.read(at: 2 + 2 * 11)
//
//        return entity
//    }
//}


/// Helper function that allows calling Enum(rawValue: value) with a nil value, which will return nil.
fileprivate func optConstruct<T: RawRepresentable>(_ type: T.Type, rawValue: T.RawValue?) -> T? {
    guard let rawValue = rawValue else { return nil }
    return T(rawValue: rawValue)
}

// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try CountryEntity.buildEntity(modelBuilder: modelBuilder)
    try EventEntity.buildEntity(modelBuilder: modelBuilder)
    try FeedListModel.buildEntity(modelBuilder: modelBuilder)
    try FeedStoreModel.buildEntity(modelBuilder: modelBuilder)
    try HashtagModel.buildEntity(modelBuilder: modelBuilder)
    try LanguageEntity.buildEntity(modelBuilder: modelBuilder)
    try LiveEntityModel.buildEntity(modelBuilder: modelBuilder)
   // try LiveSubCategoryList.buildEntity(modelBuilder: modelBuilder)
    try TrendingPhotoModel.buildEntity(modelBuilder: modelBuilder)
    try UserInfoModel.buildEntity(modelBuilder: modelBuilder)
    try UserSessionInfo.buildEntity(modelBuilder: modelBuilder)
    //try YippsWantedService.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 25, uid: 1776807730205528832)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// # In-memory database
    /// To use a file-less in-memory database, instead of a directory path pass `memory:` 
    /// together with an identifier string:
    /// ```swift
    /// let inMemoryStore = try Store(directoryPath: "memory:test-db")
    /// ```
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store,
    ///     or to use an in-memory database `memory:<identifier>`.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120. So when hitting this limit, try values around 200-500.
    ///   - readOnly: Opens the database in read-only mode, i.e. not allowing write transactions.
    ///
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024,
                            fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders,
            readOnly: readOnly)
    }
}

// swiftlint:enable all
