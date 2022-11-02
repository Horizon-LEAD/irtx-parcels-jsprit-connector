# IRTX Synthetic parcels to JSprit connector

## Introduction

This model is a connector between the upstream synthetic parcel generation
model and the downstream JSprit route and fleet optimization model.

The main purpose of this connector is to take a list of parcels generated
in the previous model and to transform it into an operator and demand
description for the JSprit model. This description contains the locations
of the generated parcels, as well as information on their distribution center
and the vehicles that are available to the operator. The output is compatible
with the standard use case scenario for the Lyon living lab, which is defined
in the JSprit model.

## Requirements

### Software requirements

The converter is packaged in a Python script. All dependencies to run the model
have been collected in a `conda` environment, which is available in the LEAD
repository as `environment.yml`.

### Input / Output

#### Input

To run the model, a synthetic parcel data set must be present in GeoPackage
format, for instance at `/irtx-parcels/output/parcels.gpkg`. Furthermore, a perimeter needs
to be defined in which parcels will be processed. For the Lyon living lab, a
file describing the perimeter of the Confluence study area is provided in
`data/perimeter_lyon.gpkg`.

#### Output

The output of the model is a JSON file describing the parcel operator. For
the standard case for the living lab of Lyon, the operator will include
information on the responsible post office for delivering the generated
parcels. The format of the operator file is described in detail in the
documentation of the downstream JSprit optimization model.

The location of the resulting JSON file can be configured (see below), for
instance as `/irtx-parcels-jsprit-connector/output/operator.json`.

## Running the model

To run the model, the `conda` environment needs to be prepared and entered. After,
one can call `convert_parcels.py` as follows:

```bash
python3 convert_parcels.py \
  --parcels-path /irtx-parcels/output/parcels.gpkg \
  --perimeter-path /irtx-parcels-jsprit-connector/data/perimeter_lyon.gpkg \
  --output-path /irtx-parcels-jsprit-connector/output/operator.json \
  --operator-id my_operator \
  --center-latitude 45.7424 \
  --center-longitude 4.8291 \
  --vehicle-type van \
  --vehicle-type cargo_bike \
  --shipment-type delivery \
  --consolidation-type none
```

The **mandatory** parameters are detailed in the following table:

Parameter             | Values                            | Description
---                   | ---                               | ---
`--parcels-path`          | String                            | Path to the input file containing the synthetic parcels
`--perimeter-path`          | String                            | GeoPackage file describing the perimeter of the study area
`--output-path`         | String                            | Path to the output file that will contain the operator information
`--operator-id`         | String                            | Identifier of the operator in the downstream JSprit model
`--center-latitude`     | Real                            | Latitude of the distribution center
`--center-longitude`     | Real                            | Longitude of the distribution center
`--vehicle-type`     | String                            | Assigns a vehicle type to the operator. *Must be called at least once, but can be called multiple times to add multiple available vehicle types*
`--driver-salary`             | Real              | Salary considered per day per driver in EUR

The following **optional** parameters exist that can be configured. See the JSprit model for a detailed description of their meaning in the delivery process of the operator:

Parameter             | Values                            | Description
---                   | ---                               | ---
`--shipment-type`         | `delivery`* or `pickup` or `none`             | Shipment from the distribution center
`--consolidation-type`             | `none`* or `delivery` or `pickup`              | Shipment type from the consolidation center (if used)

The (*) indicate the default values.

## Standard scenarios

For the Lyon living lab, operator data can be generated for the 2022 and 2030
data sets as described in the upstream parcel model. Also, the respective post
office is defined as the distribution center.

**Baseline operator data 2022**

```bash
python3 convert_parcels.py \
  --parcels-path /irtx-parcels/output/lead_2022_parcels.gpkg \
  --perimeter-path data/perimeter_lyon.gpkg \
  --output-path /irtx-parcels-jsprit-connector/output/laposte_2022.json \
  --operator-id laposte \
  --center-latitude 45.74263642703923 \
  --center-longitude 4.819784759902544 \
  --vehicle-type van \
  --shipment-type delivery \
  --consolidation-type none \
  --driver-salary 136.0
```

**Baseline operator data 2030**

```bash
python3 convert_parcels.py \
  --parcels-path /irtx-parcels/output/lead_2030_parcels.gpkg \
  --perimeter-path data/perimete_lyon.gpkg \
  --output-path /irtx-parcels-jsprit-connector/output/laposte_2030.json \
  --operator-id laposte \
  --center-latitude 45.74263642703923 \
  --center-longitude 4.819784759902544 \
  --vehicle-type van \
  --shipment-type delivery \
  --consolidation-type none \
  --driver-salary 136.0
```
