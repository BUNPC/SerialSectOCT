from setuptools import setup, find_packages

print("Packages: {}".format(find_packages()))
setup(
    name = "atsapi",
    version = "7.1.5",
    packages = find_packages(),
    author = "Alazar Technologies",
    author_email = "support@alazartech.com",
    url = "www.alazartech.com"
)
