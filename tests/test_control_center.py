"""
Tests for pwnagotchi-control-center.
"""

import ast
import sys
import types
import importlib
import importlib.util
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent


def _ensure_pwnagotchi_mocks():
    """Install mock pwnagotchi modules if not already present."""
    if "pwnagotchi" in sys.modules:
        return

    pwnagotchi = types.ModuleType("pwnagotchi")
    pwnagotchi.__path__ = []
    sys.modules["pwnagotchi"] = pwnagotchi

    plugins_mod = types.ModuleType("pwnagotchi.plugins")
    plugins_mod.Plugin = type("Plugin", (), {})
    plugins_mod.BasePlugin = type("BasePlugin", (), {})
    plugins_mod.toggle_plugin = MagicMock()
    sys.modules["pwnagotchi.plugins"] = plugins_mod
    pwnagotchi.plugins = plugins_mod

    ui_mod = types.ModuleType("pwnagotchi.ui")
    ui_mod.__path__ = []
    sys.modules["pwnagotchi.ui"] = ui_mod
    pwnagotchi.ui = ui_mod

    components_mod = types.ModuleType("pwnagotchi.ui.components")
    components_mod.LabeledValue = MagicMock
    components_mod.Text = MagicMock
    components_mod.Line = MagicMock
    components_mod.Rect = MagicMock
    components_mod.FilledRect = MagicMock
    components_mod.Widget = MagicMock
    sys.modules["pwnagotchi.ui.components"] = components_mod
    ui_mod.components = components_mod

    view_mod = types.ModuleType("pwnagotchi.ui.view")
    view_mod.BLACK = 0
    view_mod.WHITE = 1
    view_mod.__dict__["__getattr__"] = lambda name: MagicMock()
    sys.modules["pwnagotchi.ui.view"] = view_mod
    ui_mod.view = view_mod

    fonts_mod = types.ModuleType("pwnagotchi.ui.fonts")
    fonts_mod.Bold = MagicMock()
    fonts_mod.Medium = MagicMock()
    fonts_mod.Size = MagicMock()
    sys.modules["pwnagotchi.ui.fonts"] = fonts_mod
    ui_mod.fonts = fonts_mod


def _load_plugin_module(plugin_file):
    """Load a plugin module from file."""
    _ensure_pwnagotchi_mocks()
    spec = importlib.util.spec_from_file_location(plugin_file.stem, plugin_file)
    if spec is None:
        return None
    module = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(module)
        return module
    except Exception:
        return None


def _find_plugin_class(module):
    """Find the plugin class in a module."""
    for attr_name in dir(module):
        attr = getattr(module, attr_name)
        if isinstance(attr, type) and hasattr(attr, "__version__"):
            return attr
    return None


class TestControlCenterSyntax:
    """Test that control-center Python files have valid syntax."""

    def test_menu_sh_parses(self):
        """menu.sh can be parsed by bash."""
        import subprocess
        result = subprocess.run(
            ["bash", "-n", str(REPO_ROOT / "menu.sh")],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, f"Syntax error in menu.sh: {result.stderr}"

    def test_pwnbase_files_parse(self):
        """All .py files in pwnbase/ can be parsed by ast."""
        pwnbase_dir = REPO_ROOT / "pwnbase"
        if not pwnbase_dir.exists():
            pytest.skip("pwnbase/ directory not found")
        for py_file in pwnbase_dir.glob("*.py"):
            source = py_file.read_text(encoding="utf-8")
            try:
                ast.parse(source)
            except SyntaxError as e:
                pytest.fail(f"Syntax error in {py_file.name}: {e}")

    def test_scripts_files_parse(self):
        """All .py files in Scripts/ can be parsed by ast."""
        scripts_dir = REPO_ROOT / "Scripts"
        if not scripts_dir.exists():
            pytest.skip("Scripts/ directory not found")
        for py_file in scripts_dir.rglob("*.py"):
            source = py_file.read_text(encoding="utf-8")
            try:
                ast.parse(source)
            except SyntaxError as e:
                pytest.fail(f"Syntax error in {py_file.name}: {e}")


class TestControlCenterStructure:
    """Test that control-center has required files."""

    def test_readme_exists(self):
        """README.md exists."""
        assert (REPO_ROOT / "README.md").exists(), "README.md missing"

    def test_license_exists(self):
        """LICENSE exists."""
        assert (REPO_ROOT / "LICENSE").exists(), "LICENSE missing"

    def test_contributing_exists(self):
        """CONTRIBUTING.md exists."""
        assert (REPO_ROOT / "CONTRIBUTING.md").exists(), "CONTRIBUTING.md missing"

    def test_code_of_conduct_exists(self):
        """CODE_OF_CONDUCT.md exists."""
        assert (REPO_ROOT / "CODE_OF_CONDUCT.md").exists(), "CODE_OF_CONDUCT.md missing"

    def test_security_exists(self):
        """SECURITY.md exists."""
        assert (REPO_ROOT / "SECURITY.md").exists(), "SECURITY.md missing"

    def test_support_exists(self):
        """SUPPORT.md exists."""
        assert (REPO_ROOT / "SUPPORT.md").exists(), "SUPPORT.md missing"

    def test_requirements_exists(self):
        """requirements.txt exists."""
        assert (REPO_ROOT / "requirements.txt").exists(), "requirements.txt missing"

    def test_menu_sh_exists(self):
        """menu.sh exists."""
        assert (REPO_ROOT / "menu.sh").exists(), "menu.sh missing"

    def test_pwnbase_dir_exists(self):
        """pwnbase/ directory exists."""
        assert (REPO_ROOT / "pwnbase").is_dir(), "pwnbase/ directory missing"

    def test_scripts_dir_exists(self):
        """Scripts/ directory exists."""
        assert (REPO_ROOT / "Scripts").is_dir(), "Scripts/ directory missing"

    def test_pwnagotchi_plugins_dir_exists(self):
        """pwnagotchi-plugins/ directory exists."""
        assert (REPO_ROOT / "pwnagotchi-plugins").is_dir(), "pwnagotchi-plugins/ directory missing"

    def test_pwnagotchi_scripts_dir_exists(self):
        """pwnagotchi-scripts/ directory exists."""
        assert (REPO_ROOT / "pwnagotchi-scripts").is_dir(), "pwnagotchi-scripts/ directory missing"


class TestControlCenterPlugins:
    """Test that control-center plugins are valid."""

    def test_egirl_pwnagotchi_parses(self):
        """egirl-pwnagotchi plugin can be parsed by ast."""
        egirl_dir = REPO_ROOT / "egirl-pwnagotchi"
        if not egirl_dir.exists():
            pytest.skip("egirl-pwnagotchi/ directory not found")
        for py_file in egirl_dir.glob("*.py"):
            source = py_file.read_text(encoding="utf-8")
            try:
                ast.parse(source)
            except SyntaxError as e:
                pytest.fail(f"Syntax error in {py_file.name}: {e}")

    def test_extreme_breach_masks_parses(self):
        """Extreme_Breach_Masks plugin can be parsed by ast."""
        ebm_dir = REPO_ROOT / "Extreme_Breach_Masks"
        if not ebm_dir.exists():
            pytest.skip("Extreme_Breach_Masks/ directory not found")
        for py_file in ebm_dir.glob("*.py"):
            source = py_file.read_text(encoding="utf-8")
            try:
                ast.parse(source)
            except SyntaxError as e:
                pytest.fail(f"Syntax error in {py_file.name}: {e}")

    def test_password_cracking_rules_parses(self):
        """password_cracking_rules plugin can be parsed by ast."""
        pcr_dir = REPO_ROOT / "password_cracking_rules"
        if not pcr_dir.exists():
            pytest.skip("password_cracking_rules/ directory not found")
        for py_file in pcr_dir.glob("*.py"):
            source = py_file.read_text(encoding="utf-8")
            try:
                ast.parse(source)
            except SyntaxError as e:
                pytest.fail(f"Syntax error in {py_file.name}: {e}")
