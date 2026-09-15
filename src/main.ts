/**
 * Main entry point for 3D Miner Mania
 */

import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { createGameState } from './core/gamestate';
import { loadGame, saveGame, hasSave, createNewSave, type SaveData } from './systems/saveSystem';
import { calculateOfflineEarnings, validateOfflineTime, formatMoney } from './systems/economySystem';
import { RESOURCES } from './data/resources';

// Game state
const gameState = createGameState();
let saveData: SaveData | null = null;
let lastSaveTime = Date.now();

// Three.js setup
let scene: THREE.Scene;
let camera: THREE.PerspectiveCamera;
let renderer: THREE.WebGLRenderer;
let clock: THREE.Clock;

// Mining scene objects
let mineGroup: THREE.Group;
let playerPosition: THREE.Vector3;

// Touch controls
let isDragging = false;
let previousTouchX = 0;
let previousTouchY = 0;
let cameraAngle = Math.PI / 4;
let cameraDistance = 15;
let cameraHeight = 10;

// Production tracking
let productionAccumulator = 0;
const PRODUCTION_TICK_MS = 1000; // Update production every second

function init() {
  console.log('Initializing 3D Miner Mania...');
  
  // Update loading progress
  updateLoadingProgress(20);
  
  // Create scene
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x87ceeb);
  scene.fog = new THREE.Fog(0x87ceeb, 20, 50);
  
  // Create camera
  const aspect = window.innerWidth / window.innerHeight;
  camera = new THREE.PerspectiveCamera(60, aspect, 0.1, 1000);
  updateCamera();
  
  // Create renderer
  renderer = new THREE.WebGLRenderer({ 
    antialias: true,
    powerPreference: 'high-performance'
  });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  
  const container = document.getElementById('canvas-container');
  if (container) {
    container.appendChild(renderer.domElement);
  }
  
  updateLoadingProgress(40);
  
  // Setup lighting
  setupLighting();
  
  // Create world
  createWorld();
  
  updateLoadingProgress(60);
  
  // Load or create save
  loadOrCreateSave();
  
  updateLoadingProgress(80);
  
  // Setup input handlers
  setupInputHandlers();
  
  // Setup UI handlers
  setupUIHandlers();
  
  updateLoadingProgress(100);
  
  // Start game loop
  clock = new THREE.Clock();
  gameState.transitionTo('PLAYING');
  
  // Hide loading screen
  setTimeout(() => {
    const loadingScreen = document.getElementById('loading-screen');
    const hud = document.getElementById('hud');
    if (loadingScreen) loadingScreen.classList.add('hidden');
    if (hud) hud.style.display = 'block';
    
    updateHUD();
  }, 500);
  
  // Start render loop
  animate();
  
  // Auto-save every 30 seconds
  setInterval(autoSave, 30000);
}

function setupLighting() {
  // Ambient light
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
  scene.add(ambientLight);
  
  // Directional light (sun)
  const sunLight = new THREE.DirectionalLight(0xffffff, 0.8);
  sunLight.position.set(20, 30, 20);
  sunLight.castShadow = true;
  sunLight.shadow.mapSize.width = 2048;
  sunLight.shadow.mapSize.height = 2048;
  sunLight.shadow.camera.near = 0.5;
  sunLight.shadow.camera.far = 100;
  sunLight.shadow.camera.left = -25;
  sunLight.shadow.camera.right = 25;
  sunLight.shadow.camera.top = 25;
  sunLight.shadow.camera.bottom = -25;
  scene.add(sunLight);
  
  // Hemisphere light for sky/ground color variation
  const hemiLight = new THREE.HemisphereLight(0x87ceeb, 0x8b4513, 0.3);
  scene.add(hemiLight);
}

function createWorld() {
  mineGroup = new THREE.Group();
  
  // Create ground
  const groundGeometry = new THREE.PlaneGeometry(50, 50);
  const groundMaterial = new THREE.MeshStandardMaterial({ 
    color: 0x8b4513,
    roughness: 0.9
  });
  const ground = new THREE.Mesh(groundGeometry, groundMaterial);
  ground.rotation.x = -Math.PI / 2;
  ground.receiveShadow = true;
  mineGroup.add(ground);
  
  // Create mine entrance
  createMineEntrance();
  
  // Create some basic props
  createRocks();
  createTrees();
  
  scene.add(mineGroup);
  
  // Set player position near mine entrance
  playerPosition = new THREE.Vector3(0, 0, 5);
}

function createMineEntrance() {
  // Simple wooden frame for mine entrance
  const woodMaterial = new THREE.MeshStandardMaterial({ color: 0x654321 });
  
  // Entrance frame
  const frameGeo = new THREE.BoxGeometry(3, 2.5, 0.3);
  const frameTop = new THREE.Mesh(frameGeo, woodMaterial);
  frameTop.position.set(0, 2.35, 0);
  frameTop.castShadow = true;
  mineGroup.add(frameTop);
  
  const frameLeft = new THREE.Mesh(new THREE.BoxGeometry(0.3, 2.5, 0.3), woodMaterial);
  frameLeft.position.set(-1.35, 1.25, 0);
  frameLeft.castShadow = true;
  mineGroup.add(frameLeft);
  
  const frameRight = new THREE.Mesh(new THREE.BoxGeometry(0.3, 2.5, 0.3), woodMaterial);
  frameRight.position.set(1.35, 1.25, 0);
  frameRight.castShadow = true;
  mineGroup.add(frameRight);
  
  // Dark tunnel opening
  const tunnelGeo = new THREE.CylinderGeometry(1.2, 1.2, 2, 8);
  const tunnelMat = new THREE.MeshStandardMaterial({ color: 0x1a1a1a });
  const tunnel = new THREE.Mesh(tunnelGeo, tunnelMat);
  tunnel.rotation.z = Math.PI / 2;
  tunnel.position.set(0, 1, 1);
  mineGroup.add(tunnel);
}

function createRocks() {
  const rockMaterial = new THREE.MeshStandardMaterial({ 
    color: 0x696969,
    roughness: 0.9
  });
  
  const positions = [
    { x: -5, z: -3, s: 0.8 },
    { x: 5, z: -5, s: 1.2 },
    { x: -3, z: 5, s: 0.6 },
    { x: 4, z: 4, s: 0.9 }
  ];
  
  positions.forEach(pos => {
    const rockGeo = new THREE.DodecahedronGeometry(pos.s, 0);
    const rock = new THREE.Mesh(rockGeo, rockMaterial);
    rock.position.set(pos.x, pos.s / 2, pos.z);
    rock.castShadow = true;
    rock.receiveShadow = true;
    mineGroup.add(rock);
  });
}

function createTrees() {
  const trunkMat = new THREE.MeshStandardMaterial({ color: 0x654321 });
  const leavesMat = new THREE.MeshStandardMaterial({ color: 0x228b22 });
  
  const positions = [
    { x: -8, z: -8 },
    { x: 8, z: -6 },
    { x: -7, z: 8 },
    { x: 7, z: 7 }
  ];
  
  positions.forEach(pos => {
    const tree = new THREE.Group();
    
    const trunkGeo = new THREE.CylinderGeometry(0.2, 0.3, 1.5, 6);
    const trunk = new THREE.Mesh(trunkGeo, trunkMat);
    trunk.position.y = 0.75;
    trunk.castShadow = true;
    tree.add(trunk);
    
    const leavesGeo = new THREE.ConeGeometry(1, 2, 6);
    const leaves = new THREE.Mesh(leavesGeo, leavesMat);
    leaves.position.y = 2.5;
    leaves.castShadow = true;
    tree.add(leaves);
    
    tree.position.set(pos.x, 0, pos.z);
    mineGroup.add(tree);
  });
}

function updateCamera() {
  const x = cameraDistance * Math.sin(cameraAngle);
  const z = cameraDistance * Math.cos(cameraAngle);
  camera.position.set(x, cameraHeight, z);
  camera.lookAt(0, 0, 0);
}

function setupInputHandlers() {
  // Touch/mouse drag for camera rotation
  const canvas = renderer.domElement;
  
  canvas.addEventListener('touchstart', handleTouchStart, { passive: false });
  canvas.addEventListener('touchmove', handleTouchMove, { passive: false });
  canvas.addEventListener('touchend', handleTouchEnd);
  
  canvas.addEventListener('mousedown', handleMouseDown);
  canvas.addEventListener('mousemove', handleMouseMove);
  canvas.addEventListener('mouseup', handleMouseUp);
  
  // Handle resize
  window.addEventListener('resize', onWindowResize);
}

function handleTouchStart(e: TouchEvent) {
  e.preventDefault();
  isDragging = true;
  previousTouchX = e.touches[0].clientX;
  previousTouchY = e.touches[0].clientY;
}

function handleTouchMove(e: TouchEvent) {
  e.preventDefault();
  if (!isDragging) return;
  
  const deltaX = e.touches[0].clientX - previousTouchX;
  const deltaY = e.touches[0].clientY - previousTouchY;
  
  cameraAngle -= deltaX * 0.005;
  cameraDistance = Math.max(8, Math.min(25, cameraDistance + deltaY * 0.02));
  
  updateCamera();
  
  previousTouchX = e.touches[0].clientX;
  previousTouchY = e.touches[0].clientY;
}

function handleTouchEnd() {
  isDragging = false;
}

function handleMouseDown(e: MouseEvent) {
  isDragging = true;
  previousTouchX = e.clientX;
  previousTouchY = e.clientY;
}

function handleMouseMove(e: MouseEvent) {
  if (!isDragging) return;
  
  const deltaX = e.clientX - previousTouchX;
  const deltaY = e.clientY - previousTouchY;
  
  cameraAngle -= deltaX * 0.005;
  cameraDistance = Math.max(8, Math.min(25, cameraDistance + deltaY * 0.02));
  
  updateCamera();
  
  previousTouchX = e.clientX;
  previousTouchY = e.clientY;
}

function handleMouseUp() {
  isDragging = false;
}

function onWindowResize() {
  const aspect = window.innerWidth / window.innerHeight;
  camera.aspect = aspect;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

function setupUIHandlers() {
  const mineBtn = document.getElementById('mine-btn');
  const upgradeBtn = document.getElementById('upgrade-btn');
  const pauseBtn = document.getElementById('pause-btn');
  
  if (mineBtn) {
    mineBtn.addEventListener('click', handleMineAction);
    mineBtn.addEventListener('touchstart', (e) => {
      e.preventDefault();
      handleMineAction();
    });
  }
  
  if (upgradeBtn) {
    upgradeBtn.addEventListener('click', () => {
      showNotification('Upgrades coming soon!');
    });
  }
  
  if (pauseBtn) {
    pauseBtn.addEventListener('click', togglePause);
  }
}

function handleMineAction() {
  if (!saveData) return;
  if (gameState.currentState !== 'PLAYING') return;
  
  // Manual mining action
  const resource = RESOURCES['stone'];
  const amount = 1;
  
  // Add to inventory
  saveData.inventory.resources['stone'] = (saveData.inventory.resources['stone'] || 0) + amount;
  saveData.player.totalMined += amount;
  
  // Visual feedback
  showNotification('+1 Stone');
  createMiningParticles();
  
  updateHUD();
}

function createMiningParticles() {
  // Simple particle effect for mining
  const particleCount = 10;
  const geometry = new THREE.BufferGeometry();
  const positions = new Float32Array(particleCount * 3);
  
  for (let i = 0; i < particleCount * 3; i += 3) {
    positions[i] = playerPosition.x + (Math.random() - 0.5) * 2;
    positions[i + 1] = playerPosition.y + Math.random() * 2;
    positions[i + 2] = playerPosition.z + (Math.random() - 0.5) * 2;
  }
  
  geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  
  const material = new THREE.PointsMaterial({
    color: 0x8b4513,
    size: 0.2,
    transparent: true,
    opacity: 0.8
  });
  
  const particles = new THREE.Points(geometry, material);
  scene.add(particles);
  
  // Animate and remove particles
  let age = 0;
  const animateParticles = () => {
    age += 0.02;
    const positions = particles.geometry.attributes.position.array as Float32Array;
    
    for (let i = 1; i < positions.length; i += 3) {
      positions[i] -= 0.05; // Fall down
    }
    
    particles.geometry.attributes.position.needsUpdate = true;
    material.opacity = 0.8 * (1 - age);
    
    if (age < 1) {
      requestAnimationFrame(animateParticles);
    } else {
      scene.remove(particles);
      geometry.dispose();
      material.dispose();
    }
  };
  
  animateParticles();
}

function togglePause() {
  if (gameState.currentState === 'PLAYING') {
    gameState.transitionTo('PAUSED');
    showNotification('Game Paused');
  } else if (gameState.currentState === 'PAUSED') {
    gameState.transitionTo('PLAYING');
    showNotification('Game Resumed');
  }
}

function loadOrCreateSave() {
  if (hasSave()) {
    saveData = loadGame();
    if (saveData) {
      // Calculate offline earnings
      const timeValidation = validateOfflineTime(saveData.timestamp);
      if (timeValidation.valid && timeValidation.minutes > 1) {
        const offlineResult = calculateOfflineEarnings(saveData, timeValidation.minutes);
        
        if (offlineResult.moneyEarned > 0) {
          saveData.player.cash += offlineResult.moneyEarned;
          saveData.player.totalEarned += Math.max(0, offlineResult.moneyEarned);
          
          // Show offline earnings notification
          setTimeout(() => {
            showNotification(`While you were away:\nEarned ${formatMoney(offlineResult.moneyEarned)}`);
          }, 1000);
        }
      }
    }
  } else {
    saveData = createNewSave();
  }
  
  lastSaveTime = Date.now();
}

function autoSave() {
  if (saveData && gameState.currentState === 'PLAYING') {
    saveGame(saveData);
    console.log('Game auto-saved');
  }
}

function updateHUD() {
  if (!saveData) return;
  
  const moneyDisplay = document.getElementById('money-display');
  const depthDisplay = document.getElementById('depth-display');
  const storageDisplay = document.getElementById('storage-display');
  const productionDisplay = document.getElementById('production-display');
  const workersDisplay = document.getElementById('workers-display');
  
  if (moneyDisplay) moneyDisplay.textContent = formatMoney(saveData.player.cash);
  if (depthDisplay) depthDisplay.textContent = `Depth: ${saveData.world.currentDepth}m`;
  
  // Calculate total resources in storage
  let totalResources = 0;
  for (const amount of Object.values(saveData.inventory.resources)) {
    totalResources += amount;
  }
  
  if (storageDisplay) {
    storageDisplay.textContent = `${Math.floor(totalResources)}/${saveData.inventory.storageCapacity}`;
  }
  
  if (productionDisplay) {
    // Calculate production rate based on owned machines
    let productionRate = 0;
    for (const machineId of saveData.machines.owned) {
      const level = saveData.machines.levels[machineId] || 1;
      // Simplified calculation
      productionRate += level * 10;
    }
    productionDisplay.textContent = `${productionRate}/min`;
  }
  
  if (workersDisplay) {
    let workerCount = 0;
    for (const count of Object.values(saveData.workers.hired)) {
      workerCount += count;
    }
    workersDisplay.textContent = workerCount.toString();
  }
}

function showNotification(message: string) {
  const area = document.getElementById('notification-area');
  if (!area) return;
  
  const notification = document.createElement('div');
  notification.className = 'notification';
  notification.textContent = message;
  area.appendChild(notification);
  
  // Remove after 3 seconds
  setTimeout(() => {
    notification.remove();
  }, 3000);
}

function updateLoadingProgress(percent: number) {
  const progressBar = document.getElementById('loading-progress');
  const loadingText = document.getElementById('loading-text');
  
  if (progressBar) {
    progressBar.style.width = `${percent}%`;
  }
  
  if (loadingText) {
    const messages = [
      'Loading...',
      'Initializing engine...',
      'Creating world...',
      'Loading save data...',
      'Ready!'
    ];
    const index = Math.floor((percent / 100) * messages.length);
    loadingText.textContent = messages[Math.min(index, messages.length - 1)];
  }
}

function animate() {
  requestAnimationFrame(animate);
  
  const delta = clock.getDelta();
  const now = Date.now();
  
  if (gameState.currentState === 'PLAYING') {
    // Update production accumulator
    productionAccumulator += delta * 1000;
    
    if (productionAccumulator >= PRODUCTION_TICK_MS) {
      productionAccumulator = 0;
      
      // Run production tick
      if (saveData) {
        // Simplified production for vertical slice
        // Full economy system integration coming in next iteration
        updateHUD();
      }
    }
    
    // Auto-save timer
    if (now - lastSaveTime > 30000) {
      autoSave();
      lastSaveTime = now;
    }
  }
  
  renderer.render(scene, camera);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
