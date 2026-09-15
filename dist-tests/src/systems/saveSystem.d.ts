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
        hired: Record<string, number>;
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
export declare function createNewSave(): SaveData;
export declare function saveGame(data: SaveData): boolean;
export declare function loadGame(): SaveData | null;
export declare function hasSave(): boolean;
export declare function deleteSave(): boolean;
export declare function validateSaveData(data: any): data is SaveData;
export declare function getBackupSaveKey(): string;
export declare function createBackupSave(data: SaveData): boolean;
export declare function restoreBackupSave(): SaveData | null;
//# sourceMappingURL=saveSystem.d.ts.map