import Carbon.HIToolbox
import AppKit

/// Registers system-wide keyboard shortcuts via Carbon's `RegisterEventHotKey`
/// and reports presses. Native, no third-party dependencies.
///
/// The Carbon hot-key event handler runs on the main thread, so `onAction` is
/// always delivered there.
final class GlobalHotKeyManager {

    /// Called when a registered shortcut fires.
    var onAction: ((HotKeyAction) -> Void)?

    private var handlerRef: EventHandlerRef?
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var actionForID: [UInt32: HotKeyAction] = [:]
    private var nextID: UInt32 = 1
    private let signature: OSType = 0x534F_4D41 // 'SOMA'

    init() {
        installHandler()
    }

    deinit {
        unregisterAll()
        if let handlerRef { RemoveEventHandler(handlerRef) }
    }

    /// Re-register the full set of shortcuts, replacing any previous ones.
    func update(_ combos: [HotKeyAction: KeyCombo]) {
        unregisterAll()
        for (action, combo) in combos {
            register(action: action, combo: combo)
        }
    }

    // MARK: - Private

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let userData, let event else { return noErr }
            let manager = Unmanaged<GlobalHotKeyManager>.fromOpaque(userData).takeUnretainedValue()

            var hkID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            manager.fire(id: hkID.id)
            return noErr
        }, 1, &eventType, selfPtr, &handlerRef)
    }

    private func fire(id: UInt32) {
        guard let action = actionForID[id] else { return }
        onAction?(action)
    }

    private func register(action: HotKeyAction, combo: KeyCombo) {
        let id = nextID
        nextID += 1

        var hotKeyRef: EventHotKeyRef?
        let hkID = EventHotKeyID(signature: signature, id: id)
        let status = RegisterEventHotKey(combo.keyCode, combo.modifiers, hkID,
                                         GetApplicationEventTarget(), 0, &hotKeyRef)
        if status == noErr, let hotKeyRef {
            hotKeyRefs[id] = hotKeyRef
            actionForID[id] = action
        }
    }

    private func unregisterAll() {
        for ref in hotKeyRefs.values { UnregisterEventHotKey(ref) }
        hotKeyRefs.removeAll()
        actionForID.removeAll()
        nextID = 1
    }
}
