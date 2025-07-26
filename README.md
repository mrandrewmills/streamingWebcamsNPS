# streamingWebcams.ps1

## Overview

`streamingWebcams.ps1` is a PowerShell script that retrieves and lists all live streaming webcams from the National Park Service (NPS) Public Data API. It caches the webcam data locally to minimize API calls and filters for webcams flagged as streaming, displaying relevant details including status, related parks, and tags.

## Features

- Checks for a valid NPS API key in the environment variable `NPS_API_KEY`.
- Caches the full webcams dataset in `webcams.json` to avoid repeated API calls during the same day.
- Automatically refreshes cached data once per day.
- Filters webcams for streaming status (`isStreaming == true`), including both active and inactive cams.
- Outputs detailed webcam information suitable for console viewing or output redirection to files.

## Prerequisites

- PowerShell 7+ (recommended for cross-platform compatibility)
- A valid NPS API key:
  - Request one at the [NPS Developer Portal](https://www.nps.gov/subjects/developer/get-started.htm)
  - Set it as an environment variable named `NPS_API_KEY` before running the script.

## Usage

```powershell
# Run the script normally
.\streamingWebcams.ps1

# Redirect output to a text file (e.g., for logging or further processing)
.\streamingWebcams.ps1 > webcams-output.txt
```

## Notes

- The script expects to find or create `webcams.json` in the current working directory.
- If the cache file is older than the current date, the script will refresh the data from the NPS API.
- The output includes webcams flagged as streaming regardless of their active/inactive status, allowing for monitoring and follow-up.
- Errors such as missing API keys or failed API calls are reported to the error stream.

## License

This script is released under the MIT License. Use and modify freely.

## Contact

For questions or contributions, please open an issue or pull request on the repository where this script is maintained.
