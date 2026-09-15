"use strict";
/**
 * Resource definitions for the mining tycoon game
 * Data-driven architecture - add new resources without modifying gameplay systems
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.RESOURCES = void 0;
exports.getResourceById = getResourceById;
exports.getResourcesByRarity = getResourcesByRarity;
exports.getAvailableResourcesAtDepth = getAvailableResourcesAtDepth;
exports.calculateResourceValue = calculateResourceValue;
exports.RESOURCES = {
    // Common resources
    stone: {
        id: 'stone',
        name: 'Stone',
        rarity: 'common',
        baseValue: 1,
        extractionDifficulty: 0.1,
        processingRequirement: null,
        unlockDepth: 0,
        visualMaterial: 'stone_material',
        productionModifiers: {}
    },
    coal: {
        id: 'coal',
        name: 'Coal',
        rarity: 'common',
        baseValue: 3,
        extractionDifficulty: 0.2,
        processingRequirement: null,
        unlockDepth: 5,
        visualMaterial: 'coal_material',
        productionModifiers: {}
    },
    copper: {
        id: 'copper',
        name: 'Copper Ore',
        rarity: 'common',
        baseValue: 8,
        extractionDifficulty: 0.3,
        processingRequirement: 'crusher_t1',
        unlockDepth: 10,
        visualMaterial: 'copper_material',
        productionModifiers: {}
    },
    iron: {
        id: 'iron',
        name: 'Iron Ore',
        rarity: 'common',
        baseValue: 12,
        extractionDifficulty: 0.4,
        processingRequirement: 'crusher_t1',
        unlockDepth: 15,
        visualMaterial: 'iron_material',
        productionModifiers: {}
    },
    // Uncommon resources
    silver: {
        id: 'silver',
        name: 'Silver Ore',
        rarity: 'uncommon',
        baseValue: 25,
        extractionDifficulty: 0.5,
        processingRequirement: 'crusher_t2',
        unlockDepth: 25,
        visualMaterial: 'silver_material',
        productionModifiers: {}
    },
    gold: {
        id: 'gold',
        name: 'Gold Ore',
        rarity: 'uncommon',
        baseValue: 50,
        extractionDifficulty: 0.6,
        processingRequirement: 'crusher_t2',
        unlockDepth: 35,
        visualMaterial: 'gold_material',
        productionModifiers: {}
    },
    quartz: {
        id: 'quartz',
        name: 'Quartz Crystal',
        rarity: 'uncommon',
        baseValue: 35,
        extractionDifficulty: 0.55,
        processingRequirement: null,
        unlockDepth: 30,
        visualMaterial: 'quartz_material',
        productionModifiers: { valueMultiplier: 1.1 }
    },
    // Rare resources
    platinum: {
        id: 'platinum',
        name: 'Platinum Ore',
        rarity: 'rare',
        baseValue: 100,
        extractionDifficulty: 0.7,
        processingRequirement: 'crusher_t3',
        unlockDepth: 50,
        visualMaterial: 'platinum_material',
        productionModifiers: {}
    },
    emerald: {
        id: 'emerald',
        name: 'Emerald Crystal',
        rarity: 'rare',
        baseValue: 150,
        extractionDifficulty: 0.75,
        processingRequirement: null,
        unlockDepth: 55,
        visualMaterial: 'emerald_material',
        productionModifiers: { valueMultiplier: 1.2 }
    },
    ruby: {
        id: 'ruby',
        name: 'Ruby Crystal',
        rarity: 'rare',
        baseValue: 175,
        extractionDifficulty: 0.78,
        processingRequirement: null,
        unlockDepth: 60,
        visualMaterial: 'ruby_material',
        productionModifiers: { valueMultiplier: 1.2 }
    },
    sapphire: {
        id: 'sapphire',
        name: 'Sapphire Crystal',
        rarity: 'rare',
        baseValue: 180,
        extractionDifficulty: 0.8,
        processingRequirement: null,
        unlockDepth: 65,
        visualMaterial: 'sapphire_material',
        productionModifiers: { valueMultiplier: 1.2 }
    },
    // Very rare resources
    diamond: {
        id: 'diamond',
        name: 'Diamond',
        rarity: 'very_rare',
        baseValue: 500,
        extractionDifficulty: 0.9,
        processingRequirement: 'crusher_t4',
        unlockDepth: 80,
        visualMaterial: 'diamond_material',
        productionModifiers: { valueMultiplier: 1.5 }
    }
};
function getResourceById(id) {
    return exports.RESOURCES[id];
}
function getResourcesByRarity(rarity) {
    return Object.values(exports.RESOURCES).filter(r => r.rarity === rarity);
}
function getAvailableResourcesAtDepth(depth) {
    return Object.values(exports.RESOURCES).filter(r => r.unlockDepth <= depth);
}
function calculateResourceValue(resourceId, modifiers = {}) {
    const resource = getResourceById(resourceId);
    if (!resource)
        return 0;
    let value = resource.baseValue;
    if (resource.productionModifiers.valueMultiplier) {
        value *= resource.productionModifiers.valueMultiplier;
    }
    if (modifiers.valueMultiplier) {
        value *= modifiers.valueMultiplier;
    }
    return Math.floor(value);
}
//# sourceMappingURL=resources.js.map