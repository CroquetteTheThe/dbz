import json
import os
import subprocess
import platform
from typing import Dict, Any
current_dir = os.path.dirname(os.path.abspath(__file__))
STATS_FILE = current_dir + "/public/uploads/my_stats.json"

"""
It's going to update the stat json. Should look something like this:
stats = {"download_folder_size": download_file_count, "last_report": last_report_date}
"""
def update_stats_file(stats_modifications: Dict[str, Any]) -> subprocess.CompletedProcess[bytes]:

    # subprocess.run(["C:/Program Files/Git/bin/bash.exe", "stash_repo.sh"], check=True)

    # Load existing JSON or create default
    if os.path.exists(STATS_FILE):
        with open(STATS_FILE, "r", encoding="utf-8") as file:
            stats = json.load(file)
            stats.update(stats_modifications)
    else:
        stats = stats_modifications

    # Save updated JSON back to file
    with open(STATS_FILE, "w", encoding="utf-8") as file:
        json.dump(stats, file, indent=4)


    if platform.platform() == "Windows":
        command_output = subprocess.run(
            ["C:/Program Files/Git/bin/bash.exe", current_dir + "/upload.sh", STATS_FILE],
            capture_output=True,
            check=True,
            creationflags=subprocess.CREATE_NO_WINDOW
        )
    else:
        command_output = subprocess.run(
            ["bash", current_dir + "/upload.sh", STATS_FILE],
            capture_output=True,
            check=True
        )

    return command_output

    return command_output
