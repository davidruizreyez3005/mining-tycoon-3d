/**
 * Resource definitions for the mining tycoon game
 * Data-driven architecture - add new resources without modifying gameplay systems
 */
export interface ResourceDef {
    id: string;
    name: string;
    rarity: 'common' | 'uncommon' | 'rare' | 'very_rare' | 'legendary';
    baseValue: number;
    extractionDifficulty: number;
    processingRequirement: string | null;
    unlockDepth: number;
    visualMaterial: string;
    productionModifiers: {
        workerEfficiency?: number;
        machineSpeed?: number;
        valueMultiplier?: number;
    };
}
export declare const RESOURCES: Record<string, ResourceDef>;
export declare function getResourceById(id: string): ResourceDef | undefined;
export declare function getResourcesByRarity(rarity: ResourceDef['rarity']): ResourceDef[];
export declare function getAvailableResourcesAtDepth(depth: number): ResourceDef[];
export declare function calculateResourceValue(resourceId: string, modifiers?: {
    valueMultiplier?: number;
}): number;
//# sourceMappingURL=resources.d.ts.map