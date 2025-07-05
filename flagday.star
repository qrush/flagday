"""
Applet: Flag Day
Summary: Keep track of Community Boating's flag system
desc: Keep track of Community Boating's flag system
Author: qrush
"""

load("animation.star", "animation")
load("humanize.star", "humanize")
load("http.star", "http")
load("math.star", "math")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("encoding/json.star", "json")

FONT = "CG-pixel-3x5-mono"

FLAG_SVG = """<svg viewBox="0 0 50 35" fill="none" xmlns="http://www.w3.org/2000/svg" style="background-color: white;"> 
<path d="M0.600098 0.719971L47.4701 16.94L0.730098 33.78L0.600098 0.719971Z" fill="green" stroke="white" stroke-width="1"></path>
</svg>"""

COMMUNITY_SVG = """<svg viewBox="0 0 50 35" fill="none" xmlns="http://www.w3.org/2000/svg" style="background-color: white;"> 
<g clip-path="url(#clip0)"> 
<path d="M0.600098 0.719971L47.4701 16.94L0.730098 33.78L0.600098 0.719971Z" fill="white"></path> 
<path d="M23.6501 8.59003L0.900098 16.84L0.600098 0.840027L23.6501 8.59003Z" fill="green"></path> 
<path opacity="0.9" d="M23.6501 25.1L0.900098 33.35L0.600098 17.35L23.6501 25.1Z" fill="red"></path> 
<path d="M0 34.71V0L49.55 17L0 34.71ZM1.2 1.68V33.01L45.94 17.02L1.2 1.68Z" fill="white"></path> 
<path d="M23.432 8.03225L0.345215 16.9521L0.777695 18.0715L23.8645 9.15161L23.432 8.03225Z" fill="white"></path> 
<path d="M1.0069 16.2428L0.585938 17.3666L23.6145 25.9928L24.0354 24.869L1.0069 16.2428Z" fill="white"></path> 
<path d="M25.0599 15.05C24.9599 14.88 24.8299 14.74 24.6799 14.62C24.5299 14.49 24.3499 14.4 24.1599 14.33C23.9699 14.26 23.7599 14.23 23.5499 14.23C23.1599 14.23 22.8299 14.31 22.5599 14.46C22.2899 14.61 22.0699 14.81 21.8999 15.06C21.7299 15.31 21.6099 15.6 21.5299 15.92C21.4499 16.24 21.4099 16.58 21.4099 16.92C21.4099 17.25 21.4499 17.57 21.5299 17.88C21.6099 18.19 21.7299 18.47 21.8999 18.72C22.0699 18.97 22.2899 19.17 22.5599 19.32C22.8299 19.47 23.1599 19.55 23.5499 19.55C24.0799 19.55 24.4899 19.39 24.7899 19.07C25.0899 18.75 25.2699 18.32 25.3299 17.79H26.9999C26.9599 18.28 26.8399 18.72 26.6599 19.12C26.4799 19.52 26.2299 19.85 25.9299 20.13C25.6299 20.41 25.2799 20.62 24.8699 20.77C24.4699 20.92 24.0199 20.99 23.5399 20.99C22.9399 20.99 22.3999 20.89 21.9199 20.68C21.4399 20.47 21.0399 20.18 20.7099 19.82C20.3799 19.46 20.1299 19.02 19.9499 18.53C19.7699 18.04 19.6899 17.5 19.6899 16.93C19.6899 16.34 19.7799 15.8 19.9499 15.3C20.1299 14.8 20.3799 14.36 20.7099 13.99C21.0399 13.62 21.4499 13.32 21.9199 13.11C22.3999 12.9 22.9399 12.79 23.5399 12.79C23.9699 12.79 24.3799 12.85 24.7699 12.98C25.1499 13.1 25.4999 13.29 25.7999 13.52C26.0999 13.76 26.3599 14.05 26.5499 14.41C26.7399 14.77 26.8699 15.16 26.9199 15.62H25.2499C25.2299 15.4 25.1699 15.22 25.0599 15.05Z" fill="green"></path> 
</g> 
<defs> 
<clipPath id="clip0"> 
<rect width="49.55" height="34.71" fill="white"></rect> 
</clipPath> 
</defs> 
</svg>"""

# Utility to get SVG with correct color
FLAG_COLORS = {
    "G": "green",
    "Y": "yellow",
    "R": "red",
}

def get_flag_svg(flag_color):
    color = FLAG_COLORS.get(flag_color, "green")
    return FLAG_SVG.replace('fill="green"', 'fill="%s"' % color)

def fetch_latest_metric(metric_name, data_channel):
    url = "https://www.licor.cloud/api/dashboard/public/query"
    headers = {"content-type": "application/json"}
    body = json.encode({
        "id": "3896cb9d-a557-4a61-8887-3a3b0c9b2147",
        "query": {
            "limit": 1,
            "metrics": [{
                "aggregators": [{
                    "name": "last",
                    "align_start_time": False,
                }],
                "name": metric_name,
                "exclude_tags": True,
                "group_by": [],
                "tags": {"dataChannel": [data_channel]}
            }],
            "start_relative": {"value": 1, "unit": "hours"}
        }
    })
    resp = http.post(url, headers=headers, body=body)
    if resp.status_code == 200:
        data = resp.json()
        queries = data.get("queries", [])
        if len(queries) > 0:
            results = queries[0].get("results", [])
            if len(results) > 0:
                values = results[0].get("values", [])
                if len(values) > 0:
                    return str(int(math.round(values[-1][1])))
    return "?"

def main(config):
    # Get Community Boating flag status
    response = http.get("https://api.community-boating.org/api/flag")
    flag_color = "G"  # Default to green
    if response.status_code == 200:
        response_text = str(response.body())
        # response_text = "var FLAG_COLOR = \"B\""
        print(response_text)
        if response_text.find("FLAG_COLOR = \"C\"") >= 0:
            is_closed = True
            flag_svg = COMMUNITY_SVG
        else:
            is_closed = False
            # Extract flag color from response
            idx = response_text.find("FLAG_COLOR = ")
            if idx >= 0:
                flag_color = response_text[idx+14]
            if flag_color in FLAG_COLORS:
                flag_svg = get_flag_svg(flag_color)
                is_closed = False
            else:
                flag_svg = COMMUNITY_SVG
                is_closed = True
    else:
        is_closed = True
        flag_svg = COMMUNITY_SVG

    # Stub wind data
    wind_speed = fetch_latest_metric("com.onset.sensordata.windspeed_us", "4f93ba96-a978-45c0-97f5-00b6e96aee91")
    gust_speed = fetch_latest_metric("com.onset.sensordata.gustspeed_us", "4e599481-ad7d-4693-955f-7476e4db291c")

    return render.Root(
        render.Row(
            expanded=True,
            children=[
                # Left side - Flag
                render.Box(
                    render.Image(flag_svg),
                    width=48,
                    height=32,
                ),
                # Right side - Status and conditions
                render.Column(
                    expanded=True,
                    main_align="start",
                    children=[
                        # Status text
                        render.Box(
                            render.Text(
                                "Nope" if is_closed else "Open",
                                font=FONT,
                                color="#FF0000" if is_closed else "#00FF00"
                            ),
                            height=8,
                        ),
                        render.Box(height=1),
                        # Wind information
                        render.Box(
                            render.Text("WIND", font=FONT, color="#666"),
                            height=5,
                        ),
                        render.Box(
                            render.Text(wind_speed, font=FONT),
                            height=5,
                        ),
                        render.Box(height=1),
                        render.Box(
                            render.Text("GUST", font=FONT, color="#666"),
                            height=5,
                        ),
                        render.Box(
                            render.Text(gust_speed, font=FONT),
                            height=5,
                        ),
                    ],
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version="1",
        fields=[],
    )
