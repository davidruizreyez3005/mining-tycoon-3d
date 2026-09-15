/**
 * Economy simulation system
 * Deterministic calculations for idle/offline production
 */

import { RESOURCES, calculateResourceValue } from '../data/resources';
import { MACHINES, getMachineById } from '../data/machines';
import { WORKERS, getWorkerById } from '../data/workers';
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

export function calculateProductionRate(
  state: EconomyState,
  deltaTimeMinutes: number
): ProductionResult {
  const result: ProductionResult = {
    resourcesMined: {},
    resourcesProcessed: {},
    resourcesSold: {},
    moneyEarned: 0,
    wagesPaid: 0,
    rareDiscoveries: []
  };

  // Calculate worker efficiency bonuses
  let extractionBonus = 0;
  let processingBonus = 0;
  let transportBonus = 0;

  for (const [workerId, count] of Object.entries(state.hiredWorkers)) {
    const worker = getWorkerById(workerId);
    if (!worker) continue;

    // Pay wages
    result.wagesPaid += worker.wagePerMinute * count * deltaTimeMinutes;

    // Apply skill bonuses
    if (worker.skillBonus.extraction) {
      extractionBonus += worker.skillBonus.extraction * count;
    }
    if (worker.skillBonus.processing) {
      processingBonus += worker.skillBonus.processing * count;
    }
    if (worker.skillBonus.transport) {
      transportBonus += worker.skillBonus.transport * count;
    }
  }

  // Calculate mining production from extractors
  const extractorMachines = state.ownedMachines.filter(id => {
    const machine = getMachineById(id);
    return machine?.type === 'extractor';
  });

  for (const machineId of extractorMachines) {
    const machine = getMachineById(machineId);
    if (!machine) continue;

    const level = state.machineLevels[machineId] || 1;
    let baseRate = machine.productionRate * level;

    // Apply worker bonus if workers assigned
    const assignedWorkers = state.machineLevels[`${machineId}_workers`] || 0;
    if (assignedWorkers > 0) {
      baseRate *= (1 + extractionBonus);
    }

    // Determine what resources can be mined at current depth
    const availableResources = Object.values(RESOURCES).filter(
      r => r.unlockDepth <= state.currentDepth
    );

    if (availableResources.length > 0) {
      // Distribute production among available resources
      const resourcesPerType = baseRate / availableResources.length;
      
      for (const resource of availableResources) {
        const extractionFactor = 1 - resource.extractionDifficulty;
        const amount = resourcesPerType * extractionFactor * deltaTimeMinutes;
        
        result.resourcesMined[resource.id] = (result.resourcesMined[resource.id] || 0) + amount;
        
        // Check for rare discovery
        if (resource.rarity === 'rare' || resource.rarity === 'very_rare') {
          if (Math.random() < 0.01 * deltaTimeMinutes) {
            result.rareDiscoveries.push(resource.name);
          }
        }
      }
    }
  }

  // Add mined resources to inventory (respecting storage capacity)
  let totalResources = 0;
  for (const [resourceId, amount] of Object.entries(state.resources)) {
    totalResources += amount;
  }

  for (const [resourceId, amount] of Object.entries(result.resourcesMined)) {
    const availableSpace = state.storageCapacity - totalResources;
    const actualAmount = Math.min(amount, availableSpace);
    
    if (actualAmount > 0) {
      result.resourcesMined[resourceId] = actualAmount;
      state.resources[resourceId] = (state.resources[resourceId] || 0) + actualAmount;
      totalResources += actualAmount;
    } else {
      result.resourcesMined[resourceId] = 0;
    }
  }

  // Calculate processing (convert raw ore to refined)
  const processorMachines = state.ownedMachines.filter(id => {
    const machine = getMachineById(id);
    return machine?.type === 'processor';
  });

  let totalProcessingCapacity = 0;
  for (const machineId of processorMachines) {
    const machine = getMachineById(machineId);
    if (!machine) continue;

    const level = state.machineLevels[machineId] || 1;
    totalProcessingCapacity += machine.productionRate * level * (1 + processingBonus);
  }

  // Process resources that need it
  for (const [resourceId, amount] of Object.entries(state.resources)) {
    const resource = RESOURCES[resourceId];
    if (!resource || !resource.processingRequirement) continue;

    if (state.ownedMachines.includes(resource.processingRequirement)) {
      const processedAmount = Math.min(amount, totalProcessingCapacity * deltaTimeMinutes);
      if (processedAmount > 0) {
        result.resourcesProcessed[resourceId] = processedAmount;
        state.resources[resourceId] -= processedAmount;
        totalProcessingCapacity -= processedAmount / deltaTimeMinutes;
      }
    }
  }

  // Calculate selling (automatic sale of excess resources)
  const sellableResources = Object.entries(state.resources).filter(([_, amount]) => amount > 0);
  
  for (const [resourceId, amount] of sellableResources) {
    const value = calculateResourceValue(resourceId);
    const soldAmount = amount; // Sell all for now
    
    if (soldAmount > 0) {
      result.resourcesSold[resourceId] = soldAmount;
      result.moneyEarned += soldAmount * value;
      state.resources[resourceId] = 0;
    }
  }

  // Net earnings
  result.moneyEarned -= result.wagesPaid;
  state.cash += result.moneyEarned;

  return result;
}

export function calculateOfflineEarnings(
  saveData: SaveData,
  offlineMinutes: number
): ProductionResult {
  // Cap offline time to prevent abuse (max 24 hours)
  const cappedMinutes = Math.min(offlineMinutes, 24 * 60);
  
  const economyState: EconomyState = {
    cash: saveData.player.cash,
    resources: { ...saveData.inventory.resources },
    storageCapacity: saveData.inventory.storageCapacity,
    ownedMachines: saveData.machines.owned,
    machineLevels: saveData.machines.levels,
    hiredWorkers: saveData.workers.hired,
    currentDepth: saveData.world.currentDepth,
    discoveredResources: saveData.world.discoveredResources
  };

  return calculateProductionRate(economyState, cappedMinutes);
}

export function validateOfflineTime(timestamp: number): { valid: boolean; minutes: number } {
  const now = Date.now();
  const elapsedMs = now - timestamp;
  const elapsedMinutes = elapsedMs / (1000 * 60);

  // Protect against negative time
  if (elapsedMinutes < 0) {
    return { valid: false, minutes: 0 };
  }

  // Protect against absurd elapsed time (> 30 days)
  if (elapsedMinutes > 30 * 24 * 60) {
    return { valid: false, minutes: 30 * 24 * 60 };
  }

  return { valid: true, minutes: elapsedMinutes };
}

export function formatMoney(amount: number): string {
  if (amount >= 1e9) return `$${(amount / 1e9).toFixed(2)}B`;
  if (amount >= 1e6) return `$${(amount / 1e6).toFixed(2)}M`;
  if (amount >= 1e3) return `$${(amount / 1e3).toFixed(2)}K`;
  return `$${Math.floor(amount)}`;
}

export function formatNumber(num: number): string {
  if (num >= 1e9) return `${(num / 1e9).toFixed(2)}B`;
  if (num >= 1e6) return `${(num / 1e6).toFixed(2)}M`;
  if (num >= 1e3) return `${(num / 1e3).toFixed(2)}K`;
  return `${Math.floor(num)}`;
}
