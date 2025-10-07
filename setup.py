from setuptools import setup, find_packages

setup(
    name="gos",
    version="1.0.0",
    author="Mauricio-100",
    description="GoSpot Hybrid - Python + Shell CLI",
    packages=find_packages(),
    include_package_data=True,
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "gos=gos.cli:main_menu",
        ],
    },
)
