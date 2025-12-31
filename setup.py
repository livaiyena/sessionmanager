#!/usr/bin/env python3
"""
setup script for sessionmanager
"""

from setuptools import setup, find_packages
from pathlib import Path

# read README for long description
readme_file = Path(__file__).parent / "README.md"
long_description = readme_file.read_text(encoding="utf-8") if readme_file.exists() else ""

# read version from package
version_file = Path(__file__).parent / "src" / "sessionmanager" / "__init__.py"
version = "0.0.6"
if version_file.exists():
    for line in version_file.read_text().splitlines():
        if line.startswith("__version__"):
            version = line.split("=")[1].strip().strip('"').strip("'")
            break

setup(
    name="sessionmanager",
    version=version,
    description="CLI-based activity tracker and session manager for Hyprland",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Livaiyena",
    author_email="livaiyena@users.noreply.github.com",
    url="https://github.com/livaiyena/sessionmanager",
    license="GPL-3.0-or-later",
    
    # package configuration
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    
    # scripts
    scripts=["sessionmanager"],
    
    # python version requirement
    python_requires=">=3.8",
    
    # no external dependencies - pure python stdlib
    install_requires=[],
    
    # optional dependencies for development
    extras_require={
        "dev": [
            "pytest>=7.0",
            "black>=22.0",
            "mypy>=0.950",
        ],
    },
    
    # classifiers
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: Console",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Topic :: Desktop Environment :: Window Managers",
        "Topic :: Utilities",
    ],
    
    # keywords
    keywords="hyprland wayland activity tracker session manager productivity",
    
    # project URLs
    project_urls={
        "Bug Reports": "https://github.com/livaiyena/sessionmanager/issues",
        "Source": "https://github.com/livaiyena/sessionmanager",
        "Changelog": "https://github.com/livaiyena/sessionmanager/blob/main/CHANGELOG.md",
    },
)
