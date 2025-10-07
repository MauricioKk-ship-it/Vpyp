from setuptools import setup, find_packages

setup(
    name="gos",
    version="1.0.0",
    author="Mauricio-100",
    author_email="",
    description="GoSpot Hybrid - Python + Shell CLI par Mauricio-100",
    long_description=open("README.md", encoding="utf-8").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/Mauricio-100/GoSpot",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[],
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "gos=gos:main_menu",
        ],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS",
        "Operating System :: Microsoft :: Windows",
        "License :: OSI Approved :: MIT License",
    ],
)
