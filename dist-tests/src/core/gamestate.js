"use strict";
/**
 * Game state management system
 * Centralized state with clear transitions
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.createGameState = createGameState;
const VALID_TRANSITIONS = {
    BOOT: ['LOADING', 'ERROR'],
    MENU: ['LOADING', 'ERROR'],
    LOADING: ['PLAYING', 'MENU', 'ERROR'],
    PLAYING: ['PAUSED', 'UPGRADING', 'PROCESSING', 'OFFLINE_REWARD', 'PRESTIGE', 'MENU', 'ERROR'],
    PAUSED: ['PLAYING', 'MENU', 'ERROR'],
    UPGRADING: ['PLAYING', 'PAUSED', 'ERROR'],
    PROCESSING: ['PLAYING', 'PAUSED', 'ERROR'],
    OFFLINE_REWARD: ['PLAYING', 'ERROR'],
    PRESTIGE: ['PLAYING', 'ERROR'],
    ERROR: ['BOOT', 'MENU']
};
function createGameState() {
    let currentState = 'BOOT';
    let previousState = null;
    return {
        get currentState() {
            return currentState;
        },
        get previousState() {
            return previousState;
        },
        canTransitionTo(target) {
            const validTargets = VALID_TRANSITIONS[currentState];
            return validTargets.includes(target);
        },
        transitionTo(target) {
            if (!this.canTransitionTo(target)) {
                console.warn(`Invalid state transition: ${currentState} -> ${target}`);
                return false;
            }
            previousState = currentState;
            currentState = target;
            console.log(`State transition: ${previousState} -> ${currentState}`);
            return true;
        }
    };
}
//# sourceMappingURL=gamestate.js.map