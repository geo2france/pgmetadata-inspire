# pgmetadata-inspire 

Une vue SQL permettant de générer des fichiers XML au format INSPIRE, pour import dans GeoNetwork.
Cette vue a été créée pour permettre au Conservatoire d'Espaces Naturels des Hauts-de-France de publié rapidement des métadonnées sur la plateforme Géo2France.


> **Warning**
> La vue ajoute 2 liens dans le xml. Ceux-ci correspondent aux flux WMS et WFS qui seront publiée sur le Geoserver par le CEN-HdF.
> A supprimer ou adapter pour un autre contexte.

