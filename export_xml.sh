#!/bin/bash
# Usage: ./export_xml.sh pg_connection_string output_dir
# Example: ./export_xml.sh 'service=work_db' ./xml_dir
pg_connection=$1
out_dir=$2

if [ $# -lt 2 ]; then
    echo "Missing parameters"
    exit 1
fi

# Difficulté pour le faire en une seule requete car il faut trouver le separateur qui convient ? Mais ca serait beaucoup pour efficient
# libxml2-utils
psql $pg_connection -c "SELECT uid FROM pgmetadata.v_dataset_as_inspire" -tA | while read uid ; do
    psql $pg_connection -c "SELECT dataset FROM pgmetadata.v_dataset_as_inspire WHERE uid='$uid'" -tA | xmllint --format - > $out_dir/"$uid".xml
done
