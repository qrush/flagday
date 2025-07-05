# Community Boating Flag Day Pixlet App

This Pixlet app displays the current flag status and wind conditions for Community Boating, Boston. It fetches the flag color from the Community Boating API and live wind/gust data from a weather sensor API.

## Features
- Shows if Community Boating is open or closed based on the flag color (green, yellow, red, or closed)
- Displays the current wind speed and gust speed (in mph)
- Designed for 64x32 pixel displays (e.g., Tidbyt)

## Setup
1. Install [Pixlet](https://github.com/tidbyt/pixlet#installation)
2. Clone this repo:
   ```sh
   git clone https://github.com/qrush/babby-progress.git
   cd babby-progress
   ```
3. Run the app locally:
   ```sh
   pixlet serve flagday.star
   ```
4. View at [http://localhost:8080](http://localhost:8080) or deploy to your Tidbyt device.

## Configuration
- No configuration is required. The app fetches all data automatically from public APIs.

## Credits
- Community Boating flag API: https://api.community-boating.org/api/flag
- Wind data: https://www.licor.cloud/
- Inspired by [Tidbyt Community Apps](https://github.com/tidbyt/community) 