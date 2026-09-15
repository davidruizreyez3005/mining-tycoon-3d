/**
 * Economy simulation system
 * Deterministic calculations for idle/offline production
 */
import type { SaveData } from '../systems/saveSystem';
export interface ProductionResult {
    resourcesMined: Record<string, number>;
    resourcesProcessed: Record<string, number>;
    resourcesSold: Record<string, number>;
    moneyEarned: number;
    wagesPaid: number;
    rareDiscoveries: string[];
}
export interface EconomyState {
    cash: number;
    resources: Record<string, number>;
    storageCapacity: number;
    ownedMachines: string[];
    machineLevels: Record<string, number>;
    hiredWorkers: Record<string, number>;
    currentDepth: number;
    discoveredResources: string[];
}
export declare function calculateProductionRate(state: EconomyState, deltaTimeMinutes: number): ProductionResult;
export declare function calculateOfflineEarnings(saveData: SaveData, offlineMinutes: number): ProductionResult;
export declare function validateOfflineTime(timestamp: number): {
    valid: boolean;
    minutes: number;
};
export declare function formatMoney(amount: number): string;
export declare function formatNumber(num: number): string;
//# sourceMappingURL=economySystem.d.ts.map