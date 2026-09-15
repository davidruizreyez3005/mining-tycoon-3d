"""
Mining Tycoon 3D - Asset Validation Script
Validates generated GLB assets for correctness, quality, and compliance
"""

import json
import os
import sys
import struct
from pathlib import Path


class AssetValidator:
    """Validates 3D assets for game production"""
    
    # Triangle budgets by asset type
    TRIANGLE_BUDGETS = {
        "tiny": (500, 2000),
        "normal": (2000, 8000),
        "important": (5000, 15000),
        "hero": (8000, 25000)
    }
    
    # Required LOD levels
    REQUIRED_LODS = ["LOD0", "LOD1", "LOD2"]
    
    # Maximum file size (MB)
    MAX_FILE_SIZE_MB = 10
    
    def __init__(self, models_dir=None):
        if models_dir is None:
            # Use relative path from repo root
            repo_root = Path(__file__).parent.parent.parent
            models_dir = repo_root / "assets" / "models"
        self.models_dir = Path(models_dir)
        self.validation_results = []
        self.errors = []
        self.warnings = []
    
    def validate_glb_structure(self, filepath):
        """Validate GLB file structure"""
        errors = []
        warnings = []
        
        try:
            with open(filepath, 'rb') as f:
                # Read GLB header (20 bytes)
                magic = f.read(4)
                if magic != b'glTF':
                    errors.append(f"Invalid GLB magic number: {magic}")
                    return errors, warnings
                
                version = struct.unpack('<I', f.read(4))[0]
                if version not in [2]:
                    warnings.append(f"GLB version {version} may have compatibility issues")
                
                length = struct.unpack('<I', f.read(4))[0]
                
                # Read JSON chunk
                json_length = struct.unpack('<I', f.read(4))[0]
                json_type = f.read(4)
                if json_type != b'JSON':
                    errors.append("Missing or invalid JSON chunk")
                    return errors, warnings
                
                json_data = f.read(json_length).decode('utf-8')
                
                # Parse glTF JSON
                try:
                    gltf = json.loads(json_data)
                except json.JSONDecodeError as e:
                    errors.append(f"Invalid glTF JSON: {e}")
                    return errors, warnings
                
                # Validate required glTF properties
                if 'asset' not in gltf:
                    errors.append("Missing 'asset' property in glTF")
                
                if 'scene' not in gltf:
                    errors.append("Missing 'scene' property in glTF")
                
                # Check for meshes
                if 'meshes' not in gltf or len(gltf['meshes']) == 0:
                    errors.append("No meshes found in glTF")
                
                # Check for accessors (geometry data)
                if 'accessors' not in gltf:
                    warnings.append("No accessors found - may be empty scene")
                
                # Count triangles from accessors
                triangle_count = self._count_triangles_from_gltf(gltf)
                
                return errors, warnings
                
        except Exception as e:
            errors.append(f"Failed to read GLB file: {e}")
            return errors, warnings
    
    def _count_triangles_from_gltf(self, gltf):
        """Count triangles from glTF accessors"""
        total_triangles = 0
        
        if 'meshes' not in gltf:
            return 0
        
        for mesh in gltf['meshes']:
            if 'primitives' not in mesh:
                continue
            
            for primitive in mesh['primitives']:
                if 'attributes' not in primitive:
                    continue
                
                # Get POSITION attribute accessor index
                if 'POSITION' not in primitive['attributes']:
                    continue
                
                position_accessor_idx = primitive['attributes']['POSITION']
                accessors = gltf.get('accessors', [])
                
                if position_accessor_idx < len(accessors):
                    accessor = accessors[position_accessor_idx]
                    vertex_count = accessor.get('count', 0)
                    
                    # Get index accessor if present
                    if 'indices' in primitive:
                        indices_idx = primitive['indices']
                        if indices_idx < len(accessors):
                            indices_accessor = accessors[indices_idx]
                            index_count = indices_accessor.get('count', 0)
                            # Each triangle has 3 indices
                            triangles = index_count // 3
                            total_triangles += triangles
                    else:
                        # Non-indexed geometry (assume triangles)
                        triangles = vertex_count // 3
                        total_triangles += triangles
        
        return total_triangles
    
    def validate_file_size(self, filepath):
        """Validate file size is within budget"""
        size_bytes = os.path.getsize(filepath)
        size_mb = size_bytes / (1024 * 1024)
        
        if size_mb > self.MAX_FILE_SIZE_MB:
            return False, f"File size {size_mb:.2f}MB exceeds limit of {self.MAX_FILE_SIZE_MB}MB"
        
        return True, f"File size: {size_mb:.2f}MB"
    
    def validate_naming_convention(self, filepath):
        """Validate asset naming follows conventions"""
        filename = filepath.stem
        errors = []
        warnings = []
        
        # Check for valid prefixes
        valid_prefixes = ["SM_", "CHAR_", "Ore_", "Machine_", "Conveyor_", "Tunnel_"]
        has_valid_prefix = any(filename.startswith(p) for p in valid_prefixes)
        
        if not has_valid_prefix:
            warnings.append(f"Asset name '{filename}' doesn't follow naming convention")
        
        # Check for invalid characters
        if not filename.replace('_', '').replace('-', '').isalnum():
            errors.append(f"Asset name contains invalid characters: {filename}")
        
        return errors, warnings
    
    def validate_lods(self, gltf_data):
        """Validate LOD levels exist"""
        # This would require checking for multiple meshes with LOD naming
        # For now, just check if multiple meshes exist
        mesh_count = len(gltf_data.get('meshes', []))
        
        if mesh_count < 2:
            return False, "Only one mesh found - LODs may be missing"
        
        return True, f"Found {mesh_count} mesh(es) - LODs likely present"
    
    def validate_materials(self, gltf_data):
        """Validate materials are properly defined"""
        errors = []
        warnings = []
        
        if 'materials' not in gltf_data:
            warnings.append("No materials defined in asset")
            return errors, warnings
        
        for i, material in enumerate(gltf_data['materials']):
            if 'name' not in material:
                warnings.append(f"Material {i} has no name")
            
            # Check for PBR properties
            if 'pbrMetallicRoughness' not in material:
                warnings.append(f"Material '{material.get('name', i)}' may not use PBR")
        
        return errors, warnings
    
    def validate_asset(self, filepath):
        """Run full validation on a single asset"""
        result = {
            "path": str(filepath),
            "filename": filepath.name,
            "valid": True,
            "errors": [],
            "warnings": [],
            "metrics": {}
        }
        
        print(f"\nValidating: {filepath.name}")
        
        # File existence
        if not filepath.exists():
            result["valid"] = False
            result["errors"].append("File not found")
            self.validation_results.append(result)
            return result
        
        # File size validation
        size_valid, size_msg = self.validate_file_size(filepath)
        result["metrics"]["file_size"] = size_msg
        if not size_valid:
            result["valid"] = False
            result["errors"].append(size_msg)
        
        # Naming convention
        name_errors, name_warnings = self.validate_naming_convention(filepath)
        result["errors"].extend(name_errors)
        result["warnings"].extend(name_warnings)
        if name_errors:
            result["valid"] = False
        
        # GLB structure validation
        glb_errors, glb_warnings = self.validate_glb_structure(filepath)
        result["errors"].extend(glb_errors)
        result["warnings"].extend(glb_warnings)
        if glb_errors:
            result["valid"] = False
        
        # Load glTF data for additional validations
        try:
            with open(filepath, 'rb') as f:
                # Skip header
                f.read(20)
                json_length = struct.unpack('<I', f.read(4))[0]
                f.read(4)  # JSON type
                json_data = json.loads(f.read(json_length).decode('utf-8'))
                
                # Triangle count
                triangle_count = self._count_triangles_from_gltf(json_data)
                result["metrics"]["triangle_count"] = triangle_count
                
                # LOD validation
                lod_valid, lod_msg = self.validate_lods(json_data)
                result["metrics"]["lod_status"] = lod_msg
                if not lod_valid:
                    result["warnings"].append(lod_msg)
                
                # Material validation
                mat_errors, mat_warnings = self.validate_materials(json_data)
                result["errors"].extend(mat_errors)
                result["warnings"].extend(mat_warnings)
                
        except Exception as e:
            result["warnings"].append(f"Could not parse glTF data: {e}")
        
        # Update overall validity
        if result["errors"]:
            result["valid"] = False
        
        self.validation_results.append(result)
        return result
    
    def validate_all_assets(self):
        """Validate all assets in the models directory"""
        print("=" * 60)
        print("ASSET VALIDATION REPORT")
        print("=" * 60)
        
        if not self.models_dir.exists():
            print(f"ERROR: Models directory not found: {self.models_dir}")
            return False
        
        glb_files = list(self.models_dir.glob("*.glb"))
        
        if not glb_files:
            print("WARNING: No GLB files found in models directory")
            return True
        
        print(f"\nFound {len(glb_files)} asset(s) to validate\n")
        
        for glb_file in glb_files:
            self.validate_asset(glb_file)
        
        # Generate summary
        self.generate_summary()
        
        return all(r["valid"] for r in self.validation_results)
    
    def generate_summary(self):
        """Generate validation summary report"""
        print("\n" + "=" * 60)
        print("VALIDATION SUMMARY")
        print("=" * 60)
        
        total = len(self.validation_results)
        passed = sum(1 for r in self.validation_results if r["valid"])
        failed = total - passed
        total_errors = sum(len(r["errors"]) for r in self.validation_results)
        total_warnings = sum(len(r["warnings"]) for r in self.validation_results)
        total_triangles = sum(r["metrics"].get("triangle_count", 0) for r in self.validation_results)
        
        print(f"\nTotal Assets: {total}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        print(f"Total Errors: {total_errors}")
        print(f"Total Warnings: {total_warnings}")
        print(f"Total Triangles: {total_triangles:,}")
        
        if failed > 0:
            print("\n❌ FAILED ASSETS:")
            for result in self.validation_results:
                if not result["valid"]:
                    print(f"  - {result['filename']}: {', '.join(result['errors'][:3])}")
        
        if total_warnings > 0:
            print("\n⚠️  WARNINGS:")
            for result in self.validation_results:
                for warning in result["warnings"][:2]:
                    print(f"  - {result['filename']}: {warning}")
        
        print("\n" + "=" * 60)
        
        # Save detailed report
        report = {
            "summary": {
                "total_assets": total,
                "passed": passed,
                "failed": failed,
                "total_errors": total_errors,
                "total_warnings": total_warnings,
                "total_triangles": total_triangles
            },
            "results": self.validation_results
        }
        
        report_path = "/workspace/assets/manifests/validation_report.json"
        os.makedirs(os.path.dirname(report_path), exist_ok=True)
        
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Detailed report saved to: {report_path}")
        
        return failed == 0


def main():
    """Main validation entry point"""
    validator = AssetValidator()
    success = validator.validate_all_assets()
    
    if success:
        print("\n✅ All assets passed validation!")
        return 0
    else:
        print("\n❌ Some assets failed validation. Check report for details.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
