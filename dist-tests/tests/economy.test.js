"use strict";
/**
 * Economy system tests
 * Deterministic calculations for idle/offline production
 */
Object.defineProperty(exports, "__esModule", { value: true });
const economySystem_js_1 = require("../../src/systems/economySystem.js");
const resources_js_1 = require("../../src/data/resources.js");
const machines_js_1 = require("../../src/data/machines.js");
const workers_js_1 = require("../../src/data/workers.js");
let passedTests = 0;
let failedTests = 0;
function assert(condition, message) {
    if (condition) {
        passedTests++;
        console.log(`✓ ${message}`);
    }
    else {
        failedTests++;
        console.error(`✗ ${message}`);
    }
}
function assertEqual(actual, expected, message) {
    if (actual === expected) {
        passedTests++;
        console.log(`✓ ${message}`);
    }
    else {
        failedTests++;
        console.error(`✗ ${message} (expected: ${expected}, got: ${actual})`);
    }
}
// Test resource data integrity
console.log('\n=== Resource Data Tests ===');
const stone = resources_js_1.RESOURCES['stone'];
assert(stone !== undefined, 'Stone resource exists');
assertEqual(stone.id, 'stone', 'Stone has correct ID');
assertEqual(stone.rarity, 'common', 'Stone is common rarity');
assertEqual(stone.baseValue, 1, 'Stone base value is 1');
assertEqual(stone.unlockDepth, 0, 'Stone unlocks at depth 0');
const diamond = resources_js_1.RESOURCES['diamond'];
assert(diamond !== undefined, 'Diamond resource exists');
assertEqual(diamond.rarity, 'very_rare', 'Diamond is very_rare rarity');
assertEqual(diamond.baseValue, 500, 'Diamond base value is 500');
assertEqual(diamond.unlockDepth, 80, 'Diamond unlocks at depth 80');
// Test machine data integrity
console.log('\n=== Machine Data Tests ===');
const pickaxe = machines_js_1.MACHINES['pickaxe'];
assert(pickaxe !== undefined, 'Pickaxe machine exists');
assertEqual(pickaxe.type, 'extractor', 'Pickaxe is extractor type');
assertEqual(pickaxe.baseCost, 0, 'Pickaxe is free');
const crusher_t1 = machines_js_1.MACHINES['crusher_t1'];
assert(crusher_t1 !== undefined, 'Crusher T1 exists');
assertEqual(crusher_t1.type, 'processor', 'Crusher is processor type');
// Test worker data integrity
console.log('\n=== Worker Data Tests ===');
const novice_miner = workers_js_1.WORKERS['novice_miner'];
assert(novice_miner !== undefined, 'Novice Miner exists');
assertEqual(novice_miner.tier, 1, 'Novice Miner is tier 1');
assertEqual(novice_miner.efficiency, 0.8, 'Novice Miner efficiency is 0.8');
// Test economy calculations
console.log('\n=== Economy Calculation Tests ===');
// Test formatMoney
assertEqual((0, economySystem_js_1.formatMoney)(100), '$100', 'Format $100');
assertEqual((0, economySystem_js_1.formatMoney)(1500), '$1.50K', 'Format $1.5K');
assertEqual((0, economySystem_js_1.formatMoney)(2500000), '$2.50M', 'Format $2.5M');
assertEqual((0, economySystem_js_1.formatMoney)(3500000000), '$3.50B', 'Format $3.5B');
// Test offline time validation
const now = Date.now();
const oneHourAgo = now - (60 * 60 * 1000);
const validation = (0, economySystem_js_1.validateOfflineTime)(oneHourAgo);
assert(validation.valid, 'One hour ago is valid');
assertEqual(Math.round(validation.minutes), 60, 'One hour is ~60 minutes');
// Test negative time protection
const future = now + (60 * 60 * 1000);
const futureValidation = (0, economySystem_js_1.validateOfflineTime)(future);
assert(!futureValidation.valid, 'Future timestamp is invalid');
// Test absurd time protection
const thirtyDaysAgo = now - (31 * 24 * 60 * 60 * 1000);
const oldValidation = (0, economySystem_js_1.validateOfflineTime)(thirtyDaysAgo);
assert(!oldValidation.valid, '31 days ago is invalid (capped)');
// Test production calculation with basic state
console.log('\n=== Production Rate Tests ===');
const basicState = {
    cash: 100,
    resources: { stone: 0 },
    storageCapacity: 100,
    ownedMachines: ['pickaxe'],
    machineLevels: { pickaxe: 1 },
    hiredWorkers: {},
    currentDepth: 0,
    discoveredResources: ['stone']
};
const result = (0, economySystem_js_1.calculateProductionRate)(basicState, 1); // 1 minute
assert(result !== undefined, 'Production result exists');
assert(typeof result.moneyEarned === 'number', 'Money earned is a number');
assert(typeof result.wagesPaid === 'number', 'Wages paid is a number');
// Test that stone can be mined at depth 0
assert(result.resourcesMined['stone'] !== undefined, 'Stone can be mined');
// Test offline earnings calculation
console.log('\n=== Offline Earnings Tests ===');
const mockSaveData = {
    version: 1,
    timestamp: oneHourAgo,
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
        resources: { stone: 0 },
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
const offlineResult = (0, economySystem_js_1.calculateOfflineEarnings)(mockSaveData, 60);
assert(offlineResult !== undefined, 'Offline earnings calculated');
assert(typeof offlineResult.moneyEarned === 'number', 'Offline money is numeric');
// Test storage capacity limits
console.log('\n=== Storage Capacity Tests ===');
const fullStorageState = {
    ...basicState,
    resources: { stone: 100 }, // At capacity
    storageCapacity: 100
};
const fullResult = (0, economySystem_js_1.calculateProductionRate)(fullStorageState, 1);
assert(fullResult !== undefined, 'Production works with full storage');
// Summary
console.log('\n=== Test Summary ===');
console.log(`Passed: ${passedTests}`);
console.log(`Failed: ${failedTests}`);
console.log(`Total: ${passedTests + failedTests}`);
if (failedTests > 0) {
    process.exit(1);
}
else {
    console.log('\n✓ All tests passed!');
    process.exit(0);
}
//# sourceMappingURL=economy.test.js.map