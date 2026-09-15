/**
 * Machine definitions for the mining tycoon game
 * Data-driven architecture - add new machines without modifying gameplay systems
 */
export interface MachineDef {
    id: string;
    name: string;
    type: 'extractor' | 'processor' | 'transport' | 'storage';
    tier: number;
    baseCost: number;
    upgradeCostMultiplier: number;
    productionRate: number;
    powerConsumption: number;
    workerSlots: number;
    unlockRequirement: {
        depth?: number;
        cash?: number;
        machineId?: string;
    } | null;
    description: string;
}
export declare const MACHINES: Record<string, MachineDef>;
export declare function getMachineById(id: string): MachineDef | undefined;
export declare function getMachinesByType(type: MachineDef['type']): MachineDef[];
export declare function getAvailableMachines(cash: number, depth: number, ownedMachines: string[]): MachineDef[];
export declare function calculateMachineUpgradeCost(machineId: string, currentLevel: number): number;
//# sourceMappingURL=machines.d.ts.map