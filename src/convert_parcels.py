import json
import argparse
from os.path import join

import geopandas as gpd

# Command line
parser = argparse.ArgumentParser(description = "LEAD Parcel converter for JSprit")

parser.add_argument("--parcels-path", type = str, required = True)
parser.add_argument("--perimeter-path", type = str, required = True)
parser.add_argument("--output-path", type = str, required = True)
parser.add_argument("--operator-id", type = str, required = True)
parser.add_argument("--center-latitude", type = float, required = True)
parser.add_argument("--center-longitude", type = float, required = True)
parser.add_argument("--vehicle-type", type = str, action="append", required = True)
parser.add_argument("--shipment-type", type = str, required = False, default = "delivery")
parser.add_argument("--consolidation-type", type = str, required = False, default = "none")
parser.add_argument("--driver-salary", type = float, required = True, default = "none")

arguments = parser.parse_args()

# Create operator
df_perimeter = gpd.read_file(arguments.perimeter_path)
df_parcels = gpd.read_file(arguments.parcels_path)

df_parcels = df_parcels.to_crs(df_perimeter.crs)
df_parcels = gpd.sjoin(df_parcels, df_perimeter, op = "within")

# Convert to WGS84
df_parcels = df_parcels.to_crs("EPSG:4326")

demand = [
    { "lat": latitude, "lng": longitude }
    for latitude, longitude in zip(df_parcels["geometry"].y, df_parcels["geometry"].x)
]

operator = {
    "id": arguments.operator_id,
    "center": {
        "lat" : arguments.center_latitude,
        "lng" : arguments.center_longitude
    },
    "vehicle_types": arguments.vehicle_type,
    "shipment_type": arguments.shipment_type,
    "consolidation_type": arguments.consolidation_type,
    "daily_driver_salary_EUR": arguments.driver_salary,
    "demand": demand
}

# Output
with open(join(arguments.output_path, "output.json"), "w+", encoding='utf8') as fjson:
    json.dump(operator, fjson, indent = 4)
