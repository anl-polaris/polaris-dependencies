from python.utils import download_and_unzip


def boost_url(version):
    version_ = version.replace(".", "_")
    return f"https://boostorg.jfrog.io/artifactory/main/release/{version}/source/boost_{version_}.zip"


def build_boost(output_dir, version="1.71.0"):
    version_ = version.replace(".", "_")
    download_and_unzip(boost_url(version), output_dir, f"boost_{version_}")
    return True  # If we get here the "build" succeeded
