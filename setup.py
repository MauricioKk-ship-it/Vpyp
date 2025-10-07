from setuptools import setup, find_packages

setup(
    name="gospot-cli",
    version="1.0.3",
    description="GoSpot CLI - wrapper Python launching powerful shell tools for iSH/Linux",
    author="Mauricio",
    python_requires=">=3.8",
    packages=find_packages(),
    include_package_data=True,
    package_data={
        "gospot_pkg": ["*.sh", "sdk/*.sh"],
    },
    entry_points={
        "console_scripts": [
            "gos = gospot_pkg.cli:main"
        ]
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
    ],
)
