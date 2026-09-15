"use strict";
/**
 * Save/Load system with versioned schema and migrations
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.createNewSave = createNewSave;
exports.saveGame = saveGame;
exports.loadGame = loadGame;
exports.hasSave = hasSave;
exports.deleteSave = deleteSave;
exports.validateSaveData = validateSaveData;
exports.getBackupSaveKey = getBackupSaveKey;
exports.createBackupSave = createBackupSave;
exports.restoreBackupSave = restoreBackupSave;
const SAVE_VERSION = 1;
const SAVE_KEY = 'mining_tycoon_save';
const DEFAULT_SAVE = {
    version: SAVE_VERSION,
    timestamp: Date.now(),
    player: {
        cash: 100,
        totalEarned: 0,
        totalMined: 0,
        prestigeCount: 0,
        prestigeCurrency: 0
    },
    world: {
        currentDepth: 0,
        maxDepthReached: 0,
        discoveredResources: ['stone']
    },
    inventory: {
        resources: {},
        storageCapacity: 100
    },
    machines: {
        owned: ['pickaxe'],
        levels: { pickaxe: 1 },
        assignedWorkers: {}
    },
    workers: {
        hired: {}
    },
    upgrades: {
        purchased: []
    },
    settings: {
        musicVolume: 0.5,
        sfxVolume: 0.8,
        notificationsEnabled: true
    }
};
function createNewSave() {
    return JSON.parse(JSON.stringify(DEFAULT_SAVE));
}
function saveGame(data) {
    try {
        data.timestamp = Date.now();
        data.version = SAVE_VERSION;
        localStorage.setItem(SAVE_KEY, JSON.stringify(data));
        return true;
    }
    catch (e) {
        console.error('Failed to save game:', e);
        return false;
    }
}
function loadGame() {
    try {
        const saved = localStorage.getItem(SAVE_KEY);
        if (!saved)
            return null;
        const data = JSON.parse(saved);
        return migrateSave(data);
    }
    catch (e) {
        console.error('Failed to load game:', e);
        return null;
    }
}
function hasSave() {
    return localStorage.getItem(SAVE_KEY) !== null;
}
function deleteSave() {
    try {
        localStorage.removeItem(SAVE_KEY);
        return true;
    }
    catch (e) {
        console.error('Failed to delete save:', e);
        return false;
    }
}
// Migration system for save version updates
function migrateSave(data) {
    if (!data.version) {
        // Version 0 migration (if needed in future)
        data.version = 1;
    }
    // Add future migrations here
    // if (data.version === 1) { ... migrate to v2 ... }
    return data;
}
function validateSaveData(data) {
    if (!data || typeof data !== 'object')
        return false;
    if (!data.version || !data.timestamp)
        return false;
    if (!data.player || typeof data.player !== 'object')
        return false;
    if (!data.world || typeof data.world !== 'object')
        return false;
    if (!data.inventory || typeof data.inventory !== 'object')
        return false;
    if (!data.machines || typeof data.machines !== 'object')
        return false;
    // Validate critical fields
    if (typeof data.player.cash !== 'number')
        return false;
    if (!Array.isArray(data.machines.owned))
        return false;
    if (!data.inventory.resources || typeof data.inventory.resources !== 'object')
        return false;
    return true;
}
function getBackupSaveKey() {
    return `${SAVE_KEY}_backup`;
}
function createBackupSave(data) {
    try {
        localStorage.setItem(getBackupSaveKey(), JSON.stringify(data));
        return true;
    }
    catch (e) {
        console.error('Failed to create backup save:', e);
        return false;
    }
}
function restoreBackupSave() {
    try {
        const saved = localStorage.getItem(getBackupSaveKey());
        if (!saved)
            return null;
        return JSON.parse(saved);
    }
    catch (e) {
        console.error('Failed to restore backup save:', e);
        return null;
    }
}
//# sourceMappingURL=saveSystem.js.map