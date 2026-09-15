/**
 * Save/Load system with versioned schema and migrations
 */

export interface SaveData {
  version: number;
  timestamp: number;
  player: {
    cash: number;
    totalEarned: number;
    totalMined: number;
    prestigeCount: number;
    prestigeCurrency: number;
  };
  world: {
    currentDepth: number;
    maxDepthReached: number;
    discoveredResources: string[];
  };
  inventory: {
    resources: Record<string, number>;
    storageCapacity: number;
  };
  machines: {
    owned: string[];
    levels: Record<string, number>;
    assignedWorkers: Record<string, string[]>;
  };
  workers: {
    hired: Record<string, number>; // workerId -> count
  };
  upgrades: {
    purchased: string[];
  };
  settings: {
    musicVolume: number;
    sfxVolume: number;
    notificationsEnabled: boolean;
  };
}

const SAVE_VERSION = 1;
const SAVE_KEY = 'mining_tycoon_save';

const DEFAULT_SAVE: SaveData = {
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

export function createNewSave(): SaveData {
  return JSON.parse(JSON.stringify(DEFAULT_SAVE));
}

export function saveGame(data: SaveData): boolean {
  try {
    data.timestamp = Date.now();
    data.version = SAVE_VERSION;
    localStorage.setItem(SAVE_KEY, JSON.stringify(data));
    return true;
  } catch (e) {
    console.error('Failed to save game:', e);
    return false;
  }
}

export function loadGame(): SaveData | null {
  try {
    const saved = localStorage.getItem(SAVE_KEY);
    if (!saved) return null;
    
    const data = JSON.parse(saved) as SaveData;
    return migrateSave(data);
  } catch (e) {
    console.error('Failed to load game:', e);
    return null;
  }
}

export function hasSave(): boolean {
  return localStorage.getItem(SAVE_KEY) !== null;
}

export function deleteSave(): boolean {
  try {
    localStorage.removeItem(SAVE_KEY);
    return true;
  } catch (e) {
    console.error('Failed to delete save:', e);
    return false;
  }
}

// Migration system for save version updates
function migrateSave(data: SaveData): SaveData {
  if (!data.version) {
    // Version 0 migration (if needed in future)
    data.version = 1;
  }
  
  // Add future migrations here
  // if (data.version === 1) { ... migrate to v2 ... }
  
  return data;
}

export function validateSaveData(data: any): data is SaveData {
  if (!data || typeof data !== 'object') return false;
  if (!data.version || !data.timestamp) return false;
  if (!data.player || typeof data.player !== 'object') return false;
  if (!data.world || typeof data.world !== 'object') return false;
  if (!data.inventory || typeof data.inventory !== 'object') return false;
  if (!data.machines || typeof data.machines !== 'object') return false;
  
  // Validate critical fields
  if (typeof data.player.cash !== 'number') return false;
  if (!Array.isArray(data.machines.owned)) return false;
  if (!data.inventory.resources || typeof data.inventory.resources !== 'object') return false;
  
  return true;
}

export function getBackupSaveKey(): string {
  return `${SAVE_KEY}_backup`;
}

export function createBackupSave(data: SaveData): boolean {
  try {
    localStorage.setItem(getBackupSaveKey(), JSON.stringify(data));
    return true;
  } catch (e) {
    console.error('Failed to create backup save:', e);
    return false;
  }
}

export function restoreBackupSave(): SaveData | null {
  try {
    const saved = localStorage.getItem(getBackupSaveKey());
    if (!saved) return null;
    return JSON.parse(saved) as SaveData;
  } catch (e) {
    console.error('Failed to restore backup save:', e);
    return null;
  }
}
