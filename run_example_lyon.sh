set -e

## Activate environment
conda activate parcels2jsprit

## Run connector
for year in 2020 2030; do
  python3 convert_parcels.py \
  	--parcels-path /home/ubuntu/irtx-parcels/output/lead_${year}_parcels.gpkg \
  	--perimeter-path /home/ubuntu/irtx-parcels-jsprit-connector/data/perimeter_lyon.gpkg \
  	--output-path /home/ubuntu/irtx-parcels-jsprit-connector/output/laposte_${year}.json \
  	--operator-id laposte \
  	--center-latitude 45.74263642703923 \
  	--center-longitude 4.819784759902544 \
  	--vehicle-type van \
  	--shipment-type delivery \
  	--consolidation-type none \
  	--driver-salary 136.0
done
